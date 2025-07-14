import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import '../modules/login/controller.dart';
import '../data/models/subscription_model.dart';
import 'subscription_service.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final SubscriptionService _subscriptionService = SubscriptionService();
  final LoginController _loginController = Get.find<LoginController>();

  Future<bool> canPerformBackup() async {
    return await _subscriptionService.canPerformBackup();
  }

  Future<void> recordBackup() async {
    await _subscriptionService.recordBackup();
  }

  /// Main backup method that integrates with existing login controller
  Future<bool> performBackup() async {
    // Check if user can perform backup based on subscription
    final canBackup = await canPerformBackup();
    if (!canBackup) {
      Get.snackbar(
        'Backup Limit Reached',
        'You have reached your monthly backup limit. Please upgrade your subscription for more backups.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    }

    try {
      // Get current Google user
      final googleUser = _loginController.googleSignIn.currentUser;
      if (googleUser == null) {
        Get.snackbar(
          'Authentication Required',
          'Please sign in with Google to perform backups.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return false;
      }

      // Get auth headers for Google Drive API
      final authHeaders = await googleUser.authHeaders;
      final client = GoogleAuthClient(authHeaders);

      // Use existing backup method from login controller
      await _loginController.backupToDrive(client);
      
      // Record the backup usage for subscription tracking
      await recordBackup();
      
      Get.snackbar(
        'Backup Successful',
        'Your data has been backed up successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return true;
      
    } catch (e) {
      Get.snackbar(
        'Backup Error',
        'An error occurred during backup: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    }
  }

  /// Check if user is signed in and can perform backup
  Future<bool> isUserReadyForBackup() async {
    final googleUser = _loginController.googleSignIn.currentUser;
    if (googleUser == null) {
      return false;
    }
    
    final canBackup = await canPerformBackup();
    return canBackup;
  }

  /// Get backup status text for UI display
  String getBackupStatusText() {
    return _subscriptionService.getBackupStatusText();
  }

  /// Check if user has ads enabled (for ad service integration)
  bool get hasAds => _subscriptionService.hasAds;

  /// Get current subscription tier
  String getCurrentTierName() {
    return _subscriptionService.currentTier.name;
  }

  /// Get remaining backups for current month
  int getRemainingBackups() {
    final subscription = _subscriptionService.currentSubscription;
    if (subscription == null || subscription.tier == SubscriptionTier.unlimited) {
      return -1; // Unlimited
    }
    return subscription.maxBackupsPerMonth - subscription.backupsUsedThisMonth;
  }

  /// Get backup usage progress (0.0 to 1.0)
  double getBackupProgress() {
    final subscription = _subscriptionService.currentSubscription;
    if (subscription == null || subscription.tier == SubscriptionTier.unlimited) {
      return 0.0;
    }
    return subscription.backupsUsedThisMonth / subscription.maxBackupsPerMonth;
  }
} 