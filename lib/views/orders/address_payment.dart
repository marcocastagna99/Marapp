import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../profile/address_search.dart'; // Importa il delegate per la ricerca

class AddressPaymentScreen extends StatefulWidget {
  final DateTime selectedDate;

  const AddressPaymentScreen({required this.selectedDate, Key? key}) : super(key: key);

  @override
  _AddressPaymentScreenState createState() => _AddressPaymentScreenState();
}

class _AddressPaymentScreenState extends State<AddressPaymentScreen> {
  TextEditingController addressController = TextEditingController();
  String? selectedPaymentMethod;
  String? existingAddress;
  bool isNewAddress = false;

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
  void _saveOrder() {
    // Qui salverai il nuovo indirizzo (se inserito) e il metodo di pagamento
    final order = {
      'address': isNewAddress ? addressController.text : existingAddress,
      'paymentMethod': selectedPaymentMethod,
      'date': widget.selectedDate,
    };

    // Logica per salvare l'ordine nel database
    print("Order saved: $order");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Address and Payment"),
        elevation: 0,
      ),
      body: SingleChildScrollView( // Aggiunto per consentire lo scorrimento
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centra il contenuto
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mostra l'indirizzo esistente o consenti l'inserimento di uno nuovo
              existingAddress != null ?
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0), // Spaziatura tra gli elementi
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
                  padding: const EdgeInsets.only(bottom: 20.0), // Spaziatura tra gli elementi
                  child: ListTile(
                    title: TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'Search for a new address',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.streetAddress,
                      onTap: () async {
                        // Mostra il delegate per la ricerca intelligente
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
                padding: const EdgeInsets.only(bottom: 20.0), // Spaziatura tra gli elementi
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

              // Pulsante per salvare l'ordine
              Center(
                child: ElevatedButton(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
