# Cüzdanım — Kablo Olmadan S23'e Kur

## Yol A — APK ile telefona kur (önerilen, kablo yok)

### Sen (telefonda, 5 dk)

1. PC'den kendine **Google Drive** / **e-posta** / **WhatsApp Web** ile APK dosyasını gönder  
   Dosya yolu PC'de:
   ```
   C:\Users\muham\deneme_app\build\app\outputs\flutter-apk\app-debug.apk
   ```

2. S23'te dosyayı indir → **Yükle** / **Kur**

3. İzin isterse: **Bu kaynaktan yüklemeye izin ver** (Drive veya Chrome için)

4. **Cüzdanım** uygulamasını aç → Hesap oluştur → maildeki linke tıkla

### APK yoksa PC'de şunu çalıştır

```powershell
cd C:\Users\muham\deneme_app
flutter build apk --debug
```

---

## Yol B — PC'de Chrome (telefona kurmadan test)

1. Telefon tarayıcısından aç:  
   https://console.firebase.google.com/project/deneme-app-935b6/settings/general

2. **</> Web** ekle → `appId` kopyala (`...:web:...` ile biter)

3. Bana `appId`'yi yaz — ben koda eklerim

4. PC'de: `flutter run -d chrome`

---

## S23 — Geliştirici modu (sadece kabloyla PC'ye bağlarken lazım)

Kablo yoksa şimdilik atla.

1. **Ayarlar** (dişli ikon)
2. En alta in → **Telefon hakkında** (veya **Cihaz bakımı** → **Telefon hakkında**)
3. **Yazılım bilgileri**
4. **Yapı numarası** — **7 kez** hızlıca dokun
5. "Geliştirici oldunuz" yazar
6. Geri → **Geliştirici seçenekleri** → **USB hata ayıklama** aç

Yapı numarası yoksa: **Yazılım bilgileri** içinde **Derleme numarası** olabilir — ona 7 kez bas.

---

## Mail gelmezse

- Spam / Gereksiz klasörü
- "Çok fazla deneme" gördüysen 30-60 dk bekle
- Yeni e-posta ile tekrar dene
