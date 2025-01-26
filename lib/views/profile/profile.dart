import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'update_profile.dart'; // Importa il file di update_profile.dart
import 'favourites_view.dart'; // Aggiungi il tuo file per Favourites
import 'payment_method_view.dart'; // Aggiungi il tuo file per Payment Method

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  Future<String> _getUserName() async {
    // Ottieni l'ID dell'utente corrente
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Ottieni i dati utente da Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Controlla se il documento esiste e se ha i dati
      if (snapshot.exists && snapshot.data() != null) {
        // Fai il cast dei dati a Map<String, dynamic> e prendi il campo 'name'
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data['name'] ?? 'Unknown User';
      }
    }
    return 'Unknown User'; // Se l'utente non esiste o non ha un nome
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
              // Funzionalità di logout
            },
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _getUserName(), // Chiama il metodo per ottenere il nome dell'utente
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading user data'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data found'));
          }

          String userName = snapshot.data!;

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
