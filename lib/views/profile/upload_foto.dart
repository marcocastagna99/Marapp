import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePictureUploader extends StatefulWidget {
  @override
  _ProfilePictureUploaderState createState() =>
      _ProfilePictureUploaderState();
}

class _ProfilePictureUploaderState extends State<ProfilePictureUploader> {
  File? _image;
  String? _uploadedImageUrl;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Funzione per scegliere un'immagine dalla galleria o scattarla
  Future<void> _pickImage() async {
    final pickedFile = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick Image Source'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Gallery'),
          ),
        ],
      ),
    );

    if (pickedFile != null) {
      final file = await _picker.pickImage(source: pickedFile);
      if (file != null) {
        setState(() {
          _image = File(file.path);
        });
      }
    }
  }

  // Funzione per caricare l'immagine su Imgur
  Future<void> _uploadImage() async {
    if (_image == null) return;

    // Converti l'immagine in base64
    final bytes = _image!.readAsBytesSync();
    String base64Image = base64Encode(bytes);

    // URL per caricare l'immagine su Imgur
    final url = Uri.parse('https://api.imgur.com/3/image');
    final headers = {
      'Authorization': 'Bearer 3c63568977bc47a4fb662f88b52e2ee401a524d2',
    };

    final body = {
      'image': base64Image,
      'type': 'base64',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _uploadedImageUrl = responseData['data']['link']; // Link dell'immagine caricata
        });

        // Salva l'URL dell'immagine in Firestore sotto il documento dell'utente
        User? user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'profilePicture': _uploadedImageUrl,
          });
        }

        print("Image uploaded and URL saved to Firestore.");
      } else {
        // Gestisci errore
        print('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  // Funzione per caricare l'immagine dal Firebase Firestore
  Future<String?> _getProfilePictureUrl() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user.uid).get();
      return userDoc['profilePicture'];  // L'URL dell'immagine salvato in Firestore
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Profile Picture')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (_image != null) ...[
            Image.file(_image!),  // Mostra l'immagine selezionata
            const SizedBox(height: 20),
          ],
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text('Pick an Image'),
          ),
          ElevatedButton(
            onPressed: _uploadImage,
            child: const Text('Upload Image to Imgur'),
          ),
          if (_uploadedImageUrl != null) ...[
            const SizedBox(height: 20),
            Image.network(_uploadedImageUrl!), // Mostra l'immagine caricata
          ],
          // Carica e visualizza l'immagine dal Firestore quando disponibile
          FutureBuilder<String?>(
            future: _getProfilePictureUrl(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasData) {
                return snapshot.data != null
                    ? Image.network(snapshot.data!)
                    : const Text('No profile picture found.');
              } else {
                return const Text('Error loading profile picture.');
              }
            },
          ),
        ],
      ),
    );
  }
}
