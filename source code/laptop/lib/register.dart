import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:laptop/login.dart';
import 'dart:ui';  // Import for BackdropFilter

void main() {
  runApp(const RegisterPage());
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  String _selectedGender = 'Male';
  String role = "user";

  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  String _nameError = '';
  String _emailError = '';
  String _passwordError = '';
  String _addressError = '';
  String _phoneNumberError = '';
  
  // For toggling password visibility
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image with Gradient Overlay
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/l3.png'), // Your background image path
                fit: BoxFit.cover,
              ),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Form Container with Blur and Dark Background
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                constraints: BoxConstraints(maxWidth: 450),
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6), // Dark background
                  borderRadius: BorderRadius.circular(30), // Rounded corners for the form
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Applying Blur effect on the form background using BackdropFilter
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Adjust blur intensity here
                        child: Container(
                          color: Colors.black.withOpacity(0.3), // Darken the blur background
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Create an Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Name TextField
                        _buildTextField(
                          controller: _nameController,
                          label: 'Name',
                          icon: Icons.person,
                          errorText: _nameError,
                        ),
                        const SizedBox(height: 20),

                        // Email TextField
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email,
                          errorText: _emailError,
                        ),
                        const SizedBox(height: 20),

                        // Password TextField with Eye Icon
                        _buildPasswordTextField(
                          controller: _passwordController,
                          label: 'Password',
                          errorText: _passwordError,
                        ),
                        const SizedBox(height: 20),

                        // Address TextField
                        _buildTextField(
                          controller: _addressController,
                          label: 'Address',
                          icon: Icons.location_on,
                          errorText: _addressError,
                        ),
                        const SizedBox(height: 20),

                        // Gender Selection
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
                            const Text('Male', style: TextStyle(color: Colors.white)),
                            Radio(
                              value: 'Female',
                              groupValue: _selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value.toString();
                                });
                              },
                            ),
                            const Text('Female', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Phone Number TextField
                        _buildTextField(
                          controller: _phoneNumberController,
                          label: 'Phone Number',
                          icon: Icons.phone,
                          errorText: _phoneNumberError,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 30),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9C27B0), // Accent Purple
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Login Page Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account?", style: TextStyle(color: Colors.white)),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginPage()),
                                );
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(color: Color(0xFF9C27B0)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable method to build text fields with custom styling and black text color
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black), // Black input text color
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        prefixIcon: Icon(icon, color: const Color(0xFF9C27B0)),
        errorText: (errorText != null && errorText.isNotEmpty) ? errorText : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners
          borderSide: BorderSide(color: const Color(0xFF9C27B0), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: const Color(0xFF9C27B0), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  // Password text field with toggleable visibility and black text color
  Widget _buildPasswordTextField({
    required TextEditingController controller,
    required String label,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      obscureText: !_isPasswordVisible, // Toggle the visibility
      style: const TextStyle(color: Colors.black), // Black input text color
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        prefixIcon: Icon(Icons.lock, color: const Color(0xFF9C27B0)),
        errorText: (errorText != null && errorText.isNotEmpty) ? errorText : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners
          borderSide: BorderSide(color: const Color(0xFF9C27B0), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: const Color(0xFF9C27B0), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFF9C27B0),
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible; // Toggle password visibility
            });
          },
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    setState(() {
      _nameError = '';
      _emailError = '';
      _passwordError = '';
      _addressError = '';
      _phoneNumberError = '';
    });

    if (_nameController.text.isEmpty || _nameController.text.length < 6) {
      setState(() => _nameError = 'Name must be at least 6 characters');
      return;
    }

    if (_emailController.text.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return;
    } else if (!RegExp(
            r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
        .hasMatch(_emailController.text)) {
      setState(() => _emailError = 'Enter a valid email address');
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      return;
    } else if (_passwordController.text.length < 8) {
      setState(() => _passwordError = 'Password must be at least 8 characters');
      return;
    }

    if (_addressController.text.isEmpty) {
      setState(() => _addressError = 'Address is required');
      return;
    }

    if (_phoneNumberController.text.isEmpty) {
      setState(() => _phoneNumberError = 'Phone number is required');
      return;
    } else if (!RegExp(r'^\d{11}$').hasMatch(_phoneNumberController.text)) {
      setState(() => _phoneNumberError = 'Enter a valid 11-digit phone number');
      return;
    }

    try {
      // Create Firebase user
      UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      user = credential.user;

      if (user != null) {
        // Add user details to Firestore
        await FirebaseFirestore.instance.collection('User').doc(user!.uid).set({
          'uid': user!.uid,
          'UserName': _nameController.text.trim(),
          'UserEmail': _emailController.text.trim(),
          'UserAddress': _addressController.text.trim(),
          'UserGender': _selectedGender,
          'UserNumber': _phoneNumberController.text.trim(),
          'role': role,
        });

        // Show SnackBar message on success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Thank you for signing up!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF9C27B0),
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate to login page after a short delay to show SnackBar
        await Future.delayed(const Duration(seconds: 3));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered.';
      } else if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}
