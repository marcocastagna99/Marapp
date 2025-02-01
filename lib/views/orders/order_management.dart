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



Future<bool> updateDailyLimit(DateTime selectedDate, List<Map<String, dynamic>> cartItems) async {
  // Formatta la data come stringa (chiave documento)
  String formattedDate = "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
  print("🟢 Data selezionata: $formattedDate");

  // Riferimento alla collezione Firestore
  CollectionReference dailyLimits = FirebaseFirestore.instance.collection('dailyLimits');

  // Riferimento al documento della data scelta
  DocumentReference dateDocRef = dailyLimits.doc(formattedDate);

  try {
    // Ottieni il documento
    DocumentSnapshot docSnapshot = await dateDocRef.get();
    print("📄 Documento trovato: ${docSnapshot.exists}");

    // Se il documento NON esiste, lo creiamo subito
    if (!docSnapshot.exists) {
      int newPrepTimeSum = cartItems.fold(0, (sum, item) => sum + (item['prepTime'] as int));

      print("📌 Creazione nuovo documento per la data $formattedDate");
      await dateDocRef.set({
        'date': formattedDate,
        'currentOrders': 1, // Prima prenotazione del giorno
        'currentPrepTime': newPrepTimeSum,
        'maxOrders': 7, // Valore predefinito
        'maxPrepTime': 500, // Valore predefinito
        'prodPrepTime': cartItems.map((item) => {'productId': item['productId'], 'prepTime': item['prepTime']}).toList(),
      });

      print("✅ Nuovo documento creato.");
      return true; // Aggiornamento avvenuto
    }

    // Se il documento esiste, recuperiamo i dati
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
    print("🔍 Dati attuali nel documento: $data");

    List<Map<String, dynamic>> existingProdPrepTime = [];
    int currentPrepTime = data['currentPrepTime'] ?? 0;
    int maxPrepTime = data['maxPrepTime'] ?? 500; // Assumiamo un valore predefinito se non esiste
    int currentOrders = data['currentOrders'] ?? 0;

    if (data.containsKey('prodPrepTime')) {
      existingProdPrepTime = List<Map<String, dynamic>>.from(data['prodPrepTime']);
    }

    // Creiamo un set con i prodId già presenti
    Set<String> existingProdIds = existingProdPrepTime.map((e) => e['productId'] as String).toSet();
    print("🔹 Prodotti già presenti: $existingProdIds");

    // Nuovi prodotti da aggiungere
    List<Map<String, dynamic>> newProducts = [];
    int newPrepTimeSum = 0;

    for (var item in cartItems) {
      if (!existingProdIds.contains(item['productId'])) {
        newProducts.add({'productId': item['productId'], 'prepTime': item['prepTime']});
        newPrepTimeSum += (item['prepTime'] as int);
      }
    }

    print("🆕 Nuovi prodotti da aggiungere: $newProducts");
    print("⏳ Tempo di preparazione aggiunto: $newPrepTimeSum");

    // Calcoliamo il nuovo tempo totale di preparazione
    int updatedPrepTime = currentPrepTime + newPrepTimeSum;
    print("⚖️ Tempo di preparazione totale dopo aggiornamento: $updatedPrepTime / $maxPrepTime");

    // Aggiorniamo solo se il tempo di preparazione totale è inferiore a maxPrepTime
    if (updatedPrepTime <= maxPrepTime) {
      print("🔄 Aggiornamento consentito: aggiorniamo il documento.");
      await dateDocRef.set({
        'prodPrepTime': FieldValue.arrayUnion(newProducts),
        'currentPrepTime': updatedPrepTime,
        'currentOrders': currentOrders + 1, // Aggiungiamo un ordine
      }, SetOptions(merge: true));

      print("✅ Documento aggiornato con i nuovi prodotti.");
      return true; // Aggiornamento avvenuto
    } else {
      print("❌ Limite di preparazione superato. Nessun aggiornamento effettuato.");
      return false; // Aggiornamento bloccato
    }
  } catch (e) {
    print("❌ Errore durante l'aggiornamento: $e");
    return false; // Ritorna false in caso di errore
  }
}






Future<bool> checkPreparationLimit(DateTime selectedDate, List<Map<String, dynamic>> cartItems) async {
  // Formatta la data come stringa (chiave documento)
  String formattedDate = "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";

  // Riferimento alla collezione Firestore
  CollectionReference dailyLimits = FirebaseFirestore.instance.collection('dailyLimits');

  // Riferimento al documento della data scelta
  DocumentReference dateDocRef = dailyLimits.doc(formattedDate);

  try {
    // Ottieni il documento dal database
    DocumentSnapshot docSnapshot = await dateDocRef.get();

    if (!docSnapshot.exists) {
      // Se il documento non esiste, significa che non ci sono limiti superati → OK
      return true;
    }

    // Estrarre i dati esistenti
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

    List<Map<String, dynamic>> existingProdPrepTime = [];
    int currentPrepTime = 0;
    int maxPrepTime = 0;

    if (data.containsKey('prodPrepTime')) {
      existingProdPrepTime = List<Map<String, dynamic>>.from(data['prodPrepTime']);
    }
    if (data.containsKey('currentPrepTime')) {
      currentPrepTime = data['currentPrepTime'];
    }
    if (data.containsKey('maxPrepTime')) {
      maxPrepTime = data['maxPrepTime'];
    }

    // Creiamo un set con i prodId già presenti
    Set<String> existingProdIds = existingProdPrepTime.map((e) => e['productId'] as String).toSet();

    // Calcolare la somma dei nuovi tempi di preparazione da aggiungere
    int newPrepTimeSum = 0;
    for (var item in cartItems) {
      String prodId = item['productId'];
      int prepTime = item['prepTime'];

      if (!existingProdIds.contains(prodId)) {
        newPrepTimeSum += prepTime;
      }
    }

    // Controllo se la somma dei nuovi prepTime supera maxPrepTime
    if ((currentPrepTime + newPrepTimeSum) > maxPrepTime) {
      return false; // Troppo lavoro, ordine non possibile
    }

    return true; // Ordine possibile
  } catch (e) {
    print("Errore durante il controllo del limite: $e");
    return false; // Se c'è un errore, meglio non permettere l'ordine
  }
}



