import 'package:chatapp/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign Up
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Create user model
        UserModel newUser = UserModel(
          uid: result.user!.uid,
          username: username,
          email: email,
          isOnline: true,
          lastSeen: DateTime.now(),
        );

        // Save user to Firestore
        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(newUser.toJson());

        return newUser;
      }
    } catch (e) {
      print('Error in signUp: $e');
      return null;
    }
    return null;
  }

  // Sign In
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Update online status
        await _firestore.collection('users').doc(result.user!.uid).update({
          'isOnline': true,
          'lastSeen': DateTime.now().toIso8601String(),
        });

        // Get user data
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .get();

        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error in signIn: $e');
      return null;
    }
    return null;
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser!.uid).update({
          'isOnline': false,
          'lastSeen': DateTime.now().toIso8601String(),
        });
      }
      await _auth.signOut();
    } catch (e) {
      print('Error in signOut: $e');
    }
  }
}