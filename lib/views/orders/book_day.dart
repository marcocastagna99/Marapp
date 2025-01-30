// File: book_day.dart
import 'package:flutter/material.dart';

// Funzione per mostrare il selettore di data (DatePicker)
Future<void> showDatePickerDialog(BuildContext context, DateTime initialDate) async {
  final DateTime today = DateTime.now(); // Data di oggi

  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: today, // Non permettere date precedenti ad oggi
    lastDate: DateTime(2025, 12, 31), // Ultima data disponibile
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Colors.blue, // Colore del picker
          hintColor: Colors.blue, // Colore del selettore
          primaryTextTheme: TextTheme(
            titleLarge: TextStyle(color: Colors.black),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
          ),
        ),
        child: child!,
      );
    },
    selectableDayPredicate: (DateTime date) {
      // Disabilita specifici giorni (esempio: sabato e domenica)
      // Ritorna false per giorni non selezionabili
      if (date.weekday == DateTime.sunday) {
        return false; // Disabilita sabato e domenica
      }

      // Disabilita determinate date specifiche (ad esempio, feste)
      if (date.month == 2 && date.day == 25) {
        return false; // Disabilita il 25 dicembre (Natale)
      }

      // Puoi aggiungere altre condizioni personalizzate qui

      return true; // Altrimenti, la data è selezionabile
    },
  );

  if (picked != null && picked.isAfter(today)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Your order will be delivered on ${picked.toLocal()}')),
    );
    // Passa la data al carrello o salva nel database
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please select a future date for delivery.')),
    );
  }
}
