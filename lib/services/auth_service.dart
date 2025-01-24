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
      }).then((value) {
        logger.d("Utente registrato in Firestore con successo.");
      }).catchError((error) {
        logger.e("Errore durante la registrazione in Firestore:", error: error);
      });

      return userCredential.user;
    } catch (e) {
      logger.e('Authentication error:', error: e);
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    logger.d("Inizio del processo di login con Google");

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        logger.d("Login annullato dall'utente.");
        return null;
      }

      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      if (googleAuth == null) {
        logger.e("GoogleAuth è null.");
        return null;
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user == null) {
        logger.e("Autenticazione fallita: utente è null.");
        return null;
      }

      logger.d("UID utente: ${user.uid}");

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        logger.d("Documento non trovato, creazione in corso...");
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': user.displayName ?? 'Nome sconosciuto',
          'email': user.email ?? 'Email sconosciuta',
          'phoneNumber': user.phoneNumber ?? '',
          'address': '',
        });
      } else {
        logger.d("Documento già esistente.");
      }

      return user;
    } catch (e, stack) {
      logger.e('Authentication error:', error: e, stackTrace: stack);
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
