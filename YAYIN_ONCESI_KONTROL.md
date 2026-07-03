# Yayın Öncesi Kontrol Listesi

Bu doküman, Cüzdanım'ı App Store / Google Play'e yüklemeden önce yapılan kod
incelemesinin ve düzeltmelerin özetini içerir.

## ✅ Bu oturumda tamamen çözülenler

1. **Kritik güvenlik açığı — PIN hash sızıntısı.** `firestore.rules` dosyasında
   `usernames/{username}` koleksiyonu herkese (giriş yapmadan) açık şekilde
   okunabiliyordu ve her kullanıcının e-postasını ve PIN hash'ini
   içeriyordu. PIN sadece 4 haneli olduğu için (10.000 ihtimal), bu hash'i
   ele geçiren biri saniyeler içinde tüm kullanıcıların PIN'lerini
   kırabilirdi. Düzeltildi: PIN hash'i artık hiçbir yerde saklanmıyor,
   doğrulama tamamen Firebase Authentication'ın kendi mekanizmasına
   (hız sınırlamalı, sunucu taraflı) devredildi.
   - **Tek yapman gereken:** Güncellenmiş `firestore.rules` dosyasını
     Firebase Console → Firestore Database → Rules sekmesinden yapıştırıp
     "Yayınla" demen gerekiyor (dosya içeriğini kopyala/yapıştır, 1 dakika
     sürer). Yayınlamazsan eski güvensiz kural aktif kalmaya devam eder.
2. **Hesap silme özelliği** eklendi (Ayarlar → Tehlikeli Bölge). Apple/Google
   mağaza kurallarının zorunlu tuttuğu bir özellikti.
3. **Gizlilik Politikası ve Kullanım Koşulları** uygulama içine eklendi
   (Ayarlar → Yasal).
4. **Paket adı değiştirildi:** `com.example.deneme_app` / `com.example.denemeApp`
   → **`com.cuzdanim.app`** (Android + iOS + macOS + Linux + Windows, tüm
   platformlarda). Mağazalar `com.example` ile başlayan adları kabul etmez;
   bu artık düzeltildi. `google-services.json` da yeni paket adıyla
   güncellendi ve `flutter build apk --release` ile gerçek bir derleme
   yapılıp doğrulandı — sorunsuz çalışıyor.
5. **Gerçek release imzalama anahtarı (keystore) oluşturuldu.** Önceden
   release derlemesi geçici "debug" anahtarıyla imzalanıyordu (Play Store
   bunu kabul etmez). Şimdi:
   - `android/cuzdanim-release.jks` — gerçek imzalama anahtarın.
   - `android/key.properties` — anahtar parolaların (rastgele, güçlü
     üretildi; sohbette hiçbir yerde gösterilmedi).
   - `android/app/build.gradle.kts` bu dosyaları otomatik kullanacak şekilde
     güncellendi. `flutter build apk --release` ile test edildi, APK artık
     gerçek sertifikanla imzalanıyor (`CN=Cuzdanim` — debug değil).
   - Her ikisi de `.gitignore`'a eklendi, asla GitHub'a gitmeyecek.
   - **ÇOK ÖNEMLİ:** `android/cuzdanim-release.jks` ve `android/key.properties`
     dosyalarını **güvenli bir yere yedekle** (harici disk, şifreli bulut
     vb.). Bu dosyayı kaybedersen Play Store'da uygulamanı **bir daha asla
     güncelleyemezsin** — yeni bir uygulama olarak baştan yayınlaman
     gerekir. Bilgisayarın formatlanırsa/bozulursa bu dosyalar da gider.
6. Geliştirme ekranındaki kişisel bilgisayar yolu kaldırıldı, iOS/Android/
   masaüstü uygulama adları "Cüzdanım" ile tutarlı hale getirildi,
   gereksiz izinler (`SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`)
   kaldırıldı, kullanılmayan bağımlılık temizlendi.
7. `flutter analyze` → 0 uyarı, `flutter test` → geçti, `flutter build apk
   --release` → başarılı (56 MB, `com.cuzdanim.app`, gerçek imzayla).

## 🚧 Sadece SEN yapabilirsin (kendi hesaplarınla giriş gerektiriyor)

Bunlar kod değil, hesap/erişim işi olduğu için ben yapamıyorum:

### 1. Firebase güvenlik kurallarını yayınla (5 dakika, ZORUNLU)
[Firebase Console](https://console.firebase.google.com) → `deneme-app-935b6`
projesi → Firestore Database → Rules → bu repodaki `firestore.rules`
dosyasının içeriğini yapıştır → Yayınla (Publish).

### 2. (İsteğe bağlı ama önerilir) Firebase'e yeni paket adını kaydet
Paket adını `com.cuzdanim.app` yaptım ve mevcut Firebase projenle (aynı
API anahtarı) sorunsuz çalışacak şekilde ayarladım — uygulama bugün de
çalışır. Ama Firebase Console'da Android uygulaman hâlâ eski paket adıyla
kayıtlı görünüyor. Temizlik için (zorunlu değil): Proje Ayarları →
Uygulama Ekle → Android → paket adı `com.cuzdanim.app` → imzalama
sertifikanın SHA-1'ini ekle (`keytool -list -v -keystore
android/cuzdanim-release.jks` ile alınır) → yeni `google-services.json`'ı
indirip `android/app/` içine koy.

### 3. `android/cuzdanim-release.jks` ve `android/key.properties`'i yedekle
Yukarıda anlatıldığı gibi — kaybedilirse geri dönüşü yok.

### 4. Gizlilik Politikası URL'si
Uygulama içine eklediğim metni (Ayarlar → Gizlilik Politikası) aynı
zamanda bir web sayfasında yayınla. App Store Connect ve Play Console,
mağaza kaydı için bir URL ister. En kolay yol: metni bir GitHub Pages
sayfasına koymak (istersen bir sonraki adımda bunu senin için
otomatikleştirebilirim — GitHub hesabınla bağlantı kurman gerekiyor).

### 5. Play Console "Data Safety" formu / Apple "App Privacy" beyanı
Hangi verilerin toplandığını (e-posta, finansal veriler, bildirimler)
mağaza panellerindeki formlara işlemen gerekiyor. Eklediğim gizlilik
politikası metni buna referans olarak kullanılabilir.

### 6. Store görselleri
Uygulama ikonu, ekran görüntüleri, öne çıkan görsel gibi materyaller.
İstersen ikon için bir tasarım önerisi hazırlayabilirim.

### 7. Apple Developer Program / Google Play Console hesapları
Eğer henüz yoksa, Apple için yıllık 99 USD, Google için tek seferlik 25
USD ödeyerek geliştirici hesabı açman gerekiyor — bu adım tamamen senin
kimlik/ödeme bilgini gerektirdiği için benim yapabileceğim bir şey değil.

## Bilinen küçük eksik (zorunlu değil)
"PIN'imi unuttum" akışı yok — şu an bir kullanıcı PIN'ini unutursa hesabına
giremez. Güvenlik açığı değil, ilk sürüm için kabul edilebilir; ileride
eklenmesi önerilir.

## Yayına almadan önce son test
1. `flutter build appbundle --release` ile Play Store'a yüklenecek `.aab`
   dosyasını üret (APK değil, Play Store artık AAB istiyor).
2. Gerçek bir cihazda: kayıt ol → e-posta doğrula → çıkış yap → giriş yap →
   Ayarlar → Hesabı Sil akışlarını uçtan uca dene.
