import 'dart:convert'; // For base64 decoding
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:laptop/admindash.dart';
import 'package:laptop/adminorder.dart';
import 'package:laptop/bottambar.dart';
import 'package:laptop/drawer.dart';
import 'package:laptop/profile.dart';

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({super.key});

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 3; // assuming index 3 corresponds to OrderStatusPage

  final Color darkPurple = const Color(0xFF2D0C57);
  final Color offWhite = const Color(0xFFECECEC);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Stream<QuerySnapshot> getOrders(String status) {
    return FirebaseFirestore.instance
        .collection('Orders')
        .where('orderStatus', isEqualTo: status)
        .snapshots();
  }

  // Update orderStatus to 'delivered'
  Future<void> markAsDelivered(DocumentSnapshot order) async {
    await order.reference.update({'orderStatus': 'delivered'});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order marked as delivered')),
    );
  }

  // Update orderStatus to 'canceled'
  Future<void> cancelOrder(DocumentSnapshot order) async {
    await order.reference.update({'orderStatus': 'canceled'});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order canceled')),
    );
  }

  // Delete order document
  Future<void> deleteOrder(DocumentSnapshot order) async {
    await order.reference.delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPurple,
      drawer: MyDrawer(),
      appBar: AppBar(
        backgroundColor: darkPurple,
        centerTitle: true,
        title: const Text(
          "Order Status",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: offWhite,
              isScrollable: true,
              labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Delivered'),
                Tab(text: 'Cancelled'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildOrderList('pending'),
          buildOrderList('delivered'),
          buildOrderList('canceled'),
        ],
      ),
      bottomNavigationBar: CustomBottomAppBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return; // prevent pushing same page repeatedly
          setState(() {
            _currentIndex = index;
          });
          // Use pushReplacement to avoid stacking pages unnecessarily
          Widget page;
          if (index == 0) {
            page = const OrderListPage();
          } else if (index == 1) {
            page = const Dashboard();
          } else if (index == 2) {
            page = const Profile();
          } else {
            return;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
      ),
    );
  }

  // Build order list filtered by status
  Widget buildOrderList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: getOrders(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No $status orders found.',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        }

        return ListView(
          children: snapshot.data!.docs.map((order) {
            return buildOrderItem(order, status);
          }).toList(),
        );
      },
    );
  }

  // Build individual order item with details and buttons
  Widget buildOrderItem(DocumentSnapshot order, String status) {
    List<Color> listColors = [
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.orange.shade100,
      Colors.pink.shade100,
      Colors.yellow.shade100,
      Colors.teal.shade100,
    ];

    final bgColor = listColors[order.id.hashCode % listColors.length];

    // Extract shared order info here
    final userName = order['userName'] ?? 'N/A';
    final userPhone = order['userPhone'] ?? 'N/A';
    final address = order['address'] ?? 'N/A';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order ID: ${order.id}',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text('Products:', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
          buildProductList(order, userName, userPhone, address),
          const SizedBox(height: 10),
          if (status == 'pending')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () => markAsDelivered(order),
                  child: const Text('Delivered', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => cancelOrder(order),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          if (status == 'delivered' || status == 'canceled')
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete Order',
                onPressed: () => deleteOrder(order),
              ),
            ),
        ],
      ),
    );
  }

  // Build product list inside each order, showing shared user info for each product
  Widget buildProductList(DocumentSnapshot order, String userName, String userPhone, String address) {
    return StreamBuilder<QuerySnapshot>(
      stream: order.reference.collection('Products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Text("No products found.", style: TextStyle(color: Colors.black)),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final productName = data['productName']?.toString() ?? 'N/A';
            final quantity = data['qty']?.toString() ?? 'N/A';

            // Images handling, decode first base64 string if available
            final List<dynamic>? imagesList = data['images'] as List<dynamic>?;

            Widget imageWidget;
            if (imagesList != null && imagesList.isNotEmpty) {
              try {
                final base64Image = imagesList[0].toString();
                final bytes = base64Decode(base64Image);
                imageWidget = CircleAvatar(
                  backgroundImage: MemoryImage(bytes),
                  backgroundColor: Colors.white24,
                );
              } catch (_) {
                imageWidget = const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.broken_image, color: Colors.grey),
                );
              }
            } else {
              imageWidget = const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.image_not_supported, color: Colors.grey),
              );
            }

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: imageWidget,
              title: Text(productName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Qty: $quantity", style: const TextStyle(color: Colors.black)),
                  Text("User: $userName", style: const TextStyle(color: Colors.black)),
                  Text("Phone: $userPhone", style: const TextStyle(color: Colors.black)),
                  Text("Address: $address", style: const TextStyle(color: Colors.black)),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
