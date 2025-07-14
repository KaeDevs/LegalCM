# Payment System Setup Guide

This guide explains how to set up the payment system for the Legal Case Manager app with three subscription tiers.

## Overview

The app now includes a comprehensive payment system with three subscription tiers:

1. **Free Tier**: 15 backups per month with ads
2. **Ad-Free Tier**: 30 backups per month, no ads ($4.99/month)
3. **Unlimited Tier**: Unlimited backups, no ads ($9.99/month)

## Features Implemented

### ✅ Completed Features

- **Subscription Management**: Complete subscription model with Hive storage
- **In-App Purchases**: Integration with Google Play Store and Apple App Store
- **Backup Limits**: Monthly backup tracking and limits based on subscription
- **Ad System**: Ad display logic based on subscription status
- **Beautiful UI**: Modern subscription page with tier comparison
- **Dashboard Integration**: Easy access to subscription management
- **Purchase Restoration**: Ability to restore previous purchases

### 🔧 Technical Implementation

- **Models**: `SubscriptionModel` with `SubscriptionTier` enum
- **Services**: `SubscriptionService`, `BackupService`, `AdService`
- **Controllers**: `SubscriptionController` for GetX state management
- **Views**: Beautiful subscription page with tier cards
- **Routes**: Integrated into app navigation

## Setup Instructions

### 1. Dependencies

The following dependencies have been added to `pubspec.yaml`:

```yaml
in_app_purchase: ^3.1.13
in_app_purchase_android: ^0.3.6+1
in_app_purchase_storekit: ^0.3.6+1
shared_preferences: ^2.2.2
```

### 2. Google Play Console Setup

1. **Create Products**:
   - Go to Google Play Console
   - Navigate to "Monetization" > "Products" > "In-app products"
   - Create two products:
     - Product ID: `ad_free_tier`
     - Product ID: `unlimited_tier`

2. **Set Pricing**:
   - Ad-Free Tier: $4.99/month
   - Unlimited Tier: $9.99/month

3. **Configure Billing**:
   - Set up billing account
   - Configure tax information
   - Set up payment methods

### 3. Apple App Store Connect Setup

1. **Create In-App Purchases**:
   - Go to App Store Connect
   - Navigate to "Features" > "In-App Purchases"
   - Create two non-consumable products:
     - Product ID: `ad_free_tier`
     - Product ID: `unlimited_tier`

2. **Set Pricing**:
   - Ad-Free Tier: $4.99
   - Unlimited Tier: $9.99

### 4. Android Configuration

Add the following to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

### 5. iOS Configuration

Add the following to `ios/Runner/Info.plist`:

```xml
<key>SKPaymentTransactionObserverClass</key>
<string>$(PRODUCT_MODULE_NAME).PaymentTransactionObserver</string>
```

## Usage

### Accessing Subscription Page

Users can access the subscription page from:
- Dashboard → Subscription card
- Direct navigation to `/subscription`

### Backup Integration

The backup system automatically:
- Checks subscription limits before allowing backups
- Records backup usage
- Shows appropriate messages for limit exceeded

### Ad Integration

Ads are automatically:
- Hidden for premium users (Ad-Free and Unlimited tiers)
- Shown for free tier users
- Integrated with reward system for extra features

## Testing

### Test Accounts

1. **Google Play Testing**:
   - Add test accounts in Google Play Console
   - Use test cards for purchases
   - Test subscription flow

2. **Apple App Store Testing**:
   - Use Sandbox accounts
   - Test with TestFlight
   - Verify receipt validation

### Local Testing

1. **Free Tier**: Default tier for new users
2. **Mock Purchases**: Use test product IDs
3. **Backup Limits**: Test with different subscription states

## Code Structure

```
lib/
├── app/
│   ├── data/
│   │   └── models/
│   │       ├── subscription_model.dart
│   │       └── subscription_model.g.dart
│   ├── modules/
│   │   └── subscription/
│   │       ├── binding.dart
│   │       ├── controller.dart
│   │       └── view.dart
│   ├── services/
│   │   ├── subscription_service.dart
│   │   ├── backup_service.dart
│   │   └── ad_service.dart
│   └── routes/
│       └── app_routes.dart
└── main.dart
```

## Key Features

### Subscription Tiers

- **Free**: 15 backups/month, ads enabled
- **Ad-Free**: 30 backups/month, no ads
- **Unlimited**: Unlimited backups, no ads

### Backup Tracking

- Monthly reset of backup counts
- Visual progress indicators
- Limit enforcement

### Purchase Flow

- Product selection
- Payment processing
- Receipt validation
- Subscription activation

### Ad Management

- Conditional ad display
- Reward ad system
- Premium user benefits

## Troubleshooting

### Common Issues

1. **Build Runner Errors**: Run `flutter packages pub run build_runner build --delete-conflicting-outputs`
2. **Hive Adapters**: Ensure all models are registered in `main.dart`
3. **Purchase Failures**: Check product IDs match store configuration
4. **Backup Limits**: Verify subscription status and monthly reset logic

### Debug Mode

Enable debug logging by adding:

```dart
// In subscription_service.dart
print('Subscription status: ${_currentSubscription?.tier}');
print('Backup count: ${_currentSubscription?.backupsUsedThisMonth}');
```

## Future Enhancements

- [ ] Analytics integration
- [ ] Promotional pricing
- [ ] Family sharing support
- [ ] Enterprise plans
- [ ] Advanced backup features
- [ ] Real ad network integration

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review the code comments
3. Test with different subscription states
4. Verify store configuration

---

**Note**: This implementation provides a solid foundation for monetization. You can extend it with additional features like promotional pricing, family sharing, or enterprise plans as needed. 