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
            SnackBar(content: Text('Registrazione completata!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore nella registrazione')),
          );
        }
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

  void _checkPasswordMatch() {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text;
    });
  }


  Future<void> _signUpWithGoogle(BuildContext context) async {
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
    }
    finally{
      setState(() {
        _isLoading = false; // Imposta lo stato di caricamento a true
      });
    }
  }
  /*
  Future<void> _signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // L'utente ha annullato l'accesso
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Google Sign-In failed: $error';
      });
    }
  }*/

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
                _buildRoundedTextFormField(
                  controller: _nameController,
                  label: 'Nome Completo',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci il tuo nome';
                    }
                    return null;
                  },
                  onChanged: (value) => name = value,
                ),
                SizedBox(height: 10),
                _buildRoundedTextFormField(
                  controller: _phoneController,
                  label: 'Numero di Telefono',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci un numero di telefono valido';
                    } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Inserisci un numero di telefono valido';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      phoneNumber = value;
                    });
                  },
                  errorText: null, // Non usare il `errorText` personalizzato per la validazione immediata
                  borderColor: _phoneController.text.isEmpty || !RegExp(r'^\d{10}$').hasMatch(_phoneController.text)
                      ? Colors.red  // Il bordo sarà rosso solo quando il campo è vuoto o non valido
                      : Colors.green,  // Il bordo sarà verde quando il numero è valido
                ),
                SizedBox(height: 10),
                _buildRoundedTextFormField(
                  controller: _addressController,
                  label: 'Indirizzo',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci il tuo indirizzo';
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
                      return 'Inserisci un\'email valida';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Inserisci un\'email valida';
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
                      ? 'Inserisci un\'email valida'
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
                      return 'La password deve contenere almeno 6 caratteri';
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
                    label: 'Conferma Password',
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
                        ? 'Le password non corrispondono'
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
                  child: Text('Registrati'),
                ),
                SignInButton(
                  Theme.of(context).brightness == Brightness.dark
                      ? Buttons.GoogleDark
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
                    "Hai già un account? Accedi",
                    style: TextStyle(color: Colors.blue),
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
        validator: validator,
        focusNode: focusNode,
        obscureText: obscureText,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: borderColor ?? Colors.grey,
            ),
          ),
          contentPadding:
          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          suffixIcon: suffixIcon,
        ),
        style: TextStyle(color: textColor),
        onChanged: onChanged,
      );
    }
  }
}
