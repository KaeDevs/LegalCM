import 'package:hive/hive.dart';

part 'subscription_model.g.dart';

@HiveType(typeId: 7)
class SubscriptionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  SubscriptionTier tier;

  @HiveField(3)
  DateTime startDate;

  @HiveField(4)
  DateTime? endDate;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  String? transactionId;

  @HiveField(7)
  int backupsUsedThisMonth;

  @HiveField(8)
  DateTime lastBackupReset;

  @HiveField(9)
  bool hasAds;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.tier,
    required this.startDate,
    this.endDate,
    required this.isActive,
    this.transactionId,
    this.backupsUsedThisMonth = 0,
    required this.lastBackupReset,
    required this.hasAds,
  });

  int get maxBackupsPerMonth {
    switch (tier) {
      case SubscriptionTier.free:
        return 3;
      case SubscriptionTier.adFree:
        return 5;
      case SubscriptionTier.unlimited:
        return -1; // -1 indicates unlimited
    }
  }

  bool get canBackup {
    if (tier == SubscriptionTier.unlimited) return true;
    return backupsUsedThisMonth < maxBackupsPerMonth;
  }

  void incrementBackupCount() {
    if (tier != SubscriptionTier.unlimited) {
      backupsUsedThisMonth++;
    }
  }

  void resetMonthlyBackupCount() {
    backupsUsedThisMonth = 0;
    lastBackupReset = DateTime.now();
  }

  bool shouldResetBackupCount() {
    final now = DateTime.now();
    return now.month != lastBackupReset.month || now.year != lastBackupReset.year;
  }
}

@HiveType(typeId: 8)
enum SubscriptionTier {
  @HiveField(0)
  free,
  @HiveField(1)
  adFree,
  @HiveField(2)
  unlimited,
}

extension SubscriptionTierExtension on SubscriptionTier {
  String get name {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.adFree:
        return 'Ad-Free';
      case SubscriptionTier.unlimited:
        return 'Unlimited';
    }
  }

  String get description {
    switch (this) {
      case SubscriptionTier.free:
        return '15 backups per month with ads';
      case SubscriptionTier.adFree:
        return '30 backups per month, no ads';
      case SubscriptionTier.unlimited:
        return 'Unlimited backups, no ads';
    }
  }

  double get price {
    switch (this) {
      case SubscriptionTier.free:
        return 0.0;
      case SubscriptionTier.adFree:
        return 3.99;
      case SubscriptionTier.unlimited:
        return 7.99;
    }
  }

  String get productId {
    switch (this) {
      case SubscriptionTier.free:
        return 'free_tier';
      case SubscriptionTier.adFree:
        return 'ad_free_tier';
      case SubscriptionTier.unlimited:
        return 'unlimited_tier';
    }
  }
} 