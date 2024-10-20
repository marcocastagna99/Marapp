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
  String password = ''; // Aggiungi il campo per la password

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false); // Spinner di caricamento

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
              _buildEmailPasswordPage(), // Aggiungi la password qui
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
            decoration: InputDecoration(labelText: 'Email'),
            onChanged: (value) => email = value,
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true, // Nasconde il testo della password
            onChanged: (value) => password = value,
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
            child: Text('Skip to Login'),
          ),
        ],
      ),
    );
  }

  // Metodo per completare la registrazione
  void _completeRegistration() async {
    // Validazione email e password
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email e password sono obbligatorie')),
      );
      return;
    }

    isLoading.value = true; // Mostra lo spinner di caricamento
    try {
      // Creazione utente con Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Salva i dati aggiuntivi su Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneNumberController.text,
        'address': _addressController.text,
        'createdAt': Timestamp.now(),
      });

      // Reindirizza alla home dopo la registrazione
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      print('Errore durante la registrazione: $e');
    } finally {
      isLoading.value = false; // Nascondi lo spinner di caricamento
    }
  }
}
