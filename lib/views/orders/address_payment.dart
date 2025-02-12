import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';  // Importa il pacchetto intl
import '../profile/address_search.dart'; // Importa il delegate per la ricerca
import 'order_management.dart';
import 'order_summary_email.dart';
import 'thank_you.dart';
import '../products/cart.dart';

class AddressPaymentScreen extends StatefulWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> cartItems;
  final Function() clearCart;
  final Function() saveCartToFirestore;


  const AddressPaymentScreen({
    required this.selectedDate,
    required this.cartItems,
    required this.clearCart,
    required this.saveCartToFirestore,
    Key? key,
  }) : super(key: key);

  @override
  _AddressPaymentScreenState createState() => _AddressPaymentScreenState();
}

class _AddressPaymentScreenState extends State<AddressPaymentScreen> {
  TextEditingController addressController = TextEditingController();
  String? selectedPaymentMethod;
  String? existingAddress;
  String? userEmail;
  bool isNewAddress = false;
  bool showSummary = false;


  @override
  void initState() {
    super.initState();
    _loadExistingAddressAndEmail();
  }

  // Recupera l'indirizzo esistente dal database
  Future<void> _loadExistingAddressAndEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          existingAddress = snapshot.data()?['address'];
          userEmail= snapshot.data()?['email'];
        });
      }
    }
  }



  // Funzione per salvare l'ordine
  Future<void> _saveOrder() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in!')),
      );
      return;
    }

    // Determina quale indirizzo usare
    String finalAddress = isNewAddress ? addressController.text : (existingAddress ?? "");

    if (finalAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide an address')),
      );
      return;
    }

    final orderDate = Timestamp.fromDate(DateTime.now());
    final deliveryPreparationDate = Timestamp.fromDate(widget.selectedDate);

    final List<Map<String, dynamic>> items = widget.cartItems.map((item) {
      return {
        'prodId': item['productId'],
        'quantity': item['quantity'],
        'prepTime': item['prepTime'] ?? 0,
      };
    }).toList();

    final orderData = {
      'userId': user.uid,
      'orderDate': orderDate,
      'DeliveryPreparationDate': deliveryPreparationDate,
      'items': items,
      'status': 'paid',
      'total': getTotalPrice(),
      'address': finalAddress,
    };

    try {
      bool valid = await updateDailyLimit(widget.selectedDate, widget.cartItems);
      if (valid) {
        await FirebaseFirestore.instance.collection('orders').add(orderData);
        await checkAndUpdateAvailability(widget.selectedDate);

        print('item before sending email ${widget.cartItems}');
        sendOrderSummaryEmail(userEmail!, finalAddress, List.from(widget.cartItems), orderDate.toDate(), deliveryPreparationDate.toDate(), getTotalPrice(), 1.0);

        // Svuota il carrello
        widget.clearCart();
        widget.saveCartToFirestore();

        // Naviga alla schermata di ringraziamento
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ThankYouScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mara has received another order before yours, so the day is fully booked. Please try again another day as she cannot prepare your order on this date.'),
            duration: Duration(seconds: 8),
          ),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving order: $e')),
      );
    }
  }





  double getTotalPrice() {
    double total = 0.0;
    for (var item in widget.cartItems) {
      total += item['price'] * item['quantity'];
    }
    total += 1.0;  // Aggiungi 1€ per la consegna
    return total;
  }



  void _showSummaryDialog(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(widget.selectedDate);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Order Summary',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),

                Text(
                  'Delivery Date: $formattedDate',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),

                ...widget.cartItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      '${item['name']} x${item['quantity']} - €${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),

                SizedBox(height: 10),
                Text('Delivery Cost: €1.00', style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
                Text('Total: €${getTotalPrice().toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }







  @override
  Widget build(BuildContext context) {
    // Formatta la data senza l'ora
    String formattedDate = DateFormat('yyyy-MM-dd').format(widget.selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text("Address and Payment"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mostra l'indirizzo esistente o consenti l'inserimento di uno nuovo
              existingAddress != null ?
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  children: [
                    Text('Saved Address: $existingAddress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    Row(
                      children: [
                        Text('Use this address'),
                        Checkbox(
                          value: !isNewAddress,
                          onChanged: (bool? value) {
                            setState(() {
                              isNewAddress = !value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ) : SizedBox.shrink(),

              // Se l'utente ha scelto un nuovo indirizzo, mostra la ricerca intelligente
              if (isNewAddress)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ListTile(
                    title: TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'Search for a new address',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.streetAddress,
                      onTap: () async {
                        final selectedAddress = await showSearch(
                          context: context,
                          delegate: AddressSearchDelegate(),
                        );
                        if (selectedAddress != null) {
                          setState(() {
                            addressController.text = selectedAddress;
                          });
                        }
                      },
                    ),
                    trailing: Icon(Icons.search),
                  ),
                ),

              // Selezione del metodo di pagamento
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: DropdownButton<String>(
                  value: selectedPaymentMethod,
                  hint: Text("Select Payment Method"),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPaymentMethod = newValue;
                    });
                  },
                  items: <String>['Credit Card', 'PayPal', 'Cash']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),



              // Totale e Data di Consegna
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Total (without delivery): €${(getTotalPrice() - 1.0).toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Delivery Cost: €1.00', style: TextStyle(fontSize: 16)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Final Total: €${getTotalPrice().toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),

              // Pulsante per il riepilogo
              SizedBox(height: 30), // Spazio extra sopra i pulsanti
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showSummaryDialog(context);
                      },
                      icon: Icon(Icons.receipt_long, color: Colors.white), // Icona per il riepilogo
                      label: Text('Show Summary'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 20), // Distanza tra i pulsanti
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (selectedPaymentMethod != null && widget.selectedDate != null) {
                          _saveOrder();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please, fill all fields')),
                          );
                        }
                      },
                      icon: Icon(Icons.check_circle, color: Colors.white), // Icona per confermare
                      label: Text('Confirm Order'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20), // Spazio extra sotto i pulsanti

            ],
          ),
        ),
      ),
    );
  }
}
