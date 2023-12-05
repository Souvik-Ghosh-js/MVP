import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/authentication.dart';
import 'package:sign_in_button/sign_in_button.dart';


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
            final User? user = await _authService.signInWithGoogle();

            if (user != null) {
              final docRef = _firestore.collection('users').doc(user!.uid);
              docRef.set({
                'name': user.displayName,
                'email': user.email,
              });

              Navigator.pushNamed(context, 'inventory');
              print('User signed in: ${user.displayName}');
            } else {
              print('Google Sign-In failed.');
            }
          },
        ),
      ),
    );
  }
}




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
          Image.asset(
            'assets/images/apple.png',
            width: 20,
            height: 20,
            color: Colors.white,
          ),
          SizedBox(width: 10),
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