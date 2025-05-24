import 'dart:convert'; // for base64 decoding
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop/admindash.dart';
import 'package:laptop/bottambar.dart';
import 'package:laptop/drawer.dart';
import 'package:laptop/profile.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  late Stream<QuerySnapshot> _pendingOrdersStream;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pendingOrdersStream = FirebaseFirestore.instance
        .collection('Orders')
        .where('orderStatus', isEqualTo: 'pending')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      backgroundColor: const Color(0xFF2E003E),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          centerTitle: true,
          title: const Text(
            'Orders',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF2E003E),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _pendingOrdersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No pending orders found.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var order = snapshot.data!.docs[index];
              return _buildOrderItem(order, index);
            },
          );
        },
      ),
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: CustomBottomAppBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const OrderListPage()),
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Dashboard()),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Profile()),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildOrderItem(DocumentSnapshot order, int index) {
    List<Color> listColors = [
      Colors.lightBlue.shade100,
      Colors.lightGreen.shade100,
      Colors.pink.shade100,
      Colors.yellow.shade100,
      Colors.teal.shade100,
    ];

    Color backgroundColor = listColors[index % listColors.length];

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order ID: ${order.id}',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text('Products:', style: TextStyle(color: Colors.black)),
          const SizedBox(height: 5),
          _buildProductList(order),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _markAsDelivered(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text('Delivered'),
              ),
              ElevatedButton(
                onPressed: () => _cancelOrder(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(DocumentSnapshot order) {
    CollectionReference productsCollection = order.reference.collection('Products');

    return StreamBuilder<QuerySnapshot>(
      stream: productsCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: Colors.white);
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text(
            'No products found in this order.',
            style: TextStyle(color: Colors.black),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: snapshot.data!.docs.map((productDoc) {
            final productData = productDoc.data() as Map<String, dynamic>;

            final productName =
                productData['productName'] ?? 'Product Name Not Available';
            final quantity = productData['qty']?.toString() ?? 'N/A';

            String base64Image = '';
            if (productData['images'] != null &&
                productData['images'] is List &&
                productData['images'].isNotEmpty) {
              base64Image = productData['images'][0];
            }

            // Decode base64 image if exists
            Widget imageWidget;
            if (base64Image.isNotEmpty) {
              try {
                Uint8List imageBytes = base64Decode(base64Image);
                imageWidget = CircleAvatar(
                  backgroundImage: MemoryImage(imageBytes),
                  backgroundColor: Colors.white24,
                );
              } catch (e) {
                imageWidget = const CircleAvatar(
                  child: Icon(Icons.broken_image),
                  backgroundColor: Colors.white24,
                );
              }
            } else {
              imageWidget = const CircleAvatar(
                child: Icon(Icons.image_not_supported),
                backgroundColor: Colors.white24,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: imageWidget,
                  title: Text(
                    productName,
                    style: const TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(
                    'Qty: $quantity',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 72.0, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer: ${order['userName'] ?? 'N/A'}',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Phone: ${order['userPhone'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Address: ${order['address'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _markAsDelivered(DocumentSnapshot order) async {
    await order.reference.update({'orderStatus': 'delivered'});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order marked as delivered')),
    );
  }

  Future<void> _cancelOrder(DocumentSnapshot order) async {
    await order.reference.update({'orderStatus': 'canceled'});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order canceled')),
    );
  }
}
