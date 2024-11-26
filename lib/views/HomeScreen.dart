import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marapp/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Ottieni l'utente attualmente autenticato dal provider
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user; // Supponiamo che 'user' contenga i dettagli dell'utente

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Esegui il logout e reindirizza alla pagina di login
              authProvider.logout();
              Navigator.of(context).pushReplacementNamed('/register');
            },
          ),
        ],
      ),
      body: Center(
        child: user != null
            ? Text(
          'Ciao ${user.displayName ?? user.email}!', // Mostra il nome utente o l'email
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        )
            : Text(
          'Ciao!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
