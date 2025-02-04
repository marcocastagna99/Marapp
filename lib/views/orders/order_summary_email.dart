import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<void> sendOrderSummaryEmail(
    String userEmail,
    List<Map<String, dynamic>> items,
    DateTime orderDate,
    DateTime deliveryDate,
    double orderTotal,
    double deliveryCost) async {

  await dotenv.load();
  print('Dotenv loaded');

  final String apiKey = dotenv.env['EMAILJS_API_KEY'] ?? '';
  final String serviceId = dotenv.env['SERVICE_ID'] ?? '';
  final String templateId = dotenv.env['TEMPLATE_ID'] ?? '';
  final String privateKey = dotenv.env['EMAILJS_PRIVATE_KEY'] ?? '';

  print('items: ${items}');

  String itemsList = items.map((item) {
    return "<li>${item['name']} x${item['quantity']}: €${item['price']} (Total: €${(item['price'] * item['quantity']).toStringAsFixed(2)})</li>";
  }).join("");


  final emailBody = {
    'to_email': userEmail,
    'from_name': 'Marapp',
    'formattedOrderDate': '${orderDate.day}/${orderDate.month}/${orderDate.year}',
    'formattedDeliveryDate': '${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}',
    'itemsList': itemsList, // Passa la stringa HTML
    'deliveryCost': deliveryCost.toStringAsFixed(2),
    'total': orderTotal.toStringAsFixed(2),
  };

  print('Email body: $emailBody');

  final data = {
    'service_id': serviceId,
    'template_id': templateId,
    'user_id': apiKey,
    'template_params': emailBody,
    'accessToken': privateKey,
  };

  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  print('Sending request to: $url');

  final body = jsonEncode(data);
  final headers = {'Content-Type': 'application/json'};

  try {
    final response = await http.post(url, headers: headers, body: body);

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
