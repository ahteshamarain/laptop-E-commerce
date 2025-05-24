// free book//

// used laptop//

// iska alag sy table banyega admin side sy or show hoga user ko is page

import 'package:laptop/bottambar.dart';
import 'package:laptop/drawer.dart';
import 'package:laptop/userappbar.dart';
import 'package:laptop/userdash.dart';
import 'package:laptop/wishlist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductfreePage extends StatefulWidget {
  const ProductfreePage({super.key});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductfreePage> {
  int currentPage = 0;
  final CollectionReference wishlist =
      FirebaseFirestore.instance.collection('Products');

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

  @override
  void initState() {
    super.initState();

    updateCartCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBaruser(),
      drawer: MyDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<DocumentSnapshot> products = snapshot.data!.docs;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _buildProductTile(products[index]);
              },
            );
          }
        },
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
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => HomePage()));
                break;
              case 1:
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProductListwish()));
                break;
              case 2:
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProductListwish()));
                break;
              default:
              // Do nothing
            }
          },
        ),
      ),
    );
  }

  Widget _buildProductTile(DocumentSnapshot productSnapshot) {
    Map<String, dynamic> product =
        productSnapshot.data() as Map<String, dynamic>;
    List<String> imageUrls = List<String>.from(product['images']);
    if (product['productPrice'] == 0) {
      return ListTile(
        leading: Container(
          width: 100,
          height: 100,
          child: CarouselSlider(
            options: CarouselOptions(
              aspectRatio: 16 / 9,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
            ),
            items: imageUrls.map((url) {
              return Image.network(url, fit: BoxFit.cover);
            }).toList(),
          ),
        ),
        title: Text(product['productName']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ${product['productPrice']}'),
            Text('Details: ${product['productDetails']}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.add_shopping_cart),
              onPressed: () async {
                CollectionReference colref =
                    FirebaseFirestore.instance.collection('cart');

                QuerySnapshot existingDocs = await colref
                    .where('pid', isEqualTo: productSnapshot.id)
                    .where('uid', isEqualTo: currentUser?.uid)
                    .get();

                if (existingDocs.docs.isNotEmpty) {
                  DocumentReference existingDocRef =
                      existingDocs.docs.first.reference;
                  int currentQty = existingDocs.docs.first['qty'] ?? 0;

                  await existingDocRef.update({
                    'qty': currentQty + 1,
                    'fprice': (currentQty + 1) * product['productPrice'],
                  });
                } else {
                  await colref.add({
                    'pid': productSnapshot.id,
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
                    content: Text('Product added to Cart successfully!'),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } else {
      // If product price is not 0, return an empty container
      return Container();
    }
  }
}
