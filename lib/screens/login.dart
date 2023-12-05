// Import necessary packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import local Dart files and third-party buttons
import '../utils/authentication.dart';
import 'package:sign_in_button/sign_in_button.dart';

// Define the LoginPage StatelessWidget
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // "Sign In/" text
            Text(
              'Sign In/',
              style: GoogleFonts.montserrat(
                fontSize: 33,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            // "Sign Up" text
            Text(
              'Sign Up',
              style: GoogleFonts.montserrat(
                fontSize: 33,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 60),

            // Logo image
            Container(
              height: 250,
              child: Image.asset(
                'assets/images/loginicon.png',
                scale: 0.2,
              ),
            ),
            SizedBox(height: 50),

            // Google Sign In button
            GoogleSignInButton(),

            // Apple Sign In button
            SizedBox(height: 9),
            AppleSignInButton(),
          ],
        ),
      ),
    );
  }
}

// StatelessWidget for the Google Sign In button
class GoogleSignInButton extends StatelessWidget {
  final AuthenticationService _authService = AuthenticationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 50,
        child: SignInButton(
          Buttons.google,
          text: "Sign up with Google",
          onPressed: () async {
            // Sign in with Google
            final User? user = await _authService.signInWithGoogle();

            if (user != null) {
              // Create a document for the user in Firestore
              final docRef = _firestore.collection('users').doc(user!.uid);
              docRef.set({
                'name': user.displayName,
                'email': user.email,
              });

              // Navigate to the inventory page after successful sign-in
              Navigator.pushNamed(context, 'inventory');
              print('User signed in: ${user.displayName}');
            } else {
              // Handle Google Sign-In failure
              print('Google Sign-In failed.');
            }
          },
        ),
      ),
    );
  }
}

// StatelessWidget for the Apple Sign In button
class AppleSignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Apple logo image
          Image.asset(
            'assets/images/apple.png',
            width: 20,
            height: 20,
            color: Colors.white,
          ),
          SizedBox(width: 10),
          // Text for "Sign In with Apple"
          Text(
            'Sign In with Apple',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
