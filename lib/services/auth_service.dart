import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/child_profile.dart';
import '../models/user_account.dart';

class AuthServiceException implements Exception {
  AuthServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  UserAccount? currentUser;
  List<ChildProfile> _children = [];
  SessionRole role = SessionRole.parent;
  ChildProfile? activeChild;
  String? lastMailWarning;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  List<ChildProfile> get children => List.unmodifiable(_children);
  bool get isLoggedIn => _auth.currentUser != null && currentUser != null;
  bool get isParent => role == SessionRole.parent;
  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentEmail => _auth.currentUser?.email;
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _users.doc(uid);

  Future<void> load() async {
    final user = _auth.currentUser;
    if (user == null) {
      currentUser = null;
      _children = [];
      return;
    }
    await user.reload();
    await _loadProfile(user.uid);
    if (currentUser != null) {
      await _loadChildren(user.uid);
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    try {
      final doc = await _db
          .collection('usernames')
          .doc(username.toLowerCase())
          .get();
      return doc.exists;
    } on FirebaseException catch (e) {
      throw AuthServiceException(
        'Kullanıcı adı kontrol edilemedi: ${e.message ?? e.code}',
      );
    }
  }

  static String _firebasePasswordFromPin(String pin) => 'cz$pin!9';

  Future<String?> register({
    required String email,
    required String username,
    required String pin,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedUser = username.trim();

    if (!_isValidEmail(trimmedEmail)) {
      return 'Geçerli bir e-posta girin';
    }
    if (trimmedUser.length < 3) {
      return 'Kullanıcı adı en az 3 karakter olmalı';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmedUser)) {
      return 'Kullanıcı adı sadece harf, rakam ve _ içerebilir';
    }
    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      return 'PIN 4 haneli olmalı';
    }
    try {
      lastMailWarning = null;
      final cred = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: _firebasePasswordFromPin(pin),
      );
      final user = cred.user!;

      final mailErr = await _sendVerificationEmail(user);
      if (mailErr != null) {
        lastMailWarning = mailErr;
      }

      await _createAccountDocuments(
        userId: user.uid,
        username: trimmedUser,
        email: trimmedEmail,
      );

      await _loadProfile(user.uid);
      role = SessionRole.parent;
      activeChild = null;
      return null;
    } on FirebaseAuthException catch (e) {
      return _authError(e);
    } on AuthServiceException catch (e) {
      await _auth.currentUser?.delete();
      return e.message;
    } on FirebaseException catch (e) {
      await _auth.currentUser?.delete();
      return 'Veritabanı hatası: ${e.message}. Firebase Console\'da Firestore açık mı?';
    }
  }

  Future<String?> login({
    required String username,
    required String pin,
  }) async {
    final trimmedUser = username.trim();
    if (trimmedUser.isEmpty) return 'Kullanıcı adını gir';
    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      return 'PIN 4 haneli olmalı';
    }

    try {
      final usernameDoc = await _db
          .collection('usernames')
          .doc(trimmedUser.toLowerCase())
          .get();
      if (!usernameDoc.exists) return 'Kullanıcı adı bulunamadı';

      final usernameData = usernameDoc.data()!;
      final email = usernameData['email'] as String?;
      if (email == null || email.isEmpty) return 'Kullanıcı kaydı bozuk';

      // PIN doğrulaması artık istemci tarafında değil, doğrudan Firebase
      // Authentication üzerinden yapılır. Bu sayede yanlış deneme sayısı
      // sunucu tarafında hız sınırlamasına (rate limiting) tabidir ve PIN
      // karşılığı hiçbir sır istemciye/veritabanına açık şekilde konmaz.
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: _firebasePasswordFromPin(pin),
      );
      await _auth.currentUser!.reload();
      await _loadProfile(_auth.currentUser!.uid);
      if (currentUser == null) {
        return 'Kullanıcı profili bulunamadı';
      }
      await _loadChildren(_auth.currentUser!.uid);
      role = SessionRole.parent;
      activeChild = null;
      return null;
    } on FirebaseAuthException catch (e) {
      return _authError(e);
    } on FirebaseException catch (e) {
      return 'Veritabanı hatası: ${e.message ?? e.code}. '
          'Firebase Rules yayınlandı mı?';
    }
  }

  Future<String?> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) return 'Oturum bulunamadı. Tekrar giriş yap.';
    return _sendVerificationEmail(user);
  }

  Future<String?> _sendVerificationEmail(User user) async {
    try {
      await _auth.setLanguageCode('tr');
      await user.sendEmailVerification(_emailActionSettings());
      return null;
    } on FirebaseAuthException catch (e) {
      return '${_authError(e)} (kod: ${e.code})';
    } catch (e) {
      return 'Mail gönderilemedi: $e';
    }
  }

  ActionCodeSettings _emailActionSettings() {
    return ActionCodeSettings(
      url: 'https://deneme-app-935b6.firebaseapp.com',
      handleCodeInApp: true,
      androidPackageName: 'com.cuzdanim.app',
      androidInstallApp: true,
      androidMinimumVersion: '21',
    );
  }

  void clearMailWarning() => lastMailWarning = null;

  Future<bool> refreshEmailVerified() async {
    await _auth.currentUser?.reload();
    return isEmailVerified;
  }

  Future<void> logout() async {
    await _auth.signOut();
    currentUser = null;
    _children = [];
    role = SessionRole.parent;
    activeChild = null;
  }

  void loginAsParent() {
    role = SessionRole.parent;
    activeChild = null;
  }

  void loginAsChild(ChildProfile child) {
    role = SessionRole.child;
    activeChild = child;
  }

  Future<void> addChild(ChildProfile child) async {
    final uid = currentUserId;
    if (uid == null) return;
    _children.add(child);
    await _userDoc(uid).collection('children').doc(child.id).set(child.toJson());
  }

  Future<void> deleteChild(String id) async {
    final uid = currentUserId;
    if (uid == null) return;
    _children.removeWhere((c) => c.id == id);
    await _userDoc(uid).collection('children').doc(id).delete();
  }

  ChildProfile? childById(String? id) {
    if (id == null) return null;
    return _children.where((c) => c.id == id).firstOrNull;
  }

  Future<void> _createAccountDocuments({
    required String userId,
    required String username,
    required String email,
  }) async {
    final usernameRef = _db.collection('usernames').doc(username.toLowerCase());
    final userRef = _userDoc(userId);

    await _db.runTransaction((tx) async {
      final usernameSnap = await tx.get(usernameRef);
      if (usernameSnap.exists) {
        throw AuthServiceException('Bu kullanıcı adı alınmış');
      }

      tx.set(userRef, {
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.set(usernameRef, {
        'userId': userId,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Hesabı ve tüm verilerini kalıcı olarak siler. Apple/Google mağaza
  /// kurallarının gerektirdiği "hesap içi hesap silme" özelliği için gerekli.
  ///
  /// Güvenlik nedeniyle önce mevcut PIN ile yeniden kimlik doğrulaması
  /// (reauthenticate) yapılır; Firebase, hassas işlemler için (hesap silme
  /// gibi) yakın zamanda giriş yapılmış olmasını zorunlu kılar.
  Future<String?> deleteAccount({required String pin}) async {
    final user = _auth.currentUser;
    final username = currentUser?.username;
    if (user == null || username == null) {
      return 'Oturum bulunamadı. Tekrar giriş yap.';
    }
    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      return 'PIN 4 haneli olmalı';
    }

    try {
      final email = user.email;
      if (email == null) return 'E-posta bulunamadı';

      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: email,
          password: _firebasePasswordFromPin(pin),
        ),
      );

      final uid = user.uid;
      await _deleteAllUserData(uid, username);
      await user.delete();

      currentUser = null;
      _children = [];
      role = SessionRole.parent;
      activeChild = null;
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Yanlış PIN';
      }
      return _authError(e);
    } on FirebaseException catch (e) {
      return 'Hesap silinemedi: ${e.message ?? e.code}';
    }
  }

  Future<void> _deleteAllUserData(String uid, String username) async {
    final userRef = _userDoc(uid);
    const subcollections = ['transactions', 'cards', 'recurring', 'children', 'alerts'];

    for (final name in subcollections) {
      await _deleteCollection(userRef.collection(name));
    }

    await _db.collection('usernames').doc(username.toLowerCase()).delete();
    await userRef.delete();
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    const batchSize = 200;
    while (true) {
      final snap = await collection.limit(batchSize).get();
      if (snap.docs.isEmpty) return;
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (snap.docs.length < batchSize) return;
    }
  }

  Future<void> _loadProfile(String uid) async {
    final doc = await _userDoc(uid).get();
    if (doc.exists) {
      currentUser = UserAccount.fromFirestore(uid, doc.data()!);
    } else {
      currentUser = null;
    }
  }

  Future<void> _loadChildren(String uid) async {
    final snap = await _userDoc(uid).collection('children').get();
    _children = snap.docs
        .map((d) => ChildProfile.fromJson(d.data()))
        .toList();
  }

  String _authError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Bu e-posta zaten kayıtlı';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi';
      case 'weak-password':
        return 'Şifre çok zayıf (min 6 karakter)';
      case 'user-not-found':
      case 'invalid-credential':
        return 'Kullanıcı adı veya PIN hatalı';
      case 'wrong-password':
        return 'Yanlış PIN';
      case 'too-many-requests':
        return 'Çok fazla deneme. 30-60 dakika bekle, sonra tekrar dene.';
      default:
        return e.message ?? 'Giriş hatası';
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }
}
