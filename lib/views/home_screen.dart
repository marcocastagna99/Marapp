import 'package:flutter/material.dart';

import 'profile.dart'; // Importa la vista del profilo
//import 'products_view.dart';  // Importa la vista dei prodotti
//import 'cart_view.dart';      // Importa la vista del carrello
//import 'settings_view.dart';  // Importa la vista delle impostazioni

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    ProductsView(),
    CartView(),
    ProfileView(), // Qui si trova il profilo dell'utente
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
            icon: Icon(Icons.cookie,
                color: _currentIndex == 0 ? Colors.blue : Colors.grey),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart,
                color: _currentIndex == 1 ? Colors.blue : Colors.grey),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,
                color: _currentIndex == 2 ? Colors.blue : Colors.grey),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings,
                color: _currentIndex == 3 ? Colors.blue : Colors.grey),
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

// Definizione delle varie viste

class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

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
  const CartView({super.key});

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

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

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
