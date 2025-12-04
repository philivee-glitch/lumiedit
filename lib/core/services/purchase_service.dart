import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Product IDs - must match App Store Connect
  static const String monthlyId = 'com.codenestle.lumiedit.monthly';
  static const String annualId = 'com.codenestle.lumiedit.annual';
  static const String lifetimeId = 'com.codenestle.lumiedit.lifetime';
  
  static const Set<String> _productIds = {monthlyId, annualId, lifetimeId};
  
  List<ProductDetails> products = [];
  bool _isPremium = false;
  
  bool get isPremium => _isPremium;
  
  final _premiumController = StreamController<bool>.broadcast();
  Stream<bool> get premiumStream => _premiumController.stream;

  Future<void> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) {
      print('In-app purchases not available');
      return;
    }
    
    // Load saved premium status
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('isPremium') ?? false;
    _premiumController.add(_isPremium);
    
    // Listen to purchases
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) => print('Purchase error: $error'),
    );
    
    // Load products
    await loadProducts();
    
    // Restore purchases
    await restorePurchases();
  }

  Future<void> loadProducts() async {
    final response = await _iap.queryProductDetails(_productIds);
    if (response.error != null) {
      print('Error loading products: ${response.error}');
      return;
    }
    products = response.productDetails;
    print('Loaded ${products.length} products');
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyAndDeliver(purchase);
          break;
        case PurchaseStatus.error:
          print('Purchase error: ${purchase.error}');
          break;
        case PurchaseStatus.pending:
          print('Purchase pending');
          break;
        case PurchaseStatus.canceled:
          print('Purchase canceled');
          break;
      }
      
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _verifyAndDeliver(PurchaseDetails purchase) async {
    // In production, verify with your server
    // For now, trust the purchase
    await _setPremium(true);
    print('Premium activated!');
  }

  Future<void> _setPremium(bool value) async {
    _isPremium = value;
    _premiumController.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', value);
  }

  Future<void> buyProduct(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    
    if (product.id == lifetimeId) {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  ProductDetails? getProduct(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _premiumController.close();
  }
}
