# Firebase Hızlı Kurulum (Windows)

## `flutterfire` tanınmıyor hatası

PowerShell'de **her seferinde** önce PATH ekle, sonra komutu çalıştır:

```powershell
cd C:\Users\muham\deneme_app
dart pub global activate flutterfire_cli
$env:PATH += ";$env:LOCALAPPDATA\Pub\Cache\bin"
dart pub global run flutterfire_cli:flutterfire --version
```

Kalıcı PATH (bir kez yap):
- Windows arama → **Ortam değişkenleri** → **Path** → **Yeni** → `%LOCALAPPDATA%\Pub\Cache\bin`

---

## `firebase CLI` eksik hatası

`flutterfire configure` çalışması için **Firebase CLI** da lazım.

### Yol 1 — Node.js kur (önerilen)

1. https://nodejs.org → **LTS** indir ve kur
2. PowerShell'i **kapatıp yeniden aç**
3. Şunları çalıştır:

```powershell
npm install -g firebase-tools
firebase login
cd C:\Users\muham\deneme_app
$env:PATH += ";$env:LOCALAPPDATA\Pub\Cache\bin"
dart pub global run flutterfire_cli:flutterfire configure
```

- Proje: `deneme-app-935b6`
- **Android + Web** seç

### Yol 2 — Elle Web ekle (CLI olmadan, daha kolay)

1. https://console.firebase.google.com/project/deneme-app-935b6/settings/general
2. **Uygulamalarınız** → **</> Web** ikonuna tıkla
3. Takma ad: `cuzdanim-web` → Kaydet
4. Çıkan `appId` değerini kopyala (ör: `1:927025131625:web:abc123...`)
5. `lib/firebase_options.dart` dosyasında `web` bölümünü güncelle:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyAMbl9c5ig9sOoWwYYHhLVSb-niIdOeJ-I',
  appId: 'BURAYA_WEB_APP_ID_YAPIŞTIR',  // ...:web:... olmalı
  messagingSenderId: '927025131625',
  projectId: 'deneme-app-935b6',
  authDomain: 'deneme-app-935b6.firebaseapp.com',
  storageBucket: 'deneme-app-935b6.firebasestorage.app',
);
```

6. Uygulamayı yeniden başlat: `flutter run -d chrome`

---

Doğrulama maili gelmiyorsa **%99 Firebase henüz bağlanmamıştır.**

Kontrol:
- `lib/firebase_options.dart` içinde web `appId` içinde `:android:` varsa → Chrome'da **çalışmaz**
- `android/app/google-services.json` yoksa → Samsung'da çalışmaz

---

## Adım 1 — Firebase Console

1. https://console.firebase.google.com → Proje: `deneme-app-935b6`
2. **Authentication** → Sign-in method → **E-posta/Parola** → Etkinleştir
3. **Firestore Database** → Oluştur (test mode)
4. **Authentication → Settings → Authorized domains** → `localhost` listede olsun

---

## Adım 2 — Samsung'da çalıştır

```powershell
cd C:\Users\muham\deneme_app
flutter pub get
flutter devices
flutter run
```

---

## Mail hâlâ gelmiyorsa

1. **Spam / Gereksiz** klasörüne bak
2. Gönderen: `noreply@deneme-app-935b6.firebaseapp.com`
3. Firebase Console → Authentication → Users → kullanıcı oluşmuş mu?
4. Gmail kullanıyorsan birkaç dakika bekle
5. **Çok fazla deneme** hatası aldıysan 30-60 dakika bekle
6. Uygulamada **Maili Tekrar Gönder** (60 sn arayla)

---

## Önemli

Firebase **sayısal kod göndermez** — e-postadaki **linke tıklaman** gerekir.
