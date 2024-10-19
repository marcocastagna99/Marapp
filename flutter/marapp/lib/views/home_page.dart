import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Assicurati di importare Firebase
import 'login_signup_view.dart';  // Importa la vista di login/signup


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    ProductsView(),
    CartView(),
    ProfileView(),  // Qui si trova il pulsante di logout
    SettingsView(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: Colors.transparent,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.cookie, color: _currentIndex == 0 ? Colors.blue : Colors.grey),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dining, color: _currentIndex == 1 ? Colors.blue : Colors.grey),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: _currentIndex == 2 ? Colors.blue : Colors.grey),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: _currentIndex == 3 ? Colors.blue : Colors.grey),
            label: 'Settings',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class ProductsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: Center(
        child: Text('Qui verranno visualizzati i prodotti'),
      ),
    );
  }
}

class CartView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Center(
        child: Text('Qui verranno visualizzati gli articoli nel carrello'),
      ),
    );
  }
}

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Profile'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logica per il logout
                FirebaseAuth.instance.signOut();  // Disconnette l'utente
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginSignupView()),  // Reindirizza alla schermata di login
                );
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Text('Qui verranno visualizzate le impostazioni'),
      ),
    );
  }
}
