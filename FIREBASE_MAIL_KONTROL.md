# Mail Gelmiyorsa — Firebase Kontrol Listesi (5 dk)

Telefonda **S23** kullanıyorsan bu adımlar yeterli. Chrome/Web şart değil.

---

## Adım 1 — E-posta girişi açık mı?

1. Telefon tarayıcısından aç:  
   https://console.firebase.google.com/project/deneme-app-935b6/authentication/providers

2. **E-posta/Parola** satırına dokun

3. Üstteki ana anahtar **Etkin** olmalı

4. **Kaydet**

---

## Adım 2 — Doğrulama mail şablonu

1. Aç:  
   https://console.firebase.google.com/project/deneme-app-935b6/authentication/emails

2. **E-posta adresi doğrulama** → açık / varsayılan olsun

3. Gönderen: `noreply@deneme-app-935b6.firebaseapp.com`

---

## Adım 3 — Firestore kuralları (çok önemli)

Test modu süresi dolmuşsa uygulama çalışır ama sorun çıkar.

1. Aç:  
   https://console.firebase.google.com/project/deneme-app-935b6/firestore/rules

2. Proje klasöründeki `firestore.rules` içeriğini yapıştır

3. **Yayınla** (Publish)

---

## Adım 4 — Eski denemeleri temizle

1. Aç:  
   https://console.firebase.google.com/project/deneme-app-935b6/authentication/users

2. Test kullanıcılarını **sil** (çöp kutusu)

3. **30-60 dakika bekle** (çok fazla deneme engeli varsa)

4. Uygulamada **yeni Gmail** ile tekrar kayıt ol

---

## Adım 5 — Maili nerede ara?

- Gmail → **Gereksiz / Spam**
- Gönderen: `noreply@deneme-app-935b6.firebaseapp.com`
- Konu: "E-posta adresinizi doğrulayın" (Türkçe olabilir)

---

## Hâlâ gelmiyorsa

Uygulamada kırmızı hata kutusunda **kod:** yazar (ör. `too-many-requests`).  
O kodu ekran görüntüsüyle gönder.
