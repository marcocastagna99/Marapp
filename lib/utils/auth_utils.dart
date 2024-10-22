import 'package:cloud_firestore/cloud_firestore.dart'; // Aggiungi questo per Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart' as local_auth;
import '../views/homeScreen.dart';
import 'package:provider/provider.dart';

Future<void> signInWithGoogle(BuildContext context, Function setLoading) async {
  setLoading(true);

  final authProvider = Provider.of<local_auth.AuthProvider>(context, listen: false);
  User? user = await authProvider.signInWithGoogle();

  if (user != null) {
    // Aggiungiamo qui il salvataggio dei dati su Firestore se non esistono
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      // Creiamo un nuovo documento con i dati base dell'utente Google
      await userDoc.set({
        'firstName': user.displayName?.split(' ')?.first ?? '',
        'lastName': user.displayName?.split(' ')?.last ?? '',
        'email': user.email,
        'createdAt': Timestamp.now(),
      });
    }

    // Vai alla schermata home
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

  setLoading(false);
}
