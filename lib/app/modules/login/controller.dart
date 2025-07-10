import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/user_model.dart';

class LoginController extends GetxController {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Delay the login check to avoid build conflicts
    Future.delayed(Duration(milliseconds: 100), () {
      checkLoginStatus();
    });
  }

  Future<void> checkLoginStatus() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        isLoggedIn.value = true;
        // Use a microtask to avoid build conflicts
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed('/dashboard');
        });
      }
    } catch (e) {
      print('Error checking login status: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      
      print('Starting Google Sign-In process...');
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('User cancelled Google Sign-In');
        isLoading.value = false;
        return;
      }

      print('Google Sign-In successful for: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Created Firebase credential, signing in...');

      // Sign in to Firebase with the credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        print('Firebase authentication successful for: ${user.email}');
        
        // Save user data to Hive
        await _saveUserToHive(user, googleUser);
        
        isLoggedIn.value = true;
        isLoading.value = false;
        
        // Use a microtask to avoid build conflicts
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed('/dashboard');
        });
      } else {
        print('Firebase authentication failed - no user returned');
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Authentication failed. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Google Sign-In error: $e');
      isLoading.value = false;
      
      String errorMessage = 'Failed to sign in with Google';
      if (e.toString().contains('network_error')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('sign_in_failed')) {
        errorMessage = 'Sign-in failed. Please check your Firebase configuration.';
      } else if (e.toString().contains('10:')) {
        errorMessage = 'Google Sign-In configuration error. Please check your Firebase project settings.';
      } else if (e.toString().contains('PigeonUserDetails')) {
        errorMessage = 'Google Sign-In version compatibility issue. Please try again.';
      }
      
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
      );
    }
  }

  Future<void> _saveUserToHive(User firebaseUser, GoogleSignInAccount googleUser) async {
    try {
      final userBox = Hive.box<UserModel>('user');
      
      final userModel = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? '',
        photoUrl: firebaseUser.photoURL?? '',
        createdAt: DateTime.now(),
      );
      
      await userBox.put('current_user', userModel);
      print('User data saved to Hive successfully');
    } catch (e) {
      print('Error saving user to Hive: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      
      // Clear user data from Hive
      final userBox = Hive.box<UserModel>('user');
      await userBox.clear();
      
      isLoggedIn.value = false;
      // Use a microtask to avoid build conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/login');
      });
    } catch (e) {
      print('Error signing out: $e');
      Get.snackbar(
        'Error',
        'Failed to sign out: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
} 