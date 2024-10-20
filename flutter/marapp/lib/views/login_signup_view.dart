import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firestore
import 'package:provider/provider.dart';
import 'homeScreen.dart';
import '../providers/auth_provider.dart' as local_auth;
import 'package:flutter_signin_button/flutter_signin_button.dart';
import '../utils/auth_utils.dart';

class LoginSignupView extends StatefulWidget {
  @override
  _LoginSignupViewState createState() => _LoginSignupViewState();
}

class _LoginSignupViewState extends State<LoginSignupView> {
  bool isLogin = true;
  bool isLoading = false; // Variabile di stato per lo spinner di caricamento
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  TextEditingController firstNameController = TextEditingController(); // First Name
  TextEditingController lastNameController = TextEditingController();  // Last Name
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void toggleFormType() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // Mostra lo spinner di caricamento
      });

      try {
        if (isLogin) {
          // Esegui login
          UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
          // Reindirizza a Home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          // Esegui registrazione
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );

          // Recupera l'ID dell'utente
          User? user = userCredential.user;

          if (user != null) {
            // Salva i dati dell'utente su Firestore
            await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
              'firstName': firstNameController.text,
              'lastName': lastNameController.text,
              'email': emailController.text,
              'uid': user.uid,
              'createdAt': FieldValue.serverTimestamp(),
            });

            // Reindirizza a Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'email-already-in-use') {
          message = 'This email is already registered. Please use another email.';
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
    await signInWithGoogle(context, (loading) {
      setState(() {
        isLoading = loading;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Login' : 'Sign Up'),
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
                      if (!isLogin) // Mostra questi campi solo nel modulo di registrazione
                        Column(
                          children: [
                            TextFormField(
                              controller: firstNameController,
                              decoration: InputDecoration(labelText: 'First Name'),
                              validator: (value) {
                                if (value!.isEmpty) return 'Please enter your first name';
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: lastNameController,
                              decoration: InputDecoration(labelText: 'Last Name'),
                              validator: (value) {
                                if (value!.isEmpty) return 'Please enter your last name';
                                return null;
                              },
                            ),
                          ],
                        ),
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
                        child: Text(isLogin ? 'Login' : 'Sign Up'),
                      ),
                      SizedBox(height: 10),
                      SignInButton(
                        Buttons.Google,
                        onPressed: _signInWithGoogle,
                      ),
                      TextButton(
                        onPressed: toggleFormType,
                        child: Text(isLogin
                            ? "Don't have an account? Sign up"
                            : "Already have an account? Login"),
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
