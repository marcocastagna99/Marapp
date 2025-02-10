import 'package:flutter/material.dart';

import 'products/products.dart';
import 'settings.dart';
import 'orders/orders.dart';
import 'profile/profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0; // Indice per tenere traccia della pagina corrente

  final List<Widget> _screens = [
    const ProductsView(),
    const OrdersView(),
    const ProfileView(),
    const SettingsView(),
  ];

  // Metodo chiamato ogni volta che la pagina cambia tramite swipe
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Usa l'indice della pagina corrente
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Aggiorna l'indice quando viene cliccata un'icona
          });
          _pageController.jumpToPage(index); // Vai alla pagina selezionata
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.cookie),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_restaurant),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
