import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marapp/providers/auth_provider.dart' as auth;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _errorMessage;

  // Funzione per effettuare il login
  Future<void> _login() async {
    final authProvider = Provider.of<auth.AuthProvider>(context, listen: false);

    try {
      // Effettua il login con Firebase
      await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );

      // Se il login è andato a buon fine, reindirizza alla home
      if (authProvider.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRoundedTextFormField(
                controller: _emailController,
                label: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _errorMessage = null;
                  });
                },
              ),
              _buildRoundedTextFormField(
                controller: _passwordController,
                label: 'Password',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _errorMessage = null;
                  });
                },
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _login();
                  }
                },
                child: Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
                child: Text(
                  "Don't have an account? Register",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedTextFormField({
    required TextEditingController controller,
    required String label,
    FocusNode? focusNode,
    bool obscureText = false,
    String? errorText,
    Widget? suffixIcon,
    required Function(String) onChanged,
    bool enabled = true,
    Color? borderColor,
    String? Function(String?)? validator,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    if (Platform.isIOS || Platform.isMacOS) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoTextFormFieldRow(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            enabled: enabled,
            placeholder: label,
            validator: validator,
            onChanged: onChanged,
            style: TextStyle(color: textColor),
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
        child: TextFormField(
          controller: controller,
          validator: validator,
          focusNode: focusNode,
          obscureText: obscureText,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: label,
            errorText: errorText,
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            suffixIcon: suffixIcon,
          ),
          style: TextStyle(color: textColor),
          onChanged: onChanged,
        ),
      );
    }
  }
}
