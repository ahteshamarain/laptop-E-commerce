import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:laptop/bottambar.dart';
import 'package:laptop/compare.dart';
import 'package:laptop/drawer.dart';
import 'package:laptop/product_detail_page.dart';
import 'package:laptop/cart.dart';
import 'package:laptop/profile.dart';
import 'package:laptop/search.dart';
import 'package:laptop/userbottambar.dart';
import 'package:laptop/wishlist.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  int _currentIndex = 0; // <-- For bottom navigation
  int currentPage = 0;
  int totalCount = 0;
  int _currentPaginationPage = 0;
  final int _productsPerPage = 12;
  int _totalPages = 1;
  Map<String, bool> wishlistStatus = {};
  String? _sortOption = 'Alphabetical A-Z';
  String? selectedCategory;
  String? selectedCondition;
  double selectedPriceMin = 10;
  double selectedPriceMax = 1000;

  @override
  void initState() {
    super.initState();
    updateCartCount();
  }

  void updateCartCount() async {
    final cartCollection = FirebaseFirestore.instance.collection('cart');
    final userCart = await cartCollection.where('uid', isEqualTo: currentUser?.uid).get();
    setState(() {
      totalCount = userCart.size;
    });
  }

  void openFilterDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FilterDrawer(
          selectedCategory: selectedCategory,
          selectedCondition: selectedCondition,
          selectedPriceMin: selectedPriceMin,
          selectedPriceMax: selectedPriceMax,
          onApply: (category, condition, priceMin, priceMax) {
            setState(() {
              selectedCategory = category;
              selectedCondition = condition;
              selectedPriceMin = priceMin;
              selectedPriceMax = priceMax;
              _currentPaginationPage = 0;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white, // White background
      drawer: MyDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A148C),
        elevation: 4,
        centerTitle: true,
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.white, // White on purple appbar
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
      body: Column(
        children: [
          const SizedBox(height: kToolbarHeight + 24),
          CarouselSlider(
            options: CarouselOptions(
              height: 180,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 1.0,
            ),
            items: ['assets/s1.jpg', 'assets/s2.jpg', 'assets/s3.png']
                .map(
                  (imagePath) => ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                        onPressed: _currentPaginationPage > 0
                            ? () {
                                setState(() {
                                  _currentPaginationPage--;
                                });
                              }
                            : null,
                      ),
                      InkWell(
                        onTap: openFilterDrawer,
                        child: Row(
                          children: const [
                            Icon(Icons.filter_list, color: Colors.black, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Filter',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          iconEnabledColor: Colors.black,
                          value: _sortOption,
                          borderRadius: BorderRadius.circular(12),
                          items: [
                            'Alphabetical A-Z',
                            'Alphabetical Z-A',
                            'Price Low to High',
                            'Price High to Low',
                          ].map((option) {
                            return DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _sortOption = value;
                              _currentPaginationPage = 0;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            if (_currentPaginationPage < _totalPages - 1) _currentPaginationPage++;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Products').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                List<DocumentSnapshot> docs = snapshot.data!.docs;

                List<DocumentSnapshot> filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>? ?? {};
                  if (selectedCategory != null && selectedCategory!.isNotEmpty) {
                    if (!(data['category'] == selectedCategory)) return false;
                  }
                  if (selectedCondition != null && selectedCondition!.isNotEmpty) {
                    if (!(data['condition'] == selectedCondition)) return false;
                  }
                  final price = (data['productPrice'] as num?)?.toDouble() ?? 0;
                  if (price < selectedPriceMin || price > selectedPriceMax) return false;
                  return true;
                }).toList();

                if (_sortOption == 'Alphabetical A-Z') {
                  filteredDocs.sort((a, b) {
                    return (a['productName'] ?? '').toString().compareTo((b['productName'] ?? '').toString());
                  });
                } else if (_sortOption == 'Alphabetical Z-A') {
                  filteredDocs.sort((a, b) {
                    return (b['productName'] ?? '').toString().compareTo((a['productName'] ?? '').toString());
                  });
                } else if (_sortOption == 'Price Low to High') {
                  filteredDocs.sort((a, b) {
                    return ((a['productPrice'] ?? 0) as num).compareTo((b['productPrice'] ?? 0) as num);
                  });
                } else if (_sortOption == 'Price High to Low') {
                  filteredDocs.sort((a, b) {
                    return ((b['productPrice'] ?? 0) as num).compareTo((a['productPrice'] ?? 0) as num);
                  });
                }

                _totalPages = (filteredDocs.length / _productsPerPage).ceil();

                int startIndex = _currentPaginationPage * _productsPerPage;
                int endIndex = startIndex + _productsPerPage;
                if (endIndex > filteredDocs.length) endIndex = filteredDocs.length;
                final paginatedDocs = filteredDocs.sublist(startIndex, endIndex);

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: paginatedDocs.length,
                  itemBuilder: (context, index) {
                    final doc = paginatedDocs[index];
                    final productId = doc.id;
                    wishlistStatus.putIfAbsent(productId, () => false);
                    final data = doc.data() as Map<String, dynamic>? ?? {};

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductPage(productId: productId),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24), // Added border radius here
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24), // Added border radius here
                              border: Border.all(color: Colors.white24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2), // Shadow color
                                  offset: const Offset(0, 4), // Shadow position
                                  blurRadius: 8, // Shadow blur
                                  spreadRadius: 1, // Shadow spread
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(24), // Match border radius here
                                  ),
                                  child: (data['images'] != null && (data['images'] as List).isNotEmpty)
                                      ? Image.memory(
                                          base64Decode(data['images'][0]),
                                          height: 160,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : const SizedBox(
                                          height: 160,
                                          child: Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                  child: Column(
                                    children: [
                                      Text(
                                        data['productName'] ?? '',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '\$${data['productPrice'] ?? ''}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        data['productDetails'] ?? '',
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.favorite,
                                          color: wishlistStatus[productId]! ? Colors.red : Colors.black,
                                        ),
                                        onPressed: () async {
                                          setState(() {
                                            wishlistStatus[productId] = !wishlistStatus[productId]!;
                                          });
                                          wishlistStatus[productId]!
                                              ? await addToWishlist(doc)
                                              : await removeFromWishlist(productId);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_shopping_cart,
                                          color: Colors.black,
                                        ),
                                        onPressed: () => addToCart(doc),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
      bottomNavigationBar: UserBottomAppBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsearchPage()));
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const Compare()));
              break;
            case 3:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListwish()));
              break;
            case 4:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const Profile()));
              break;
          }
        },
      ),
    );
  }

  Future<void> addToCart(DocumentSnapshot doc) async {
    final colref = FirebaseFirestore.instance.collection('cart');
    final existingDocs =
        await colref.where('pid', isEqualTo: doc.id).where('uid', isEqualTo: currentUser?.uid).get();

    if (existingDocs.docs.isNotEmpty) {
      final ref = existingDocs.docs.first.reference;
      int currentQty = existingDocs.docs.first['qty'] ?? 0;
      await ref.update({
        'qty': currentQty + 1,
        'fprice': (currentQty + 1) * (doc.data() as Map<String, dynamic>)['productPrice'],
      });
    } else {
      await colref.add({
        'pid': doc.id,
        'iniprice': (doc.data() as Map<String, dynamic>)['productPrice'],
        'qty': 1,
        'fprice': (doc.data() as Map<String, dynamic>)['productPrice'],
        'uid': currentUser?.uid,
        'image': (doc.data() as Map<String, dynamic>)['images'][0],
      });
    }

    updateCartCount();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added to cart')));
  }

  Future<void> addToWishlist(DocumentSnapshot product) async {
    final wishlist = FirebaseFirestore.instance.collection('wishlist');
    final existing =
        await wishlist.where('userId', isEqualTo: currentUser?.uid).where('productId', isEqualTo: product.id).get();

    if (existing.docs.isEmpty) {
      final data = product.data() as Map<String, dynamic>;
      await wishlist.add({
        'productName': data['productName'],
        'productPrice': data['productPrice'],
        'productDetails': data['productDetails'],
        'userId': currentUser?.uid,
        'productId': product.id,
        'image': data['images'][0],
      });
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    final wishlist = FirebaseFirestore.instance.collection('wishlist');
    final snapshot =
        await wishlist.where('userId', isEqualTo: currentUser?.uid).where('productId', isEqualTo: productId).get();

    for (final doc in snapshot.docs) {
      await wishlist.doc(doc.id).delete();
    }
  }
}

