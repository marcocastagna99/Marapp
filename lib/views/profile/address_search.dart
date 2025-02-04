import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:marapp/views/secrets.dart';


class AddressSearchDelegate extends SearchDelegate<String> {
  static final String apiKey = dotenv.env['OpenCageapiKey'] ?? '';
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text('Start typing to search for an address'),
      );
    }

    return FutureBuilder<List<String>>(
      future: fetchSuggestions(query), // Usa la funzione fetchSuggestions
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No suggestions found.'));
        }

        List<String> suggestions = snapshot.data!;

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return ListTile(
              title: Text(suggestion),
              onTap: () {
                close(context, suggestion); // Chiude la ricerca con il risultato selezionato
              },
            );
          },
        );
      },
    );
  }

  // Funzione per recuperare i suggerimenti dall'API
  static Future<List<String>> fetchSuggestions(String query) async {
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
}
