import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';  // Importa il pacchetto intl
import '../profile/address_search.dart'; // Importa il delegate per la ricerca
import 'order_management.dart';
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
  bool isNewAddress = false;
  bool showSummary = false;


  @override
  void initState() {
    super.initState();
    _loadExistingAddress();
  }

  // Recupera l'indirizzo esistente dal database
  Future<void> _loadExistingAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          existingAddress = snapshot.data()?['address'];
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

    final orderDate = Timestamp.fromDate(DateTime.now());
    final deliveryPreparationDate = Timestamp.fromDate(widget.selectedDate);


    final List<Map<String, dynamic>> items = widget.cartItems.map((item) {
      return {
        'prodId': item['productId'], // Assicurati che ogni item abbia un campo 'id'
        'quantity': item['quantity'],
        'prepTime': item['prepTime'] ?? 0, // Usa un valore di default se prepTime non è presente
      };
    }).toList();

    final orderData = {
      'userId': user.uid,
      'orderDate': orderDate,
      'DeliveryPreparationDate': deliveryPreparationDate,
      'items': items,
      'status': 'paid', // Puoi cambiare lo stato in base al metodo di pagamento
      'total': getTotalPrice(),
    };

    try {
      bool valid= await updateDailyLimit(widget.selectedDate, widget.cartItems);
      if(valid){
        await FirebaseFirestore.instance.collection('orders').add(orderData);
        await checkAndUpdateAvailability(widget.selectedDate);
        //empty the cart
        widget.clearCart();
        widget.saveCartToFirestore();



        // NAVIGA ALLA SCHERMATA DI RINGRAZIAMENTO
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ThankYouScreen()),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Mostra o nasconde il riepilogo al clic del pulsante
                      setState(() {
                        showSummary = !showSummary;
                      });
                    },
                    child: Text(showSummary ? 'Hide Summary' : 'Show Summary'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedPaymentMethod != null && widget.selectedDate != null) {
                        _saveOrder();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Order saved!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please, fill all fields')),
                        );
                      }
                    },
                    child: Text('Confirm the Order'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),

              // Mostra il riepilogo solo se showSummary è true
              if (showSummary)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: AlertDialog(
                    title: Text('Order Summary'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Delivery Date: $formattedDate'),
                        ...widget.cartItems.map((item) {
                          return Text('${item['name']} x${item['quantity']} - €${(item['price'] * item['quantity']).toStringAsFixed(2)}');
                        }).toList(),
                        Text('Delivery Cost: €1.00'),
                        Text('Total: €${getTotalPrice().toStringAsFixed(2)}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            showSummary = false;
                          });
                        },
                        child: Text('Close'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
