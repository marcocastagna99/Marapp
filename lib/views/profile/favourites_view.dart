import 'package:flutter/material.dart';

class FavouritesView extends StatelessWidget {
  const FavouritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Favourite Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Mocked list of favourite items
            ListTile(
              title: const Text('Item 1'),
              leading: const Icon(Icons.favorite, color: Colors.red),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // Implement remove functionality
                },
              ),
            ),
            ListTile(
              title: const Text('Item 2'),
              leading: const Icon(Icons.favorite, color: Colors.red),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // Implement remove functionality
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement add new favourite item functionality
              },
              child: const Text('Add to Favourites'),
            ),
          ],
        ),
      ),
    );
  }
}
