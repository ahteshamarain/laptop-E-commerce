import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop/compare.dart';
import 'package:laptop/profile.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final picker = ImagePicker();

  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  String? _imageBase64;

  final Color darkPurple = const Color(0xFF4A148C);
  final Color lightPurple = const Color(0xFF9B59B6);
  final Color offWhite = const Color(0xFFF3F3F3);
  final Color textPurple = const Color(0xFF6A1B9A);

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(currentUser.uid)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          nameController.text = userSnapshot['UserName'] ?? '';
          bioController.text = userSnapshot['UserGender'] ?? '';
          numberController.text = userSnapshot['UserNumber'] ?? '';
          addressController.text = userSnapshot['UserAddress'] ?? '';
          _imageBase64 = userSnapshot['imageBase64'];
        });
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _updateUserProfile() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      await FirebaseFirestore.instance.collection('User').doc(currentUser.uid).update({
        'UserName': nameController.text,
        'UserGender': bioController.text,
        'UserNumber': numberController.text,
        'UserAddress': addressController.text,
        'imageBase64': _imageBase64,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Updated Successfully!')),
      );
    } catch (error) {
      print('Error updating profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offWhite,
      appBar: AppBar(
        backgroundColor: darkPurple,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back on tap
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _imageBase64 != null
                    ? MemoryImage(base64Decode(_imageBase64!))
                    : null,
                backgroundColor: Colors.grey[300],
                child: _imageBase64 == null
                    ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField('Name', nameController),
            _buildTextField('Gender', bioController),
            _buildTextField('Phone Number', numberController, type: TextInputType.phone),
            _buildTextField('Address', addressController),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _updateUserProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: lightPurple,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Update Profile',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar removed as requested
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(color: Colors.black), // Text color black
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: textPurple),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: lightPurple),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: darkPurple),
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
