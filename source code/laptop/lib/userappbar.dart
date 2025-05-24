import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop/cart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppBaruser extends StatefulWidget implements PreferredSizeWidget {
  const AppBaruser({Key? key}) : super(key: key);

  @override
  _AppBaruserState createState() => _AppBaruserState();

  @override
  Size get preferredSize => Size.fromHeight(70);
}

class _AppBaruserState extends State<AppBaruser> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;
  int totalCount = 0;
  Map<String, bool> wishlistStatus = {};

  Future<void> updateCartCount() async {
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
    return AppBar(
      title: Text(
        'Flutter Home Page',
        style: TextStyle(color: Colors.black), // Change title color
      ),
      backgroundColor: Colors.amber, // Change appbar background color
      iconTheme: IconThemeData(color: Colors.black), // Change icon color
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
    );
  }
}
