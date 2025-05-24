import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:laptop/profile.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Color darkPurple = const Color(0xFF4A148C);
  final Color lightPurple = const Color(0xFF9B59B6);

  bool _isLoading = false;

  String? oldPasswordError;
  String? newPasswordError;
  String? confirmPasswordError;

  Future<void> _changePassword() async {
    final user = _auth.currentUser;
    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    setState(() {
      oldPasswordError = null;
      newPasswordError = null;
      confirmPasswordError = null;
    });

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        if (oldPassword.isEmpty)
          oldPasswordError = 'Please enter your old password.';
        if (newPassword.isEmpty)
          newPasswordError = 'Please enter a new password.';
        if (confirmPassword.isEmpty)
          confirmPasswordError = 'Please confirm your new password.';
      });
      return;
    }

    if (newPassword.length < 8) {
      setState(() {
        newPasswordError = 'New password must be at least 8 characters.';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        confirmPasswordError = 'New password and confirmation do not match.';
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cred = EmailAuthProvider.credential(
        email: user!.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(cred);

      await user.updatePassword(newPassword);

      _showMessage('Your password has been updated.', success: true);

      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Profile()),
        );
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'wrong-password') {
          oldPasswordError = 'The old password you entered is incorrect.';
        } else {
          _showMessage('Something went wrong. Please try again.');
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer hata diya gaya hai, ab sirf back icon ayega
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: darkPurple,
        title: const Text('Change Password'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // back page par le jane ke liye
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: Color(0xFF6A1B9A),
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                'Old Password',
                oldPasswordController,
                oldPasswordError,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                'New Password',
                newPasswordController,
                newPasswordError,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                'Re-Enter New Password',
                confirmPasswordController,
                confirmPasswordError,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Update Password',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    String? errorText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: true,
          cursorColor: lightPurple,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Color(0xFF6A1B9A)),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF9B59B6)),
            ),
            prefixIcon: const Icon(Icons.lock, color: Color(0xFF6A1B9A)),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 8.0),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
