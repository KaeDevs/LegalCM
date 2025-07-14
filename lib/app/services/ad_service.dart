import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'subscription_service.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  final SubscriptionService _subscriptionService = SubscriptionService();

  bool get shouldShowAds => _subscriptionService.hasAds;

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isBannerAdLoaded = false;

  void loadBannerAd() {
    if (!shouldShowAds || _bannerAd != null) return;
    
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/9214589741',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          debugPrint('Banner Ad Loaded');
          _isBannerAdLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner Ad Failed: $error');
          ad.dispose();
          _bannerAd = null;
          _isBannerAdLoaded = false;
        },
        onAdOpened: (_) => debugPrint('Banner Ad Opened'),
        onAdClosed: (_) => debugPrint('Banner Ad Closed'),
      ),
    )..load();
  }

  Widget? getBannerAd() {
    if (!shouldShowAds) return null;
    
    // If banner ad is not loaded yet, load it and return null for now
    if (_bannerAd == null || !_isBannerAdLoaded) {
      loadBannerAd();
      return null;
    }

    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  // Method to create a new banner ad widget for each usage
  Widget? createBannerAdWidget() {
    if (!shouldShowAds) return null;
    
    // Create a new banner ad instance for each widget
    final bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/9214589741',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => debugPrint('New Banner Ad Loaded'),
        onAdFailedToLoad: (ad, error) {
          debugPrint('New Banner Ad Failed: $error');
          ad.dispose();
        },
      ),
    )..load();

    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: bannerAd.size.width.toDouble(),
      height: bannerAd.size.height.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }

  void loadInterstitialAd() {
    if (!shouldShowAds) return;
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => debugPrint('Interstitial Failed: $error'),
      ),
    );
  }

  Future<void> showInterstitialAd() async {
    if (!shouldShowAds || _interstitialAd == null) return;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd(); // preload for next time
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadInterstitialAd(); // preload for next time
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void loadRewardAd() {
    if (!shouldShowAds) return;
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) => debugPrint('Reward Ad Failed: $error'),
      ),
    );
  }

  Future<bool> showRewardAd() async {
    if (!shouldShowAds || _rewardedAd == null) return true;

    bool rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewardAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadRewardAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        rewardEarned = true;
      },
    );

    _rewardedAd = null;
    return rewardEarned;
  }

  Future<bool> canPerformActionWithAd() async {
    if (!shouldShowAds) return true;
    return await showRewardAd();
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
  }

  void disposeAds() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
    _isBannerAdLoaded = false;
  }
}