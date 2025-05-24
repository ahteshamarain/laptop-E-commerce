import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop/admindash.dart';
import 'package:laptop/adminorder.dart';
import 'package:laptop/bottambar.dart';
import 'package:laptop/cart.dart';
import 'package:laptop/changepass.dart';
import 'package:laptop/compare.dart';
import 'package:laptop/drawer.dart';
import 'package:laptop/login.dart';
import 'package:laptop/search.dart';
import 'package:laptop/updateprofile.dart';
import 'package:laptop/userbottambar.dart';
import 'package:laptop/userdash.dart';
import 'package:laptop/userorder.dart';
import 'package:laptop/wishlist.dart';


class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final Color lightPurple = const Color(0xFF9B59B6);
  final Color textPurple = const Color(0xFF6A1B9A);
  final Color background = const Color(0xFFF3F3F3);

  String name = '';
  String email = '';
  String role = '';
  String? _imageBase64;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('User')
          .doc(currentUser?.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          name = data?['UserName'] ?? '';
          email = currentUser?.email ?? '';
          _imageBase64 = data?['imageBase64'];
          role = data?['role'] ?? '';
          _currentIndex = role == 'admin' ? 2 : 4; // ✅ set index based on role
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void navigateToPage(String route) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _getPage(route)),
    );
  }

  Widget buildCard(String title, String subtitle, IconData icon, String route) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: lightPurple.withOpacity(0.4)),
      ),
      child: ListTile(
        leading: Icon(icon, color: lightPurple),
        title: Text(title, style: TextStyle(color: textPurple, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: textPurple)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textPurple),
        onTap: () => navigateToPage(route),
      ),
    );
  }

  Widget _getPage(String route) {
    switch (route) {
      case 'update':
        return const MyHomePage();
      case 'order':
        return role == 'admin' ? const OrderListPage() : const HomePageuser2();
      case 'change_password':
        return const ChangePasswordPage();
      default:
        return const Profile();
    }
  }

  void onBottomNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);

    if (role == 'admin') {
      if (index == 0) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OrderListPage()));
      } else if (index == 1) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Dashboard()));
      } else if (index == 2) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Profile()));
      }
    } else {
      final pages = [
        const HomePage(),
        const ProductsearchPage(),
        const Compare(),
        const ProductListwish(),
        const Profile(),
      ];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => pages[index]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      drawer: MyDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A148C),
        elevation: 4,
        centerTitle: true,
        title: const Text(
          'Profile',
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image and Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _imageBase64 != null
                      ? MemoryImage(base64Decode(_imageBase64!))
                      : null,
                  child: _imageBase64 == null
                      ? const Icon(Icons.person, size: 55, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textPurple)),
                      const SizedBox(height: 6),
                      Text(email,
                          style: TextStyle(fontSize: 16, color: textPurple)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Action Cards
            buildCard('My Account', 'View your account details',
                Icons.account_circle, 'update'),

            buildCard('Change Password', 'Update your password',
                Icons.lock, 'change_password'),

            buildCard('Order Details', 'View your order history',
                Icons.receipt_long, 'order'),

            const SizedBox(height: 30),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout, size: 20),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),

      // ✅ Show bottom bar based on role
      bottomNavigationBar: role == 'admin'
          ? AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: CustomBottomAppBar(
                currentIndex: _currentIndex,
                onTap: onBottomNavTap,
              ),
            )
          : UserBottomAppBar(
              currentIndex: _currentIndex,
              onTap: onBottomNavTap,
            ),
    );
  }
}
