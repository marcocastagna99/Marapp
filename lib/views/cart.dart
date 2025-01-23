import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartView extends StatefulWidget {
  final String userId; // Aggiungi l'ID dell'utente per identificare il carrello
  final List<Map<String, dynamic>> cartItems;
  final Function(String, int) updateCart; // Funzione di aggiornamento

  const CartView({
    super.key,
    required this.cartItems,
    required this.updateCart,
    required this.userId, // Passiamo l'ID utente
  });

  @override
  CartViewState createState() => CartViewState();
}

class CartViewState extends State<CartView> {
  List<Map<String, dynamic>> cartItems = [];

  // Funzione per leggere o creare un documento di carrello per un determinato userId
  Future<void> _getCartData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("Utente non autenticato. Nessun carrello da caricare.");
        return;
      }

      final cartRef = FirebaseFirestore.instance.collection('cart').doc(user.uid);
      final docSnapshot = await cartRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          if (data['userId'] == user.uid) {
            if (data['cartItems'] is List) {
              List<Map<String, dynamic>> fetchedItems = List<Map<String, dynamic>>.from(data['cartItems']);
              setState(() {
                cartItems = fetchedItems;
              });
              print("Carrello caricato con successo per l'utente: ${user.uid}");
              print("Dati del carrello: $cartItems");
            } else {
              print("Errore: 'cartItems' non è una lista valida.");
            }
          } else {
            print("Errore: userId nel documento non corrisponde all'utente autenticato.");
          }
        } else {
          print("Errore: Il documento esiste ma i dati sono nulli.");
        }
      } else {
        print("Documento del carrello non trovato. Creazione di un nuovo carrello per l'utente: ${user.uid}");
        await cartRef.set({
          'cartItems': [],
          'userId': user.uid,
        });
        setState(() {
          cartItems = [];
        });
        print("Nuovo carrello creato con successo.");
      }
    } catch (e) {
      print("Errore nel recupero dei dati del carrello: $e");
    }
  }

  Future<void> _saveCartToFirestore() async {
    try {
      final cartRef = FirebaseFirestore.instance.collection('cart').doc(widget.userId);

      // Rimuovi gli articoli con quantità zero prima di salvare
      cartItems.removeWhere((item) => item['quantity'] <= 0);

      await cartRef.update({
        'cartItems': cartItems,
      });
    } catch (e) {
      print("Errore durante il salvataggio del carrello su Firestore: $e");
    }
  }


  @override
  void initState() {
    super.initState();
    _getCartData();
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = cartItems.fold(
      0, (sum, item) => sum + (item['price'] * item['quantity']),
    );

    Color bottomNavBarColor = Theme.of(context).primaryColor;
    Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: cartItems.isEmpty
          ? const Center(
        child: Text(
          'Your cart is empty!',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];

          return ListTile(
            title: Text(item['name'] ?? 'Nome prodotto non disponibile'),
            subtitle: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    widget.updateCart(item['name'], -1);
                    setState(() {
                      item['quantity']--;
                      if (item['quantity'] <= 0) {
                        cartItems.removeAt(index); // Rimuovi l'elemento se la quantità è zero
                      }
                      _saveCartToFirestore(); // Salva il carrello su Firestore
                    });
                  },
                ),
                Text('Quantity: ${item['quantity']}'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    widget.updateCart(item['name'], 1);
                    setState(() {
                      item['quantity']++;
                      _saveCartToFirestore(); // Salva il carrello su Firestore
                    });
                  },
                ),
              ],
            ),
            trailing: Text('€${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: bottomNavBarColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total:',
              style: TextStyle(fontSize: 18, color: textColor),
            ),
            Text(
              '€${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
