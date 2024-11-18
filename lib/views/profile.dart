import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  ProfileViewState createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _emailValid = true;
  bool _passwordValid = true;

  bool _oldPasswordVisible = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  bool _showConfirmPassword = false;
  bool _passwordsMatch = true;

  bool _passwordsMatchError = false; // Flag for matching error
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();

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

  Future<void> _fetchUserProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(user.uid).get();

      setState(() {
        _nameController.text = snapshot['name'] ?? '';
        _phoneNumberController.text = snapshot['phoneNumber'] ?? '';
        _addressController.text = snapshot['address'] ?? '';
        _emailController.text = user.email ?? '';
      });
    }
  }

  void _checkPasswordMatch() {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  // New function to check if new password is the same as the old one
  void _checkPasswordEquality() {
    setState(() {
      _passwordsMatchError =
          _passwordController.text == _oldPasswordController.text;
    });
  }

  Future<void> _updateProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        if (!_emailValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email format error')),
          );
          return;
        }

        if (!_passwordValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Password must be at least 6 characters long')),
          );
          return;
        }

        if (_passwordController.text.isNotEmpty && !_passwordsMatch) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Passwords do not match')),
          );
          return;
        }

        if (_passwordsMatchError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('New password cannot be the same as old password')),
          );
          return;
        }

        // If old password is provided, verify it
        if (_oldPasswordController.text.isNotEmpty) {
          try {
            AuthCredential credential = EmailAuthProvider.credential(
              email: user.email!,
              password: _oldPasswordController.text,
            );
            await user.reauthenticateWithCredential(credential);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Old password is incorrect')),
            );
            return;
          }
        }

        // Update profile information
        await _firestore.collection('users').doc(user.uid).update({
          'name': _nameController.text,
          'phoneNumber': _phoneNumberController.text,
          'address': _addressController.text,
        });

        // Update email if changed
        if (_emailController.text != user.email) {
          await user.verifyBeforeUpdateEmail(_emailController.text);
        }

        // Update password if provided
        if (_passwordController.text.isNotEmpty) {
          await user.updatePassword(_passwordController.text);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRoundedTextField(
              controller: _nameController,
              label: 'Update Name',
            ),
            SizedBox(height: 10),
            _buildRoundedTextField(
              controller: _phoneNumberController,
              label: 'Update Phone Number',
            ),
            SizedBox(height: 10),
            _buildRoundedTextField(
              controller: _addressController,
              label: 'Update Address',
            ),
            SizedBox(height: 10),
            _buildRoundedTextField(
              controller: _emailController,
              label: 'Update Email',
              focusNode: _emailFocusNode,
              errorText: !_emailValid ? 'Email format error' : null,
              onChanged: (value) {
                setState(() {
                  _emailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
                });
              },
              borderColor: _emailController.text.isEmpty
                  ? Colors.grey
                  : _emailValid
                      ? Colors.green
                      : Colors.red,
            ),
            SizedBox(height: 10),

            // Old password text field
            _buildRoundedTextField(
              controller: _oldPasswordController,
              label: 'Old Password',
              obscureText: !_oldPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _oldPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _oldPasswordVisible = !_oldPasswordVisible;
                  });
                },
              ),
            ),
            SizedBox(height: 10),

            // New password text field
            _buildRoundedTextField(
              controller: _passwordController,
              label: 'New Password',
              focusNode: _passwordFocusNode,
              obscureText: !_passwordVisible,
              errorText: _passwordsMatchError
                  ? 'New password cannot be the same as old password'
                  : (!_passwordValid
                      ? 'Password must be at least 6 characters'
                      : null),
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility_off : Icons.visibility,
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
                  _showConfirmPassword = value.isNotEmpty;
                  _checkPasswordMatch();
                  _checkPasswordEquality(); // Check new password against old password
                });
              },
              borderColor: _passwordsMatchError
                  ? Colors.red
                  : _passwordController.text.isEmpty
                      ? Colors.grey
                      : _passwordValid
                          ? Colors.green
                          : Colors.red,
            ),
            if (_showConfirmPassword)
              _buildRoundedTextField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                obscureText: !_confirmPasswordVisible,
                errorText: !_passwordsMatch ? 'Passwords do not match' : null,
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
                    _checkPasswordMatch();
                  });
                },
                borderColor: _passwordsMatch ? Colors.green : Colors.red,
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Update Profile'),
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
    void Function(String)? onChanged,
    Color? borderColor,
  }) {
    return Platform.isIOS || Platform.isMacOS
        ? CupertinoTextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            placeholder: label,
            suffix: suffixIcon,
            onChanged: onChanged,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor ?? CupertinoColors.systemGrey),
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
          )
        : Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor ?? Colors.grey),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              decoration: InputDecoration(
                labelText: label,
                errorText: errorText,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                suffixIcon: suffixIcon,
              ),
              onChanged: onChanged,
            ),
          );
  }
}
