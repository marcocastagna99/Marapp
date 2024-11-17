import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login.dart';

class RegistrationFlow extends StatefulWidget {
  const RegistrationFlow({super.key});

  @override
  State<RegistrationFlow> createState() => _RegistrationFlowState();
}

class _RegistrationFlowState extends State<RegistrationFlow> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String name = '';
  String email = '';
  String phoneNumber = '';
  String address = '';
  String password = '';
  String confirmPassword = '';

  bool _emailValid = true;
  bool _passwordValid = true;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _showConfirmPassword = false;
  bool _passwordsMatch = true;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        setState(() {
          _emailValid =
              RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text);
        });
      }
    });

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        setState(() {
          _passwordValid = _passwordController.text.length >= 6;
          _showConfirmPassword = _passwordController.text.isNotEmpty;
        });
      }
    });
  }

  void _skipToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Signup")),
      body: authProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Name
                  _buildRoundedTextField(
                    controller: _nameController,
                    label: 'Name',
                    onChanged: (value) => name = value,
                  ),
                  SizedBox(height: 10),

                  // Email
                  _buildRoundedTextField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    label: 'Email',
                    errorText: !_emailValid ? 'Email format error' : null,
                    onChanged: (value) {
                      setState(() {
                        email = value;
                        _emailValid =
                            RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
                      });
                    },
                    borderColor: _emailController.text.isEmpty
                        ? Colors.grey // Neutral color when empty
                        : _emailValid
                            ? Colors.green // Change to green if valid
                            : Colors.red, // Change to red if invalid
                  ),
                  SizedBox(height: 10),

                  // Password
                  _buildRoundedTextField(
                    controller: _passwordController,
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
                        password = value;
                        _passwordValid = password.length >= 6;
                        _showConfirmPassword = password.isNotEmpty;
                        _checkPasswordMatch();
                      });
                    },
                    borderColor: _passwordController.text.isEmpty
                        ? Colors.grey // Neutral color when empty
                        : _passwordsMatch
                            ? Colors.green // Change to green if valid
                            : Colors.red, // Change to red if invalid
                  ),
                  SizedBox(height: 10),

                  // Confirm Password
                  if (_showConfirmPassword)
                    _buildRoundedTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      errorText:
                          !_passwordsMatch ? 'Passwords do not match' : null,
                      obscureText: !_confirmPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _confirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _confirmPasswordVisible = !_confirmPasswordVisible;
                          });
                        },
                      ),
                      onChanged: (value) {
                        setState(() {
                          confirmPassword = value;
                          _checkPasswordMatch();
                        });
                      },
                      borderColor: _passwordsMatch
                          ? Colors.green
                          : null, // Same for confirm password field
                    ),
                  if (_showConfirmPassword) SizedBox(height: 10),

                  // Phone Number
                  _buildRoundedTextField(
                    controller: _phoneNumberController,
                    label: 'Phone Number',
                    onChanged: (value) => phoneNumber = value,
                  ),
                  SizedBox(height: 10),

                  // Address
                  _buildRoundedTextField(
                    controller: _addressController,
                    label: 'Address',
                    onChanged: (value) => address = value,
                  ),
                  SizedBox(height: 10),

                  // Complete Registration Button
                  ElevatedButton(
                    onPressed: _completeRegistration,
                    child: Text('Create an account'),
                  ),
                  SizedBox(height: 10),

                  // "Or" TextField
                  Center(
                    child: Text(
                      'or',
                    ),
                  ),
                  SizedBox(height: 5),

                  // Back to Login / Sign up with Google
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SignInButton(
                        Theme.of(context).brightness == Brightness.dark
                            ? Buttons.GoogleDark
                            : Buttons.Google,
                        text: "Sign up with Google",
                        onPressed: () {
                          Provider.of<AuthProvider>(context, listen: false)
                              .signInWithGoogle();
                        },
                      ),
                      SizedBox(
                          height: 10), // Add some space between the buttons
                      TextButton(
                        onPressed: _skipToLogin,
                        child: Text('Already have an account? Login'),
                      ),
                    ],
                  ),
                ],
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: borderColor ?? Colors.grey), // Dynamic border color
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
          contentPadding: EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0), // Reduced padding for shorter height
          suffixIcon: suffixIcon,
        ),
        onChanged: onChanged,
      ),
    );
  }

  void _checkPasswordMatch() {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  void _completeRegistration() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text;
    final password = _passwordController.text;

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email format error')),
      );
      return;
    }

    if (password.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('The password must be at least 6 characters long')),
      );
      return;
    }

    if (password != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final success = await authProvider.signUp(
        email,
        password,
        _nameController.text,
        _phoneNumberController.text,
        _addressController.text);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed')),
      );
    }
  }
}
