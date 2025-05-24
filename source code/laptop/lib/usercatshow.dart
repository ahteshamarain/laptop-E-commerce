import 'dart:convert';

import 'package:laptop/bottambar.dart';
import 'package:laptop/cart.dart';
import 'package:laptop/drawer.dart';
import 'package:laptop/userdash.dart';
import 'package:laptop/wishlist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class HomePageuser extends StatefulWidget {
  const HomePageuser({super.key});

  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageuser> {
  int currentPage = 0;
  FirebaseAuth auth = FirebaseAuth.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;
  int totalCount = 0;

  void updateCartCount() async {
    CollectionReference cartCollection =
        FirebaseFirestore.instance.collection('cart');
    QuerySnapshot userCart =
        await cartCollection.where('uid', isEqualTo: currentUser?.uid).get();

    setState(() {
      totalCount = userCart.size;
    });
  }

  List<DocumentSnapshot> categories = [];

  void fetchCategories() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('categ').get();
    setState(() {
      categories = snapshot.docs;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
    updateCartCount();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Flutter Home Page',
            style: TextStyle(color: Colors.black), // Change title color
          ),
          backgroundColor: Colors.amber, // Change appbar background color
          iconTheme: IconThemeData(color: Colors.black),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartPage(),
                      ),
                    );
                    setState(() {});
                  },
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 10,
                    child: Text(
                      totalCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            tabs: categories.map((category) {
              return Tab(
                text: category['name'],
              );
            }).toList(),
          ),
        ),
        drawer: MyDrawer(),
        body: TabBarView(
          children: categories.map((category) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Products')
                  .where('category', isEqualTo: category['name'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  //is code sy null operator wala error nai ata/////////////////////
                  List<DocumentSnapshot> products = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var product = products[index];
                      String productId = product.id;
                      return ListTile(
                        leading: Image.memory(
                          base64Decode(product['images'][0]),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(product['productName']),
                        subtitle: Text(product['productDetails']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('\$${product['productPrice']}'),
                            IconButton(
                              icon: Icon(Icons.add_shopping_cart),
                              onPressed: () async {
                                CollectionReference colref = FirebaseFirestore
                                    .instance
                                    .collection('cart');

                                QuerySnapshot existingDocs = await colref
                                    .where('pid', isEqualTo: product.id)
                                    .where('uid', isEqualTo: currentUser?.uid)
                                    .get();

                                if (existingDocs.docs.isNotEmpty) {
                                  DocumentReference existingDocRef =
                                      existingDocs.docs.first.reference;
                                  int currentQty =
                                      existingDocs.docs.first['qty'] ?? 0;

                                  await existingDocRef.update({
                                    'qty': currentQty + 1,
                                    'fprice': (currentQty + 1) *
                                        product['productPrice'],
                                  });
                                } else {
                                  await colref.add({
                                    'pid': product.id,
                                    'iniprice': product['productPrice'],
                                    'qty': 1,
                                    'fprice': product['productPrice'] * 1,
                                    'uid': currentUser?.uid,
                                    'image': product['images'][0],
                                    // Add user id to cart
                                  });
                                }

                                setState(() {});
                                updateCartCount();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Product added to Cart successfully!'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            );
          }).toList(),
        ),
        bottomNavigationBar: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: CustomBottomAppBar(
            currentIndex: currentPage,
            onTap: (index) {
              setState(() {
                currentPage = index;
              });
              // Handle navigation based on the index
              switch (index) {
                case 0:
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HomePage()));
                  break;
                case 1:
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProductListwish()));
                  break;
                case 2:
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProductListwish()));
                  break;
                default:
                // Do nothing
              }
            },
          ),
        ),
      ),
    );
  }
}
