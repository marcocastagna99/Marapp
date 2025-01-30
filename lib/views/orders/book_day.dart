// File: book_day.dart
import 'package:flutter/material.dart';

class BookDay extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  BookDay({required this.cartItems});

  @override
  _BookDayState createState() => _BookDayState();
}

class _BookDayState extends State<BookDay> {
  DateTime selectedDate = DateTime.now(); // Data predefinita (oggi)

  // Funzione che gestisce la selezione della data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2025), // Prima data disponibile
      lastDate: DateTime(2025, 12, 31), // Ultima data disponibile
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Delivery Day'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Selected Date: ${selectedDate.toLocal()}'.split(' ')[0], // Mostra solo la data
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context), // Apre il selettore di data
              child: const Text('Select Date'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Procedi con la logica di prenotazione, ad esempio, salva la data nel carrello o Firestore
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Your order for ${widget.cartItems.length} items will be delivered on ${selectedDate.toLocal()}'),
                  ),
                );
                // Puoi anche salvare la data scelta nel carrello o nel database
              },
              child: const Text('Confirm Order'),
            ),
          ],
        ),
      ),
    );
  }
}
