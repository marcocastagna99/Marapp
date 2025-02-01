import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/material.dart';
import 'package:marapp/views/secrets.dart';

class AddressSearch extends StatefulWidget {
  final DateTime selectedDate; // Add selectedDate here if you want to pass it

  AddressSearch({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _AddressSearchState createState() => _AddressSearchState(); // Implementing createState
}

class _AddressSearchState extends State<AddressSearch> {
  TextEditingController _controller = TextEditingController();

  // Sostituisci questa con la tua chiave API
  final String apiKey = Secrets.OpenCageapiKey;

  // Funzione per cercare i suggerimenti
  Future<List<String>> fetchSuggestions(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final url = 'https://api.opencagedata.com/geocode/v1/json?q=$query&key=$apiKey&language=it&limit=5';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<String> suggestions = [];
      for (var result in data['results']) {
        suggestions.add(result['formatted']);
      }
      return suggestions;
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Address Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: (TypeAheadField<String>(
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Search Address',
                border: OutlineInputBorder(),
              ),
            );
          },
          suggestionsCallback: fetchSuggestions,
          itemBuilder: (context, suggestion) {
            return ListTile(
              title: Text(suggestion),
            );
          },
          onSelected: (suggestion) {
            print('Selected address: $suggestion');
          },
        )
        ),
      ),
    );
  }
}
