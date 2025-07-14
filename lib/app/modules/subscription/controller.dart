import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../data/models/subscription_model.dart';
import '../../services/subscription_service.dart';
import '../../services/ad_service.dart';
import '../../services/backup_service.dart';

class SubscriptionController extends GetxController {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final AdService adService = AdService();
  final BackupService _backupService = BackupService();
  
  final Rx<SubscriptionModel?> currentSubscription = Rx<SubscriptionModel?>(null);
  final RxList<ProductDetails> products = <ProductDetails>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isPurchasing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSubscription();
    // Load reward ad for subscription page
    adService.loadRewardAd();
  }

  Future<void> _initializeSubscription() async {
    isLoading.value = true;
    
    try {
      await _subscriptionService.initialize();
      
      // Listen to subscription changes
      _subscriptionService.subscriptionStream.listen((subscription) {
        currentSubscription.value = subscription;
      });
      
      // Load products
      await _loadProducts();
    } catch (e) {
      print('Error initializing subscription: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadProducts() async {
    try {
      final productList = await _subscriptionService.getProducts();
      products.assignAll(productList);
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  Future<void> purchaseSubscription(SubscriptionTier tier) async {
    if (tier == SubscriptionTier.free) {
      Get.snackbar(
        'Free Tier',
        'You are already on the free tier!',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isPurchasing.value = true;
    
    try {
      final success = await _subscriptionService.purchaseSubscription(tier);
      
      if (success) {
        // Trigger backup after successful subscription change
        await _backupService.performBackup();
        Get.snackbar(
          'Purchase Initiated',
          'Your purchase is being processed...',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Purchase Failed',
          'Unable to initiate purchase. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred during purchase: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isPurchasing.value = false;
    }
  }

  Future<void> restorePurchases() async {
    isLoading.value = true;
    
    try {
      await _subscriptionService.restorePurchases();
      Get.snackbar(
        'Restore Complete',
        'Your purchases have been restored.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Restore Failed',
        'Unable to restore purchases: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> canPerformBackup() async {
    return await _subscriptionService.canPerformBackup();
  }

  Future<void> recordBackup() async {
    await _subscriptionService.recordBackup();
  }

  String getBackupStatusText() {
    return _subscriptionService.getBackupStatusText();
  }

  bool get hasAds => _subscriptionService.hasAds;
  
  SubscriptionTier get currentTier => _subscriptionService.currentTier;

  // Helper methods for UI
  String getCurrentTierName() {
    return currentSubscription.value?.tier.name ?? 'Free';
  }

  String getCurrentTierDescription() {
    return currentSubscription.value?.tier.description ?? '15 backups per month with ads';
  }

  bool get isUnlimitedTier => currentTier == SubscriptionTier.unlimited;
  bool get isAdFreeTier => currentTier == SubscriptionTier.adFree;
  bool get isFreeTier => currentTier == SubscriptionTier.free;

  int get remainingBackups {
    final subscription = currentSubscription.value;
    if (subscription == null || subscription.tier == SubscriptionTier.unlimited) {
      return -1; // Unlimited
    }
    return subscription.maxBackupsPerMonth - subscription.backupsUsedThisMonth;
  }

  double getProgressPercentage() {
    final subscription = currentSubscription.value;
    if (subscription == null || subscription.tier == SubscriptionTier.unlimited) {
      return 0.0;
    }
    return subscription.backupsUsedThisMonth / subscription.maxBackupsPerMonth;
  }

  @override
  void onClose() {
    _subscriptionService.dispose();
    super.onClose();
  }
} 