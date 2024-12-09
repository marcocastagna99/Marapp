import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final logger = Logger();

  // Login
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      logger.e('Authentication error:', error: e);
      return null;
    }
  }

  // Sign Up
  Future<User?> signUp(String email, String password, String name,
      String phoneNumber, String address) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Salva i dettagli dell'utente in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'name': name,
        'phoneNumber': phoneNumber,
        'address': address,
      });

      return userCredential.user;
    } catch (e) {
      logger.e('Authentication error:', error: e);
      return null;
    }
  }

  // Google Sign In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // L'utente ha annullato il login con Google
        return null;
      }

      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Esegui l'accesso con le credenziali ottenute da Google
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Verifica se l'utente esiste già in Firestore
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!doc.exists) {
          // Se il documento non esiste, crealo
          logger.d("Documento non trovato, creazione in corso...");
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'name': user.displayName ?? 'Nome sconosciuto',
            'phoneNumber': user.phoneNumber ?? '0000000000',
            'email': user.email ?? 'Email sconosciuta',
          });
          logger.d("Documento creato con successo.");
        } else {
          logger.d("Documento già esistente.");
        }
      }

      return user;
    } catch (e) {
      logger.e('Authentication error:', error: e);
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Current User
  User? get currentUser => _auth.currentUser;
}
