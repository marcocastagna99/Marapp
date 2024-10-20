import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'homeScreen.dart';
import '../providers/auth_provider.dart' as local_auth; // Rinominato per evitare conflitti
import 'package:flutter_signin_button/flutter_signin_button.dart';
import '../utils/auth_utils.dart';
import 'registration_flow.dart'; // Importa il flusso di registrazione

class LoginSignupView extends StatefulWidget {
  @override
  _LoginSignupViewState createState() => _LoginSignupViewState();
}

class _LoginSignupViewState extends State<LoginSignupView> {
  bool isLoading = false; // Variabile di stato per lo spinner di caricamento
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // Mostra lo spinner di caricamento
      });

      try {
        // Utilizza local_auth.AuthProvider per eseguire il login
        await Provider.of<local_auth.AuthProvider>(context, listen: false).login(
          emailController.text,
          passwordController.text,
        );

        // Reindirizza a Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          message = 'Invalid email or password. Please try again.';
        } else {
          message = e.message ?? 'An error occurred. Please try again.';
        }
        // Mostra messaggio di errore
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
          isLoading = false; // Nascondi lo spinner di caricamento
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    await Provider.of<local_auth.AuthProvider>(context, listen: false).signInWithGoogle();
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
            mainAxisAlignment: isLoading ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              if (!isLoading) // Mostra il modulo se non in caricamento
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty || !value.contains('@')) return 'Please enter a valid email';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty || value.length < 6) return 'Password must be at least 6 characters long';
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text('Login'),
                      ),
                      SizedBox(height: 10),
                      SignInButton(
                        Buttons.Google,
                        onPressed: _signInWithGoogle,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => RegistrationFlow()), // Naviga al flusso di registrazione
                          );
                        },
                        child: Text("Don't have an account? Sign up"),
                      ),
                    ],
                  ),
                ),
              if (isLoading) // Mostra lo spinner di caricamento
                Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
