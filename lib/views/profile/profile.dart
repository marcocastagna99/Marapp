import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marapp/views/profile/upload_foto.dart';
import 'update_profile.dart'; // Importa il file di update_profile.dart
import 'favourites_view.dart'; // Aggiungi il tuo file per Favourites
import 'payment_method_view.dart'; // Aggiungi il tuo file per Payment Method
import '../login_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String _statusMessage = '';




  // Stream che restituisce i dati dell'utente in tempo reale da Firestore
  Stream<DocumentSnapshot<Map<String, dynamic>>> _getUserStream() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots();
    } else {
      throw Exception("User is not logged in");
    }
  }

  Future<void> _handleImageUpload() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    final uploader = ProfilePictureUploader();
    final result = await uploader.pickAndUploadImage(context);

    setState(() {
      _isLoading = false;
      _statusMessage = result;
    });

    // Mostra lo Snackbar con il risultato del caricamento
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Image uploaded successfully!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }


  // Metodo per il logout
  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _getUserStream(), // Otteniamo il flusso dei dati dell'utente
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading user data'));
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text('No user data found'));
          }

          // Ottieni i dati dall'istanza di snapshot
          Map<String, dynamic> userData = snapshot.data!.data()!;
          String userName = userData['name'] ?? 'Unknown User';
          String? profilePicUrl = userData['profilePicture']; // URL immagine

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Foto del profilo con icona della fotocamera
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profilePicUrl != null
                          ? NetworkImage(profilePicUrl) // Mostra immagine da Firestore
                          : const NetworkImage('https://link.to/default/image.jpg'), // Immagine di default se manca
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: _handleImageUpload,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Nome utente
              ListTile(
                title: Text(
                  userName, // Usa il nome dell'utente da Firebase
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text("User Name"),
              ),
              const Divider(),

              // Modifica Profilo
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit Profile"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UpdateProfileProfileView()),
                  );
                },
              ),
              const Divider(),

              // Favourites
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text("Favourites"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FavouritesView()),
                  );
                },
              ),
              const Divider(),

              // Payment Method
              ListTile(
                leading: const Icon(Icons.payment),
                title: const Text("Payment Method"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PaymentMethodView()),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
