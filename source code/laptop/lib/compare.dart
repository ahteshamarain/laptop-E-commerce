import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop/bottambar.dart';
import 'package:laptop/cart.dart';
import 'package:laptop/drawer.dart';
import 'package:laptop/product_detail_page.dart';
import 'package:laptop/search.dart';
import 'package:laptop/userbottambar.dart';
import 'package:laptop/userdash.dart';
import 'package:laptop/wishlist.dart';
import 'package:laptop/profile.dart';

class Compare extends StatefulWidget {
  const Compare({super.key});

  @override
  State<Compare> createState() => _CompareState();
}

class _CompareState extends State<Compare> {
  String searchLeft = '';
  String searchRight = '';
  DocumentSnapshot? selectedLeftProduct;
  DocumentSnapshot? selectedRightProduct;

  final ScrollController leftScrollController = ScrollController();
  final ScrollController rightScrollController = ScrollController();

  bool isLeftScrolling = false;
  bool isRightScrolling = false;

  final Color lightPurple = const Color(0xFF9B59B6); // Light purple
  final Color textPurple = const Color(0xFF6A1B9A);  // Darker purple for text

  int _currentIndex = 2; // Compare index

  @override
  void initState() {
    super.initState();

    leftScrollController.addListener(() {
      if (!isLeftScrolling && leftScrollController.hasClients) {
        isRightScrolling = true;
        rightScrollController.jumpTo(leftScrollController.offset);
        isRightScrolling = false;
      }
    });

    rightScrollController.addListener(() {
      if (!isRightScrolling && rightScrollController.hasClients) {
        isLeftScrolling = true;
        leftScrollController.jumpTo(rightScrollController.offset);
        isLeftScrolling = false;
      }
    });
  }

  @override
  void dispose() {
    leftScrollController.dispose();
    rightScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      drawer: MyDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A148C),
        elevation: 4,
        centerTitle: true,
        title: const Text(
          'Compare Products',
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
      ),
      body: Row(
        children: [
          Expanded(
            child: buildCompareSide(
              isLeft: true,
              controller: leftScrollController,
            ),
          ),
          Container(width: 1, color: Colors.white24),
          Expanded(
            child: buildCompareSide(
              isLeft: false,
              controller: rightScrollController,
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: UserBottomAppBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProductsearchPage()),
              );
            } else if (index == 2) {
              // Stay on Compare
            } else if (index == 3) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProductListwish()),
              );
            } else if (index == 4) {
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

  Widget buildCompareSide({
    required bool isLeft,
    required ScrollController controller,
  }) {
    String searchText = isLeft ? searchLeft : searchRight;
    DocumentSnapshot? selectedProduct =
        isLeft ? selectedLeftProduct : selectedRightProduct;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  if (isLeft) {
                    searchLeft = value;
                  } else {
                    searchRight = value;
                  }
                });
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                hintText: 'Search Product...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: lightPurple),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Products')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var products = snapshot.data!.docs.where(
                  (doc) => doc['productName']
                      .toString()
                      .toLowerCase()
                      .contains(searchText.toLowerCase()),
                );

                return ListView(
                  children: products.map((doc) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(doc['images'][0]),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          doc['productName'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: lightPurple,
                          ),
                        ),
                        subtitle: Text(
                          "\$${doc['productPrice']}",
                          style: TextStyle(color: textPurple),
                        ),
                        onTap: () {
                          setState(() {
                            if (isLeft) {
                              selectedLeftProduct = doc;
                            } else {
                              selectedRightProduct = doc;
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          if (selectedProduct != null)
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                child: Container(
                  decoration: BoxDecoration(
                    color: lightPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isLeft) {
                                selectedLeftProduct = null;
                              } else {
                                selectedRightProduct = null;
                              }
                            });
                          },
                          child: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          base64Decode(selectedProduct['images'][0]),
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildDetailItem('Product Name:', selectedProduct['productName']),
                      _buildDetailItem('Price:', "\$${selectedProduct['productPrice']}"),
                      _buildDetailItem('Details:', selectedProduct['productDetails']),
                      _buildDetailItem('Category:', selectedProduct['category']),
                      _buildDetailItem('Condition:', selectedProduct['condition']),
                      const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lightPurple,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductPage(productId: selectedProduct.id),
                              ),
                            );
                          },
                          child: const Text(
                            'More Details',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textPurple,
          ),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
        const Divider(),
      ],
    );
  }
}
