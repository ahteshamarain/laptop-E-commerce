import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop/compare.dart';
import 'package:laptop/checkout.dart';
import 'package:laptop/profile.dart';
import 'package:laptop/search.dart';
import 'package:laptop/userbottambar.dart';
import 'package:laptop/userdash.dart';
import 'package:laptop/wishlist.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int _currentIndex = 5;

  final CollectionReference cart = FirebaseFirestore.instance.collection('cart');
  final CollectionReference products = FirebaseFirestore.instance.collection('Products');
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A148C),
        elevation: 4,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
          },
        ),
        title: const Text(
          'Cart',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
       
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cart.where('uid', isEqualTo: currentUser?.uid).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> cartSnapshot) {
          if (cartSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }
          if (!cartSnapshot.hasData || cartSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Your Cart is Empty', style: TextStyle(color: Colors.black, fontSize: 18)),
            );
          }

          // Calculate total price dynamically from cart documents
          double totalPrice = 0.0;
          for (var doc in cartSnapshot.data!.docs) {
            totalPrice += (doc['fprice'] as num).toDouble();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartSnapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot cartDoc = cartSnapshot.data!.docs[index];
                    return CartItemWidget(
                      cartDoc: cartDoc,
                      productsCollection: products,
                      cartCollection: cart,
                    );
                  },
                ),
              ),

              // Total Price
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                alignment: Alignment.centerRight,
                child: Text(
                  'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),

              // Bottom Buttons
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.4,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsearchPage()));
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        label: const Text('Continue..', style: TextStyle(fontSize: 16, color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          side: const BorderSide(color: Colors.deepPurple),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: screenWidth * 0.4,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutPage()));
                        },
                        icon: const Icon(Icons.payment, color: Colors.white),
                        label: const Text('Checkout', style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
            } else if (index == 1) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductsearchPage()));
            } else if (index == 2) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Compare()));
            } else if (index == 3) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductListwish()));
            } else if (index == 4) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Profile()));
            }
          },
        ),
      ),
    );
  }
}

class CartItemWidget extends StatefulWidget {
  final DocumentSnapshot cartDoc;
  final CollectionReference productsCollection;
  final CollectionReference cartCollection;

  const CartItemWidget({
    Key? key,
    required this.cartDoc,
    required this.productsCollection,
    required this.cartCollection,
  }) : super(key: key);

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  late int qty;
  late int iniprice;
  late int fprice;

  @override
  void initState() {
    super.initState();
    qty = widget.cartDoc['qty'];
    iniprice = widget.cartDoc['iniprice'];
    fprice = widget.cartDoc['fprice'];
  }

  void updateQuantity(int newQty) async {
    if (newQty < 1) {
      await widget.cartCollection.doc(widget.cartDoc.id).delete();
      return;
    }
    int newFPrice = iniprice * newQty;
    setState(() {
      qty = newQty;
      fprice = newFPrice;
    });
    await widget.cartCollection.doc(widget.cartDoc.id).update({
      'qty': newQty,
      'fprice': newFPrice,
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: widget.productsCollection.doc(widget.cartDoc['pid']).get(),
      builder: (context, productSnapshot) {
        if (productSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }
        if (!productSnapshot.hasData || !productSnapshot.data!.exists) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Product not found', style: TextStyle(color: Colors.black)),
          );
        }

        final productData = productSnapshot.data!;
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(productData['images'][0]),
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productData['productName'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "\$$iniprice", // price per item
                        style: const TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        productData['productDetails'],
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.black),
                            onPressed: () {
                              if (qty > 1) {
                                updateQuantity(qty - 1);
                              } else {
                                updateQuantity(0); // remove item
                              }
                            },
                          ),
                          Text(
                            qty.toString(),
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.black),
                            onPressed: () {
                              updateQuantity(qty + 1);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: () async {
                        await widget.cartCollection.doc(widget.cartDoc.id).delete();
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "\$$fprice",
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}