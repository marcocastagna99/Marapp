import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({Key? key}) : super(key: key);

  @override
  OrdersViewState createState() => OrdersViewState();
}

class OrdersViewState extends State<OrdersView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // Otteniamo l'utente attualmente autenticato
    User? user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
        ),
        body: const Center(
          child: Text('Please log in to see your orders.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Filtriamo la query per mostrare solo gli ordini dell'utente corrente
        stream: _firestore
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot documentSnapshot = snapshot.data!.docs[index];

              // Estrazione dei dati
              String orderId = documentSnapshot.id;
              Timestamp deliveryPreparationDate = documentSnapshot['DeliveryPreparationDate'];
              List<dynamic> items = documentSnapshot['items'];
              double total = documentSnapshot['total'];
              String status = documentSnapshot['status'];
              String userId = documentSnapshot['userId'];
              Timestamp orderDateTimestamp = documentSnapshot['orderDate'];

              // Conversione timestamp in DateTime
              DateTime orderDate = orderDateTimestamp.toDate();
              DateTime preparationDate = deliveryPreparationDate.toDate();

              // Formattazione delle date
              String formattedOrderDate = '${orderDate.day}/${orderDate.month}/${orderDate.year}';
              String formattedPreparationDate = '${preparationDate.day}/${preparationDate.month}/${preparationDate.year}';

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Order ID: $orderId'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Date: $formattedOrderDate'),
                      Text('Preparation Date: $formattedPreparationDate'),
                      Text('Status: $status'),
                      Text('Total: \$${total.toStringAsFixed(2)}'),
                      const SizedBox(height: 5),
                      const Text('Items:'),
                      ...items.map((item) {
                        return Text('- Product ID: ${item['prodId']} x${item['quantity']}');
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
