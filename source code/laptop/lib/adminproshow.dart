import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:laptop/admincategadd.dart';
import 'package:laptop/admindash.dart';
import 'package:laptop/adminorder.dart';
import 'package:laptop/adminproadd.dart';
import 'package:laptop/adminproedit.dart';
import 'package:laptop/bottambar.dart';
import 'package:laptop/drawer.dart';
import 'package:laptop/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAom2tJlU_Nlrw0PPxgJZgWnwjO4Kl1J5E',
      appId: '1:441683668081:android:22a60aa8056256563cffd0',
      messagingSenderId: '441683668081',
      projectId: 'classfire-58dd3',
      databaseURL: 'https://classfire-58dd3-default-rtdb.firebaseio.com',
      storageBucket: 'classfire-58dd3.firebasestorage.app',
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProductListPage(),
    );
  }
}

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final darkPurple = const Color(0xFF2E003E);
  final offWhite = const Color(0xFFF9F9F9);
  final accentPurple = const Color(0xFF9C27B0);

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  int _currentIndex = 3;

  Color getCardColor(int index) {
    return offWhite;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Uint8List> _decodeBase64Images(List<String> base64Images) {
    return base64Images.map((base64Image) {
      return base64Decode(base64Image);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPurple,
      appBar: AppBar(
        backgroundColor: darkPurple,
        elevation: 0,
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            "View Product",
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 280,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: darkPurple),
                    hintText: "Search product...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                searchQuery = "";
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.trim().toLowerCase();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Products').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                  }

                  List<DocumentSnapshot> products = snapshot.data!.docs.where((doc) {
                    final name = doc['productName'].toString().toLowerCase();
                    return name.contains(searchQuery);
                  }).toList();

                  if (products.isEmpty) {
                    return const Center(
                      child: Text("No Products Found.", style: TextStyle(color: Colors.white70, fontSize: 18)),
                    );
                  }

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _buildProductTile(products[index], index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddPage()));
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Product", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPurple,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 10,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // Bottom Navigation Bar
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: CustomBottomAppBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => OrderListPage()));
            } else if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => Dashboard()));
            } else if (index == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => Profile()));
            }
          },
        ),
      ),
    );
  }

  Widget _buildProductTile(DocumentSnapshot productSnapshot, int index) {
    Map<String, dynamic> product = productSnapshot.data() as Map<String, dynamic>;
    List<Uint8List> imageBytes = _decodeBase64Images(List<String>.from(product['images']));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: getCardColor(index),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                imageBytes.isNotEmpty ? imageBytes[0] : Uint8List(0),
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['productName'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkPurple),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Price: ${product['productPrice']}",
                    style: TextStyle(color: darkPurple, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Details: ${product['productDetails']}",
                    style: TextStyle(color: darkPurple, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Category: ${product['category']}",
                    style: TextStyle(color: darkPurple, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Condition: ${product['condition']}",
                    style: TextStyle(color: darkPurple, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: accentPurple),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductEditPage(productId: productSnapshot.id),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          await FirebaseFirestore.instance.collection('Products').doc(productSnapshot.id).delete();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
