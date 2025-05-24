import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laptop/admincategadd.dart';
import 'package:laptop/admindash.dart';
import 'package:laptop/adminorder.dart';
import 'package:laptop/bottambar.dart';
import 'package:laptop/drawer.dart';
// Make sure this file exists and defines CustomBottomAppBar

class listuser extends StatefulWidget {
  const listuser({super.key});

  @override
  State<listuser> createState() => _listuserState();
}

class _listuserState extends State<listuser> {
  final darkPurple = const Color(0xFF2E003E);

  final List<Color> cardColors = [
    Color(0xFFFFF1E6),
    Color(0xFFE6F7FF),
    Color(0xFFE7F6EC),
    Color(0xFFFBE4FF),
    Color(0xFFFFF9E6),
    Color(0xFFFFE6E6),
  ];

  final Map<String, Color> assignedColors = {};
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  int _currentIndex = 1;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color getRandomColorForDoc(String docId) {
    if (!assignedColors.containsKey(docId)) {
      final random = Random();
      assignedColors[docId] = cardColors[random.nextInt(cardColors.length)];
    }
    return assignedColors[docId]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPurple,
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            "View Users",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        backgroundColor: darkPurple,
        centerTitle: true,
        elevation: 4,
        toolbarHeight: 70,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 280,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: darkPurple),
                    hintText: "Search user...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                searchQuery = "";
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.trim().toLowerCase();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('User').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final users = snapshot.data!.docs.where((doc) {
                    final name = doc['UserName'].toString().toLowerCase();
                    final role = doc['role'];
                    return name.contains(searchQuery) && role == 'user';
                  }).toList();

                  if (users.isEmpty) {
                    return const Center(
                      child: Text(
                        "No Users Found.",
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final doc = users[index];
                      final cardColor = getRandomColorForDoc(doc.id);

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        color: cardColor,
                        elevation: 6,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc['UserName'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text("📧 Email: ${doc['UserEmail']}", style: TextStyle(color: Colors.grey[800])),
                              Text("📞 Number: ${doc['UserNumber']}", style: TextStyle(color: Colors.grey[800])),
                              Text("🏠 Address: ${doc['UserAddress']}", style: TextStyle(color: Colors.grey[800])),
                              Text("⚧ Gender: ${doc['UserGender']}", style: TextStyle(color: Colors.grey[800])),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('User')
                                        .doc(doc.id)
                                        .delete();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => cat()));
            }
          },
        ),
      ),
    );
  }
}
