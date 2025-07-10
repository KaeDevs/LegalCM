import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/case_model.dart';
import '../../data/models/client_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/task_model.dart';
import '../../data/models/time_entry_model.dart';
import '../../data/models/user_model.dart';

class LoginController extends GetxController {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/drive.file',
    ],
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;

  /// Path and filename for the backup zip on Google Drive
  final String driveBackupFileName = 'legalcm_hive_backup.zip';

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
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('User cancelled Google Sign-In');
        isLoading.value = false;
        return;
      }

      print('Google Sign-In successful for: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final authHeaders = await googleUser.authHeaders;
      final client = GoogleAuthClient(authHeaders);

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Created Firebase credential, signing in...');

      // Sign in to Firebase with the credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        print('Firebase authentication successful for: ${user.email}');

        // Save user data to Hive
        await _saveUserToHive(user, googleUser);

        // Restore backup from Drive before navigating to dashboard
        try {
          await restoreFromDrive(client);
        } catch (e) {
          print(
              'No backup found or error restoring from Drive: ${e.toString()}');
        }

        // Ensure all boxes are open before proceeding
        await ensureAllBoxesOpen();

        isLoggedIn.value = true;
        isLoading.value = false;
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
        errorMessage =
            'Sign-in failed. Please check your Firebase configuration.';
      } else if (e.toString().contains('10:')) {
        errorMessage =
            'Google Sign-In configuration error. Please check your Firebase project settings.';
      } else if (e.toString().contains('PigeonUserDetails')) {
        errorMessage =
            'Google Sign-In version compatibility issue. Please try again.';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
      );
    }
  }

  // Add this helper method to your LoginController or create a separate HiveHelper class

Future<Box<T>> _getSafeBox<T>(String boxName) async {
  try {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<T>(boxName);
    } else {
      return await Hive.openBox<T>(boxName);
    }
  } catch (e) {
    // If there's a type mismatch, close and reopen
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
    return await Hive.openBox<T>(boxName);
  }
}

// Update your _saveUserToHive method
Future<void> _saveUserToHive(
    User firebaseUser, GoogleSignInAccount googleUser) async {
  try {
    final userBox = await _getSafeBox<UserModel>('user');

    final userModel = UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? '',
      photoUrl: firebaseUser.photoURL ?? '',
      createdAt: DateTime.now(),
    );

    await userBox.put('current_user', userModel);
    print('User data saved to Hive successfully');
  } catch (e) {
    print('Error saving user to Hive: $e');
  }
}

