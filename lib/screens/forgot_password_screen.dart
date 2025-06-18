import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isEmailValid = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    setState(() {
      _isEmailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
    });
  }

  void _resetPassword() {
    if (_isEmailValid) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reset password instructions sent to your email'),
          backgroundColor: Color(0xFF00704A),
        ),
      );
      
      // Navigate back after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Forgot Password heading
            const Text(
              'Forgot Password',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00704A),
              ),
            ),
            const SizedBox(height: 16),
            
            // Instruction text
            const Text(
              'Masuk Email anda dan kami akan mengirim instruksi!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // Email field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: _validateEmail,
              decoration: InputDecoration(
                hintText: 'Email Address',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Reset Password button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00704A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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