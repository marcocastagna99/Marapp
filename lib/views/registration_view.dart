import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marapp/providers/auth_provider.dart';
import 'package:marapp/views/home.dart';
import 'package:marapp/views/login_view.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  bool _isLoading = false;

  String name = '';
  String email = '';
  String phoneNumber = '';
  String address = '';
  String password = '';
  String confirmPassword = '';

  bool _emailValid = true;
  bool _phoneValid = true;
  bool _passwordValid = true;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _showConfirmPassword = false;
  bool _passwordsMatch = true;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  void _register(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
          _phoneController.text.trim(),
          _addressController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registrazione completata!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: ${error.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrazione'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRoundedTextField( // Name
                  controller: _nameController,
                  label: 'Nome Completo',
                  onChanged: (value) => name = value,
                  errorText: _formKey.currentState?.validate() == false &&
                          _nameController.text.isEmpty
                      ? 'Inserisci il tuo nome'
                      : null,
                ),
                SizedBox(height: 10),

                _buildRoundedTextField( // Phone Number
                  controller: _phoneController,
                  label: 'Numero di Telefono',
                  onChanged: (value) {
                    setState(() {
                      phoneNumber = value;
                      _phoneValid = RegExp(r'^\d{10}$')
                          .hasMatch(_phoneController.text);
                    });
                  },
                  errorText: _formKey.currentState?.validate() == false &&
                          (_phoneController.text.isEmpty || !_phoneValid)
                      ? 'Inserisci un numero di telefono valido'
                      : null,
                  borderColor: _phoneController.text.isEmpty
                      ? Colors.grey 
                      : RegExp(r'^\d{10}$').hasMatch(_phoneController.text)
                          ? Colors.green 
                          : Colors.red, 
                ),
                SizedBox(height: 10),

                _buildRoundedTextField( // Address
                  controller: _addressController,
                  label: 'Indirizzo',
                  onChanged: (value) {},
                  errorText: _formKey.currentState?.validate() == false &&
                          _addressController.text.isEmpty
                      ? 'Inserisci il tuo indirizzo'
                      : null,
                ),
                SizedBox(height: 10),

                _buildRoundedTextField( // Email
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  label: 'Email',
                  onChanged: (value) {
                    setState(() {
                      email = value;
                      _emailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(_emailController.text);
                    });
                  },
                  errorText: _formKey.currentState?.validate() == false &&
                          (_emailController.text.isEmpty || !_emailValid)
                      ? 'Inserisci un\'email valida'
                      : null,
                  borderColor: _emailController.text.isEmpty
                      ? Colors.grey 
                      : _emailValid
                          ? Colors.green 
                          : Colors.red, 
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

                SizedBox(height: 20),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () => _register(context),
                        child: Text('Registrati'),
                      ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                    "Hai già un account? Accedi",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

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
        child: TextField(
          controller: controller,
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


void _checkPasswordMatch() {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  // TODO check if unused
  // void _completeRegistration() async {
  //   final authProvider = Provider.of<AuthProvider>(context, listen: false);
  //   final email = _emailController.text;
  //   final password = _passwordController.text;

  //   if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Invalid email format')),
  //     );
  //     return;
  //   }

  //   if (password.isEmpty || password.length < 6) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Password must be at least 6 characters long')),
  //     );
  //     return;
  //   }

  //   if (password != _confirmPasswordController.text) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Passwords do not match')),
  //     );
  //     return;
  //   }

  //   final success = await authProvider.signUp(
  //       email,
  //       password,
  //       _nameController.text,
  //       _phoneController.text,
  //       _addressController.text);

  //   if (success) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => HomeScreen()),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Registration failed')),
  //     );
  //   }
  // }
  
}