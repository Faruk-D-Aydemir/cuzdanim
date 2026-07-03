import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

enum LegalDocument { privacy, terms }

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPrivacy = document == LegalDocument.privacy;

    return Scaffold(
      appBar: AppBar(
        title: Text(isPrivacy ? l10n.privacyPolicy : l10n.termsOfUse),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Text(
            isPrivacy ? _privacyText(l10n.isTr) : _termsText(l10n.isTr),
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
      ),
    );
  }

  String _privacyText(bool tr) {
    if (tr) {
      return '''Gizlilik Politikası

Son güncelleme: ${DateTime.now().year}

Cüzdanım ("Uygulama"), kişisel bütçe ve aile harcamalarını takip etmene yardımcı olan bir mobil uygulamadır. Bu metin, hangi verileri topladığımızı ve nasıl kullandığımızı açıklar.

1. Topladığımız Veriler
- Hesap bilgileri: e-posta adresin ve seçtiğin kullanıcı adı.
- Finansal kayıtlar: eklediğin gelir/gider işlemleri, kategori, tutar, tarih, açıklama.
- Kart bilgileri: yalnızca kartına verdiğin isim, son 4 hane ve ödeme günü (tam kart numarası, son kullanma tarihi veya CVV asla istenmez veya saklanmaz).
- Aile/çocuk profilleri: ebeveyn tarafından oluşturulan isim, haftalık limit ve harcama kayıtları. Çocuklar için ayrı bir e-posta/hesap oluşturulmaz; bu profiller ebeveynin hesabı altında yönetilir.

2. Verilerin Saklanması
Verilerin Google Firebase (Authentication ve Cloud Firestore) altyapısında, hesabına özel olarak saklanır. Verilerine yalnızca sen (kimlik doğrulaman ile) erişebilirsin.

3. Verilerin Kullanımı
Verilerin sadece uygulama içi bütçe takibi, bildirimler (ödeme hatırlatmaları, çocuk harcama bildirimleri) ve cihazlar arası senkronizasyon amacıyla kullanılır. Verilerin reklam amacıyla üçüncü taraflarla paylaşılmaz veya satılmaz.

4. Bildirimler
Uygulama, tekrarlayan ödeme/gelir hatırlatmaları ve çocuk harcama bildirimleri göndermek için cihazındaki bildirim iznini kullanır. Bu bildirimler tamamen cihazında işlenir.

5. Verilerin Silinmesi
Ayarlar > Hesap bölümünden hesabını ve tüm verilerini kalıcı olarak silebilirsin. Silme işlemi geri alınamaz.

6. Çocukların Gizliliği
Uygulama, çocuklardan doğrudan kişisel bilgi toplamaz. Çocuk profilleri yalnızca ebeveyn tarafından, ebeveynin hesabı içinde oluşturulur ve yönetilir.

7. İletişim
Sorularınız için lütfen uygulama mağazasındaki geliştirici iletişim bilgilerini kullanın.''';
    }

    return '''Privacy Policy

Last updated: ${DateTime.now().year}

Cüzdanım ("the App") helps you track personal and family budgets. This notice explains what data we collect and how it is used.

1. Data We Collect
- Account information: your email address and chosen username.
- Financial records: income/expense entries, category, amount, date, and description you add.
- Card information: only the nickname you give a card, its last 4 digits, and due day (we never ask for or store full card numbers, expiry dates, or CVV).
- Family/child profiles: names, weekly limits, and spending records created by the parent. Children do not have separate accounts or emails; these profiles are managed under the parent's account.

2. Data Storage
Your data is stored on Google Firebase (Authentication and Cloud Firestore), scoped to your account. Only you, after authenticating, can access your data.

3. How We Use Data
Data is used solely to provide budget tracking, notifications (payment reminders, child spending alerts), and cross-device sync. We do not sell your data or share it with third parties for advertising.

4. Notifications
The App uses your device's notification permission to deliver recurring payment/income reminders and child spending alerts. These are processed entirely on your device.

5. Deleting Your Data
You can permanently delete your account and all associated data from Settings > Account at any time. This action cannot be undone.

6. Children's Privacy
The App does not directly collect personal information from children. Child profiles are created and managed solely by the parent within the parent's account.

7. Contact
For questions, please use the developer contact information listed on the app store page.''';
  }

  String _termsText(bool tr) {
    if (tr) {
      return '''Kullanım Koşulları

Son güncelleme: ${DateTime.now().year}

Bu uygulamayı kullanarak aşağıdaki koşulları kabul etmiş olursun:

1. Kullanım Amacı
Cüzdanım, kişisel ve aile bütçesi takibi için bir araçtır; profesyonel finansal, vergi veya hukuki tavsiye niteliği taşımaz.

2. Hesap Sorumluluğu
Kullanıcı adın ve PIN'in gizliliğinden sen sorumlusun. Hesabınla ilgili şüpheli bir durum fark edersen PIN'ini değiştirmen veya hesabını silmen önerilir.

3. Veri Doğruluğu
Girdiğin finansal veriler tamamen senin sorumluluğundadır. Uygulama, girilen verilerin doğruluğunu garanti etmez.

4. Hizmetin Sürekliliği
Uygulama "olduğu gibi" sunulur. Bulut senkronizasyonu internet bağlantısı ve üçüncü taraf altyapı (Firebase) sağlığına bağlıdır; kesinti veya veri kaybı riskine karşı düzenli olarak dışa aktarma (CSV) yapmanı öneririz.

5. Değişiklikler
Bu koşullar zaman zaman güncellenebilir. Önemli değişikliklerde uygulama içinde bilgilendirme yapılır.

6. İletişim
Sorularınız için uygulama mağazasındaki geliştirici iletişim bilgilerini kullanabilirsiniz.''';
    }

    return '''Terms of Use

Last updated: ${DateTime.now().year}

By using this app, you agree to the following terms:

1. Purpose
Cüzdanım is a tool for personal and family budget tracking. It does not provide professional financial, tax, or legal advice.

2. Account Responsibility
You are responsible for keeping your username and PIN confidential. If you notice suspicious activity, we recommend changing your PIN or deleting your account.

3. Data Accuracy
You are solely responsible for the accuracy of the financial data you enter. The App does not guarantee the accuracy of entered data.

4. Service Availability
The App is provided "as is". Cloud sync depends on your internet connection and third-party infrastructure (Firebase); we recommend exporting your data (CSV) regularly to protect against outages or data loss.

5. Changes
These terms may be updated from time to time. Significant changes will be communicated within the app.

6. Contact
For questions, please use the developer contact information listed on the app store page.''';
  }
}
