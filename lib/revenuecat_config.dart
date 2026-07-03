/// RevenueCat yapılandırması.
///
/// Buradaki anahtarlar RevenueCat'in "Public app-specific API key" değerleridir
/// (gizli/sunucu anahtarı DEĞİLDİR) — istemci uygulamasına gömülmek üzere
/// tasarlanmıştır, bu yüzden Firebase anahtarları gibi .gitignore'a eklemeye
/// gerek yoktur.
///
/// Anahtarları almak için:
/// 1. https://app.revenuecat.com adresinde ücretsiz bir hesap oluştur.
/// 2. "Create new project" ile bir proje oluştur (örn. "Cüzdanım").
/// 3. Projeye Android ve iOS uygulaması ekle:
///    - Android package name: com.cuzdanim.app
///    - iOS bundle ID: com.cuzdanim.app
/// 4. Project settings > API keys sayfasından her platform için
///    "Public app-specific API key" değerini kopyala ve aşağıya yapıştır.
///
/// Henüz bir ücretli plan/ürün oluşturmadan da bu adımları tamamlayıp
/// anahtarları buraya girebilirsin; SDK ürünsüz de sorunsuz başlatılır ve
/// ileride RevenueCat panelinden ürün/paket eklediğinde otomatik olarak
/// görünür hale gelir, uygulamada tekrar kod değişikliği gerekmez.
class RevenueCatConfig {
  const RevenueCatConfig._();

  /// RevenueCat > Project settings > API keys > Google Play Store
  static const String androidApiKey = 'REVENUECAT_ANDROID_API_KEY';

  /// RevenueCat > Project settings > API keys > App Store
  static const String iosApiKey = 'REVENUECAT_IOS_API_KEY';

  static bool get isAndroidConfigured =>
      androidApiKey.isNotEmpty && androidApiKey != 'REVENUECAT_ANDROID_API_KEY';

  static bool get isIosConfigured =>
      iosApiKey.isNotEmpty && iosApiKey != 'REVENUECAT_IOS_API_KEY';
}
