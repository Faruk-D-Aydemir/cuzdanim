import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../revenuecat_config.dart';

/// RevenueCat entegrasyonunu yönetir. Henüz aktif bir ücretli plan/ürün
/// olmasa bile SDK başlatılır; RevenueCat panelinden ileride ürün/paket
/// eklendiğinde uygulamada ek kod değişikliği gerekmeden kullanılabilir hale
/// gelir.
///
/// API anahtarları girilmeden (bkz. [RevenueCatConfig]) [init] sessizce hiçbir
/// şey yapmaz; böylece bu adımı henüz tamamlamamış olman uygulamanın
/// çalışmasını etkilemez.
class PurchaseService {
  PurchaseService._();
  static final PurchaseService instance = PurchaseService._();

  bool _isConfigured = false;
  bool get isConfigured => _isConfigured;

  Future<void> init() async {
    final apiKey = _apiKeyForPlatform();
    if (apiKey == null) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ RevenueCat yapılandırılmadı. lib/revenuecat_config.dart '
          'dosyasına API anahtarlarını gir.',
        );
      }
      return;
    }

    try {
      await Purchases.setLogLevel(
        kDebugMode ? LogLevel.debug : LogLevel.warn,
      );
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _isConfigured = true;
    } catch (e) {
      _isConfigured = false;
      if (kDebugMode) {
        debugPrint('RevenueCat başlatılamadı: $e');
      }
    }
  }

  String? _apiKeyForPlatform() {
    if (!kIsWeb && Platform.isAndroid && RevenueCatConfig.isAndroidConfigured) {
      return RevenueCatConfig.androidApiKey;
    }
    if (!kIsWeb && Platform.isIOS && RevenueCatConfig.isIosConfigured) {
      return RevenueCatConfig.iosApiKey;
    }
    return null;
  }

  /// Kullanıcı giriş yaptığında/kayıt olduğunda çağrılır; satın alma
  /// geçmişini ve abonelik durumunu RevenueCat tarafında bu kullanıcıya
  /// (Firebase uid) bağlar.
  Future<void> identify(String userId) async {
    if (!_isConfigured) return;
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      if (kDebugMode) debugPrint('RevenueCat identify hatası: $e');
    }
  }

  /// Kullanıcı çıkış yaptığında/hesabını sildiğinde çağrılır.
  Future<void> reset() async {
    if (!_isConfigured) return;
    try {
      await Purchases.logOut();
    } catch (e) {
      if (kDebugMode) debugPrint('RevenueCat logout hatası: $e');
    }
  }

  /// Kullanıcının aktif bir aboneliği/entitlement'ı var mı kontrol eder.
  /// Henüz RevenueCat panelinde ürün/entitlement tanımlanmadıysa her zaman
  /// false döner; ileride bir entitlement eklendiğinde `entitlementId`
  /// değerini panelde belirlediğin isimle eşleştirmen yeterlidir.
  Future<bool> isEntitledTo(String entitlementId) async {
    if (!_isConfigured) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(entitlementId);
    } catch (e) {
      if (kDebugMode) debugPrint('RevenueCat entitlement kontrolü hatası: $e');
      return false;
    }
  }

  /// Mevcut ürün paketlerini (offerings) getirir. Panelde henüz ürün
  /// tanımlanmadıysa boş/null dönebilir.
  Future<Offerings?> getOfferings() async {
    if (!_isConfigured) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      if (kDebugMode) debugPrint('RevenueCat offerings hatası: $e');
      return null;
    }
  }

  Future<CustomerInfo?> purchasePackage(Package package) async {
    if (!_isConfigured) return null;
    final result = await Purchases.purchase(
      PurchaseParams.package(package),
    );
    return result.customerInfo;
  }

  Future<CustomerInfo?> restorePurchases() async {
    if (!_isConfigured) return null;
    return Purchases.restorePurchases();
  }
}
