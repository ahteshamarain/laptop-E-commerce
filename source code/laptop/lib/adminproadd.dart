import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop/drawer.dart';
import 'package:laptop/bottambar.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AddPage> {
  List<XFile>? _images;
  List<Uint8List>? _imageBytes = [];
  final picker = ImagePicker();

  TextEditingController textController1 = TextEditingController();
  TextEditingController textController2 = TextEditingController();
  TextEditingController textController3 = TextEditingController();
  TextEditingController textController4 = TextEditingController(); // Graphics Card
  TextEditingController textController5 = TextEditingController(); // SSD
  TextEditingController textController6 = TextEditingController(); // HDD
  TextEditingController textController7 = TextEditingController(); // RAM
  TextEditingController textController8 = TextEditingController(); // Generation
  TextEditingController textController9 = TextEditingController(); // Processor

  var selectedCurrency, selectedCondition;

  final darkPurple = const Color(0xFF2E003E);
  final offWhite = const Color(0xFFF9F9F9);
  final accentPurple = const Color(0xFF9C27B0);
  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPurple,
      appBar: AppBar(
        backgroundColor: darkPurple,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Add Products',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
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
                  _buildTextField('Product Name', textController1),
                  const SizedBox(height: 16),
                  _buildTextField('Product Price', textController2,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildTextField('Product Details', textController3, maxLines: 3),
                  const SizedBox(height: 16),
                  _buildTextField('Graphics Card', textController4),
                  const SizedBox(height: 16),
                  _buildTextField('SSD', textController5),
                  const SizedBox(height: 16),
                  _buildTextField('HDD', textController6),
                  const SizedBox(height: 16),
                  _buildTextField('RAM', textController7),
                  const SizedBox(height: 16),
                  _buildTextField('Generation', textController8),
                  const SizedBox(height: 16),
                  _buildTextField('Processor', textController9),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    'Choose Category Type',
                    'categ',
                    selectedCurrency,
                    (val) => setState(() => selectedCurrency = val),
                  ),
                  const SizedBox(height: 24),
                  _buildDropdown(
                    'Choose Condition',
                    'condition',
                    selectedCondition,
                    (val) => setState(() => selectedCondition = val),
                  ),
                  const SizedBox(height: 24),
                  _buildImagePicker(),
                  const SizedBox(height: 30),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Add Product',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          shadowColor: Colors.black45,
                        ),
                        onPressed:
                            _imageBytes != null && _imageBytes!.isNotEmpty
                                ? _addProduct
                                : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: accentPurple),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accentPurple, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String collection,
    dynamic value,
    void Function(dynamic) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(collection).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text("Loading...");
          List<DropdownMenuItem> items = snapshot.data!.docs
              .map(
                (doc) => DropdownMenuItem(
                  value: doc['name'],
                  child: Text(
                    doc['name'],
                    style: TextStyle(color: darkPurple),
                  ),
                ),
              )
              .toList();
          return DropdownButton(
            items: items,
            onChanged: onChanged,
            value: value,
            isExpanded: true,
            hint: Text(label, style: TextStyle(color: Colors.grey[700])),
            underline: const SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: accentPurple),
            dropdownColor: offWhite,
          );
        },
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: _imageBytes != null && _imageBytes!.isNotEmpty
            ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _imageBytes!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        _imageBytes![index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              )
            : const Center(
                child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
              ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final pickedFiles = await picker.pickMultiImage(imageQuality: 50);
    if (pickedFiles != null) {
      List<Uint8List> bytesList = [];
      for (var file in pickedFiles) {
        Uint8List bytes = await file.readAsBytes();
        bytesList.add(bytes);
      }
      setState(() {
        _images = pickedFiles;
        _imageBytes = bytesList;
      });
    }
  }

  Future<List<String>> convertImagesToBase64(List<Uint8List> images) async {
    List<String> base64Images = [];
    for (Uint8List imageBytes in images) {
      String base64String = base64Encode(imageBytes);
      base64Images.add(base64String);
    }
    return base64Images;
  }

  Future<void> _addProduct() async {
    if (_images == null || _images!.isEmpty) return;

    List<String> base64Images = await convertImagesToBase64(_imageBytes!);
    await FirebaseFirestore.instance.collection('Products').add({
      'productName': textController1.text,
      'productPrice': int.parse(textController2.text),
      'productDetails': textController3.text,
      'graphicsCard': textController4.text,
      'ssd': textController5.text,
      'hdd': textController6.text,
      'ram': textController7.text,
      'generation': textController8.text,
      'processor': textController9.text,
      'category': selectedCurrency,
      'condition': selectedCondition,
      'images': base64Images,
    });

    // ✅ Clear all inputs and images after successful submission
    setState(() {
      textController1.clear();
      textController2.clear();
      textController3.clear();
      textController4.clear();
      textController5.clear();
      textController6.clear();
      textController7.clear();
      textController8.clear();
      textController9.clear();
      selectedCurrency = null;
      selectedCondition = null;
      _images = [];
      _imageBytes = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product added successfully with Base64 images!'),
      ),
    );
  }
}
