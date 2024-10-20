import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'homeScreen.dart';
import 'login_signup_view.dart'; // Aggiungi import del login
import '../providers/auth_provider.dart' as local_auth;
import '../utils/auth_utils.dart'; // Importa il file di utilità
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

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false); // Spinner di caricamento

  // Variabili per la validazione
  bool _emailValid = true;
  bool _passwordValid = true;
  bool _passwordVisible = false; // Stato di visibilità della password
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
          _passwordValid = _passwordController.text.length >= 6; // Verifica lunghezza minima
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
    return Scaffold(
      appBar: AppBar(title: Text("Registration")),
      body: ValueListenableBuilder<bool>(
        valueListenable: isLoading,
        builder: (context, loading, child) {
          return loading
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
          );
        },
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
                  signInWithGoogle(context, (loading) {
                    isLoading.value = loading; // Aggiorna il valore di isLoading
                  });
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
                    _passwordVisible = !_passwordVisible; // Cambia lo stato della visibilità
                  });
                },
              ),
            ),
            obscureText: !_passwordVisible, // Nasconde il testo della password
            onChanged: (value) {
              setState(() {
                password = value;
                _passwordValid = password.length >= 6; // Controllo della lunghezza
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
            onPressed: _skipToLogin, // Pulsante per saltare al login
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
            onPressed: _skipToLogin, // Pulsante per saltare al login
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
            onPressed: () {
              _completeRegistration();
            },
            child: Text('Complete Registration'),
          ),
          TextButton(
            onPressed: _previousPage,
            child: Text('Back'),
          ),
          TextButton(
            onPressed: _skipToLogin, // Pulsante per saltare al login
            child: Text('If you have an account skip to Login'),
          ),
        ],
      ),
    );
  }

  // Metodo per completare la registrazione
  void _completeRegistration() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Verifica che l'email sia valida
    final emailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
    if (!emailValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email format error')),
      );
      return;
    }

    // Verifica che la password soddisfi i requisiti
    if (password.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('The password must be at least 6 characters long')),
      );
      return;
    }

    isLoading.value = true; // Mostra lo spinner di caricamento
    try {
      // Registrazione dell'utente
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Salvataggio dei dettagli dell'utente nel Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': email,
        'phoneNumber': _phoneNumberController.text,
        'address': _addressController.text,
      });

      // Naviga alla HomeScreen o alla schermata desiderata
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Gestione errori
      String errorMessage = 'An error occurred';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      isLoading.value = false; // Nascondi lo spinner di caricamento
    }
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
