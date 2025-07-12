
import 'package:in_app_update/in_app_update.dart';

Future<void> checkForUpdate() async {
    try {
      // Check for available updates
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        // Immediate update: forces user to update before using the app
        await InAppUpdate.performImmediateUpdate();

        // Flexible update (optional): lets user update in the background
        // await InAppUpdate.startFlexibleUpdate();
        // await InAppUpdate.completeFlexibleUpdate();
      } else {
        // print("No update available.");
      }
    } catch (e) {
      // print("Failed to check for updates: $e");
    }
  }
