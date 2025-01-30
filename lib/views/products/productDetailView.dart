import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailView extends StatefulWidget {
  final String productId;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final int maxQuantity;
  final Function(String, double, String, int) addToCart;

  const ProductDetailView({
    super.key,
    required this.productId,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.addToCart,
    required this.maxQuantity,
  });

  @override
  _ProductDetailViewState createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  int _quantity = 1;
  bool _isFavorite = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus(); // Carica lo stato dal cloud all'avvio
  }

  Future<void> _loadFavoriteStatus() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid; // Recupera l'ID utente autenticato
      if (userId == null) {
        debugPrint('Utente non autenticato');
        return;
      }

      final docRef = _firestore.collection('favorites').doc(userId);
      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data();
        final favorites = List.from(data?['favorites'] ?? []);

        // Verifica se il prodotto è già nei preferiti
        setState(() {
          _isFavorite = favorites.any((favorite) => favorite['prodID'] == widget.productId);
        });
      } else {
        // Se il documento non esiste, lo creiamo con un array vuoto di preferiti
        await docRef.set({
          'userId': userId,
          'favorites': [],
        });
        debugPrint('Documento creato per l\'utente con ID $userId');
      }
    } catch (e) {
      debugPrint('Errore nel caricamento dello stato del preferito: $e');
    }
  }



  Future<void> _toggleFavorite() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid; // Recupera l'ID utente autenticato
      if (userId == null) {
        debugPrint('Utente non autenticato');
        return;
      }

      final docRef = _firestore.collection('favorites').doc(userId);
      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data();
        final favorites = List.from(data?['favorites'] ?? []);

        // Verifica se il prodotto è già nei preferiti
        final existingFavorite = favorites.firstWhere(
              (favorite) => favorite['prodID'] == widget.productId,
          orElse: () => null,
        );

        if (existingFavorite != null) {
          // Se è già nei preferiti, rimuovilo
          favorites.removeWhere((favorite) => favorite['prodID'] == widget.productId);
          setState(() {
            _isFavorite = false;
          });
        } else {
          // Se non è nei preferiti, aggiungilo
          favorites.add({
            'prodID': widget.productId,
            'name': widget.name,
            'isFavorite': true,
          });
          setState(() {
            _isFavorite = true;
          });
        }

        // Aggiorna l'array di preferiti nel documento
        await docRef.update({
          'favorites': favorites,
        });

        debugPrint('Stato del preferito aggiornato per il prodotto con ID ${widget.productId}');
      }
    } catch (e) {
      debugPrint('Errore durante il salvataggio nel cloud: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/${widget.imageUrl}',
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '€${widget.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Allinea il testo a sinistra
              children: [
                Text(
                  widget.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 4),
                Text(
                  "max quantity: ${widget.maxQuantity}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (_quantity > 1) _quantity--;
                    });
                  },
                ),
                Text(
                  _quantity.toString(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_quantity >= 1) {
                  widget.addToCart(
                    widget.productId,
                    widget.price,
                    widget.name,
                    _quantity,
                  );
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Product added to cart successfully!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
