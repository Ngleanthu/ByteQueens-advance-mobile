import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob Service for managing Banner and Interstitial Ads
/// 
/// Usage:
/// 1. Initialize in main.dart: await AdService().initialize()
/// 2. Banner Ads: Use AdBannerWidget in your UI
/// 3. Interstitial Ads: Call AdService().showInterstitialAd()
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  int _numInterstitialLoadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;

  // Ad Unit IDs - Replace with your actual IDs from AdMob
  // Test IDs for development
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test banner ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test banner ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test interstitial ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test interstitial ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Initialize AdMob SDK
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      print('✅ AdMob initialized successfully');
      
      // Pre-load first interstitial ad
      _loadInterstitialAd();
    } catch (e) {
      print('❌ AdMob initialization failed: $e');
    }
  }

  /// Load Interstitial Ad
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('✅ Interstitial ad loaded');
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _numInterstitialLoadAttempts = 0;

          // Set fullscreen content callback
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) {
              print('📺 Interstitial ad showing');
            },
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              print('👋 Interstitial ad dismissed');
              ad.dispose();
              _isInterstitialAdReady = false;
              // Load next ad
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              print('❌ Interstitial ad failed to show: $error');
              ad.dispose();
              _isInterstitialAdReady = false;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('❌ Interstitial ad failed to load: $error');
          _numInterstitialLoadAttempts++;
          _isInterstitialAdReady = false;

          // Retry loading with exponential backoff
          if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
            Future.delayed(
              Duration(seconds: _numInterstitialLoadAttempts * 2),
              _loadInterstitialAd,
            );
          }
        },
      ),
    );
  }

  /// Show Interstitial Ad if ready
  void showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      print('⚠️ Interstitial ad not ready yet, loading...');
      _loadInterstitialAd();
    }
  }

  /// Check if interstitial ad is ready
  bool get isInterstitialAdReady => _isInterstitialAdReady;

  /// Dispose resources
  void dispose() {
    _interstitialAd?.dispose();
  }
}

/// Banner Ad Widget
/// 
/// Usage:
/// ```dart
/// AdBannerWidget(
///   onAdLoaded: () => print('Banner ad loaded'),
///   onAdFailedToLoad: (error) => print('Banner ad failed: $error'),
/// )
/// ```
class AdBannerWidget extends StatefulWidget {
  final VoidCallback? onAdLoaded;
  final Function(String error)? onAdFailedToLoad;

  const AdBannerWidget({
    super.key,
    this.onAdLoaded,
    this.onAdFailedToLoad,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('✅ Banner ad loaded');
          setState(() {
            _isAdLoaded = true;
          });
          widget.onAdLoaded?.call();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('❌ Banner ad failed to load: $error');
          ad.dispose();
          widget.onAdFailedToLoad?.call(error.toString());
        },
        onAdOpened: (Ad ad) => print('📺 Banner ad opened'),
        onAdClosed: (Ad ad) => print('👋 Banner ad closed'),
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
