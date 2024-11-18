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
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _emailValid = true;
  bool _passwordValid = true;
  bool _passwordVisible = false;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        setState(() {
          _emailValid = emailController.text.isNotEmpty &&
              RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text);
        });
      }
    });

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        setState(() {
          _passwordValid = passwordController.text.length >= 6;
        });
      }
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        await Provider.of<local_auth.AuthProvider>(context, listen: false)
            .login(emailController.text, passwordController.text);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } on FirebaseAuthException catch (e) {
        String message =
            e.code == 'user-not-found' || e.code == 'wrong-password'
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
  }

  Future<void> _signInWithGoogle() async {
    await Provider.of<local_auth.AuthProvider>(context, listen: false)
        .signInWithGoogle();
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
          child: Column(
            mainAxisAlignment:
                isLoading ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              if (!isLoading)
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email
                      _buildRoundedTextField(
                        controller: emailController,
                        focusNode: _emailFocusNode,
                        label: 'Email',
                        errorText: !_emailValid ? 'Invalid email format' : null,
                        onChanged: (value) {
                          setState(() {
                            _emailValid = value.isNotEmpty &&
                                RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
                          });
                        },
                        borderColor: emailController.text.isEmpty
                            ? Colors.grey // Neutral color when empty
                            : _emailValid
                                ? Colors.green
                                : Colors.red,
                      ),
                      SizedBox(height: 10),

                      // Password
                      _buildRoundedTextField(
                        controller: passwordController,
                        focusNode: _passwordFocusNode,
                        label: 'Password',
                        errorText: !_passwordValid
                            ? 'Password must be at least 6 characters'
                            : null,
                        obscureText: !_passwordVisible,
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
                        onChanged: (value) {
                          setState(() {
                            _passwordValid = value.length >= 6;
                          });
                        },
                        borderColor: passwordController.text.isEmpty
                            ? Colors.grey // Neutral color when empty
                            : _passwordValid
                                ? Colors.green
                                : Colors.red,
                      ),
                      SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: _submit,
                        child: Text('Login'),
                      ),
                      SizedBox(height: 10),

                      SignInButton(
                        Theme.of(context).brightness == Brightness.dark ? Buttons.GoogleDark : Buttons.Google,
                        onPressed: _signInWithGoogle,
                      ),
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
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
            ],
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
