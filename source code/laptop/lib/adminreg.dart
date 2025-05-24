import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPagea extends StatefulWidget {
  const RegisterPagea({Key? key}) : super(key: key);

  @override
  State<RegisterPagea> createState() => _RegisterPageState();
}

// class UserModel {
//   String userName,
//       userEmail,
//       userGender,
//       userPhoneNumber,
//       userImage,
//       userAddress,
//       role;
//   UserModel(
//       {required this.userEmail,
//       required this.userImage,
//       required this.userAddress,
//       required this.userGender,
//       required this.userName,
//       required this.userPhoneNumber,
//       required this.role});
// }

class _RegisterPageState extends State<RegisterPagea> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  String _selectedGender = 'Male';
  String _selectedRole = 'admin'; // Default role
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  String _nameError = '';
  String _emailError = '';
  String _passwordError = '';
  String _addressError = '';
  String _phoneNumberError = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _nameController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'Enter Name',
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                ),
              ),
            ),
            Text(
              _nameError,
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _emailController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter Email',
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                ),
              ),
            ),
            Text(
              _emailError,
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _passwordController,
              textAlign: TextAlign.center,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter Password',
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                ),
              ),
            ),
            Text(
              _passwordError,
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _addressController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'Enter Address',
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                ),
              ),
            ),
            Text(
              _addressError,
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio(
                  value: 'Male',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value.toString();
                    });
                  },
                ),
                Text('Male'),
                Radio(
                  value: 'Female',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value.toString();
                    });
                  },
                ),
                Text('Female'),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio(
                  value: 'user',
                  groupValue: _selectedRole,
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value.toString();
                    });
                  },
                ),
                Text('User'),
                Radio(
                  value: 'admin',
                  groupValue: _selectedRole,
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value.toString();
                    });
                  },
                ),
                Text('Admin'),
              ],
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _phoneNumberController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Enter Phone Number',
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                ),
              ),
            ),
            Text(
              _phoneNumberError,
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Material(
                elevation: 5.0,
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(30.0),
                child: MaterialButton(
                  onPressed: () async {
                    setState(() {
                      // Clear previous error messages
                      _nameError = '';
                      _emailError = '';
                      _passwordError = '';
                      _addressError = '';
                      _phoneNumberError = '';
                    });

                    ///////////////////////////////////validation start/////////////////////////////////////
                    if (_nameController.text.isEmpty ||
                        _nameController.text.length < 6) {
                      setState(() {
                        _nameError = 'Name must be at least 6 characters';
                      });
                    }

                    if (_emailController.text.isEmpty) {
                      setState(() {
                        _emailError = 'Email is required';
                      });
                    } else if (!RegExp(
                            r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                        .hasMatch(_emailController.text)) {
                      setState(() {
                        _emailError = 'Enter a valid email address';
                      });
                    }

                    if (_passwordController.text.isEmpty) {
                      setState(() {
                        _passwordError = 'Password is required';
                      });
                    } else if (_passwordController.text.length < 8) {
                      setState(() {
                        _passwordError =
                            'Password must be at least 8 characters';
                      });
                    }

                    if (_addressController.text.isEmpty) {
                      setState(() {
                        _addressError = 'Address is required';
                      });
                    }

                    if (_phoneNumberController.text.isEmpty) {
                      setState(() {
                        _phoneNumberError = 'Phone number is required';
                      });
                    } else if (_phoneNumberController.text.length != 11) {
                      setState(() {
                        _phoneNumberError =
                            'Phone number must be 11 characters';
                      });
                    }

                    /////////////////////////////////////validation end/////////////////////////////////////////

                    if (_nameError.isEmpty &&
                        _emailError.isEmpty &&
                        _passwordError.isEmpty &&
                        _addressError.isEmpty &&
                        _phoneNumberError.isEmpty) {
                      try {
                        UserCredential userCredential =
                            await auth.createUserWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );

                        await FirebaseFirestore.instance
                            .collection("User")
                            .doc(userCredential.user?.uid)
                            .set({
                          "UserName": _nameController.text,
                          "UserId": userCredential.user?.uid,
                          "UserEmail": _emailController.text,
                          "UserAddress": _addressController.text,
                          "UserGender":
                              _selectedGender == 'Male' ? "Male" : "Female",
                          "UserNumber": _phoneNumberController.text,
                          "role": _selectedRole,
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Data added successfully!'),
                          ),
                        );

                        user = userCredential.user;
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          setState(() {
                            _passwordError = 'The password is too weak';
                          });
                        } else if (e.code == 'email-already-in-use') {
                          setState(() {
                            _emailError = 'Email is already in use';
                          });
                        }

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      } catch (e) {
                        print(e);
                      }
                    }
                  },
                  minWidth: 200.0,
                  height: 42.0,
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
