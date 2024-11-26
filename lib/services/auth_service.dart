import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
 // final GoogleSignIn _googleSignIn = GoogleSignIn();
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
 /* Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      logger.e('Authentication error:', error: e);
      return null;
    }
  }*/

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Current User
  User? get currentUser => _auth.currentUser;
}
