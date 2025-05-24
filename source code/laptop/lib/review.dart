import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:laptop/bottambar.dart';
import 'package:laptop/cart.dart';
import 'package:laptop/compare.dart';
import 'package:laptop/drawer.dart';
import 'package:laptop/profile.dart';
import 'package:laptop/search.dart';
import 'package:laptop/userbottambar.dart';
import 'package:laptop/userdash.dart';
import 'package:laptop/wishlist.dart';

class ReviewPagee extends StatefulWidget {
  final String orderId;
  final String productId;

  const ReviewPagee({super.key, required this.orderId, required this.productId});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPagee> {
  int currentPage = 0;
  int _currentIndex = 5; // <-- For bottom navigation

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0.0;

  final Color lightPurple = const Color(0xFF9B59B6); // Light purple
  final Color textPurple = const Color(0xFF6A1B9A); // Darker purple for text

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate()) {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('User').doc(userId).get();
      String username = userSnapshot['UserName'];

      await FirebaseFirestore.instance.collection('reviews').add({
        'userId': userId,
        'username': username,
        'orderId': widget.orderId,
        'productId': widget.productId,
        'rating': _rating,
        'review': _reviewController.text,
        'timestamp': Timestamp.now(),
      });

      _reviewController.clear();

      await FirebaseFirestore.instance
          .collection('Orders')
          .doc(widget.orderId)
          .collection('Products')
          .doc(widget.productId)
          .update({'reviewStatus': 'done'});

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 219, 216, 216), // Page background color
  drawer: MyDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A148C),
        elevation: 4,
        centerTitle: true,
        title: const Text(
          'My Reviews',
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
    
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "Rate the Product",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textPurple,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              RatingBar.builder(
  initialRating: _rating,
  minRating: 1,
  direction: Axis.horizontal,
  allowHalfRating: true,
  itemCount: 5,
  itemSize: 45,
  itemBuilder: (context, index) {
    bool isSelected = index < _rating;
    return Container(
      
      decoration: BoxDecoration(
    
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: Colors.black)
            : Border.all(color: lightPurple, width: 1.5),
      ),
      child: Icon(
        isSelected ? Icons.star : Icons.star_border_rounded,
        size: 45,
        color: isSelected ? Colors.amber : lightPurple,
      ),
    );
  },
  onRatingUpdate: (rating) {
    setState(() {
      _rating = rating;
    });
  },
),

              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: lightPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _reviewController,
                  style: TextStyle(color: textPurple, fontSize: 18),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a review';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Your Review',
                    labelStyle:
                        TextStyle(color: textPurple.withOpacity(0.7), fontSize: 18),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightPurple,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.send),
                    SizedBox(width: 10),
                    Text(
                      'Submit Review',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
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
    )
    );
  }
}