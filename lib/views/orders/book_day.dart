import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<DateTime?> showDatePickerDialog(BuildContext context, DateTime initialDate) async {
  final DateTime today = DateTime.now();
  List<DateTime> unavailableDates = [];

  // Recupera i giorni non disponibili da Firestore
  try {
    final snapshot = await FirebaseFirestore.instance.collection('notAvailable').get();
    for (var doc in snapshot.docs) {
      final timestamp = doc['date'];
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        final normalizedDate = DateTime(date.year, date.month, date.day);
        unavailableDates.add(normalizedDate);
      }
    }
  } catch (e) {
    print("Errore nel recupero dei giorni non disponibili: $e");
  }

  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: today,
    lastDate: DateTime(2025, 12, 31),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Colors.blue,
          hintColor: Colors.blue,
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
      final normalizedDate = DateTime(date.year, date.month, date.day);

      if (unavailableDates.contains(normalizedDate) || date.weekday == DateTime.sunday) {
        return false;
      }

      return true;
    },
  );

  if (picked != null && picked.isAfter(today)) {
    /*ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Your order will be delivered on ${picked.toLocal()}')),
    );*/
    return picked; // Ritorna la data selezionata
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please select a future date for delivery.')),
    );
    return null; // Nessuna data selezionata
  }
}
