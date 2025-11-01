import 'package:flutter/material.dart';
import 'package:simple_chat_app/services/auth/auth_service.dart';
import 'package:simple_chat_app/components/my_button.dart';
import 'package:simple_chat_app/components/my_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordConttroller = TextEditingController();
  final TextEditingController _confirmPasswordConttroller =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordConttroller.dispose();
    _confirmPasswordConttroller.dispose();
    super.dispose();
  }

  void register(BuildContext context) async {
    final authService = AuthService();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordConttroller.text;
    final confirmPassword = _confirmPasswordConttroller.text;
    debugPrint('Register pressed: username=$username, email=$email');

    if (username.isEmpty) {
      debugPrint('Username is empty');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text("Username is required!")),
      );
      return;
    }

    // Check username uniqueness
    debugPrint('Checking username uniqueness...');
    final usernameQuery =
        await FirebaseFirestore.instance
            .collection('Users')
            .where('username', isEqualTo: username)
            .get();
    debugPrint('Username query docs: ${usernameQuery.docs.length}');
    if (usernameQuery.docs.isNotEmpty) {
      debugPrint('Username already taken');
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(title: Text("Username already taken!")),
      );
      return;
    }

    if (password == confirmPassword) {
      try {
        debugPrint('Attempting to register user...');
        await authService.signUpWithEmailPassword(
          email,
          password,
          username: username,
        );
        debugPrint('Registration successful');
        // Clear fields
        _emailController.clear();
        _usernameController.clear();
        _passwordConttroller.clear();
        _confirmPasswordConttroller.clear();
        // Show success dialog
        if (mounted) {
          await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text("Registration successful!"),
                  content: Text("You can now log in with your new account."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("OK"),
                    ),
                  ],
                ),
          );
          Navigator.of(context).pop();
        }
      } catch (e, stack) {
        debugPrint('Registration error: $e');
        debugPrint(stack.toString());
        showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text(e.toString())),
        );
      }
    } else {
      debugPrint('Passwords do not match');
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text("Passwords don't match!"),
              titlePadding: EdgeInsets.all(10),
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            Icon(
              Icons.message,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 50),

            // welcome back message
            Text(
              "Let's create an account for you!",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            // username textfield
            MyTextfield(
              hintText: "Username",
              obscureText: false,
              controller: _usernameController,
            ),

            const SizedBox(height: 10),

            // email textfield
            MyTextfield(
              hintText: "Email",
              obscureText: false,
              controller: _emailController,
            ),

            const SizedBox(height: 10),
            // pw textfield
            MyTextfield(
              hintText: "Password",
              obscureText: true,
              controller: _passwordConttroller,
            ),

            const SizedBox(height: 10),
            // pw textfield
            MyTextfield(
              hintText: "Confirm Password",
              obscureText: true,
              controller: _confirmPasswordConttroller,
            ),

            const SizedBox(height: 25),

            // login button
            MyButton(text: "Register", onTap: () => register(context)),

            const SizedBox(height: 25),

            // register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text(
                    "Login now",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
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
