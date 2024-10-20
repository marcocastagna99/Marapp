import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'homeScreen.dart';
import 'login_signup_view.dart'; // Aggiungi import del login
import '../providers/auth_provider.dart'; // Usa AuthProvider
import 'package:flutter_signin_button/flutter_signin_button.dart';

class RegistrationFlow extends StatefulWidget {
  @override
  _RegistrationFlowState createState() => _RegistrationFlowState();
}

class _RegistrationFlowState extends State<RegistrationFlow> {
  final PageController _pageController = PageController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String firstName = '';
  String lastName = '';
  String email = '';
  String phoneNumber = '';
  String address = '';
  String password = '';

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
          _emailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text);
        });
      }
    });

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        setState(() {
          _passwordValid = _passwordController.text.length >= 6;
        });
      }
    });
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skipToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginSignupView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context); // Usa il provider

    return Scaffold(
      appBar: AppBar(title: Text("Registration")),
      body: authProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _buildNamePage(),
          _buildEmailPasswordPage(),
          _buildPhoneNumberPage(),
          _buildAddressPage(),
        ],
      ),
    );
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _firstNameController,
            decoration: InputDecoration(labelText: 'First Name'),
            onChanged: (value) => firstName = value,
          ),
          TextField(
            controller: _lastNameController,
            decoration: InputDecoration(labelText: 'Last Name'),
            onChanged: (value) => lastName = value,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _nextPage,
            child: Text('Next'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _skipToLogin,
                child: Text('Skip to Login'),
              ),
              SizedBox(width: 10),
              SignInButton(
                Buttons.Google,
                text: "Sign up with Google",
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).signInWithGoogle();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmailPasswordPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            decoration: InputDecoration(
              labelText: 'Email',
              errorText: !_emailValid ? 'Email format error' : null,
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: !_emailValid ? Colors.red : Colors.grey,
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {
                email = value;
                _emailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
              });
            },
          ),
          SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: !_passwordValid ? 'Password must be at least 6 characters' : null,
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: !_passwordValid ? Colors.red : Colors.grey,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
            ),
            obscureText: !_passwordVisible,
            onChanged: (value) {
              setState(() {
                password = value;
                _passwordValid = password.length >= 6;
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _nextPage,
            child: Text('Next'),
          ),
          TextButton(
            onPressed: _previousPage,
            child: Text('Back'),
          ),
          TextButton(
            onPressed: _skipToLogin,
            child: Text('Skip to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _phoneNumberController,
            decoration: InputDecoration(labelText: 'Phone Number'),
            onChanged: (value) => phoneNumber = value,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _nextPage,
            child: Text('Next'),
          ),
          TextButton(
            onPressed: _previousPage,
            child: Text('Back'),
          ),
          TextButton(
            onPressed: _skipToLogin,
            child: Text('Skip to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _addressController,
            decoration: InputDecoration(labelText: 'Address'),
            onChanged: (value) => address = value,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _completeRegistration,
            child: Text('Complete Registration'),
          ),
          TextButton(
            onPressed: _previousPage,
            child: Text('Back'),
          ),
          TextButton(
            onPressed: _skipToLogin,
            child: Text('If you have an account skip to Login'),
          ),
        ],
      ),
    );
  }

  void _completeRegistration() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text;
    final password = _passwordController.text;

    // Validazione dell'email e della password
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email format error')),
      );
      return;
    }

    if (password.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('The password must be at least 6 characters long')),
      );
      return;
    }

    // Invia la richiesta di registrazione tramite il provider
    final success = await authProvider.signUp(
      email,
      password,
      _firstNameController.text,
      _lastNameController.text,
      _phoneNumberController.text,
      _addressController.text,
    );

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
