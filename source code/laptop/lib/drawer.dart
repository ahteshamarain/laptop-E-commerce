import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:laptop/adminorder.dart';
import 'package:laptop/adminorderstatus.dart';
import 'package:laptop/adminreview.dart';
import 'package:laptop/adminusershow.dart';
import 'package:laptop/compare.dart';
import 'package:laptop/profile.dart';
import 'package:laptop/register.dart';
import 'package:laptop/review.dart';
import 'package:laptop/updateprofile.dart';
import 'package:laptop/admindash.dart';
import 'package:laptop/admincatshow.dart';
import 'package:laptop/adminproadd.dart';
import 'package:laptop/adminproshow.dart';
import 'package:laptop/usercateg.dart';
import 'package:laptop/userdash.dart';
import 'package:laptop/userorder.dart';
import 'package:laptop/usershow.dart';
import 'package:laptop/wishlist.dart';
import 'package:laptop/adminconshow.dart';
import 'package:laptop/admincategadd.dart';

FirebaseAuth auth = FirebaseAuth.instance;
User? currentUser = auth.currentUser;

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get darkPurple => Color(0xFF2C003E);
  Color get lightPurple => Color(0xFF8A2BE2);

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Drawer(
        backgroundColor: darkPurple,
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('User')
              .doc(currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

            var userData = snapshot.data!.data() as Map<String, dynamic>;
            bool isAdmin = userData['role'] == 'admin';

            return Column(
              children: [
                _buildHeader(userData),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      if (isAdmin) ...[
                        _buildItem(Icons.dashboard, 'Admin Dashboard', () => Navigator.push(context, MaterialPageRoute(builder: (_) => Dashboard()))),
                        _buildDropdowns(context),
                      ] else ...[
                        Divider(color: lightPurple.withOpacity(0.5), thickness: 1),
                        _buildSectionTitle("General"),
                        _buildItem(Icons.home, 'Home', () => Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()))),
                        _buildItem(Icons.account_circle, 'Account', () => Navigator.push(context, MaterialPageRoute(builder: (_) => MyHomePage()))),
                        _buildItem(Icons.shopping_basket, 'My Orders', () => Navigator.push(context, MaterialPageRoute(builder: (_) => HomePageuser2()))),
                        _buildItem(Icons.favorite, 'Wishlist', () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListwish()))),
                        _buildItem(Icons.compare_arrows, 'Compare', () => Navigator.push(context, MaterialPageRoute(builder: (_) => Compare()))),
                      
                      ],
                      _buildItem(Icons.close, 'Close', () => Navigator.of(context).pop()),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> userData) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [darkPurple, lightPurple]),
      ),
      accountName: Text(
        userData['UserName'] ?? '',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      accountEmail: Text(userData['UserEmail'] ?? ''),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: userData['imageBase64'] != null
            ? ClipOval(
                child: Image.memory(
                  base64Decode(userData['imageBase64']),
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(Icons.person, size: 30, color: lightPurple),
      ),
    );
  }

  Widget _buildItem(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: lightPurple),
      title: Text(text, style: TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      hoverColor: Colors.white10,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 0, 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: lightPurple),
      ),
    );
  }

  Widget _buildDropdowns(BuildContext context) {
    return Column(
      children: [
        _buildExpansionTile(
          icon: Icons.category,
          title: 'Category',
          children: [
            _buildItem(Icons.add_circle, 'Add Category', () => Navigator.push(context, MaterialPageRoute(builder: (_) => cat()))),
            _buildItem(Icons.list, 'View Categories', () => Navigator.push(context, MaterialPageRoute(builder: (_) => listcat()))),
            _buildItem(Icons.rule, 'View Conditions', () => Navigator.push(context, MaterialPageRoute(builder: (_) => listConditions()))),
          ],
        ),
        _buildExpansionTile(
          icon: Icons.production_quantity_limits,
          title: 'Product Management',
          children: [
            _buildItem(Icons.add_box, 'Add Product', () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddPage()))),
            _buildItem(Icons.visibility, 'View Products', () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListPage()))),
          ],
        ),
        _buildExpansionTile(
          icon: Icons.shopping_bag,
          title: 'Orders Management',
          children: [
            _buildItem(Icons.list_alt, 'Orders', () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderListPage()))),
            _buildItem(Icons.assignment_turned_in, 'Order Status', () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderStatusPage()))),
          ],
        ),
        _buildExpansionTile(
          icon: Icons.group,
          title: 'Users Management',
          children: [
            _buildItem(Icons.people, 'Users', () => Navigator.push(context, MaterialPageRoute(builder: (_) => listuser()))),
            _buildItem(Icons.reviews, 'Users Review', () => Navigator.push(context, MaterialPageRoute(builder: (_) => Myreview()))),
          ],
        ),
      ],
    );
  }

  Widget _buildExpansionTile({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, color: lightPurple),
        title: Text(
          title,
          style: TextStyle(
            color: Color(0xFFE0BBE4),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        backgroundColor: darkPurple.withOpacity(0.1),
        collapsedBackgroundColor: darkPurple,
        collapsedIconColor: lightPurple,
        iconColor: lightPurple,
        children: children,
      ),
    );
  }
}
