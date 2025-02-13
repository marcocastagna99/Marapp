import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'package:http/http.dart' as http;

class PushNotificationService {
  // Metodo per monitorare i cambiamenti dello stato dell'ordine
  void monitorOrderStatusChanges(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Verifica se l'utente è autenticato
    if (authProvider.isAuthenticated) {
      FirebaseFirestore.instance
          .collection('orders') // Collezione degli ordini
          .snapshots()
          .listen((snapshot) {
        for (var doc in snapshot.docChanges) {
          if (doc.type == DocumentChangeType.modified) {
            var order = doc.doc.data()!;
            String orderStatus = order['status']; // Stato dell'ordine
            String userId = order['userId']; // Id dell'utente
            String orderId = doc.doc.id;

            // Ottieni il playerId di OneSignal dell'utente (salvato in Firestore)
            FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get()
                .then((userDoc) {
              String oneSignalPlayerId = userDoc.data()!['oneSignalPlayerId'];

              // Invia la notifica push tramite OneSignal
              sendStatusPushNotification(oneSignalPlayerId, orderId, orderStatus);
            });
          }
        }
      });
    } else {
      print(
          "L'utente non è autenticato. Non è possibile monitorare gli ordini.");
    }
  }

  // Metodo per inviare una notifica push
  void sendStatusPushNotification(String playerId, String orderId, String status) async {
    String heading = "Order Update";
    String content = "";

    switch (status) {
      case "pending":
        content = "We've received your order #$orderId and it's being processed.";
        break;
      case "confirmed":
        content = "Your order #$orderId has been confirmed! We'll start preparing it soon.";
        break;
      case "preparing":
        content = "Your order #$orderId is now being prepared. It won't be long!";
        break;
      case "ready":
        content = "Your order #$orderId is ready for pickup or delivery!";
        break;
      case "outForDelivery":
        content = "Great news! Your order #$orderId is on its way.";
        break;
      case "delivered":
        content = "Your order #$orderId has been delivered. Enjoy your meal!";
        break;
      case "canceled":
        content = "Unfortunately, your order #$orderId has been cancelled. Contact us for more details.";
        break;
      default:
        content = "Your order #$orderId status has been updated to: $status.";
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Basic ${dotenv.env['ONE_SIGNAL_API_KEY']!}" // API Key sicura
    };

    var body = jsonEncode({
      "app_id": dotenv.env['ONE_SIGNAL_APP_ID']!,
      "include_player_ids": [playerId],
      "headings": {"en": heading},
      "contents": {"en": content}
    });

    var response = await http.post(
      Uri.parse("https://onesignal.com/api/v1/notifications"),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      print("✅ Notifica inviata con successo: ${response.body}");
    } else {
      print("❌ Errore nell'invio della notifica: ${response.body}");
    }
  }


  // Metodo statico per inizializzare OneSignal
  static void initializeOneSignal() {
    if (!kIsWeb) {
      OneSignal.shared.setAppId(dotenv.env['ONE_SIGNAL_APP_ID']!);

      // Richiedi il permesso per le notifiche push
      OneSignal.shared.promptUserForPushNotificationPermission().then((
          accepted) {
        if (accepted) {
          print("User accepted push notifications");
        } else {
          print("User declined push notifications");
        }
      });

      // Puoi anche recuperare il Player ID dopo che l'utente ha accettato
      OneSignal.shared.getDeviceState().then((deviceState) {
        String? playerId = deviceState?.userId;
        print("Player ID: $playerId"); // Salva questo ID per inviare notifiche
      });
    }
    else
      print("OneSignal non supportato su Web, bypassing...");
  }

  static sendTestPushNotification(String playerId) async {
    String heading = "Test Notification";
    String content = "Ciao, this is a test notification from Marapp.";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Basic ${dotenv.env['ONE_SIGNAL_API_KEY']!}" // API Key sicura
    };

    var body = jsonEncode({
      "app_id": dotenv.env['ONE_SIGNAL_APP_ID']!,
      "include_player_ids": [playerId],
      "headings": {"en": heading},
      "contents": {"en": content}
    });

    var response = await http.post(
      Uri.parse("https://onesignal.com/api/v1/notifications"),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      print("✅ Notifica inviata con successo: ${response.body}");
    } else {
      print("❌ Errore nell'invio della notifica: ${response.body}");
    }
  }






}