// Update your signOut method
Future<void> signOut() async {
  try {
    await _auth.signOut();
    await googleSignIn.signOut();

    // Clear ALL Hive boxes related to user data using safe box access
    final userBox = await _getSafeBox<UserModel>('user');
    final caseBox = await _getSafeBox<CaseModel>('cases');
    final expenseBox = await _getSafeBox<ExpenseModel>('expenses');
    final timeEntryBox = await _getSafeBox<TimeEntryModel>('time_entries');
    final clientBox = await _getSafeBox<ClientModel>('clients');
    final taskBox = await _getSafeBox<TaskModel>('tasks');
    final invoiceBox = await _getSafeBox<InvoiceModel>('invoices');

    await userBox.clear();
    await caseBox.clear();
    await expenseBox.clear();
    await timeEntryBox.clear();
    await clientBox.clear();
    await taskBox.clear();
    await invoiceBox.clear();
    
    isLoggedIn.value = false;

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

  /// Backup all Hive box files to a zip and upload to Google Drive
  /// Backup all Hive box files to a zip and upload to Google Drive
Future<void> backupToDrive(GoogleAuthClient client) async {
  try {
    // Flush all boxes first
    if (Hive.isBoxOpen('user')) await Hive.box<UserModel>('user').flush();
    if (Hive.isBoxOpen('cases')) await Hive.box<CaseModel>('cases').flush();
    if (Hive.isBoxOpen('clients')) await Hive.box<ClientModel>('clients').flush();
    if (Hive.isBoxOpen('tasks')) await Hive.box<TaskModel>('tasks').flush();
    if (Hive.isBoxOpen('time_entries')) await Hive.box<TimeEntryModel>('time_entries').flush();
    if (Hive.isBoxOpen('expenses')) await Hive.box<ExpenseModel>('expenses').flush();
    if (Hive.isBoxOpen('invoices')) await Hive.box<InvoiceModel>('invoices').flush();

    await Future.delayed(const Duration(milliseconds: 500));

    // Get Hive directory
    final hiveDir = await getApplicationDocumentsDirectory();
    final hivePath = hiveDir.path;
    final zipFile = File('${hivePath}/$driveBackupFileName');

    // Delete existing zip file if it exists
    if (await zipFile.exists()) {
      await zipFile.delete();
    }

    // Create archive manually using Archive class
    final archive = Archive();
    final dir = Directory(hivePath);
    bool hasFiles = false;
    int totalOriginalSize = 0;

    print('Creating archive from Hive files:');
    await for (var entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.hive')) {
        final file = File(entity.path);
        final fileBytes = await file.readAsBytes();
        final fileName = file.path.split('/').last;
        
        print('Adding ${fileName} (${fileBytes.length} bytes)');
        totalOriginalSize += fileBytes.length;
        
        // Create ArchiveFile with the file data
        final archiveFile = ArchiveFile(fileName, fileBytes.length, fileBytes);
        archive.addFile(archiveFile);
        hasFiles = true;
      }
    }

    if (!hasFiles) {
      throw Exception('No Hive files found to backup');
    }

    print('Total original files size: $totalOriginalSize bytes');

    // Encode archive to zip format
    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);
    
    if (zipData == null || zipData.isEmpty) {
      throw Exception('Failed to create zip data - encoder returned null/empty');
    }

    print('Zip data created: ${zipData.length} bytes');

    // Write zip file
    await zipFile.writeAsBytes(zipData);
    
    // Verify the file was written
    if (!await zipFile.exists()) {
      throw Exception('Zip file was not created on disk');
    }

    final zipSize = await zipFile.length();
    print('Zip file written to disk: $zipSize bytes');

    if (zipSize < 50) { // Even an empty zip should be larger than this
      throw Exception('Zip file is too small ($zipSize bytes), likely corrupt');
    }

    // Test read the zip file to make sure it's valid
    try {
      final testBytes = await zipFile.readAsBytes();
      final testArchive = ZipDecoder().decodeBytes(testBytes);
      print('Zip validation: ${testArchive.files.length} files in archive');
      for (final file in testArchive.files) {
        print('  - ${file.name}: ${file.size} bytes');
      }
    } catch (e) {
      print('Zip validation failed: $e');
      throw Exception('Created zip file is invalid: $e');
    }

    // Upload to Google Drive
    final driveApi = drive.DriveApi(client);
    
    final fileList = await driveApi.files
        .list(q: "name='$driveBackupFileName' and trashed=false");
    
    drive.File? backupFile;
    if (fileList.files != null && fileList.files!.isNotEmpty) {
      backupFile = fileList.files!.first;
    }

    final media = drive.Media(zipFile.openRead(), zipSize);
    
    if (backupFile != null) {
      await driveApi.files.update(
        drive.File(),
        backupFile.id!,
        uploadMedia: media,
      );
      print('Updated existing backup on Google Drive');
    } else {
      final newFile = drive.File();
      newFile.name = driveBackupFileName;
      newFile.description = 'LegalCM Hive Database Backup - Created ${DateTime.now().toIso8601String()}';
      await driveApi.files.create(newFile, uploadMedia: media);
      print('Created new backup on Google Drive');
    }

    // Clean up local zip file
    if (await zipFile.exists()) {
      await zipFile.delete();
    }

    print('Backup uploaded to Google Drive successfully!');
  } catch (e) {
    print('Error backing up to Drive: $e');
    rethrow;
  }
}

  /// Restore Hive data from Google Drive backup zip
  Future<void> restoreFromDrive(GoogleAuthClient client) async {
    try {
      // 1. Close all boxes before restoring
      if (Hive.isBoxOpen('user')) await Hive.box<UserModel>('user').close();
      if (Hive.isBoxOpen('cases')) await Hive.box<CaseModel>('cases').close();
      if (Hive.isBoxOpen('clients')) await Hive.box<ClientModel>('clients').close();
      if (Hive.isBoxOpen('tasks')) await Hive.box<TaskModel>('tasks').close();
      if (Hive.isBoxOpen('time_entries')) await Hive.box<TimeEntryModel>('time_entries').close();
      if (Hive.isBoxOpen('expenses')) await Hive.box<ExpenseModel>('expenses').close();
      if (Hive.isBoxOpen('invoices')) await Hive.box<InvoiceModel>('invoices').close();

      final hiveDir = await getApplicationDocumentsDirectory();
      final hivePath = hiveDir.path;
      final zipFile = File('${hivePath}/$driveBackupFileName');

      // 2. Download backup zip from Drive
      final driveApi = drive.DriveApi(client);
      final fileList = await driveApi.files.list(q: "name='$driveBackupFileName' and trashed=false");
      if (fileList.files == null || fileList.files!.isEmpty) {
        print('No backup found on Drive.');
        return;
      }
      final backupFile = fileList.files!.first;
      final mediaStream = await driveApi.files.get(backupFile.id!, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
      final List<int> dataStore = [];
      await for (final data in mediaStream.stream) {
        dataStore.addAll(data);
      }
      await zipFile.writeAsBytes(dataStore);

      // 3. Unzip and overwrite Hive files
      final bytes = zipFile.readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        final outFile = File('${hivePath}/${file.name}');
        await outFile.writeAsBytes(file.content as List<int>);
      }
      print('Hive data restored from Drive!');

      // 4. Re-open all boxes with the correct type
      await Hive.openBox<UserModel>('user');
      await Hive.openBox<CaseModel>('cases');
      await Hive.openBox<ClientModel>('clients');
      await Hive.openBox<TaskModel>('tasks');
      await Hive.openBox<TimeEntryModel>('time_entries');
      await Hive.openBox<ExpenseModel>('expenses');
      await Hive.openBox<InvoiceModel>('invoices');
    } catch (e) {
      print('Error restoring from Drive: $e');
      rethrow;
    }
  }

  /// Delete backup from Google Drive
  Future<void> deleteBackupFromDrive(GoogleAuthClient client) async {
    try {
      final driveApi = drive.DriveApi(client);
      final fileList = await driveApi.files
          .list(q: "name='$driveBackupFileName' and trashed=false");
      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final backupFile = fileList.files!.first;
        await driveApi.files.delete(backupFile.id!);
        print('Backup deleted from Google Drive!');
      }
    } catch (e) {
      print('Error deleting backup from Drive: $e');
      rethrow;
    }
  }

  Future<void> ensureAllBoxesOpen() async {
    if (!Hive.isBoxOpen('user')) await Hive.openBox<UserModel>('user');
    if (!Hive.isBoxOpen('cases')) await Hive.openBox<CaseModel>('cases');
    if (!Hive.isBoxOpen('clients')) await Hive.openBox<ClientModel>('clients');
    if (!Hive.isBoxOpen('tasks')) await Hive.openBox<TaskModel>('tasks');
    if (!Hive.isBoxOpen('time_entries')) await Hive.openBox<TimeEntryModel>('time_entries');
    if (!Hive.isBoxOpen('expenses')) await Hive.openBox<ExpenseModel>('expenses');
    if (!Hive.isBoxOpen('invoices')) await Hive.openBox<InvoiceModel>('invoices');
  }

}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
