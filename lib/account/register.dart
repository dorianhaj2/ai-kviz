import 'package:aikviz/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:aikviz/services/auth_service.dart';
import 'package:aikviz/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final regUsername = _usernameController.text.trim();
      if (email.isEmpty || password.isEmpty || regUsername.isEmpty) {
        setState(() {
          errorMessage = 'Please enter all fields';
        });
        throw Exception('Please enter all fields');
      }
      await authService.value.register(email: email, password: password);

      await DatabaseService().create(
        path: 'UserData',
        data: {
          'username': regUsername,
          'email': email,
          'quizzes': 0,
          'avg_score': 0.0,
          'total_correct': 0,
          'total_answers': 0,
          'admin': false,
        },
      );

      authService.value.signOut();
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        // Update the UI to show the error message
        errorMessage = e.message ?? 'An error occurred during login';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryTextColor = Colors.white;
    const secondaryTextColor = Color(0xffc4b5fd);
    const primaryButtonColor = Color(0xff6a2ae5);
    const textFieldBackgroundColor = Color(0xff271845);

    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Register',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create an account to start your quiz journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryTextColor, fontSize: 16),
                ),
                const SizedBox(height: 48),

                // Username Text Field
                TextField(
                  controller: _usernameController,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(color: primaryTextColor),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: const TextStyle(color: secondaryTextColor),
                    filled: true,
                    fillColor: textFieldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Email Text Field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: primaryTextColor),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: secondaryTextColor),
                    filled: true,
                    fillColor: textFieldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Text Field
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible, // Hide or show password
                  style: const TextStyle(color: primaryTextColor),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: secondaryTextColor),
                    filled: true,
                    fillColor: textFieldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: secondaryTextColor,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: secondaryTextColor,
                      ),
                      onPressed: () {
                        // Toggle the password's visibility
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(errorMessage, style: TextStyle(color: Colors.red)),
                const SizedBox(height: 32),

                // Register Button
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryButtonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18, color: primaryTextColor),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Back to ",
                      style: TextStyle(color: secondaryTextColor),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to the login screen
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: primaryButtonColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
