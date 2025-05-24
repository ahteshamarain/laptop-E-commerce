// Keep your existing imports
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:laptop/cart.dart';
import 'package:laptop/compare.dart';
import 'package:laptop/drawer.dart';
import 'package:laptop/profile.dart';
import 'package:laptop/search.dart';
import 'package:laptop/userbottambar.dart';
import 'package:laptop/userdash.dart';
import 'package:laptop/wishlist.dart';

class ProductPage extends StatefulWidget {
  final String productId;

  const ProductPage({super.key, required this.productId});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  bool isInWishlist = false;
  late String userId;
  int _currentIndex = 5;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    checkWishlistStatus();
  }

  Future<void> checkWishlistStatus() async {
    final wishlistRef = await FirebaseFirestore.instance
        .collection('wishlist')
        .where('productId', isEqualTo: widget.productId)
        .where('userId', isEqualTo: userId)
        .get();

    setState(() {
      isInWishlist = wishlistRef.docs.isNotEmpty;
    });
  }

  Future<void> addToCartAndNavigate(DocumentSnapshot doc) async {
    final colref = FirebaseFirestore.instance.collection('cart');
    final existingDocs = await colref
        .where('pid', isEqualTo: doc.id)
        .where('uid', isEqualTo: userId)
        .get();

    if (existingDocs.docs.isNotEmpty) {
      final ref = existingDocs.docs.first.reference;
      int currentQty = existingDocs.docs.first['qty'] ?? 0;
      await ref.update({
        'qty': currentQty + 1,
        'fprice': (currentQty + 1) *
            (doc.data() as Map<String, dynamic>)['productPrice'],
      });
    } else {
      await colref.add({
        'pid': doc.id,
        'iniprice': (doc.data() as Map<String, dynamic>)['productPrice'],
        'qty': 1,
        'fprice': (doc.data() as Map<String, dynamic>)['productPrice'],
        'uid': userId,
        'image': (doc.data() as Map<String, dynamic>)['images'][0],
      });
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage()));
  }

  Future<void> addToWishlist(DocumentSnapshot product) async {
    final wishlist = FirebaseFirestore.instance.collection('wishlist');
    final existing = await wishlist
        .where('userId', isEqualTo: userId)
        .where('productId', isEqualTo: product.id)
        .get();

    if (existing.docs.isEmpty) {
      final data = product.data() as Map<String, dynamic>;
      await wishlist.add({
        'productName': data['productName'],
        'productPrice': data['productPrice'],
        'productDetails': data['productDetails'],
        'userId': userId,
        'productId': product.id,
        'image': data['images'][0],
      });

      setState(() {
        isInWishlist = true;
      });
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('wishlist')
        .where('productId', isEqualTo: productId)
        .where('userId', isEqualTo: userId)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    setState(() {
      isInWishlist = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Product removed from wishlist")),
    );
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
          'Product Details',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Products')
                    .doc(widget.productId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var productData = snapshot.data!.data() as Map<String, dynamic>;
                  List<dynamic> images = productData['images'];
                  return PageView.builder(
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return Image.memory(
                        base64Decode(images[index]),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Products')
                    .doc(widget.productId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var productData = snapshot.data!.data() as Map<String, dynamic>;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            productData['productName'],
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Average Rating',
                                style: TextStyle(
                                  fontSize: 14, // Increase the font size slightly
                                  fontWeight: FontWeight.bold, // Make it bold
                                  color: Colors.black54,
                                ),
                              ),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('reviews')
                                    .where('productId', isEqualTo: widget.productId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return const CircularProgressIndicator();
                                  var reviews = snapshot.data!.docs;
                                  double averageRating = 0;
                                  if (reviews.isNotEmpty) {
                                    averageRating = reviews.map((doc) {
                                      var data = doc.data() as Map<String, dynamic>;
                                      return data['rating'] as double;
                                    }).reduce((a, b) => a + b) / reviews.length;
                                  }
                                  return RatingBarIndicator(
                                    rating: averageRating,
                                    itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                                    itemCount: 5,
                                    itemSize: 25.0,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                          const SizedBox(height: 10),
                      Text(
                        'Category: ${productData['category']}',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                              const SizedBox(height: 10),
                      Text(
                        'Condition: ${productData['condition']}',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(height: 10),

                         Text(
                        'Generation: ${productData['generation']}',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      
                      const SizedBox(height: 10),

                         Text(
                        'Processor: ${productData['processor']}',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                         const SizedBox(height: 10),

                         Text(
                        'Graphics Card: ${productData['graphicsCard']}',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                         const SizedBox(height: 10),

                         Text(
                        'RAM: ${productData['ram']}',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                         const SizedBox(height: 10),

                         Text(
                        'SSD: ${productData['ssd']}',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                         const SizedBox(height: 10),

                         Text(
                        'HDD: ${productData['hdd']}',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Price: \$${productData['productPrice']}',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Description: ${productData['productDetails']}',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(height: 20),

                      // Wishlist and Add to Cart Buttons (Favorite icon next to Add to Cart)
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isInWishlist ? Icons.favorite : Icons.favorite_border,
                              color: isInWishlist ? Colors.red : Colors.grey,
                              size: 30,
                            ),
                            onPressed: () async {
                              final doc = await FirebaseFirestore.instance
                                  .collection('Products')
                                  .doc(widget.productId)
                                  .get();
                              isInWishlist
                                  ? await removeFromWishlist(widget.productId)
                                  : await addToWishlist(doc);
                            },
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final doc = await FirebaseFirestore.instance
                                  .collection('Products')
                                  .doc(widget.productId)
                                  .get();
                              await addToCartAndNavigate(doc);
                            },
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Add to Cart'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ],
                      ),

                      const Divider(),  // Divider line

                      // Move the Reviews Section below Average Rating
                      const SizedBox(height: 20),
                      const Text('Reviews:', style: TextStyle(fontSize: 16, color: Colors.black)),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('reviews')
                            .where('productId', isEqualTo: widget.productId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const CircularProgressIndicator();
                          var reviews = snapshot.data!.docs;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              var reviewData = reviews[index].data() as Map<String, dynamic>;
                              return ListTile(
                                title: Text(reviewData['username'], style: const TextStyle(color: Colors.black)),
                                subtitle: Text(reviewData['review'], style: const TextStyle(color: Colors.black87)),
                                trailing: RatingBarIndicator(
                                  rating: reviewData['rating'].toDouble(),
                                  itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                                  itemCount: 5,
                                  itemSize: 20.0,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: UserBottomAppBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            switch (index) {
              case 0:
                Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
                break;
              case 1:
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProductsearchPage()));
                break;
              case 2:
                Navigator.push(context, MaterialPageRoute(builder: (_) => Compare()));
                break;
              case 3:
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListwish()));
                break;
              case 4:
                Navigator.push(context, MaterialPageRoute(builder: (_) => Profile()));
                break;
            }
          },
        ),
      ),
    );
  }
}
