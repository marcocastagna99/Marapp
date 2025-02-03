import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<DateTime?> showDatePickerDialog(BuildContext context, DateTime initialDate) async {
  final DateTime today = DateTime.now();
  List<DateTime> unavailableDates = [];

  // Recupera i giorni non disponibili da Firestore
  try {
    final snapshot = await FirebaseFirestore.instance.collection('notAvailable').get();
    for (var doc in snapshot.docs) {
      final dateString = doc['date'];
      if (dateString is String) {
        // Converte la stringa in DateTime con il formato corretto
        final dateParts = dateString.split('-');
        if (dateParts.length == 3) {
          final year = int.parse(dateParts[0]);
          final month = int.parse(dateParts[1]);
          final day = int.parse(dateParts[2]);
          final date = DateTime(year, month, day);
          final normalizedDate = DateTime(date.year, date.month, date.day);
          unavailableDates.add(normalizedDate);
        }
      }
    }
  } catch (e) {
    print("Errore nel recupero dei giorni non disponibili: $e");
  }

  // Verifica se l'initialDate è valida, altrimenti trova il primo giorno disponibile
  DateTime validInitialDate = initialDate;
  while (unavailableDates.contains(validInitialDate) || validInitialDate.weekday == DateTime.sunday) {
    validInitialDate = validInitialDate.add(Duration(days: 1)); // Sposta in avanti
  }

  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: validInitialDate, // Usa la data valida
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
      // Verifica che la data non sia nella lista dei giorni non disponibili e che non sia domenica
      return !unavailableDates.contains(normalizedDate) && date.weekday != DateTime.sunday;
    },
  );

  if (picked != null && picked.isAfter(today)) {
    return picked;
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please select a future date for delivery.')),
    );
    return null;
  }
}
