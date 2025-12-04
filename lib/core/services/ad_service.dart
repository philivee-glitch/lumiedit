import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'purchase_service.dart';
import 'dart:io';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isInitialized = false;

  // Your Ad Unit IDs
  static String get bannerAdUnitId {
    if (Platform.isIOS) {
      return 'ca-app-pub-9349326189536065/2575631791';
    }
    return 'ca-app-pub-3940256099942544/6300978111'; // Android test ID
  }

  static String get interstitialAdUnitId {
    if (Platform.isIOS) {
      return 'ca-app-pub-9349326189536065/1314521017';
    }
    return 'ca-app-pub-3940256099942544/1033173712'; // Android test ID
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
    loadInterstitialAd();
  }

  BannerAd? get bannerAd => _bannerAd;

  void loadBannerAd({required Function(Ad) onAdLoaded}) {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          print('Banner ad failed to load: $error');
        },
      ),
    )..load();
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('Banner ad loaded successfully!');
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              loadInterstitialAd(); // Preload next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  Future<void> showInterstitialAd() async {
    if (PurchaseService().isPremium) return; // Don't show ads for premium users
    if (_interstitialAd != null) {
      await _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }
}
