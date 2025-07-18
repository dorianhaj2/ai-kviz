import 'package:aikviz/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers to retrieve the text from the fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String errorMessage = '';

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      if (email.isEmpty || password.isEmpty) {
        setState(() {
          errorMessage = 'Please enter both email and password';
        });
        return;
      }
      await authService.value.signIn(email: email, password: password);

      setState(() {
        Navigator.pop(context);
        currentScreenIndex = 0;
      });
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
      appBar: AppBar(
        backgroundColor: primaryBackgroundColor,
        foregroundColor: primaryTextColor,
      ),
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
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Log in to continue your quiz journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryTextColor, fontSize: 16),
                ),
                const SizedBox(height: 48),

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

                // Login Button
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryButtonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(fontSize: 18, color: primaryTextColor),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: secondaryTextColor),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const RegisterScreen();
                            },
                          ),
                        );
                      },
                      child: const Text(
                        'Sign Up',
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
