import 'package:laptop/bottambar.dart';
import 'package:laptop/drawer.dart';
import 'package:laptop/review.dart';
import 'package:laptop/userdash.dart';
import 'package:laptop/wishlist.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class HomePageuser2 extends StatefulWidget {
  const HomePageuser2({Key? key}) : super(key: key);

  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageuser2> {
  int currentPage = 3;
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: new AppBar(
          title: new Text("Home"),
          // elevation:
          //     defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.android),
                text: "Pending Orders",
              ),
              Tab(icon: Icon(Icons.phone_iphone), text: "Delivered Orders"),
              Tab(text: "Canceled Order"),
            ],
          ),
        ),
        drawer: MyDrawer(),
        body: TabBarView(
          children: [
            buildOrdersTab('pending'), // Pending Orders Tab
            buildOrdersTab('delivered'), // Delivered Orders Tab
            buildOrdersTab('canceled'), // Canceled Orders Tab
          ],
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
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HomePage()));
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

  Widget buildOrdersTab(String orderStatus) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Orders')
          .where('orderStatus', isEqualTo: orderStatus)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<DocumentSnapshot> orders = snapshot.data!.docs;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              return _buildOrderItem(order);
            },
          );
        }
      },
    );
  }

  Widget _buildOrderItem(DocumentSnapshot order) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order ID: ${order.id}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Products:'),
              SizedBox(height: 5),
              _buildProductList(order),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildProductList(DocumentSnapshot order) {
    CollectionReference productsCollection =
        order.reference.collection('Products');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: productsCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Text('No products available');
            }
            return ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: snapshot.data!.docs.map((productDoc) {
                final productData = productDoc.data() as Map<String, dynamic>;

                if (productData != null) {
                  final productName = productData['productName'];
                  final productQty = productData['qty'];
                  final productImage = productData['images'][0] ?? '';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: productImage.isNotEmpty
                              ? NetworkImage(productImage)
                              : null,
                        ),
                        title: Text(productName),
                        subtitle: Text('Qty: $productQty'),
                      ),
                      SizedBox(height: 10),
                      // Conditionally show the review button only if the order status is "delivered"
                      if (order['orderStatus'] == 'delivered')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [],
                        ),
                      Divider(),
                    ],
                  );
                } else {
                  return Text('Product Data Not Available');
                }
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
