// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AuthService  extends ChangeNotifier{
//   //instance of auth
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

//   //instance of firestore
//   final FirebaseFirestore _fireStore = FirebaseFirestore.instance; 

//   //sign in
//   Future<UserCredential> signInWithEmailandPassword(String email, String password) async {
//     try {
//       //sign in
//       UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
//         email: email, 
//         password: password
//       );

//       //add a new document
//       _fireStore.collection('users').doc(userCredential.user!.uid).set({
//         'uid' : userCredential.user!.uid,
//         'email' : email,
//       }, SetOptions(merge: true));

//       return userCredential;
//     }
//     //catch error
//     on FirebaseAuthException catch (e) {
//       throw Exception(e.code);
//     }
//   }

//   //sign out
//   Future<void> signOut() async {
//     return await FirebaseAuth.instance.signOut();
//   }

//   // create user
//   Future<UserCredential> signUpWithEmailandPassword(String email, String password) async {
//     try {
//       UserCredential userCredential = await _firebaseAuth. createUserWithEmailAndPassword(
//         email: email, 
//         password: password
//       );

//       _fireStore.collection('users').doc(userCredential.user!.uid).set({
//         'uid' : userCredential.user!.uid,
//         'email' : email,
//       });

//       return userCredential;
//     }on FirebaseAuthException catch (e) {
//       throw Exception(e.code);
//     }
//   }
// }