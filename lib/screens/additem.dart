// Import necessary packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Import custom Firebase service
import '../services/firebase_service.dart';

// Create a StatefulWidget for the AddItemPage
class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

// Create the State class for AddItemPage
class _AddItemPageState extends State<AddItemPage> {
  // Variables and controllers for managing state
  XFile? pickedImage;
  FirebaseService _firebaseService = FirebaseService();
  TextEditingController itemNameController = TextEditingController();
  TextEditingController maintenanceDateController = TextEditingController();
  TextEditingController installmentController = TextEditingController();

  String imageUrl = '';
  CollectionReference _reference = FirebaseFirestore.instance.collection('users');
  GlobalKey<FormState> key = GlobalKey();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Build the Scaffold widget for the AddItemPage
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // TextFormField for Item Name
              TextFormField(
                controller: itemNameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the item name.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                  hintText: 'Enter the item name',
                ),
              ),
              SizedBox(height: 12),

              // TextFormField for Installment Date
              TextFormField(
                controller: installmentController,
                onTap: () async {
                  // Show date picker when tapping on the Installment Date field
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  // Update the Installment Date field with the selected date
                  if (pickedDate != null && pickedDate != DateTime.now()) {
                    installmentController.text = pickedDate.toLocal().toString().split(' ')[0];
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Installment Date',
                  border: OutlineInputBorder(),
                  hintText: 'Select the installment date',
                ),
              ),
              SizedBox(height: 12),

              // TextFormField for Maintenance Date
              TextFormField(
                controller: maintenanceDateController,
                onTap: () async {
                  // Show date picker when tapping on the Maintenance Date field
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  // Update the Maintenance Date field with the selected date
                  if (pickedDate != null && pickedDate != DateTime.now()) {
                    maintenanceDateController.text = pickedDate.toLocal().toString().split(' ')[0];
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Maintenance Date',
                  border: OutlineInputBorder(),
                  hintText: 'Select the maintenance date',
                ),
              ),
              SizedBox(height: 12),

              // Stack for handling image upload
              Stack(
                children: [
                  IconButton(
                    onPressed: () async {
                      // Open image picker to choose an image from the gallery
                      ImagePicker imagePicker = ImagePicker();
                      XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
                      if (file == null) return;

                      // Get the chosen image file
                      final imageFile = File(file.path);

                      // Set loading state to true while uploading image
                      setState(() {
                        isLoading = true;
                      });

                      try {
                        // Generate a unique file name for the image
                        final uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

                        // Reference to Firebase Storage
                        Reference referenceRoot = FirebaseStorage.instance.ref();
                        Reference referenceDirImages = referenceRoot.child('images');
                        Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

                        // Upload the image to Firebase Storage
                        await referenceImageToUpload.putFile(imageFile);

                        // Get the download URL of the uploaded image
                        imageUrl = await referenceImageToUpload.getDownloadURL();
                      } catch (error) {
                        // Handle errors during image upload
                        print('Error uploading image: $error');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Image upload failed!')),
                        );
                      } finally {
                        // Set loading state to false after image upload
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    icon: Icon(Icons.camera_alt),
                  ),
                  // Display a loading indicator while uploading an image
                  if (isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black45,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8),

              // Display text if no image is uploaded
              if (imageUrl.isEmpty)
                Text(
                  '   Upload an image',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              SizedBox(height: 16),

              // ElevatedButton for saving the item
              ElevatedButton(
                onPressed: () async {
                  // Validate the form before saving the item
                  if (key.currentState!.validate()) {
                    // Get values from form fields
                    String itemName = itemNameController.text;
                    String installmentDate = installmentController.text;
                    String maintainanceDate = maintenanceDateController.text;

                    // Get the current user's ID
                    String userId = FirebaseAuth.instance.currentUser!.uid;

                    // Prepare data to be sent to Firestore
                    Map<String, dynamic> dataToSend = {
                      'name': itemName,
                      'installment_date': installmentDate,
                      'maintainance_date': maintainanceDate,
                      'image': imageUrl,
                      'user_id': userId,
                    };

                    // Add the item data to Firestore
                    await _reference.doc(userId).collection('items').add(dataToSend);

                    // Navigate back to the previous screen
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 13, horizontal: 25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Save Item',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
