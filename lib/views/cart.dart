import 'package:flutter/material.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  CartViewState createState() => CartViewState();
}

class CartViewState extends State<CartView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Center(
        child: Text('Cart'),
      ),
    );
  }
}
