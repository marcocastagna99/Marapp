import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressViewScreen extends StatefulWidget {
  final DateTime selectedDate; // Data selezionata da passare al widget

  // Aggiungi il required per il parametro
  AddressViewScreen({Key? key, required this.selectedDate}) : super(key: key);
  @override
  _AddressViewScreenState createState() => _AddressViewScreenState();
}

class _AddressViewScreenState extends State<AddressViewScreen> {

  String address = ''; // Indirizzo dell'utente
  LatLng? _currentPosition; // Posizione corrente per il segnalino sulla mappa

  @override
  void initState() {
    super.initState();
    _getAddress();
  }

  // Carica l'indirizzo dal documento dell'utente
  Future<void> _getAddress() async {
    try {
      // Ottieni l'ID dell'utente autenticato
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Recupera il documento dell'utente usando l'ID
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid) // Usa l'ID dell'utente autenticato
            .get();

        // Controlla se il documento esiste e se contiene il campo address
        if (userDoc.exists && userDoc.data() != null) {
          setState(() {
            address = userDoc.data()?['address'] ?? ''; // Imposta l'indirizzo se esiste
          });
        } else {
          setState(() {
            address = ''; // Se non c'è l'indirizzo, lascialo vuoto
          });
        }
      }
    } catch (e) {
      print('Errore nel recupero dell\'indirizzo: $e');
    }
  }


  // Mostra la mappa per selezionare una nuova posizione
  void _selectOnMap() async {
    final LatLng? newPosition = await showDialog(
      context: context,
      builder: (context) => MapPickerDialog(currentPosition: _currentPosition),
    );

    if (newPosition != null) {
      setState(() {
        _currentPosition = newPosition;
        // Potresti anche voler aggiornare la posizione su Firestore qui
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Your Address: $address',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            _currentPosition != null
                ? GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 14.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('currentPosition'),
                  position: _currentPosition!,
                ),
              },
            )
                : Container(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectOnMap,
              child: Text('Change Address on Map'),
            ),
          ],
        ),
      ),
    );
  }
}

class MapPickerDialog extends StatelessWidget {
  final LatLng? currentPosition;
  MapPickerDialog({required this.currentPosition});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 400,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: currentPosition ?? LatLng(37.7749, -122.4194), // Default San Francisco
            zoom: 14.0,
          ),
          onTap: (LatLng position) {
            Navigator.of(context).pop(position);
          },
        ),
      ),
    );
  }
}
