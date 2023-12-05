import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? getCurrentUserUid() {
    return _auth.currentUser?.uid;
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addItem(String itemName, String description, String maintenanceDate, File? pickedImage) async {
    try {
      // Upload the image to Firebase Storage
      String imageUrl = await _uploadImage(pickedImage);

      // Add the item details to Firestore
      await _firestore.collection('items').add({
        'name': itemName,
        'description': description,
        'maintenanceDate': maintenanceDate,
        'imageUrl': imageUrl,
        // Add more fields as needed
      });
    } catch (e) {
      print('Error adding item: $e');
    }
  }

  Stream<QuerySnapshot> getItems() {
    return _firestore.collection('items').snapshots();
  }

  Future<String> _uploadImage(File? pickedImage) async {
    if (pickedImage == null) {
      return ''; // Return an empty string if no image is provided
    }

    try {
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('images/$imageName');
      await storageReference.putFile(pickedImage);
      String imageUrl = await storageReference.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return ''; // Return an empty string in case of an error
    }
  }
}
