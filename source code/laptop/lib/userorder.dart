import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:laptop/bottambar.dart';
import 'package:laptop/cart.dart';
import 'package:laptop/drawer.dart';
import 'package:laptop/review.dart';
import 'package:laptop/search.dart';
import 'package:laptop/userbottambar.dart';
import 'package:laptop/userdash.dart';
import 'package:laptop/wishlist.dart';
import 'package:laptop/compare.dart';
import 'package:laptop/profile.dart';

class HomePageuser2 extends StatefulWidget {
  const HomePageuser2({Key? key}) : super(key: key);

  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageuser2> {
  int _currentIndex = 5;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: MyDrawer(),
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF4A148C),
          elevation: 4,
          centerTitle: true,
          title: const Text(
            'My Orders',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductsearchPage()),
                );
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Delivered'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildOrdersTab('pending'),
            buildOrdersTab('delivered'),
            buildOrdersTab('canceled'),
          ],
        ),
        bottomNavigationBar: UserBottomAppBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => const HomePage()));
                break;
              case 1:
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const ProductsearchPage()));
                break;
              case 2:
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const Compare()));
                break;
              case 3:
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const ProductListwish()));
                break;
              case 4:
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const Profile()));
                break;
            }
          },
        ),
      ),
    );
  }

  Widget buildOrdersTab(String orderStatus) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Orders')
          .where('userId', isEqualTo: currentUser?.uid)
          .where('orderStatus', isEqualTo: orderStatus)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No orders found'));
        }

        List<DocumentSnapshot> orders = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(top: 30),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            var order = orders[index];
            return Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54, // DARKER SHADOW HERE
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ID: ${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildProductList(order),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductList(DocumentSnapshot order) {
    CollectionReference productsCollection = order.reference.collection('Products');
    return StreamBuilder<QuerySnapshot>(
      stream: productsCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No products available', style: TextStyle(color: Colors.black));
        }
        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: snapshot.data!.docs.map((productDoc) {
            final productData = productDoc.data() as Map<String, dynamic>;

            final productName = productData['productName'] ?? 'N/A';
            final productQty = productData['qty'] ?? 0;
            final List<dynamic> imageList = productData['images'] ?? [];
            final String base64Image = imageList.isNotEmpty ? imageList[0] : '';
            final productDescription = productData['productDetails'] ?? 'No description';
            final review = productData['reviewStatus'] ?? '';
            final productPrice = productData['fprice'] ?? 'N/A';

            ImageProvider? imageProvider;
            if (base64Image.isNotEmpty) {
              try {
                final decodedBytes = base64Decode(base64Image);
                imageProvider = MemoryImage(decodedBytes);
              } catch (e) {
                imageProvider = null;
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: imageProvider,
                    backgroundColor: Colors.grey.shade200,
                    child: imageProvider == null
                        ? const Icon(Icons.image_not_supported, color: Colors.grey, size: 40)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Product: $productName',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(height: 5),
                      Text('Quantity: $productQty',
                          style: const TextStyle(fontSize: 16, color: Colors.black)),
                      const SizedBox(height: 5),
                      Text('Price: $productPrice',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(height: 5),
                      Text('Description: $productDescription',
                          style: const TextStyle(fontSize: 15, color: Colors.black)),
                    ],
                  ),
                ),
                if (order['orderStatus'] == 'delivered' && review != 'done')
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewPagee(
                                orderId: order.id,
                                productId: productDoc.id,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF9B59B6), width: 2),
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF9B59B6),
                        ),
                        child: const Text('Review'),
                      ),
                    ),
                  ),
                const Divider(),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
