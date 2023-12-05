// Import necessary packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import local Dart files
import 'additem.dart';
import '../utils/authentication.dart';
import 'package:inventory/models/itemmodel.dart';

// Define a User class
class User {
  String name;
  String email;

  User({
    required this.name,
    required this.email,
  });
}

// Define the ItemDetailsPage StatelessWidget
class ItemDetailsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Details'),
        actions: [
          ProfileButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 15),

            // Container for the header with a background image
            Container(
              height: 200,
              width: screenWidth,
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg.jpg'),
                  fit: BoxFit.cover,
                  opacity: 0.2,
                ),
              ),
              child: Center(
                child: Text(
                  'Item Details',
                  style: GoogleFonts.oswald(
                    fontSize: 33,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),

            // Button to add a new item
            AddItemButton(),

            // StreamBuilder to fetch and display items from Firestore
            StreamBuilder(
              stream: _firestore
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('items')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                // Loading indicator while data is being fetched
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                // Map document data to Item objects
                List<Item> itemList = snapshot.data!.docs.map((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  return Item(
                    name: data['name'] ?? '',
                    installmentDate: data['installment_date'] ?? '',
                    maintenanceDate: data['maintainance_date'] ?? '',
                    imageUrl: data['image'] ?? '',
                    documentId: doc.id, // Retrieve document ID
                  );
                }).toList();

                // Display items in a ListView
                return itemList.isEmpty
                    ? Text('No items available.')
                    : ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: itemList.map((item) {
                    return GestureDetector(
                      onTap: () {
                        showItemDetails(context, item);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            SizedBox(height: 10),
                            Expanded(
                              flex: 4,
                              child: ListTile(
                                title: Text(
                                  '${item.name} - ${item.installmentDate ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: item.imageUrl != null
                                  ? Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(item.imageUrl!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                                  : Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey,
                                child: Icon(
                                  Icons.image,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  // Function to show detailed information about an item in a dialog
  void showItemDetails(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item.name),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Installment Date: ${item.installmentDate ?? 'N/A'}'),
              Text('Maintenance Date: ${item.maintenanceDate ?? 'N/A'}'),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Confirm deletion with a dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirm Delete'),
                          content: Text('Are you sure you want to delete this item?'),
                          actions: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.pop(context),
                            ),
                            TextButton(
                              child: Text('Delete'),
                              onPressed: () async {
                                // Delete the item using the retrieved ID
                                await _firestore
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('items')
                                    .doc(item.documentId!) // Use "!" as the ID is non-nullable
                                    .delete();

                                // Close all dialogs after deleting
                                Navigator.pop(context); // Close confirmation dialog
                                Navigator.pop(context); // Close item details dialog

                                // Show a snackbar to confirm deletion
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Item deleted successfully!'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// StatelessWidget for the "Add Item" button
class AddItemButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, 'additem');
      },
      child: Container(
        width: 150,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              'Add item',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// StatelessWidget for the profile button in the app bar
class ProfileButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.account_circle),
      onPressed: () {
        showProfileMenu(context);
      },
    );
  }

  // Function to show a profile menu in a dialog
  void showProfileMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: _getUserData(),
          builder: (context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              User? user = snapshot.data;
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(user?.name ?? ''),
                      subtitle:
                      Text(user?.email ?? ''),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('Logout'),
                      onTap: () async {
                        await AuthenticationService().signOut();
                        Navigator.pushNamed(context, 'login');
                      },
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }

  Future<User?> _getUserData() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {

      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('users').doc(currentUser.uid).get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;
        return User(
          name: data['name'] ?? '',
          email: data['email'] ?? '',
        );
      }
    }

    return null;
  }
}
