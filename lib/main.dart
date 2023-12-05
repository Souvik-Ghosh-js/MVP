  import 'package:flutter/material.dart';
  import 'screens/login.dart';
  import 'services/firebase_options.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'screens/inventory.dart';
  import 'screens/additem.dart';
  import 'package:firebase_app_check/firebase_app_check.dart';






  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform
    );
    final appCheck = FirebaseAppCheck.instance;


    runApp(
        MaterialApp(
          title: 'Inventory',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Poppins',
            useMaterial3: true,
          ),

          initialRoute: 'login',
          routes: {
            'login' : (context)=> LoginPage(),
            'inventory' : (context)=> ItemDetailsPage(),
            'additem' : (context)=> AddItemPage(),

          },
        ));
  }