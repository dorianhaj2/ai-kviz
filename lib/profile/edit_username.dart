import 'package:aikviz/constants.dart';
import 'package:aikviz/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditUsernameScreen extends StatefulWidget {
  final VoidCallback onUsernameUpdated;

  const EditUsernameScreen({Key? key, required this.onUsernameUpdated})
    : super(key: key);

  @override
  _EditUsernameScreenState createState() => _EditUsernameScreenState();
}

class _EditUsernameScreenState extends State<EditUsernameScreen> {
  // Controllers to retrieve the text from the fields
  final _newUsernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String errorMessage = '';

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _newUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateUsername() async {
    try {
      final newUsername = _newUsernameController.text.trim();

      if (newUsername.isEmpty) {
        setState(() {
          errorMessage = 'Please enter a username';
        });
        return;
      }
      await DatabaseService().update(
        path: 'UserData',
        id: userId,
        data: {'username': newUsername},
      );

      username = newUsername; // Update the global username variable

      widget.onUsernameUpdated();
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
                  'Enter New Username',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 48),

                // Email Text Field
                TextField(
                  controller: _newUsernameController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: primaryTextColor),
                  decoration: InputDecoration(
                    labelText: 'New Username',
                    labelStyle: const TextStyle(color: secondaryTextColor),
                    filled: true,
                    fillColor: textFieldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: secondaryTextColor,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Text(errorMessage, style: TextStyle(color: Colors.red)),
                const SizedBox(height: 32),

                // Login Button
                ElevatedButton(
                  onPressed: _updateUsername,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryButtonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontSize: 18, color: primaryTextColor),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
