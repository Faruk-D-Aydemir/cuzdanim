import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  bool get isTr => locale.languageCode == 'tr';

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('tr', 'TR'),
    Locale('en', 'US'),
  ];

  String get appName => isTr ? 'Cüzdanım' : 'My Wallet';
  String get authTagline => isTr
      ? 'Bulut destekli, modern bütçe takibi'
      : 'Cloud-backed, modern budget tracking';
  String get tabLogin => isTr ? 'Giriş Yap' : 'Log In';
  String get tabRegister => isTr ? 'Hesap Oluştur' : 'Create Account';
  String get usernameLabel => isTr ? 'Kullanıcı adı' : 'Username';
  String get usernameHintLogin =>
      isTr ? 'Kayıtlı kullanıcı adın' : 'Your registered username';
  String get usernameRequired => isTr ? 'Kullanıcı adını gir' : 'Enter your username';
  String get continueToPin =>
      isTr ? 'Devam Et — PIN Gir' : 'Continue — Enter PIN';
  String get emailLabel => isTr ? 'E-posta' : 'Email';
  String get emailHint =>
      isTr ? 'Doğrulama maili gönderilecek' : 'A verification email will be sent';
  String get emailRequired => isTr ? 'E-posta girin' : 'Enter your email';
  String get emailInvalid =>
      isTr ? 'Geçerli bir e-posta girin' : 'Enter a valid email';
  String get usernameHintRegister =>
      isTr ? 'Benzersiz kullanıcı adı seç' : 'Choose a unique username';
  String get usernameMinLength =>
      isTr ? 'En az 3 karakter olmalı' : 'Must be at least 3 characters';
  String get usernameInvalidChars => isTr
      ? 'Sadece harf, rakam ve _ kullanılabilir'
      : 'Only letters, numbers, and _ allowed';
  String get continueCreatePin =>
      isTr ? 'Devam Et — PIN Oluştur' : 'Continue — Create PIN';
  String get usernameTaken =>
      isTr ? 'Bu kullanıcı adı alınmış' : 'This username is taken';
  String get pinEnterTitle => isTr ? 'PIN Gir' : 'Enter PIN';
  String get pinEnterSubtitle =>
      isTr ? '4 haneli PIN\'ini gir' : 'Enter your 4-digit PIN';
  String get pinCreateTitle => isTr ? 'PIN Oluştur' : 'Create PIN';
  String get pinConfirmTitle => isTr ? 'PIN Onayla' : 'Confirm PIN';
  String get pinConfirmPadTitle => isTr ? 'PIN\'i Onayla' : 'Confirm PIN';
  String get pinCreateSubtitle =>
      isTr ? '4 haneli PIN belirle' : 'Set a 4-digit PIN';
  String get pinConfirmSubtitle =>
      isTr ? 'Aynı PIN\'i tekrar gir' : 'Enter the same PIN again';
  String get pinMismatch =>
      isTr ? 'PIN\'ler eşleşmedi. Tekrar dene.' : 'PINs don\'t match. Try again.';
  String usernameAt(String username) => '@$username';

  String get emailVerifyTitle => isTr ? 'E-postanı Doğrula' : 'Verify Your Email';
  String emailVerifySentTo(String email) => isTr
      ? '$email adresine doğrulama linki gönderiyoruz.'
      : 'We\'re sending a verification link to $email.';
  String get emailVerifyInitial => isTr
      ? 'Doğrulama maili gönderildi. Spam klasörünü kontrol et. Gelmezse 1-2 dakika bekle, sonra "Maili Tekrar Gönder"e bas.'
      : 'Verification email sent. Check spam. Wait 1–2 minutes, then tap Resend Email.';
  String get emailVerifyNotYet => isTr
      ? 'Henüz doğrulanmadı. Maildeki linke tıkladığından emin ol.'
      : 'Not verified yet. Make sure you clicked the link in the email.';
  String get emailVerifyResentSuccess =>
      isTr ? 'Doğrulama maili gönderildi!' : 'Verification email sent!';
  String get emailVerifySnackbarSent => isTr
      ? 'Mail gönderildi — spam klasörünü de kontrol et'
      : 'Email sent — also check your spam folder';
  String get emailVerifyHelp => isTr
      ? 'Gönderen: noreply@deneme-app-935b6.firebaseapp.com\nGmail → Gereksiz / Spam klasörüne bak.\nLinke tıkladıktan sonra "Linke Tıkladım, Devam Et" butonuna bas.'
      : 'From: noreply@deneme-app-935b6.firebaseapp.com\nCheck Gmail Spam/Junk.\nAfter clicking the link, tap "I Clicked the Link, Continue".';
  String get emailVerifyContinue =>
      isTr ? 'Linke Tıkladım, Devam Et' : 'I Clicked the Link, Continue';
  String get emailVerifyResend => isTr ? 'Maili Tekrar Gönder' : 'Resend Email';
  String emailVerifyResendCooldown(int seconds) =>
      isTr ? 'Tekrar gönder ($seconds sn)' : 'Resend (${seconds}s)';
  String get logout => isTr ? 'Çıkış Yap' : 'Log Out';
  String get logoutShort => isTr ? 'Çıkış' : 'Log Out';
  String get logoutDialogTitle => isTr ? 'Çıkış Yap' : 'Log Out';
  String get logoutDialogMessage => isTr
      ? 'Hesabından çıkış yapılacak. Tekrar giriş için kullanıcı adı ve PIN gerekir.'
      : 'You will be logged out. Username and PIN are required to sign in again.';
  String get cancel => isTr ? 'İptal' : 'Cancel';
  String get save => isTr ? 'Kaydet' : 'Save';
  String get delete => isTr ? 'Sil' : 'Delete';
  String get add => isTr ? 'Ekle' : 'Add';
  String get seeAll => isTr ? 'Tümü' : 'See all';

  String get whoUsing => isTr ? 'Kim kullanıyor?' : 'Who\'s using the app?';
  String get parentName => isTr ? 'Ebeveyn' : 'Parent';
  String get parentSubtitle =>
      isTr ? 'Tüm hesapları yönet' : 'Manage all accounts';
  String get noChildren =>
      isTr ? 'Henüz çocuk profili yok' : 'No child profiles yet';
  String get noChildrenHint => isTr
      ? 'Ebeveyn olarak giriş yapıp Aile sekmesinden ekleyebilirsin'
      : 'Log in as parent and add one from the Family tab';
  String get childAccount => isTr ? 'Çocuk hesabı' : 'Child account';
  String get addChild => isTr ? 'Çocuk Ekle' : 'Add Child';
  String get nameLabel => isTr ? 'İsim' : 'Name';
  String get nameHint => isTr ? 'Örn: Ali' : 'e.g. Ali';
  String get nameRequired => isTr ? 'İsim girin' : 'Enter a name';
  String get weeklyLimitLabel =>
      isTr ? 'Haftalık harcama limiti (₺)' : 'Weekly spending limit (₺)';
  String get weeklyLimitHint =>
      isTr ? 'İsteğe bağlı, örn: 200' : 'Optional, e.g. 200';
  String get profileColor => isTr ? 'Profil rengi' : 'Profile color';

  String get navSummary => isTr ? 'Özet' : 'Summary';
  String get navAnalytics => isTr ? 'Analiz' : 'Analytics';
  String get navTransactions => isTr ? 'İşlemler' : 'Transactions';
  String get navMarket => isTr ? 'Market' : 'Groceries';
  String get navCards => isTr ? 'Kartlar' : 'Cards';
  String get navFamily => isTr ? 'Aile' : 'Family';
  String get settings => isTr ? 'Ayarlar' : 'Settings';
  String get switchProfile => isTr ? 'Profil değiştir' : 'Switch profile';
  String get remainingBalance => isTr ? 'Kalan Bakiye' : 'Remaining Balance';
  String get income => isTr ? 'Gelir' : 'Income';
  String get expense => isTr ? 'Gider' : 'Expense';
  String get marketSpending => isTr ? 'Market Harcaması' : 'Grocery Spending';
  String get monthlyBudget => isTr ? 'Aylık Bütçe' : 'Monthly Budget';
  String get budgetExceeded => isTr ? 'Aşıldı!' : 'Over budget!';
  String budgetRemaining(String amount) =>
      isTr ? 'Kalan: $amount' : 'Remaining: $amount';
  String get childSpending => isTr ? 'Çocuk Harcamaları' : 'Children\'s Spending';
  String thisMonth(String amount) => isTr ? 'Bu ay: $amount' : 'This month: $amount';
  String weeklyShort(String amount) => isTr ? 'Hft: $amount' : 'Wk: $amount';
  String get upcomingCardPayments =>
      isTr ? 'Yaklaşan Kart Ödemeleri' : 'Upcoming Card Payments';
  String get addCard => isTr ? 'Kart Ekle' : 'Add Card';
  String get noCardsYet => isTr ? 'Henüz kart eklenmedi' : 'No cards added yet';
  String get addCardHint => isTr
      ? 'Ödeme tarihlerini takip etmek için kart ekle'
      : 'Add a card to track payment dates';
  String cardDueSubtitle(String day, String amount) => isTr
      ? 'Son ödeme: $day. gün • $amount bu ay'
      : 'Due: day $day • $amount this month';
  String get today => isTr ? 'Bugün' : 'Today';
  String daysLeft(int days) => isTr ? '$days gün' : '$days days';
  String get spendingBreakdown => isTr ? 'Harcama Dağılımı' : 'Spending Breakdown';
  String get noExpensesThisMonth =>
      isTr ? 'Bu ay henüz gider kaydı yok' : 'No expenses recorded this month';

  String get analyticsTitle => isTr ? 'Analiz' : 'Analytics';
  String get expenseVsLastMonth =>
      isTr ? 'Geçen aya göre gider' : 'Expense vs last month';
  String expenseIncrease(String percent) =>
      isTr ? '%$percent artış' : '$percent% increase';
  String expenseDecrease(String percent) =>
      isTr ? '%$percent azalış' : '$percent% decrease';
  String budgetExceededBy(String amount) => isTr
      ? 'Bütçeyi $amount aştın!'
      : 'You exceeded the budget by $amount!';
  String get categoryBreakdown =>
      isTr ? 'Kategori Dağılımı' : 'Category Breakdown';
  String get noExpenseData =>
      isTr ? 'Bu ay gider verisi yok' : 'No expense data this month';

  String get transactionsTitle => isTr ? 'İşlemler' : 'Transactions';
  String get searchHint => isTr
      ? 'Ara (kategori, açıklama, tutar)'
      : 'Search (category, description, amount)';
  String get filterAll => isTr ? 'Tümü' : 'All';
  String get transactionsEmpty =>
      isTr ? 'İşlem bulunamadı' : 'No transactions found';
  String get deleteTransactionTitle => isTr ? 'Sil' : 'Delete';
  String get deleteTransactionMessage =>
      isTr ? 'Bu işlemi silmek istiyor musun?' : 'Delete this transaction?';
  String get transactionDeleted => isTr ? 'İşlem silindi' : 'Transaction deleted';

  String get addTransactionTitle => isTr ? 'İşlem Ekle' : 'Add Transaction';
  String get amountLabel => isTr ? 'Tutar (₺)' : 'Amount (₺)';
  String get amountRequired => isTr ? 'Tutar girin' : 'Enter amount';
  String get amountInvalid =>
      isTr ? 'Geçerli bir tutar girin' : 'Enter a valid amount';
  String get descriptionOptional =>
      isTr ? 'Açıklama (isteğe bağlı)' : 'Description (optional)';
  String get date => isTr ? 'Tarih' : 'Date';
  String get repeatMonthly => isTr ? 'Her ay tekrarla' : 'Repeat monthly';
  String repeatMonthlySubtitle(int day) => isTr
      ? 'Bu işlemi her ayın $day. gününde otomatik ekle'
      : 'Automatically add this on the $day${_ordinal(day)} of each month';
  String get category => isTr ? 'Kategori' : 'Category';
  String get incomeType => isTr ? 'Gelir Türü' : 'Income type';
  String get whoseExpense => isTr ? 'Kimin harcaması?' : 'Whose expense?';
  String get parentGeneral => isTr ? 'Ebeveyn / genel' : 'Parent / general';
  String get cardOptional => isTr ? 'Kart (isteğe bağlı)' : 'Card (optional)';
  String get cashOrCard => isTr ? 'Nakit / kart seç' : 'Cash / select card';
  String get cash => isTr ? 'Nakit' : 'Cash';
  String get transactionSaved =>
      isTr ? 'İşlem buluta kaydedildi' : 'Transaction saved to cloud';
  String get transactionAndRecurringSaved => isTr
      ? 'İşlem ve aylık tekrar buluta kaydedildi'
      : 'Transaction and monthly repeat saved to cloud';
  String get cardNameLabel => isTr ? 'Kart Adı' : 'Card name';
  String get cardNameHint => isTr ? 'Örn: Garanti Bonus' : 'e.g. Garanti Bonus';
  String get cardNameRequired => isTr ? 'Kart adı girin' : 'Enter card name';
  String get lastFourLabel =>
      isTr ? 'Son 4 Hane (isteğe bağlı)' : 'Last 4 digits (optional)';
  String get dueDayLabel =>
      isTr ? 'Son Ödeme Günü (ayın kaçı)' : 'Payment due day (day of month)';
  String dueDayMonthly(int day) =>
      isTr ? 'Her ayın $day. günü' : 'On the $day${_ordinal(day)} of each month';
  String get cardColor => isTr ? 'Kart Rengi' : 'Card color';
  String get saveCard => isTr ? 'Kartı Kaydet' : 'Save Card';
  String get cardSaved => isTr ? 'Kart buluta kaydedildi' : 'Card saved to cloud';

  String get cardsTitle => isTr ? 'Kredi Kartları' : 'Credit Cards';
  String get cardsEmpty => isTr
      ? 'Henüz kart eklenmedi.\nÖdeme tarihlerini takip etmek için kart ekle.'
      : 'No cards yet.\nAdd a card to track payment dates.';
  String lastPayment(String date) =>
      isTr ? 'Son ödeme: $date' : 'Last payment: $date';
  String get dueToday => isTr ? 'Bugün!' : 'Today!';
  String daysLeftLong(int days) =>
      isTr ? '$days gün kaldı' : '$days days left';
  String get deleteCardTitle => isTr ? 'Kartı Sil' : 'Delete Card';
  String deleteCardMessage(String name) => isTr
      ? '$name kartını silmek istiyor musun?'
      : 'Delete card $name?';
  String get cardDeleted => isTr ? 'Kart silindi' : 'Card deleted';

  String get marketTitle => isTr ? 'Market Harcamaları' : 'Grocery Spending';
  String get totalMarketSpending =>
      isTr ? 'Toplam Market Harcaması' : 'Total Grocery Spending';
  String shareOfExpenses(String percent) => isTr
      ? 'Tüm giderlerin %$percent\'i'
      : '$percent% of all expenses';
  String get weeklyBreakdown => isTr ? 'Haftalık Dağılım' : 'Weekly Breakdown';
  String weekLabel(int week) => isTr ? 'H$week' : 'W$week';
  String transactionsCount(int count) =>
      isTr ? 'İşlemler ($count)' : 'Transactions ($count)';
  String get marketEmpty => isTr
      ? 'Bu ay market harcaması yok.\nAlışveriş ekleyerek başla.'
      : 'No grocery spending this month.\nAdd a purchase to get started.';
  String get defaultMarketTitle =>
      isTr ? 'Market alışverişi' : 'Grocery purchase';
  String get expenseDeleted => isTr ? 'Harcama silindi' : 'Expense deleted';

  String get familyTitle => isTr ? 'Aile Kontrolü' : 'Family Control';
  String get familyEmpty => isTr
      ? 'Çocuk profili ekle.\nHarcamalarını takip et, limit koy.'
      : 'Add a child profile.\nTrack spending and set limits.';
  String get deleteProfileTitle => isTr ? 'Profili Sil' : 'Delete Profile';
  String deleteProfileMessage(String name) => isTr
      ? '$name profilini silmek istiyor musun?'
      : 'Delete profile $name?';
  String get thisWeek => isTr ? 'Bu hafta' : 'This week';
  String childDetailTitle(String name) =>
      isTr ? '$name — Harcamalar' : '$name — Spending';
  String get childNoExpenses =>
      isTr ? 'Bu ay henüz harcama yok.' : 'No spending this month yet.';

  String hello(String name) => isTr ? 'Merhaba, $name' : 'Hello, $name';
  String get spentThisMonth => isTr ? 'Bu ay harcadın' : 'You spent this month';
  String get weeklyLimit => isTr ? 'Haftalık limit' : 'Weekly limit';
  String get limitExceeded => isTr ? 'Limiti aştın!' : 'You exceeded the limit!';
  String get mySpending => isTr ? 'Harcamalarım' : 'My Spending';
  String get childEmpty => isTr
      ? 'Henüz harcama yok.\nAşağıdaki butonla ekle.'
      : 'No spending yet.\nAdd one with the button below.';
  String get addExpense => isTr ? 'Harcama Ekle' : 'Add Expense';
  String get whatBought => isTr ? 'Ne aldın?' : 'What did you buy?';
  String get expenseSaved =>
      isTr ? 'Harcama buluta kaydedildi' : 'Expense saved to cloud';

  String get settingsTitle => isTr ? 'Ayarlar' : 'Settings';
  String get appearance => isTr ? 'Görünüm' : 'Appearance';
  String get themeLight => isTr ? 'Aydınlık' : 'Light';
  String get themeDark => isTr ? 'Karanlık' : 'Dark';
  String get themeSystem => isTr ? 'Sistem' : 'System';
  String get language => isTr ? 'Dil' : 'Language';
  String get languageTurkish => 'Türkçe';
  String get languageEnglish => 'English';
  String get cloudBackupTitle => isTr ? 'Bulut yedek' : 'Cloud backup';
  String get cloudBackupSubtitle => isTr
      ? 'İşlemler, kartlar ve bütçe Firebase\'de saklanır. Uygulamayı silsen bile hesabınla geri gelir.'
      : 'Transactions, cards, and budget are stored in Firebase. Sign in again to restore after uninstalling.';
  String get budgetLimitLabel =>
      isTr ? 'Aylık gider limiti (₺)' : 'Monthly expense limit (₺)';
  String get budgetLimitHint =>
      isTr ? 'Boş bırak = limitsiz' : 'Leave empty = unlimited';
  String get saveBudget => isTr ? 'Bütçeyi Kaydet' : 'Save Budget';
  String get budgetSaved =>
      isTr ? 'Bütçe buluta kaydedildi' : 'Budget saved to cloud';
  String get recurringTitle =>
      isTr ? 'Tekrarlayan İşlemler' : 'Recurring Transactions';
  String get recurringHint => isTr
      ? 'Maaş, kira gibi her ay otomatik eklenir'
      : 'Added automatically each month (salary, rent, etc.)';
  String get noRecurring =>
      isTr ? 'Henüz tekrarlayan işlem yok' : 'No recurring transactions yet';
  String recurringSubtitle(int day, String amount) => isTr
      ? 'Her ayın $day. günü • $amount'
      : 'On the $day${_ordinal(day)} of each month • $amount';
  String get recurringDeleted =>
      isTr ? 'Tekrarlayan işlem silindi' : 'Recurring transaction deleted';
  String get exportTitle => isTr ? 'Veri Dışa Aktar' : 'Export Data';
  String get exportCsv => isTr ? 'CSV Kopyala (Excel)' : 'Copy CSV (Excel)';
  String get csvCopied => isTr
      ? 'CSV panoya kopyalandı — Excel\'e yapıştırabilirsin'
      : 'CSV copied to clipboard — paste into Excel';
  String get addRecurring => isTr ? 'Tekrarlayan Ekle' : 'Add Recurring';
  String get descriptionExample =>
      isTr ? 'Açıklama (ör: Maaş, Kira)' : 'Description (e.g. Salary, Rent)';
  String get whichDay => isTr ? 'Her ay hangi gün?' : 'Which day each month?';
  String recurringDaySelected(String date, int day) => isTr
      ? '$date seçildi, her ayın $day. günü uygulanır'
      : '$date selected, applied on the $day${_ordinal(day)} of each month';
  String get recurringSaved =>
      isTr ? 'Tekrarlayan işlem buluta kaydedildi' : 'Recurring transaction saved to cloud';
  String get savedToCloud => isTr ? 'Buluta kaydedildi' : 'Saved to cloud';

  String get firebaseSetupTitle =>
      isTr ? 'Firebase Kurulumu Gerekli' : 'Firebase Setup Required';
  String get firebaseSetupInstructions => isTr
      ? 'BASLA.md dosyasındaki adımları uygula.'
      : 'Follow the steps in BASLA.md.';
  String get firebaseWebTitle =>
      isTr ? 'En Kolay Yol: Samsung Telefon' : 'Easiest Way: Samsung Phone';
  String get firebaseWebBody => isTr
      ? 'Chrome\'da mail çalışmıyor çünkü Web uygulaması eksik.\nTelefonda her şey hazır — USB ile bağla ve çalıştır.'
      : 'Email doesn\'t work in Chrome because the web app is incomplete.\nEverything is ready on your phone — connect via USB and run.';
  String get firebaseDetail => isTr
      ? 'Detay: proje klasöründeki BASLA.md'
      : 'Details: BASLA.md in the project folder';

  String get accountSection => isTr ? 'Hesap' : 'Account';
  String get legalSection => isTr ? 'Yasal' : 'Legal';
  String get privacyPolicy => isTr ? 'Gizlilik Politikası' : 'Privacy Policy';
  String get termsOfUse => isTr ? 'Kullanım Koşulları' : 'Terms of Use';
  String get dangerZone => isTr ? 'Tehlikeli Bölge' : 'Danger Zone';
  String get deleteAccount => isTr ? 'Hesabı Sil' : 'Delete Account';
  String get deleteAccountHint => isTr
      ? 'Hesabını ve tüm verilerini kalıcı olarak siler'
      : 'Permanently deletes your account and all your data';
  String get deleteAccountDialogTitle =>
      isTr ? 'Hesabını silmek istiyor musun?' : 'Delete your account?';
  String get deleteAccountDialogMessage => isTr
      ? 'Bu işlem geri alınamaz. Tüm işlemlerin, kartların, çocuk profillerin ve hesap bilgilerin kalıcı olarak silinecek.'
      : 'This cannot be undone. All your transactions, cards, child profiles, and account information will be permanently deleted.';
  String get deleteAccountConfirmButton =>
      isTr ? 'Evet, Devam Et' : 'Yes, Continue';
  String get deleteAccountPinTitle =>
      isTr ? 'Silmek için PIN\'ini gir' : 'Enter your PIN to delete';
  String get deleteAccountPinSubtitle => isTr
      ? 'Kimliğini doğrulamak için 4 haneli PIN\'ini gir'
      : 'Enter your 4-digit PIN to confirm your identity';
  String get deleteAccountSuccess =>
      isTr ? 'Hesabın silindi.' : 'Your account has been deleted.';
  String get appVersion => isTr ? 'Uygulama sürümü' : 'App version';

  String categoryMarket() => isTr ? 'Market' : 'Groceries';
  String categoryFood() => isTr ? 'Yemek' : 'Food';
  String categoryTransport() => isTr ? 'Ulaşım' : 'Transport';
  String categoryBills() => isTr ? 'Faturalar' : 'Bills';
  String categoryEntertainment() => isTr ? 'Eğlence' : 'Entertainment';
  String categoryHealth() => isTr ? 'Sağlık' : 'Health';
  String categoryClothing() => isTr ? 'Giyim' : 'Clothing';
  String categoryOther() => isTr ? 'Diğer' : 'Other';
  String incomeSalary() => isTr ? 'Maaş' : 'Salary';
  String incomeFreelance() => isTr ? 'Serbest' : 'Freelance';
  String incomeInvestment() => isTr ? 'Yatırım' : 'Investment';
  String incomeGift() => isTr ? 'Hediye' : 'Gift';
  String incomeOther() => isTr ? 'Diğer' : 'Other';

  String get notificationChannelMain =>
      isTr ? 'Cüzdanım Bildirimleri' : 'My Wallet Notifications';
  String get notificationChannelMainDesc => isTr
      ? 'Ödeme ve harcama bildirimleri'
      : 'Payment and spending notifications';
  String get incomeAddedTitle => isTr ? 'Gelir eklendi' : 'Income added';
  String incomeAddedBody(String amount, String label) => isTr
      ? 'Bugün $amount $label geldi.'
      : 'Today $amount $label was received.';
  String get paymentMadeTitle => isTr ? 'Ödeme yapıldı' : 'Payment made';
  String paymentMadeBody(String amount, String label) => isTr
      ? 'Bugün $amount $label ödemesi yapıldı.'
      : 'Today $amount payment for $label was made.';
  String get notificationChannelRecurring =>
      isTr ? 'Tekrarlayan İşlemler' : 'Recurring Transactions';
  String get notificationChannelRecurringDesc => isTr
      ? 'Aylık gelir ve gider hatırlatmaları'
      : 'Monthly income and expense reminders';
  String get monthlyIncomeTodayTitle =>
      isTr ? 'Aylık gelir bugün' : 'Monthly income today';
  String get monthlyPaymentTodayTitle =>
      isTr ? 'Aylık ödeme bugün' : 'Monthly payment today';
  String monthlyIncomeTodayBody(String amount, String label) => isTr
      ? 'Bugün $amount $label geliyor.'
      : 'Today $amount $label is due.';
  String monthlyPaymentTodayBody(String amount, String label) => isTr
      ? 'Bugün $amount $label ödemen var.'
      : 'Today you have a $amount payment for $label.';
  String get childExpenseTitle => isTr ? 'harcama yaptı' : 'made a purchase';
  String childExpenseAlert(String childName) =>
      isTr ? '$childName harcama yaptı' : '$childName made a purchase';

  String _ordinal(int day) {
    if (isTr) return '.';
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['tr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
