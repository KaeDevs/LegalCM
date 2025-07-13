import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../login/controller.dart';

class SplashController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    print('SplashController initialized');
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    print('Starting splash initialization...');
    
    // Wait for 3 seconds to show splash
    await Future.delayed(const Duration(seconds: 3));
    print('Splash delay completed');
    
    try {
      // Check if user is logged in
      final user = _auth.currentUser;
      print('Firebase auth check - User: ${user?.email}');
      
      if (user != null) {
        // User is logged in, navigate to dashboard
        print('Navigating to dashboard...');
        Get.offAllNamed('/dashboard');
      } else {
        // User is not logged in, navigate to login
        print('Navigating to login...');
        Get.offAllNamed('/login');
      }
    } catch (e) {
      print('Error checking login status: $e');
      // If there's an error, navigate to login
      print('Navigating to login due to error...');
      Get.offAllNamed('/login');
    }
  }

  @override
  void onClose() {
    print('SplashController disposed');
    super.onClose();
  }
} 
