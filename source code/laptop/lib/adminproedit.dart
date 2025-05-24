import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laptop/adminappbar.dart';
import 'package:laptop/admincategadd.dart';
import 'package:laptop/admindash.dart';
import 'package:laptop/adminorder.dart';
import 'package:laptop/bottambar.dart';
import 'package:laptop/drawer.dart';

class ProductEditPage extends StatefulWidget {
  final String productId;
  ProductEditPage({required this.productId});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<ProductEditPage> {
  List<String> _existingImageBase64 = [];
  List<String?> _newImageBase64 = [];
  final picker = ImagePicker();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _detailsController = TextEditingController();
  var selectedCategory;
  var selectedCondition;

  final darkPurple = const Color(0xFF2E003E);
  final offWhite = const Color(0xFFF9F9F9);
  final accentPurple = const Color(0xFF9C27B0);
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  void _fetchProductDetails() {
    FirebaseFirestore.instance
        .collection('Products')
        .doc(widget.productId)
        .get()
        .then((docSnapshot) {
      if (docSnapshot.exists) {
        setState(() {
          _nameController.text = docSnapshot['productName'];
          _priceController.text = docSnapshot['productPrice'].toString();
          _detailsController.text = docSnapshot['productDetails'];
          selectedCategory = docSnapshot['category'];
          selectedCondition = docSnapshot['condition'];
          _existingImageBase64 = List<String>.from(docSnapshot['images']);
          _newImageBase64 = List<String?>.filled(_existingImageBase64.length, null);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPurple,
      appBar: AppBar(
        backgroundColor: darkPurple,
        elevation: 0,
        title: Text(
          "Update Product",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: offWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLabel("Product Name"),
              _buildInputField(_nameController),
              SizedBox(height: 16),
              _buildLabel("Product Price"),
              _buildInputField(_priceController, keyboardType: TextInputType.number),
              SizedBox(height: 16),
              _buildLabel("Product Details"),
              _buildInputField(_detailsController, maxLines: 3),
              SizedBox(height: 16),
              _buildLabel("Category"),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('categ').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<DropdownMenuItem> categoryItems = snapshot.data!.docs.map((doc) {
                      return DropdownMenuItem(
                        value: doc['name'],
                        child: Text(doc['name'], style: TextStyle(color: Colors.black)),
                      );
                    }).toList();

                    return _buildDropdown(
                      items: categoryItems,
                      value: selectedCategory,
                      hint: "Choose Category",
                      onChanged: (value) => setState(() => selectedCategory = value),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
              SizedBox(height: 16),
              _buildLabel("Condition"),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('condition').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<DropdownMenuItem> conditionItems = snapshot.data!.docs.map((doc) {
                      return DropdownMenuItem(
                        value: doc['name'],
                        child: Text(doc['name'], style: TextStyle(color: Colors.black)),
                      );
                    }).toList();

                    return _buildDropdown(
                      items: conditionItems,
                      value: selectedCondition,
                      hint: "Choose Condition",
                      onChanged: (value) => setState(() => selectedCondition = value),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
              SizedBox(height: 24),
              _buildLabel("Images (Tap to Replace)"),
              SizedBox(height: 12),
              Container(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _existingImageBase64.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _pickImages(index),
                      child: Container(
                        margin: EdgeInsets.only(right: 12),
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _newImageBase64[index] != null
                              ? Image.memory(base64Decode(_newImageBase64[index]!), fit: BoxFit.cover)
                              : Image.memory(base64Decode(_existingImageBase64[index]), fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentPurple,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _updateProduct,
                child: Text(
                  "Update Product",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => OrderListPage()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => Dashboard()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => cat()));
          }
        },
      ),
    );
  }

  Future<void> _updateProduct() async {
    List<String> updatedImageBase64 = [];
    for (int i = 0; i < _newImageBase64.length; i++) {
      updatedImageBase64.add(_newImageBase64[i] ?? _existingImageBase64[i]);
    }

    await FirebaseFirestore.instance.collection('Products').doc(widget.productId).update({
      'productName': _nameController.text,
      'productPrice': int.parse(_priceController.text),
      'productDetails': _detailsController.text,
      'category': selectedCategory,
      'condition': selectedCondition,
      'images': updatedImageBase64,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Your product has been updated')),
    );

    Future.delayed(Duration(seconds: 2), () => Navigator.of(context).pop());
  }

  Future<void> _pickImages(int index) async {
    final pickedFiles = await picker.pickMultiImage(imageQuality: 50);
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      Uint8List bytes = await pickedFiles[0].readAsBytes();
      setState(() {
        _newImageBase64[index] = base64Encode(bytes);
      });
    }
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(color: darkPurple, fontWeight: FontWeight.w600, fontSize: 16),
    );
  }

  Widget _buildInputField(TextEditingController controller,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdown({
    required List<DropdownMenuItem> items,
    required dynamic value,
    required String hint,
    required void Function(dynamic) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white, // White background
      ),
      child: DropdownButton(
        items: items,
        value: value,
        isExpanded: true,
        onChanged: onChanged,
        underline: SizedBox(),
        hint: Text(hint, style: TextStyle(color: Colors.black)),
        style: TextStyle(color: Colors.black), // Selected item text
        dropdownColor: Colors.white,
        iconEnabledColor: Colors.black,
      ),
    );
  }
}
