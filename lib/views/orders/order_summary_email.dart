import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendOrderSummaryEmail(String userEmail, List<dynamic> items, DateTime orderDate, DateTime deliveryDate, double orderTotal, double deliveryCost) async {
  // Carica le variabili di ambiente
  await dotenv.load();
  print('Dotenv loaded');

  // Recupera le informazioni dal file .env
  final String apiKey = dotenv.env['API_KEY'] ?? ''; // La tua API Key
  final String serviceId = dotenv.env['SERVICE_ID'] ?? ''; // Il tuo Service ID
  final String templateId = dotenv.env['TEMPLATE_ID'] ?? ''; // Il tuo Template ID

  // Debug: Controlliamo i valori caricati dal file .env
  print('API Key: $apiKey');
  print('Service ID: $serviceId');
  print('Template ID: $templateId');

  // Crea il corpo dell'email
  final emailBody = {
    'to_email': userEmail,
    'from_name': 'Marapp', // Nome del negozio o dell'app
    'formattedOrderDate': '${orderDate.day}/${orderDate.month}/${orderDate.year}',
    'formattedDeliveryDate': '${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}',
    'items': items.map((item) {
      return {
        'productName': item['productName'],
        'quantity': item['quantity'],
        'productPrice': item['productPrice'],
        'itemTotal': item['itemTotal'],
      };
    }).toList(),
    'deliveryCost': deliveryCost.toString(),
    'total': (orderTotal + deliveryCost).toStringAsFixed(2),
  };

  // Debug: Controlliamo il corpo dell'email
  print('Email body: $emailBody');

  // L'endpoint di EmailJS
  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  print('Sending request to: $url');

  // Crea il corpo della richiesta JSON
  final body = jsonEncode({
    'service_id': serviceId,
    'template_id': templateId,
    'user_id': apiKey, // L'API Key viene utilizzata come 'user_id'
    'template_params': emailBody,
  });

  // Debug: Controlliamo il corpo della richiesta
  print('Request body: $body');

  // Impostazioni della richiesta HTTP
  final headers = {
    'Content-Type': 'application/json',
  };

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      print('Email sent successfully');
    } else {
      print('Failed to send email. Status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error sending email: $e');
  }
}
