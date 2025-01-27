import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavouritesView extends StatefulWidget {
  const FavouritesView({super.key});

  @override
  _FavouritesViewState createState() => _FavouritesViewState();
}

class _FavouritesViewState extends State<FavouritesView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Funzione per caricare i preferiti dell'utente
  Future<void> _loadFavorites() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        debugPrint('Utente non autenticato');
        return;
      }

      final docRef = _firestore.collection('favorites').doc(userId);
      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data();
        final favorites = List<Map<String, dynamic>>.from(data?['favorites'] ?? []);

        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
      } else {
        setState(() {
          _favorites = [];
          _isLoading = false;
        });
        debugPrint('Nessun preferito trovato per l\'utente con ID $userId');
      }
    } catch (e) {
      debugPrint('Errore nel caricamento dei preferiti: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Funzione per rimuovere un prodotto dai preferiti
  Future<void> _removeFromFavorites(String prodID) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        debugPrint('Utente non autenticato');
        return;
      }

      final docRef = _firestore.collection('favorites').doc(userId);
      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data();
        final favorites = List<Map<String, dynamic>>.from(data?['favorites'] ?? []);

        // Rimuovi il prodotto dai preferiti
        favorites.removeWhere((favorite) => favorite['prodID'] == prodID);

        // Aggiorna la lista dei preferiti
        await docRef.update({
          'favorites': favorites,
        });

        setState(() {
          _favorites = favorites;
        });

        debugPrint('Prodotto rimosso dai preferiti: $prodID');
      }
    } catch (e) {
      debugPrint('Errore nel rimuovere il prodotto dai preferiti: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Favourite Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _favorites.isEmpty
                ? const Center(child: Text('No favourites found.'))
                : ListView.builder(
              shrinkWrap: true,
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final favorite = _favorites[index];
                return ListTile(
                  title: Text(favorite['name'] ?? 'Product'),
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeFromFavorites(favorite['prodID']),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implementa la funzionalità per aggiungere un nuovo elemento ai preferiti
              },
              child: const Text('Add to Favourites'),
            ),
          ],
        ),
      ),
    );
  }
}
