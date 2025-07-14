import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/subscription_model.dart';
import '../../utils/font_styles.dart';
import '../../services/ad_service.dart';
import 'controller.dart';

class SubscriptionView extends GetView<SubscriptionController> {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Subscription Plans",
          style: FontStyles.poppins(
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimary
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withAlpha((0.9 * 255).toInt()),
                colorScheme.secondary.withAlpha((0.9 * 255).toInt()),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 1,
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: controller.restorePurchases,
            tooltip: 'Restore Purchases',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Subscription Status
              _buildCurrentSubscriptionCard(context),
              const SizedBox(height: 24),
              
              // Backup Usage Progress
              _buildBackupUsageCard(context),
              const SizedBox(height: 24),
              
              // Reward Ad Button for Free Tier
              
                  _buildRewardAdButton(context),
                
              
              const SizedBox(height: 24),
              
              // Subscription Plans
              Text(
                "Choose Your Plan",
                style: FontStyles.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              
              // Free Tier
              _buildSubscriptionCard(
                context,
                tier: SubscriptionTier.free,
                isCurrentTier: controller.isFreeTier,
                isPopular: false,
              ),
              const SizedBox(height: 16),
              
              // Ad-Free Tier
              _buildSubscriptionCard(
                context,
                tier: SubscriptionTier.adFree,
                isCurrentTier: controller.isAdFreeTier,
                isPopular: true,
              ),
              const SizedBox(height: 16),
              
              // Unlimited Tier
              _buildSubscriptionCard(
                context,
                tier: SubscriptionTier.unlimited,
                isCurrentTier: controller.isUnlimitedTier,
                isPopular: false,
              ),
              const SizedBox(height: 32),
              
              // Terms and Conditions
              _buildTermsSection(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentSubscriptionCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.1),
            colorScheme.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "Current Plan",
                style: FontStyles.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            controller.getCurrentTierName(),
            style: FontStyles.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            controller.getCurrentTierDescription(),
            style: FontStyles.poppins(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupUsageCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.backup,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Backup Usage",
                style: FontStyles.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: controller.getProgressPercentage(),
            backgroundColor: colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Text(
            controller.getBackupStatusText(),
            style: FontStyles.poppins(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context, {
    required SubscriptionTier tier,
    required bool isCurrentTier,
    required bool isPopular,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isCurrentTier 
            ? colorScheme.primary.withValues(alpha: 0.1)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentTier 
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha: 0.2),
          width: isCurrentTier ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Text(
                  "POPULAR",
                  style: FontStyles.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSecondary,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tier.name,
                      style: FontStyles.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (isCurrentTier)
                      Icon(
                        Icons.check_circle,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  tier.description,
                  style: FontStyles.poppins(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      tier.price == 0 ? "FREE" : "\$${tier.price.toStringAsFixed(2)}",
                      style: FontStyles.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    if (tier.price > 0) ...[
                      Text(
                        "/month",
                        style: FontStyles.poppins(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                _buildFeatureList(context, tier),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentTier 
                        ? null 
                        : () => controller.purchaseSubscription(tier),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentTier 
                          ? colorScheme.surfaceContainerHighest
                          : colorScheme.primary,
                      foregroundColor: isCurrentTier 
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Obx(() {
                      if (controller.isPurchasing.value) {
                        return const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }
                      return Text(
                        isCurrentTier ? "Current Plan" : "Subscribe",
                        style: FontStyles.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context, SubscriptionTier tier) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    List<String> features = [];
    
    switch (tier) {
      case SubscriptionTier.free:
        features = [
          "15 backups per month",
          "Basic case management",
          "Ad-supported",
          // "Email support",
        ];
        break;
      case SubscriptionTier.adFree:
        features = [
          "30 backups per month",
          // "All free features",
          "No advertisements",
          // "Priority email support",
        ];
        break;
      case SubscriptionTier.unlimited:
        features = [
          "Unlimited backups",
          "All ad-free features",
          // "Advanced analytics",
          // "Priority phone support",
          // "Custom integrations",
        ];
        break;
    }

    return Column(
      children: features.map((feature) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: colorScheme.primary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                feature,
                style: FontStyles.poppins(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildTermsSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Terms & Conditions",
            style: FontStyles.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "• Subscriptions auto-renew monthly unless cancelled\n"
            "• Cancel anytime in your device settings\n"
            "• Backup limits reset monthly\n"
            "• All data is encrypted and secure",
            style: FontStyles.poppins(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardAdButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.secondary.withValues(alpha: 0.1),
            colorScheme.tertiary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.play_circle_outline,
                color: colorScheme.secondary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "Watch Ad for Extra Backup",
                style: FontStyles.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Watch a short advertisement to earn an extra backup this month!",
            style: FontStyles.poppins(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final rewardEarned = await controller.adService.showRewardAd();
                if (rewardEarned) {
                  // Give extra backup by reducing the used count
                  final subscription = controller.currentSubscription.value;
                  if (subscription != null && subscription.backupsUsedThisMonth > 0) {
                    subscription.backupsUsedThisMonth--;
                    await subscription.save();
                    controller.currentSubscription.refresh();
                    Get.snackbar(
                      'Reward Earned!',
                      'You now have an extra backup available this month.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } else {
                    Get.snackbar(
                      'No Backup Used',
                      'You haven\'t used any backups this month yet.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                  }
                }
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text("Watch Ad"),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 