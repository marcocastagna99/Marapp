import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> checkAndUpdateAvailability(DateTime date) async {
  try {
    // Converte la data in formato DateTime UTC per fare la query correttamente
    final dateUtc = DateTime.utc(date.year, date.month, date.day);

    // Ottieni il documento relativo alla data nella collection 'dailyLimits'
    final snapshot = await FirebaseFirestore.instance
        .collection('dailyLimits')
        .where('date', isEqualTo: dateUtc)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final currentOrders = doc['currentOrders']; // Ordini correnti
      final maxOrders = doc['maxOrders']; // Limite massimo ordini

      // Verifica se il numero di ordini ha raggiunto il massimo
      if (currentOrders >= maxOrders) {
        // Aggiungi la data alla collection 'notAvailable' con il campo isSystemWrite
        await FirebaseFirestore.instance.collection('notAvailable').add({
          'date': dateUtc, // La data quando non è disponibile
          'isSystemWrite': true, // Indica che la scrittura è automatica (procedurale)
        });
        print("Data $dateUtc aggiunta a notAvailable");

        // Restituisce true per indicare che la data è stata aggiunta
        return true;
      }
    } else {
      print('Data non trovata nella collection dailyLimits.');
    }
  } catch (e) {
    print('Errore durante l\'aggiornamento della disponibilità: $e');
  }

  // Restituisce false se non è stato aggiunto un giorno non disponibile
  return false;
}




Future<void> updateDailyLimit(DateTime selectedDate, List<Map<String, dynamic>> cartItems) async {
  // Formatta la data come stringa per usarla come chiave nel Firestore
  String formattedDate = "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";

  // Riferimento alla collezione
  CollectionReference dailyLimits = FirebaseFirestore.instance.collection('daily_limits');

  // Riferimento al documento della data scelta
  DocumentReference dateDocRef = dailyLimits.doc(formattedDate);

  try {
    // Ottieni il documento
    DocumentSnapshot docSnapshot = await dateDocRef.get();

    // Inizializza array esistente e currentPrepTime
    List<Map<String, dynamic>> existingProdPrepTime = [];
    int currentPrepTime = 0;

    if (docSnapshot.exists) {
      // Se il documento esiste, recupera i dati
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

      // Recupera l'array `prodPrepTime` e `currentPrepTime`
      if (data.containsKey('prodPrepTime')) {
        existingProdPrepTime = List<Map<String, dynamic>>.from(data['prodPrepTime']);
      }
      if (data.containsKey('currentPrepTime')) {
        currentPrepTime = data['currentPrepTime'];
      }
    }

    // Creiamo un set con tutti i prodId già presenti nell'array
    Set<String> existingProdIds = existingProdPrepTime.map((e) => e['prodId'] as String).toSet();

    // Lista dei nuovi prodotti da aggiungere
    List<Map<String, dynamic>> newProducts = [];
    int newPrepTimeSum = 0;

    for (var item in cartItems) {
      String prodId = item['prodId'];
      int prepTime = item['prepTime'];

      // Se il prodotto non è già presente, aggiungilo alla lista
      if (!existingProdIds.contains(prodId)) {
        newProducts.add({'prodId': prodId, 'prepTime': prepTime});
        newPrepTimeSum += prepTime;
      }
    }

    // Se ci sono nuovi prodotti da aggiungere, aggiorna Firestore
    if (newProducts.isNotEmpty) {
      await dateDocRef.set(
        {
          'prodPrepTime': FieldValue.arrayUnion(newProducts),
          'currentPrepTime': currentPrepTime + newPrepTimeSum,
        },
        SetOptions(merge: true), // Mantiene i dati esistenti e aggiorna solo i campi necessari
      );
    }

    print("Prodotti aggiornati per la data $formattedDate.");
  } catch (e) {
    print("Errore durante l'aggiornamento: $e");
  }
}

