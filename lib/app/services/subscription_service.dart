import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:in_app_purchase_android/in_app_purchase_android.dart';
// import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/subscription_model.dart';
import '../data/models/user_model.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  // Product IDs for different subscription tiers
  static const Set<String> _productIds = {
    'ad_free_tier',
    'unlimited_tier',
  };

  // Current user's subscription
  SubscriptionModel? _currentSubscription;
  SubscriptionModel? get currentSubscription => _currentSubscription;

  // Stream controller for subscription updates
  final StreamController<SubscriptionModel?> _subscriptionController = 
      StreamController<SubscriptionModel?>.broadcast();
  Stream<SubscriptionModel?> get subscriptionStream => _subscriptionController.stream;

  // Test mode flag - set to true for testing without store setup
  bool _testMode = true; // Set to false when ready for production

  Future<void> initialize() async {
    // Initialize in-app purchase
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      print('In-app purchases not available');
      return;
    }

    // Listen to purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (error) => print('Error in purchase stream: $error'),
    );

    // Load current subscription from storage
    await _loadCurrentSubscription();
  }

  Future<void> _loadCurrentSubscription() async {
    final userBox = Hive.box<UserModel>('user');
    final subscriptionBox = Hive.box<SubscriptionModel>('subscriptions');
    
    if (userBox.isNotEmpty) {
      final user = userBox.values.first;
      final subscription = subscriptionBox.values
          .where((s) => s.userId == user.id && s.isActive)
          .firstOrNull;
      
      if (subscription != null) {
        _currentSubscription = subscription;
        _checkAndResetMonthlyBackupCount();
        _subscriptionController.add(_currentSubscription);
      } else {
        // Create default free subscription
        await _createDefaultSubscription(user.id);
      }
    }
  }

  Future<void> _createDefaultSubscription(String userId) async {
    final subscription = SubscriptionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      tier: SubscriptionTier.free,
      startDate: DateTime.now(),
      isActive: true,
      lastBackupReset: DateTime.now(),
      hasAds: true,
    );

    await Hive.box<SubscriptionModel>('subscriptions').add(subscription);
    _currentSubscription = subscription;
    _subscriptionController.add(_currentSubscription);
  }

  Future<List<ProductDetails>> getProducts() async {
    if (_testMode) {
      // Return mock products for testing
      return [
        ProductDetails(
          id: 'ad_free_tier',
          title: 'Ad-Free Tier',
          description: '30 backups per month, no ads',
          price: '\$4.99',
          rawPrice: 4.99,
          currencyCode: 'USD',
        ),
        ProductDetails(
          id: 'unlimited_tier',
          title: 'Unlimited Tier',
          description: 'Unlimited backups, no ads',
          price: '\$9.99',
          rawPrice: 9.99,
          currencyCode: 'USD',
        ),
      ];
    }

    final ProductDetailsResponse response = 
        await _inAppPurchase.queryProductDetails(_productIds);
    
    if (response.notFoundIDs.isNotEmpty) {
      print('Products not found: ${response.notFoundIDs}');
    }
    
    return response.productDetails;
  }

  Future<bool> purchaseSubscription(SubscriptionTier tier) async {
    if (tier == SubscriptionTier.free) {
      return true; // Free tier doesn't require purchase
    }

    if (_testMode) {
      // Simulate purchase for testing
      await _simulatePurchase(tier);
      return true;
    }

    final products = await getProducts();
    final product = products.firstWhere(
      (p) => p.id == tier.productId,
      orElse: () => throw Exception('Product not found'),
    );

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    
    try {
      if (tier == SubscriptionTier.adFree || tier == SubscriptionTier.unlimited) {
        return await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      print('Error purchasing subscription: $e');
      return false;
    }
    
    return false;
  }

  Future<void> _simulatePurchase(SubscriptionTier tier) async {
    final userBox = Hive.box<UserModel>('user');
    if (userBox.isEmpty) return;

    final user = userBox.values.first;

    // Deactivate current subscription if exists
    if (_currentSubscription != null) {
      _currentSubscription!.isActive = false;
      _currentSubscription!.endDate = DateTime.now();
      await _currentSubscription!.save();
    }

    // Create new subscription
    final newSubscription = SubscriptionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.id,
      tier: tier,
      startDate: DateTime.now(),
      isActive: true,
      transactionId: 'test_transaction_${DateTime.now().millisecondsSinceEpoch}',
      lastBackupReset: DateTime.now(),
      hasAds: false,
    );

    await Hive.box<SubscriptionModel>('subscriptions').add(newSubscription);
    _currentSubscription = newSubscription;
    _subscriptionController.add(_currentSubscription);

    // Save subscription status to SharedPreferences for persistence
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_subscription_tier', tier.name);
    await prefs.setBool('subscription_has_ads', false);
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Handle pending purchase
        print('Purchase pending: ${purchaseDetails.productID}');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Handle error
        print('Purchase error: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        // Handle successful purchase
        await _handleSuccessfulPurchase(purchaseDetails);
      }
      
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    final userBox = Hive.box<UserModel>('user');
    if (userBox.isEmpty) return;

    final user = userBox.values.first;
    SubscriptionTier tier;

    switch (purchaseDetails.productID) {
      case 'ad_free_tier':
        tier = SubscriptionTier.adFree;
        break;
      case 'unlimited_tier':
        tier = SubscriptionTier.unlimited;
        break;
      default:
        print('Unknown product ID: ${purchaseDetails.productID}');
        return;
    }

    // Deactivate current subscription if exists
    if (_currentSubscription != null) {
      _currentSubscription!.isActive = false;
      _currentSubscription!.endDate = DateTime.now();
      await _currentSubscription!.save();
    }

    // Create new subscription
    final newSubscription = SubscriptionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.id,
      tier: tier,
      startDate: DateTime.now(),
      isActive: true,
      transactionId: purchaseDetails.purchaseID,
      lastBackupReset: DateTime.now(),
      hasAds: false,
    );

    await Hive.box<SubscriptionModel>('subscriptions').add(newSubscription);
    _currentSubscription = newSubscription;
    _subscriptionController.add(_currentSubscription);

    // Save subscription status to SharedPreferences for persistence
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_subscription_tier', tier.name);
    await prefs.setBool('subscription_has_ads', false);
  }

  Future<bool> canPerformBackup() async {
    if (_currentSubscription == null) return false;
    
    _checkAndResetMonthlyBackupCount();
    return _currentSubscription!.canBackup;
  }

  Future<void> recordBackup() async {
    if (_currentSubscription == null) return;
    
    _currentSubscription!.incrementBackupCount();
    await _currentSubscription!.save();
    _subscriptionController.add(_currentSubscription);
  }

  void _checkAndResetMonthlyBackupCount() {
    if (_currentSubscription != null && 
        _currentSubscription!.shouldResetBackupCount()) {
      _currentSubscription!.resetMonthlyBackupCount();
      _currentSubscription!.save();
    }
  }

  Future<void> restorePurchases() async {
    if (_testMode) {
      // Simulate restore for testing
      print('Test mode: Simulating purchase restore');
      return;
    }
    await _inAppPurchase.restorePurchases();
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    // await _subscriptionController.close();
  }

  // Helper methods for UI
  String getBackupStatusText() {
    if (_currentSubscription == null) return 'No subscription';
    
    if (_currentSubscription!.tier == SubscriptionTier.unlimited) {
      return 'Unlimited backups available';
    }
    
    final remaining = _currentSubscription!.maxBackupsPerMonth - 
                     _currentSubscription!.backupsUsedThisMonth;
    return '$remaining backups remaining this month';
  }

  bool get hasAds => _currentSubscription?.hasAds ?? true;
  
  SubscriptionTier get currentTier => _currentSubscription?.tier ?? SubscriptionTier.free;

  // Test mode getter
  bool get isTestMode => _testMode;
} 