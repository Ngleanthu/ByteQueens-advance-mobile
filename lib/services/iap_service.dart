import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:bytequeens_adm/services/subscription_service.dart';

/// In-App Purchase Service for managing subscriptions
/// 
/// Supports:
/// - Monthly Pro subscription
/// - Yearly Pro subscription (with discount)
/// - Purchase verification with backend
class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final SubscriptionService _subscriptionService = SubscriptionService();

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _purchasePending = false;

  // Product IDs - Replace with your actual product IDs from App Store Connect & Google Play Console
  static const String kMonthlySubscriptionId = 'jarvis_pro_monthly';
  static const String kYearlySubscriptionId = 'jarvis_pro_yearly';

  static const List<String> _kProductIds = <String>[
    kMonthlySubscriptionId,
    kYearlySubscriptionId,
  ];

  /// Initialize IAP
  Future<void> initialize() async {
    try {
      // Check if IAP is available
      final available = await _iap.isAvailable();
      if (!available) {
        _isAvailable = false;
        print('❌ IAP not available on this device');
        return;
      }

      _isAvailable = true;
      print('✅ IAP is available');

      // Platform-specific setup
      // iOS delegate setup commented out - uncomment if needed
      // if (Platform.isIOS) {
      //   final iosPlatform = InAppPurchaseStoreKitPlatformAddition();
      //   await iosPlatform.setDelegate(PaymentQueueDelegate());
      // }

      // Listen to purchase updates
      final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _handlePurchaseUpdates,
        onDone: () => _subscription?.cancel(),
        onError: (error) {
          print('❌ Purchase stream error: $error');
        },
      );

      // Load products
      await loadProducts();

      // Check for pending purchases
      await _checkPendingPurchases();
    } catch (e) {
      print('❌ IAP initialization failed: $e');
      _isAvailable = false;
    }
  }

  /// Load available products from store
  Future<void> loadProducts() async {
    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails(_kProductIds.toSet());

      if (response.notFoundIDs.isNotEmpty) {
        print('⚠️ Products not found: ${response.notFoundIDs}');
      }

      if (response.error != null) {
        print('❌ Error loading products: ${response.error}');
        return;
      }

      _products = response.productDetails;
      print('✅ Loaded ${_products.length} products');

      for (var product in _products) {
        print('  - ${product.id}: ${product.title} - ${product.price}');
      }
    } catch (e) {
      print('❌ Failed to load products: $e');
    }
  }

  /// Check for pending purchases on app start
  Future<void> _checkPendingPurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      print('❌ Failed to restore purchases: $e');
    }
  }

  /// Handle purchase updates
  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      print('📦 Purchase update: ${purchaseDetails.status}');

      if (purchaseDetails.status == PurchaseStatus.pending) {
        _purchasePending = true;
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _handleError(purchaseDetails.error!);
          _purchasePending = false;
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          // Verify purchase with backend
          final verified = await _verifyPurchase(purchaseDetails);
          if (verified) {
            print('✅ Purchase verified successfully');
            await _deliverProduct(purchaseDetails);
          } else {
            print('❌ Purchase verification failed');
            _handleError(IAPError(
              source: 'verification',
              code: 'verification_failed',
              message: 'Failed to verify purchase with backend',
            ));
          }
          _purchasePending = false;
        }

        // Mark purchase as delivered/completed
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  /// Verify purchase with backend
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      // TODO: Call your backend API to verify purchase
      // This should validate the receipt with Apple/Google
      // and update user's subscription status
      
      // For now, just call the subscribe API
      final response = await _subscriptionService.subscribeToPro();
      return response.success;
    } catch (e) {
      print('❌ Purchase verification error: $e');
      return false;
    }
  }

  /// Deliver product to user
  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    // Update local state, refresh subscription info, etc.
    print('🎁 Delivering product: ${purchaseDetails.productID}');
  }

  /// Handle purchase errors
  void _handleError(IAPError error) {
    print('❌ Purchase error: ${error.code} - ${error.message}');
  }

  /// Buy monthly subscription
  Future<bool> buyMonthlySubscription() async {
    final product = _products.firstWhere(
      (p) => p.id == kMonthlySubscriptionId,
      orElse: () => throw Exception('Monthly subscription not found'),
    );

    return await _buyProduct(product);
  }

  /// Buy yearly subscription
  Future<bool> buyYearlySubscription() async {
    final product = _products.firstWhere(
      (p) => p.id == kYearlySubscriptionId,
      orElse: () => throw Exception('Yearly subscription not found'),
    );

    return await _buyProduct(product);
  }

  /// Buy a product
  Future<bool> _buyProduct(ProductDetails product) async {
    if (!_isAvailable) {
      print('❌ IAP not available');
      return false;
    }

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      return true;
    } catch (e) {
      print('❌ Purchase failed: $e');
      return false;
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
      print('✅ Purchases restored');
    } catch (e) {
      print('❌ Failed to restore purchases: $e');
    }
  }

  /// Get product by ID
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Get monthly subscription product
  ProductDetails? get monthlyProduct => getProduct(kMonthlySubscriptionId);

  /// Get yearly subscription product
  ProductDetails? get yearlyProduct => getProduct(kYearlySubscriptionId);

  /// Check if IAP is available
  bool get isAvailable => _isAvailable;

  /// Check if purchase is pending
  bool get isPurchasePending => _purchasePending;

  /// Get all products
  List<ProductDetails> get products => _products;

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
  }
}

/// Payment Queue Delegate for iOS
// PaymentQueueDelegate implementation (optional for advanced iOS features)
// Uncomment and implement if you need specific iOS transaction handling
// class PaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
//   @override
//   bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
//     return true;
//   }
//
//   @override
//   bool shouldShowPriceConsent() {
//     return false;
//   }
// }
