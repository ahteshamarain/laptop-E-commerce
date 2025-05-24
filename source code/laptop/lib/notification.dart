import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:laptop/adminOrdershow.dart';


import 'package:laptop/cart.dart';
import 'package:laptop/compare.dart';
import 'package:laptop/drawer.dart';
import 'package:laptop/profile.dart';
import 'package:laptop/search.dart';
import 'package:laptop/userbottambar.dart';
import 'package:laptop/userdash.dart';
import 'package:laptop/wishlist.dart';


class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _ProductListViewState createState() => _ProductListViewState();
}

class _ProductListViewState extends State<NotificationsPage> {
  int _currentIndex = 3; // <-- For bottom navigation
  final CollectionReference wishlist = FirebaseFirestore.instance.collection('wishlist');
  FirebaseAuth auth = FirebaseAuth.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;
  int totalCount = 0;

  void updateCartCount() async {
    CollectionReference cartCollection = FirebaseFirestore.instance.collection('cart');
    QuerySnapshot userCart = await cartCollection.where('uid', isEqualTo: currentUser?.uid).get();

    setState(() {
      totalCount = userCart.size;
    });
  }

  @override
  void initState() {
    super.initState();
    updateCartCount();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color lightPurple = const Color(0xFF9B59B6);
    final Color textPurple = const Color(0xFF6A1B9A);

    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A148C),
        elevation: 4,
        centerTitle: true,
        title: const Text(
          'My Wishlist',
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsearchPage()));
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: wishlist.where('userId', isEqualTo: currentUser?.uid).snapshots(),
          builder: (context, streamSnapshot) {
            if (!streamSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot product = streamSnapshot.data!.docs[index];
                Uint8List? imageBytes;

                try {
                  imageBytes = base64Decode(product['image']);
                } catch (e) {
                  imageBytes = null;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: lightPurple, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          product['productName'],
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: textPurple,
                          ),
                        ),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '\$${product['productPrice']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: lightPurple,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: lightPurple, width: 1.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              product['productDetails'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageBytes != null
                          ? Image.memory(imageBytes, width: 55, height: 55, fit: BoxFit.cover)
                          : Container(
                              width: 55,
                              height: 55,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image_not_supported),
                            ),
                    ),
                    trailing: Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await wishlist.doc(product.id).delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Removed from Wishlist')),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.add_shopping_cart, color: textPurple),
                          onPressed: () async {
                            CollectionReference colref = FirebaseFirestore.instance.collection('cart');
                            QuerySnapshot existingDocs = await colref
                                .where('pid', isEqualTo: product['productId'])
                                .where('uid', isEqualTo: currentUser?.uid)
                                .get();

                            if (existingDocs.docs.isNotEmpty) {
                              DocumentReference existingDocRef = existingDocs.docs.first.reference;
                              int currentQty = existingDocs.docs.first['qty'] ?? 0;

                              await existingDocRef.update({
                                'qty': currentQty + 1,
                                'fprice': (currentQty + 1) * product['productPrice'],
                              });
                            } else {
                              await colref.add({
                                'pid': product['productId'],
                                'iniprice': product['productPrice'],
                                'qty': 1,
                                'fprice': product['productPrice'],
                                'uid': currentUser?.uid,
                                'image': product['image'],
                              });
                            }

                            updateCartCount();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Product added to Cart successfully!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),

      // ✅ Bottom Navigation Bar with Animation
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: UserBottomAppBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

            // Navigation logic
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HomePage()),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductsearchPage()),
              );
            } 
             else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Compare()),
              );
            } 
            else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductListwish()),
              );
            }
              else if (index == 4) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Profile()),
              );
            }
          },
        ),
      ),
    );
  }
}
