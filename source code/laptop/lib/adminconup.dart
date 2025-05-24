import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop/admincategadd.dart';
import 'package:laptop/admindash.dart';
import 'package:laptop/adminorder.dart';
import 'package:laptop/bottambar.dart';
import 'package:laptop/drawer.dart';
import 'package:laptop/profile.dart'; // ✅ Update path if needed

class conEdit extends StatefulWidget {
  final String id;
  conEdit({required this.id});

  @override
  State<conEdit> createState() => _EditState();
}

class _EditState extends State<conEdit> {
  TextEditingController name = TextEditingController();

  final darkPurple = const Color(0xFF2E003E);
  final offWhite = const Color(0xFFF9F9F9);
  final accentPurple = const Color(0xFF9C27B0);

  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    DocumentSnapshot data = await FirebaseFirestore.instance
        .collection("condition")
        .doc(widget.id)
        .get();

    if (data.exists) {
      name.text = data.get("name");
    }
  }

  void update() {
    FirebaseFirestore.instance
        .collection('condition')
        .doc(widget.id)
        .update({'name': name.text})
        .then((_) {
      // Show the success message using SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your condition has been updated')),
      );

      // Wait for a short delay before navigating back
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop(); // Navigate back to the previous screen
      });
    }).catchError((error) {
      // Show error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating condition: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPurple,
      appBar: AppBar(
        backgroundColor: darkPurple,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Condition',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        // Replace the drawer icon with a back arrow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back arrow icon
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
          },
        ),
      ),
      drawer: MyDrawer(), // Optional: you can remove this if not needed
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: offWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Condition Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: name,
                  style: TextStyle(color: Colors.black), // Set text color to black
                  decoration: InputDecoration(
                    hintText: 'Enter new condition name',
                    hintStyle: TextStyle(color: Colors.black), // Set hint text color to black
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accentPurple, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: update,
                    child: const Text(
                      'Update Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Bottom Navigation Bar code
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: CustomBottomAppBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OrderListPage()),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Dashboard()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Profile()),
              );
            }
          },
        ),
      ),
    );
  }
}