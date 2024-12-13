import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:marapp/providers/auth_provider.dart' as auth;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _login() async {
    final authProvider = Provider.of<auth.AuthProvider>(context, listen: false);

    setState(() {
      _isLoading = true; // Imposta lo stato di caricamento a true
    });

    try {
      await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );

      if (authProvider.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      setState(() {
        _isLoading = false; // Imposta lo stato di caricamento a false
      });
    }
  }

  Future<void> _loginWithGoogle(BuildContext context) async {
    setState(() {
      _isLoading = true; // Imposta lo stato di caricamento a true
    });

    try {
      // Ottieni il provider di autenticazione
      final authProvider = Provider.of<auth.AuthProvider>(context, listen: false);

      final User? user = await authProvider.signInWithGoogle();

      if (user == null) {
        // Se l'utente ha annullato il login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login Google annullato")),
        );
        return;
      }

      // Se il login è riuscito, naviga alla home
      Navigator.pushReplacementNamed(context, '/home');
    } catch (error) {
      // Gestisci eventuali errori
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore durante il login: $error")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Imposta lo stato di caricamento a false
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRoundedTextFormField(
                controller: _emailController,
                label: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _errorMessage = null;
                  });
                },
              ),
              _buildRoundedTextFormField(
                controller: _passwordController,
                label: 'Password',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _errorMessage = null;
                  });
                },
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator()) // Mostra la rotella
                  : ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _login();
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 20),
              SignInButton(
                Theme.of(context).brightness == Brightness.dark
                    ? Buttons.GoogleDark
                    : Buttons.Google,
                text: "Sign in with Google",
                onPressed: () async {
                  await _loginWithGoogle(context);
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
                child: const Text(
                  "Don't have an account? Register",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor ?? Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        focusNode: focusNode,
        obscureText: obscureText,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          suffixIcon: suffixIcon,
        ),
        style: TextStyle(color: textColor),
        onChanged: onChanged,
      ),
    );
  }
}
