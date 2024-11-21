import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;

import '../providers/auth_provider.dart' as local_auth;
import 'home_screen.dart';
import 'signup.dart';

class LoginView extends StatefulWidget {
  final FirebaseAuth? auth;

  const LoginView({super.key, this.auth});

  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _passwordVisible = false;

  Future<void> _submit() async {
    // Controlla che il form sia valido
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Effettua il login
      await Provider.of<local_auth.AuthProvider>(context, listen: false)
          .login(emailController.text, passwordController.text);

      // Naviga alla HomeScreen in caso di successo
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Gestione errori di autenticazione
      String message = e.code == 'user-not-found' || e.code == 'wrong-password'
          ? 'Invalid email or password. Please try again.'
          : e.message ?? 'An error occurred. Please try again.';
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? CircularProgressIndicator()
              : Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Email Field
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Login Button
                ElevatedButton(
                  onPressed: _submit,
                  child: Text('Login'),
                ),
                SizedBox(height: 10),

                // Google Sign In Button
                SignInButton(
                  Theme.of(context).brightness == Brightness.dark
                      ? Buttons.GoogleDark
                      : Buttons.Google,
                  text: "Sign in with Google",
                  onPressed: () {
                    Provider.of<local_auth.AuthProvider>(context,
                        listen: false)
                        .signInWithGoogle();
                  },
                ),
                SizedBox(height: 10),

                // Navigate to Sign Up
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegistrationFlow()),
                    );
                  },
                  child: Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedTextField({
    required TextEditingController controller,
    required String label,
    FocusNode? focusNode,
    bool obscureText = false,
    String? errorText,
    Widget? suffixIcon,
    required Function(String) onChanged,
    bool enabled = true,
    Color? borderColor,
  }) {
    if (Platform.isIOS || Platform.isMacOS) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoTextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            enabled: enabled,
            placeholder: label,
            suffix: suffixIcon,
            onChanged: onChanged,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor ?? Colors.grey),
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                errorText,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? Colors.grey),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: label,
            errorText: errorText,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            suffixIcon: suffixIcon,
          ),
          onChanged: onChanged,
        ),
      );
    }
  }
}
