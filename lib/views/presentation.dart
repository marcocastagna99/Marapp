import 'package:flutter/material.dart';

class PresentationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade200, Colors.pink.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Marapp",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade700,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Do you want to treat your taste buds?\n"
                  "Can't choose between sweet or savory?\n\n"
                  "\"Marapp\" is exactly what you need!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 30),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/marapp.png"),
            ),
            SizedBox(height: 20),
            Text(
              "Let me introduce myself: I'm Mara, and I love cooking. "
                  "Here, you'll find a wide range of dishes, all carefully made in my kitchen. "
                  "I've especially picked some \"sweet and savory\" treats that have been with me since I was a child.\n"
                  "I can't wait for you to try them!\n\n"
                  "But first, take a look at the allergens.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // Azione per visualizzare gli allergeni
              },
              icon: Icon(Icons.info_outline),
              label: Text("View Allergens"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
