# Payment System Testing Guide

## 🧪 **Test Mode Enabled**

The payment system is currently in **TEST MODE**. This means you can test all subscription features without setting up store products.

## ✅ **What You Can Test Now**

### **1. Subscription Page**
- Go to Dashboard → Click the ⭐ star icon in the app bar
- View current subscription status
- See backup usage progress
- Compare subscription tiers

### **2. Purchase Flow (Simulated)**
- Click "Subscribe" on any tier
- Purchase will be simulated instantly
- Subscription will be activated immediately
- No real payment will be charged

### **3. Backup Limits**
- Test backup functionality with different tiers
- Verify backup limits are enforced
- Check monthly reset logic

### **4. Ad System**
- Verify ads are hidden for premium users
- Check ad display for free users

## 🎯 **Testing Steps**

### **Step 1: Test Free Tier**
1. Sign in to the app
2. Go to Subscription page
3. Verify you're on "Free" tier
4. Check backup limit shows "15 backups per month"
5. Try backing up (should work)

### **Step 2: Test Purchase Flow**
1. Click "Subscribe" on "Ad-Free Tier"
2. Purchase should complete instantly (test mode)
3. Verify subscription changes to "Ad-Free"
4. Check backup limit shows "30 backups per month"
5. Verify no ads are shown

### **Step 3: Test Unlimited Tier**
1. Click "Subscribe" on "Unlimited Tier"
2. Purchase should complete instantly
3. Verify subscription changes to "Unlimited"
4. Check backup limit shows "Unlimited backups"
5. Try multiple backups (should work unlimited)

### **Step 4: Test Backup Limits**
1. Switch back to Free tier
2. Try backing up 15 times
3. 16th backup should show "limit reached" message
4. Verify upgrade prompt appears

### **Step 5: Test Monthly Reset**
1. Check current backup count
2. Note the date
3. Wait for next month or manually reset (for testing)

## 🔧 **Manual Testing Commands**

You can add these debug commands to test specific scenarios:

```dart
// In any service or controller
final subscriptionService = SubscriptionService();

// Check current subscription
print('Current tier: ${subscriptionService.currentTier}');
print('Can backup: ${await subscriptionService.canPerformBackup()}');
print('Backup count: ${subscriptionService.currentSubscription?.backupsUsedThisMonth}');

// Manually reset backup count (for testing)
subscriptionService.currentSubscription?.resetMonthlyBackupCount();
```

## 🚀 **Ready for Production**

When you're ready to go live:

### **1. Set Up Store Products**
- Google Play Console: Create `ad_free_tier` and `unlimited_tier`
- Apple App Store Connect: Create same products

### **2. Disable Test Mode**
In `lib/app/services/subscription_service.dart`:
```dart
bool _testMode = false; // Change to false
```

### **3. Add Permissions**
In `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

### **4. Test Real Purchases**
- Use test accounts in store consoles
- Test with real payment flow
- Verify receipt validation

## 📊 **Expected Test Results**

| Action | Free Tier | Ad-Free Tier | Unlimited Tier |
|--------|-----------|--------------|----------------|
| Initial Backup Limit | 15/month | 30/month | Unlimited |
| Can Backup | ✅ (if < 15) | ✅ (if < 30) | ✅ Always |
| Ads Displayed | ✅ Yes | ❌ No | ❌ No |
| Purchase Flow | N/A | ✅ Simulated | ✅ Simulated |
| Backup Tracking | ✅ Counted | ✅ Counted | ✅ Not Counted |

## 🐛 **Troubleshooting**

### **"Box not found" Error**
- Ensure you've signed out and signed back in
- Check that `subscriptions` box is opened in `LoginController`

### **Purchase Not Working**
- Verify test mode is enabled (`_testMode = true`)
- Check console for error messages
- Ensure user is signed in

### **Backup Limits Not Working**
- Check subscription data in Hive
- Verify monthly reset logic
- Test with different subscription tiers

## 🎉 **Success Criteria**

Your payment system is working correctly if:

1. ✅ Subscription page loads without errors
2. ✅ Purchase flow completes instantly (test mode)
3. ✅ Backup limits are enforced correctly
4. ✅ Subscription changes are reflected immediately
5. ✅ Ad display respects subscription status
6. ✅ Monthly reset works properly

---

**Once all tests pass, you're ready to set up real store products and go live!** 