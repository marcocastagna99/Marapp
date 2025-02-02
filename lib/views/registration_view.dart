import 'package:firebase_auth/firebase_auth.dart';
import 'package:universal_io/io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marapp/providers/auth_provider.dart' as auth;
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

  static const Color lightblue = Color(0xFF76B6FE);
  bool _isLoading = false;

  String name = '';
  String email = '';
  String phoneNumber = '';
  String address = '';
  String password = '';
  String confirmPassword = '';
  String? _errorMessage;

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
        final authProvider = Provider.of<auth.AuthProvider>(context, listen: false);
        final success = await authProvider.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
          _phoneController.text.trim(),
          _addressController.text.trim(),
        );
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration successful!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration error')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _checkPasswordMatch() {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  Future<void> _signUpWithGoogle(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Get the authentication provider
      final authProvider = Provider.of<auth.AuthProvider>(context, listen: false);

      final User? user = await authProvider.signInWithGoogle();

      if (user == null) {
        // If the user canceled the login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google login canceled")),
        );
        return;
      }

      // If the login is successful, navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    } catch (error) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during login: $error")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRoundedTextFormField(
                  controller: _nameController,
                  label: 'Full Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your name';
                    }
                    return null;
                  },
                  onChanged: (value) => name = value,
                ),
                SizedBox(height: 10),
                _buildRoundedTextFormField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a valid phone number';
                    } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      phoneNumber = value;
                    });
                  },
                  errorText: null,
                  borderColor: _phoneController.text.isEmpty || !RegExp(r'^\d{10}$').hasMatch(_phoneController.text)
                      ? Colors.red
                      : Colors.green,
                ),
                SizedBox(height: 10),
                _buildRoundedTextFormField(
                  controller: _addressController,
                  label: 'Address',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your address';
                    }
                    return null;
                  },
                  onChanged: (value) => address = value,
                ),
                SizedBox(height: 10),
                _buildRoundedTextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  label: 'Email',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a valid email';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      email = value;
                      _emailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(_emailController.text);
                    });
                  },
                  errorText: !_emailValid
                      ? 'Enter a valid email'
                      : null,
                  borderColor: _emailController.text.isEmpty
                      ? Colors.grey
                      : _emailValid
                      ? Colors.green
                      : Colors.red,
                ),
                SizedBox(height: 10),
                _buildRoundedTextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  label: 'Password',
                  obscureText: !_passwordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
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
                  borderColor: _passwordValid
                      ? Colors.green
                      : Colors.red,
                ),
                SizedBox(height: 10),
                if (_showConfirmPassword)
                  _buildRoundedTextFormField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
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
                    errorText: !_passwordsMatch
                        ? 'Passwords do not match'
                        : null,
                    onChanged: (value) {
                      setState(() {
                        confirmPassword = value;
                        _checkPasswordMatch();
                      });
                    },
                    borderColor: _passwordsMatch
                        ? Colors.green
                        : Colors.red,
                  ),
                if (_showConfirmPassword) SizedBox(height: 10),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: () => _register(context),
                  child: Text('Register'),
                ),
                SignInButton(
                  Theme.of(context).brightness == Brightness.dark
                      ? Buttons.Google
                      : Buttons.Google,
                  text: "Sign Up with Google",
                  onPressed: () async {
                    await _signUpWithGoogle(context);
                  },
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
                    "Already have an account? Sign in",
                    style: TextStyle(color: lightblue),
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
      return CupertinoTextFormFieldRow(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        enabled: enabled,
        placeholder: label,
        validator: validator,
        onChanged: onChanged,
        style: TextStyle(color: textColor),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? Colors.grey),
          borderRadius: BorderRadius.circular(10.0),
        ),
      );
    } else {
      return TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        enabled: enabled,
        onChanged: onChanged,
        style: TextStyle(color: textColor),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffixIcon,
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: borderColor ?? Colors.grey),
          ),
        ),
      );
    }
  }
}
