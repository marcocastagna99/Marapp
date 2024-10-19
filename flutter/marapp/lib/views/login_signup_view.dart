import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import '../providers/auth_provider.dart' as local_auth;
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginSignupView extends StatefulWidget {
  @override
  _LoginSignupViewState createState() => _LoginSignupViewState();
}

class _LoginSignupViewState extends State<LoginSignupView> {
  bool isLogin = true;
  bool isLoading = false; // Variabile di stato per il caricamento
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
        isLoading = true; // Mostra la rotella di caricamento
      });

      try {
        if (isLogin) {
          // Perform login
          UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
          // Redirect to home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          // Perform registration
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
          // Redirect to home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'email-already-in-use') {
          message = 'This email is already registered. Please use another email.';
        } else {
          message = e.message ?? 'An error occurred. Please try again.';
        }
        // Show an error message
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
          isLoading = false; // Nascondi la rotella di caricamento
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      isLoading = true; // Mostra la rotella di caricamento
    });

    final authProvider = Provider.of<local_auth.AuthProvider>(context, listen: false);
    User? user = await authProvider.signInWithGoogle();

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred during Google login.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }

    setState(() {
      isLoading = false; // Nascondi la rotella di caricamento
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Login' : 'Sign Up'),
      ),
      body: Center( // Usa Center per centrare il contenuto
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: isLoading ? MainAxisAlignment.center : MainAxisAlignment.start, // Allinea al centro se in caricamento
            children: [
              if (!isLoading) // Mostra il form solo se non stai caricando
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
              if (isLoading) // Mostra la rotella di caricamento
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
