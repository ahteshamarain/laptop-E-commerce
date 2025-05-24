import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:laptop/admincategadd.dart';
import 'package:laptop/admindash.dart';
import 'package:laptop/adminorder.dart';
import 'package:laptop/bottambar.dart';
import 'package:laptop/drawer.dart';
import 'package:laptop/profile.dart'; // make sure this exists
 // replace with actual path

class Myreview extends StatefulWidget {
  @override
  State<Myreview> createState() => _MyreviewState();
}

class _MyreviewState extends State<Myreview> {
  int _currentIndex = 3;
  final Color darkPurple = const Color(0xFF2E003E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPurple,
      appBar: AppBar(
        backgroundColor: darkPurple,
        title: const Text(
          'Review List',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 4,
      ),
      drawer: MyDrawer(),
      body: ReviewList(),
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
}

class ReviewList extends StatelessWidget {
  final Color darkPurple = const Color(0xFF2E003E);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final List<DocumentSnapshot> documents = snapshot.data!.docs;

        if (documents.isEmpty) {
          return Center(
            child: Text(
              "View Reviews",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (BuildContext context, int index) {
            final reviewData = documents[index].data() as Map<String, dynamic>;
            final String reviewId = documents[index].id;
            final String orderId = reviewData['orderId'];
            final String productId = reviewData['productId'];
            final double rating = reviewData['rating'].toDouble();
            final String reviewText = reviewData['review'];
            final String userName = reviewData['username'];

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListTile(
                  title: RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                    itemSize: 24,
                    ignoreGestures: true,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (_) {},
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🆔 OrderID: $orderId'),
                        Text('🛒 ProductID: $productId'),
                        Text('📝 Review: $reviewText'),
                        Text('👤 UserName: $userName'),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('reviews')
                          .doc(reviewId)
                          .delete();
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
