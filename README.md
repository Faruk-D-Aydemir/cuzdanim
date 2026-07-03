# Cüzdanım

`Cüzdanım`, aile odaklı bir Flutter finans takip uygulamasıdır. Gelir, gider, kart, çocuk profili, aylık bütçe ve tekrarlayan işlemler Firebase üzerinde saklanır.

## Özellikler

- E-posta doğrulamalı hesap oluşturma ve PIN ile giriş
- Gelir / gider / market / kart takibi
- Çocuk profilleri ve haftalık limit mantığı
- Her ay otomatik işlenen tekrarlayan gelir ve giderler
- Firebase Firestore ile bulut yedekleme

## Çalıştırma

```bash
flutter pub get
flutter run
```

## Android APK

Debug APK üretmek için:

```bash
flutter build apk --debug
```

Hazır kopya dosya genelde proje kökünde tutulur:

`C:\Users\muham\deneme_app\Cuzdanim.apk`

## Docker

Bu repo içinde Flutter ortamını hızlı kurmak için bir `Dockerfile` vardır. Bu Docker imajı:

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`

için uygundur.

Örnek kullanım:

```bash
docker build -t cuzdanim .
docker run --rm -it cuzdanim flutter analyze
```

Not: Docker, iOS App Store yüklemesinin yerine geçmez. iOS derleme ve mağaza yükleme için yine macOS gerekir.

## Firebase

Projede Firestore kullanılır. Temel koleksiyonlar:

- `users/{userId}`
- `users/{userId}/transactions`
- `users/{userId}/cards`
- `users/{userId}/recurring`
- `users/{userId}/children`
- `usernames/{username}`

Firestore Rules dosyası:

`firestore.rules`
