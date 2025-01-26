import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'update_profile.dart'; // Importa il file di update_profile.dart
import 'favourites_view.dart'; // Aggiungi il tuo file per Favourites
import 'payment_method_view.dart';// Aggiungi il tuo file per Payment Method
import '../login_view.dart';

class ProfileView extends StatelessWidget {

 const ProfileView({Key? key}) : super(key: key);
 static final FirebaseAuth _auth = FirebaseAuth.instance;

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
        stream: _getUserStream(),
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


          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Foto del profilo
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage("https://www.example.com/profile.jpg"), // Modifica con il link della foto
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
