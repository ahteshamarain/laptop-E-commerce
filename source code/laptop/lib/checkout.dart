import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop/cart.dart';
import 'package:laptop/compare.dart';
import 'package:laptop/profile.dart';
import 'package:laptop/search.dart';
import 'package:laptop/userbottambar.dart';
import 'package:laptop/userdash.dart';
import 'package:laptop/wishlist.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _currentIndex = 5;
  final CollectionReference cart =
      FirebaseFirestore.instance.collection('cart');
  final CollectionReference products =
      FirebaseFirestore.instance.collection('Products');
  final CollectionReference users = FirebaseFirestore.instance.collection('Users');
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('Orders');

  FirebaseAuth auth = FirebaseAuth.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;

  late double totalPrice = 0.0;
  String selectedPaymentMethod = 'Cash on Delivery';
  String address = '';
  String name = '';
  String phoneNumber = '';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Controllers for bank transfer details
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();

  List<Map<String, String>> bankTransferCards = [];
  int? selectedBankCardIndex;

  @override
  void initState() {
    super.initState();
    calculateTotalPrice();
    _fetchUserDetails();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();
    super.dispose();
  }

  void clearBankForm() {
    bankNameController.clear();
    accountNumberController.clear();
    ifscController.clear();
  }

  void addOrUpdateBankCard() {
    String bankName = bankNameController.text.trim();
    String accountNumber = accountNumberController.text.trim();
    String ifsc = ifscController.text.trim();

    if (bankName.isEmpty || accountNumber.isEmpty || ifsc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all bank details')),
      );
      return;
    }

    if (accountNumber.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account Number must be exactly 11 digits')),
      );
      return;
    }

    if (ifsc.length != 3 || !RegExp(r'^\d{3}$').hasMatch(ifsc)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('IFSC Code must be exactly 3 digits')),
      );
      return;
    }

    setState(() {
      if (selectedBankCardIndex == null) {
        // Add new
        bankTransferCards.add({
          'bankName': bankName,
          'accountNumber': accountNumber,
          'ifsc': ifsc,
        });
        selectedBankCardIndex = bankTransferCards.length - 1;
      } else {
        // Update existing
        bankTransferCards[selectedBankCardIndex!] = {
          'bankName': bankName,
          'accountNumber': accountNumber,
          'ifsc': ifsc,
        };
      }
      clearBankForm();
      selectedBankCardIndex = null;
    });
  }

  void editBankCard(int index) {
    setState(() {
      selectedBankCardIndex = index;
      bankNameController.text = bankTransferCards[index]['bankName'] ?? '';
      accountNumberController.text = bankTransferCards[index]['accountNumber'] ?? '';
      ifscController.text = bankTransferCards[index]['ifsc'] ?? '';
    });
  }

  void deleteBankCard(int index) {
    setState(() {
      if (selectedBankCardIndex != null && selectedBankCardIndex == index) {
        selectedBankCardIndex = null;
        clearBankForm();
      }
      bankTransferCards.removeAt(index);
      if (bankTransferCards.isEmpty) {
        selectedBankCardIndex = null;
      } else if (selectedBankCardIndex != null && selectedBankCardIndex! > index) {
        selectedBankCardIndex = selectedBankCardIndex! - 1;
      }
    });
  }

  String? validatePhoneNumber(String value) {
    if (value.length != 11) {
      return 'Phone number must be exactly 11 digits';
    }
    if (!RegExp(r'^\d{11}$').hasMatch(value)) {
      return 'Phone number must contain only digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background for entire page
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A148C),
        elevation: 4,
        centerTitle: true,
        title: const Text(
          'Checkout',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Cart items with fixed height and scroll
              SizedBox(
                height: 300,
                child: StreamBuilder(
                  stream: cart.where('uid', isEqualTo: currentUser?.uid).snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                    if (streamSnapshot.hasData) {
                      if (streamSnapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text(
                          "Your cart is empty.",
                          style: TextStyle(color: Colors.black),
                        ));
                      }
                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: streamSnapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final DocumentSnapshot documentSnapshot =
                              streamSnapshot.data!.docs[index];

                          return FutureBuilder<DocumentSnapshot>(
                            future: products.doc(documentSnapshot['pid']).get(),
                            builder: (context, productSnapshot) {
                              if (productSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (productSnapshot.hasError) {
                                return Text('Error: ${productSnapshot.error}',
                                    style:
                                        const TextStyle(color: Colors.black));
                              }
                              if (!productSnapshot.hasData ||
                                  !productSnapshot.data!.exists) {
                                return const Text('Product not found',
                                    style:
                                        TextStyle(color: Colors.black));
                              }

                              final productData = productSnapshot.data!;
                              return Card(
                                margin: const EdgeInsets.all(10),
                                color: Colors.white,
                                elevation: 6,
                                shadowColor: Colors.grey.shade400,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Colors.grey.shade300, width: 1)
                                ),
                                child: ListTile(
                                  leading: Image.memory(
                                    base64Decode(productData['images'][0]),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text(
                                    productData['productName'],
                                    style: const TextStyle(
                                        color: Colors.black), // Black text
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Quantity: ${documentSnapshot['qty']}",
                                        style: const TextStyle(
                                            color: Colors.black), // Black text
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    "Total: \$${(documentSnapshot['fprice'] as num).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        color: Colors.black), // Black text
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              // User details form
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
              ),
              const SizedBox(height: 15),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 11,
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  if (value.length <= 11) {
                    setState(() {
                      phoneNumber = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 15),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  setState(() {
                    address = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              // Payment method options
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title:
                          const Text('Cash on Delivery', style: TextStyle(color: Colors.black)),
                      value: 'Cash on Delivery',
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value!;
                          selectedBankCardIndex = null; // reset bank card selection if switching payment
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title:
                          const Text('Bank Transfer', style: TextStyle(color: Colors.black)),
                      value: 'Bank Transfer',
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Show bank transfer card form and list only if Bank Transfer selected
              if (selectedPaymentMethod == 'Bank Transfer') ...[
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 3))
                      ]),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      TextField(
                        controller: bankNameController,
                        decoration: const InputDecoration(
                          labelText: 'Bank Name',
                          border: OutlineInputBorder(),
                        ),
                        style:
                            const TextStyle(color: Colors.black), // input text color black
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: accountNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Account Number',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                        maxLength: 11,
                        keyboardType: TextInputType.number,
                        style:
                            const TextStyle(color: Colors.black), // input text color black
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: ifscController,
                        decoration: const InputDecoration(
                          labelText: 'IFSC Code',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                        maxLength: 3,
                        keyboardType: TextInputType.number,
                        style:
                            const TextStyle(color: Colors.black), // input text color black
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: addOrUpdateBankCard,
                            child: Text(selectedBankCardIndex == null ? 'Add' : 'Update'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A148C),
                              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (selectedBankCardIndex != null)
                            ElevatedButton(
                              onPressed: () {
                                clearBankForm();
                                setState(() {
                                  selectedBankCardIndex = null;
                                });
                              },
                              child: const Text('Cancel'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Display added bank transfer cards
                if (bankTransferCards.isNotEmpty)
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: bankTransferCards.length,
                    itemBuilder: (context, index) {
                      final card = bankTransferCards[index];
                      bool isSelected = selectedBankCardIndex == index;
                      return Card(
                        color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text('${card['bankName']} - ${card['accountNumber']}',
                              style: const TextStyle(color: Colors.black)),
                          subtitle:
                              Text('IFSC: ${card['ifsc']}', style: const TextStyle(color: Colors.black54)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFF4A148C)),
                                onPressed: () => editBankCard(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteBankCard(index),
                              ),
                              Radio<int>(
                                value: index,
                                groupValue: selectedBankCardIndex,
                                onChanged: (int? value) {
                                  setState(() {
                                    selectedBankCardIndex = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              selectedBankCardIndex = index;
                            });
                          },
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),
              ],

              // Order summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  Text('\$${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.black)),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Shipping Fee:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  Text('\$125.00', style: TextStyle(color: Colors.black)),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Tax Fee:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  Text('\$26.00', style: TextStyle(color: Colors.black)),
                ],
              ),
              const Divider(height: 25, thickness: 2, color: Colors.grey),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Order Total:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                  Text(
                    '\$${(totalPrice + 125 + 26).toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: (address.trim().isEmpty ||
                        name.trim().isEmpty ||
                        phoneNumber.trim().isEmpty ||
                        phoneNumber.length != 11 ||
                        (selectedPaymentMethod == 'Bank Transfer' && selectedBankCardIndex == null))
                    ? null
                    : () async {
                        await placeOrder();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Your order has been placed successfully!')),
                        );
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => HomePage()),
                            (route) => false);
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  backgroundColor: (address.trim().isEmpty ||
                          name.trim().isEmpty ||
                          phoneNumber.trim().isEmpty ||
                          phoneNumber.length != 11 ||
                          (selectedPaymentMethod == 'Bank Transfer' && selectedBankCardIndex == null))
                      ? Colors.grey
                      : const Color(0xFF4A148C),
                ),
                child: const Text('Place Order', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: UserBottomAppBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            switch (index) {
              case 0:
                Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
                break;
              case 1:
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProductsearchPage()));
                break;
              case 2:
                Navigator.push(context, MaterialPageRoute(builder: (_) => Compare()));
                break;
              case 3:
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListwish()));
                break;
              case 4:
                Navigator.push(context, MaterialPageRoute(builder: (_) => Profile()));
                break;
            }
          },
        ),
      ),
    );
  }

  Future<void> placeOrder() async {
    if (currentUser == null) return;

    // Prepare payment details map
    Map<String, dynamic> paymentDetails = {};
    if (selectedPaymentMethod == 'Bank Transfer') {
      if (selectedBankCardIndex != null) {
        paymentDetails = bankTransferCards[selectedBankCardIndex!];
      }
    }

    Map<String, dynamic> orderData = {
      'userId': currentUser!.uid,
      'userName': name,
      'userPhone': phoneNumber,
      'totalPrice': totalPrice + 125 + 26,
      'paymentMethod': selectedPaymentMethod,
      'paymentDetails': paymentDetails,
      'address': address,
      'orderStatus': 'pending',
      'orderDate': Timestamp.now(),
    };

    try {
      DocumentReference orderRef = await orders.add(orderData);

      QuerySnapshot cartSnapshot =
          await cart.where('uid', isEqualTo: currentUser!.uid).get();

      for (var cartItem in cartSnapshot.docs) {
        String pid = cartItem['pid'];

        DocumentSnapshot productSnapshot = await products.doc(pid).get();
        if (!productSnapshot.exists) continue;

        Map<String, dynamic> productData =
            Map<String, dynamic>.from(productSnapshot.data() as Map);
        productData['qty'] = cartItem['qty'];
        productData['fprice'] = cartItem['fprice'];
        productData['reviewStatus'] = 'pending';

        await orderRef.collection('Products').doc(pid).set(productData);
      }

      for (var cartItem in cartSnapshot.docs) {
        await cart.doc(cartItem.id).delete();
      }
    } catch (e) {
      print('Error placing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    }
  }

  Future<void> calculateTotalPrice() async {
    if (currentUser == null) return;

    double total = 0.0;
    QuerySnapshot cartSnapshot =
        await cart.where('uid', isEqualTo: currentUser!.uid).get();

    for (var doc in cartSnapshot.docs) {
      total += (doc['fprice'] as num).toDouble();
    }
    setState(() {
      totalPrice = total;
    });
  }

  Future<void> _fetchUserDetails() async {
    if (currentUser == null) return;
    DocumentSnapshot userSnapshot = await users.doc(currentUser!.uid).get();

    if (userSnapshot.exists) {
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;
      if (userData != null) {
        if (userData['UserAddress'] != null) {
          address = userData['UserAddress'];
          addressController.text = address;
        }
        if (userData['UserName'] != null) {
          name = userData['UserName'];
          nameController.text = name;
        }
        if (userData['UserPhone'] != null) {
          phoneNumber = userData['UserPhone'];
          phoneController.text = phoneNumber;
        }
        if (userData['PreferredPaymentMethod'] != null) {
          selectedPaymentMethod = userData['PreferredPaymentMethod'];
          if (selectedPaymentMethod == 'Bank Transfer' &&
              userData['BankTransferCards'] != null) {
            List<dynamic> cards = userData['BankTransferCards'];
            bankTransferCards = cards.map((e) => Map<String, String>.from(e)).toList();
            if (bankTransferCards.isNotEmpty) selectedBankCardIndex = 0;
          }
        }
        setState(() {});
      }
    }
  }
}