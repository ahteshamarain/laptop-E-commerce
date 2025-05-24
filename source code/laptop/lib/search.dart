import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:laptop/bottambar.dart';
import 'package:laptop/cart.dart';
import 'package:laptop/compare.dart';
import 'package:laptop/drawer.dart';
import 'package:laptop/product_detail_page.dart';
import 'package:laptop/profile.dart';
import 'package:laptop/userbottambar.dart';
import 'package:laptop/userdash.dart';
import 'package:laptop/wishlist.dart';

class ProductsearchPage extends StatefulWidget {
  const ProductsearchPage({Key? key}) : super(key: key);

  @override
  _ProductSearchPageState createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductsearchPage> {
  int _currentIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A148C),
        elevation: 4,
        centerTitle: true,
        title: const Text(
          'Search Products',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(color: Colors.black54),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.purple));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
                } else {
                  List<DocumentSnapshot> products = snapshot.data!.docs;
                  List<DocumentSnapshot> filteredProducts = products.where((product) {
                    String name = (product['productName'] ?? '').toLowerCase();
                    String desc = (product['productDetails'] ?? '').toLowerCase();
                    String price = (product['productPrice'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery.toLowerCase()) ||
                        desc.contains(_searchQuery.toLowerCase()) ||
                        price.contains(_searchQuery.toLowerCase());
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return _buildProductTile(filteredProducts[index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: UserBottomAppBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsearchPage()));
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const Compare()));
              break;
            case 3:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListwish()));
              break;
            case 4:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const Profile()));
              break;
          }
        },
      ),
    );
  }

  Widget _buildProductTile(DocumentSnapshot productSnapshot) {
    Map<String, dynamic> product = productSnapshot.data() as Map<String, dynamic>;
    List<String> base64Images = List<String>.from(product['images']);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 80,
          height: 80,
          child: CarouselSlider(
            options: CarouselOptions(
              aspectRatio: 1,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              viewportFraction: 1.0,
            ),
            items: base64Images.map((base64Str) {
              try {
                final imageBytes = base64Decode(base64Str);
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                  ),
                );
              } catch (e) {
                return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
              }
            }).toList(),
          ),
        ),
        title: Text(
          product['productName'] ?? '',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ${product['productPrice']}', style: TextStyle(color: Colors.grey[700])),
            Text('Details: ${product['productDetails']}', style: TextStyle(color: Colors.grey[700])),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductPage(productId: productSnapshot.id),
            ),
          );
        },
      ),
    );
  }
}