class FilterDrawer extends StatefulWidget {
  final String? selectedCategory;
  final String? selectedCondition;
  final double selectedPriceMin;
  final double selectedPriceMax;
  final Function(String?, String?, double, double) onApply;

  const FilterDrawer({
    Key? key,
    required this.onApply,
    this.selectedCategory,
    this.selectedCondition,
    required this.selectedPriceMin,
    required this.selectedPriceMax,
  }) : super(key: key);

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  String? _selectedCategory;
  String? _selectedCondition;
  late double _minPrice;
  late double _maxPrice;

  final double _fixedMinPrice = 10;
  final double _fixedMaxPrice = 1000;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _selectedCondition = widget.selectedCondition;
    _minPrice = widget.selectedPriceMin.clamp(_fixedMinPrice, _fixedMaxPrice);
    _maxPrice = widget.selectedPriceMax.clamp(_fixedMinPrice, _fixedMaxPrice);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 20),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  BoxDecoration _chipDecoration(bool selected) {
    if (selected) {
      return BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.6),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      );
    } else {
      return BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(24),
      );
    }
  }

  Widget _buildChoiceChip(
    String label,
    bool selected,
    VoidCallback onSelected,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      decoration: _chipDecoration(selected),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onSelected,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.8;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -4),
            blurRadius: 14,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const Text(
              'Filter Products',
              style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            _buildSectionTitle('Select Category'),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('categ').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                final categories = snapshot.data!.docs;
                if (categories.isEmpty) {
                  return const Text(
                    'No categories available',
                    style: TextStyle(color: Colors.black54),
                  );
                }
                return Wrap(
                  children: categories.map<Widget>((doc) {
                    final categoryName = doc['name'] ?? '';
                    final selected = _selectedCategory == categoryName;
                    return _buildChoiceChip(categoryName, selected, () {
                      setState(() {
                        _selectedCategory = selected ? null : categoryName;
                      });
                    });
                  }).toList(),
                );
              },
            ),
            _buildSectionTitle('Select Condition'),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('condition').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                final conditions = snapshot.data!.docs;
                if (conditions.isEmpty) {
                  return const Text(
                    'No conditions available',
                    style: TextStyle(color: Colors.black54),
                  );
                }
                return Wrap(
                  children: conditions.map<Widget>((doc) {
                    final conditionName = doc['name'] ?? '';
                    final selected = _selectedCondition == conditionName;
                    return _buildChoiceChip(conditionName, selected, () {
                      setState(() {
                        _selectedCondition = selected ? null : conditionName;
                      });
                    });
                  }).toList(),
                );
              },
            ),
            _buildSectionTitle('Price Range'),
            RangeSlider(
              values: RangeValues(_minPrice, _maxPrice),
              min: _fixedMinPrice,
              max: _fixedMaxPrice,
              divisions: (_fixedMaxPrice - _fixedMinPrice).toInt(),
              labels: RangeLabels(
                '\$${_minPrice.round()}',
                '\$${_maxPrice.round()}',
              ),
              activeColor: Colors.purpleAccent,
              inactiveColor: Colors.black26,
              onChanged: (values) {
                setState(() {
                  _minPrice = values.start.roundToDouble();
                  _maxPrice = values.end.roundToDouble();
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purpleAccent,
                      side: const BorderSide(
                        color: Colors.purpleAccent,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                        _selectedCondition = null;
                        _minPrice = _fixedMinPrice;
                        _maxPrice = _fixedMaxPrice;
                      });
                    },
                    child: const Text(
                      'Clear Filters',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      shadowColor: Colors.purpleAccent.withOpacity(0.7),
                    ),
                    onPressed: () {
                      widget.onApply(
                        _selectedCategory,
                        _selectedCondition,
                        _minPrice,
                        _maxPrice,
                      );
                    },
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}