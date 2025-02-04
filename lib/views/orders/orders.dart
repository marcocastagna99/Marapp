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

  // Recupera il nome del prodotto da Firestore
  Future<String> getProductName(String productId) async {
    DocumentSnapshot productSnapshot =
    await _firestore.collection('products').doc(productId).get();
    return productSnapshot.exists ? productSnapshot['name'] : 'Unknown Product';
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Orders')),
        body: const Center(child: Text('Please log in to see your orders.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('orderDate', descending: true)
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

              // Estrazione dati
              Timestamp deliveryDateTimestamp =
              documentSnapshot['DeliveryPreparationDate'];
              Timestamp orderDateTimestamp = documentSnapshot['orderDate'];
              List<dynamic> items = documentSnapshot['items'];
              double total = documentSnapshot['total'];
              String status = documentSnapshot['status'];

              // Formattazione date (giorno/mese/anno)
              DateTime deliveryDate = deliveryDateTimestamp.toDate();
              DateTime orderDate = orderDateTimestamp.toDate();
              String formattedDeliveryDate =
                  '${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}';
              String formattedOrderDate =
                  '${orderDate.day}/${orderDate.month}/${orderDate.year}';

              // Definizione colore dello stato
              Color statusColor;
              switch (status) {
                case 'paid':
                  statusColor = Colors.green;
                  break;
                case 'pending':
                  statusColor = Colors.orange;
                  break;
                case 'canceled':
                  statusColor = Colors.red;
                  break;
                case 'inPreparation':
                  statusColor = Colors.blue;
                  break;
                case 'outForDelivery': // In consegna
                  statusColor = Colors.blue;
                  break;
                case 'delivered':
                  statusColor = Colors.green[700]!;
                  break;

                default:
                  statusColor = Colors.grey;
              }

              return FutureBuilder<List<String>>(
                future: Future.wait(
                    items.map((item) => getProductName(item['prodId']))),
                builder: (context, productNamesSnapshot) {
                  if (!productNamesSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<String> productNames = productNamesSnapshot.data!;

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order: $formattedOrderDate',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'Delivery: $formattedDeliveryDate',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Products:',
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                              for (int i = 0; i < items.length; i++)
                                Text(
                                    '- ${productNames[i]} x${items[i]['quantity']}'),
                              const SizedBox(height: 8),
                              Text(
                                'Total: €${total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
