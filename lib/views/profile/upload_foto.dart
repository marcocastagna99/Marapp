import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // Per kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img; // Per la compressione delle immagini
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ProfilePictureUploader {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  File? _image; // Per mobile
  Uint8List? _webImage; // Per web
  bool _isLoading = false; // Stato per la rotella di caricamento

  Uint8List compressImage(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    final resizedImage = img.copyResize(image!, width: 800);
    return Uint8List.fromList(img.encodeJpg(resizedImage, quality: 85));
  }

  // Funzione per scegliere un'immagine e caricarla
  Future<String> pickAndUploadImage(BuildContext context) async {
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
        if (kIsWeb) {
          _webImage = await file.readAsBytes();
          //return await uploadImageToVercel(context);
        } else {
          _image = File(file.path);
        }
        return await uploadImage(context);
      }
    }
    return 'No image selected';
  }

  // Funzione per caricare l'immagine su Imgur e salvarla su Firestore


  Future<String> uploadImage(BuildContext context) async {
    if (_image == null && _webImage == null) return 'No image selected';

    try {
      Uint8List bytes = kIsWeb ? _webImage! : await _image!.readAsBytes();
      bytes = compressImage(bytes); // Comprimi l'immagine

      String base64Image = base64Encode(bytes);

      final url = Uri.parse('https://api.imgur.com/3/image');
      final headers = {
        'Authorization': 'Bearer ${dotenv.env['imgurAuthToken']}',
        'Content-Type': 'application/json',  // Importante per il JSON
      };

      final body = jsonEncode({
        'image': base64Image,
        'type': 'base64',
      });

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final uploadedImageUrl = responseData['data']['link'];

        User? user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'profilePicture': uploadedImageUrl,
          });
        }

        return 'Image uploaded successfully!';
      } else {
        print('Error: ${response.body}'); // Stampa l'errore della richiesta
        return 'Failed to upload image: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error uploading image: $e';
    }
  }









  Future<String> uploadImageToVercel(BuildContext context) async {
    if (_image == null && _webImage == null) return 'No image selected';

    try {
      Uint8List bytes = kIsWeb ? _webImage! : await _image!.readAsBytes();
      bytes = compressImage(bytes); // Comprimi l'immagine

      // Fai una richiesta POST al backend su Vercel
      final url = Uri.parse('https://marapp-backend.vercel.app/api/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['image'] = base64Encode(bytes); // Invia l'immagine in base64

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseData = jsonDecode(responseBody);
        final uploadedImageUrl = responseData['imageUrl'];

        // Salva l'URL su Firestore
        User? user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'profilePicture': uploadedImageUrl,
          });
        }

        return 'Image uploaded successfully!';
      } else {
        return 'Failed to upload image: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error uploading image: $e';
    }
  }
}

