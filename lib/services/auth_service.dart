import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
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
      final profileDoc = await _userDoc(user.uid).get();
      final pinHash = profileDoc.data()?['pinHash'] as String?;
      final email = profileDoc.data()?['email'] as String?;
      if (pinHash != null && email != null) {
        await _syncUsernameLoginFields(
          username: currentUser!.username,
          userId: user.uid,
          email: email,
          pinHash: pinHash,
        );
      }
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

  static String hashPin(String pin) {
    final bytes = utf8.encode('cuzdanim_$pin');
    return sha256.convert(bytes).toString();
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
      final uid = cred.user!;
      final user = cred.user!;
      final pinHash = hashPin(pin);

      final mailErr = await _sendVerificationEmail(user);
      if (mailErr != null) {
        lastMailWarning = mailErr;
      }

      await _createAccountDocuments(
        userId: uid.uid,
        username: trimmedUser,
        email: trimmedEmail,
        pinHash: pinHash,
      );

      await _loadProfile(uid.uid);
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
      final userId = usernameData['userId'] as String?;
      if (userId == null) return 'Kullanıcı kaydı bozuk';

      var email = usernameData['email'] as String?;
      var pinHash = usernameData['pinHash'] as String?;

      // Eski hesaplar: e-posta/PIN sadece users/{id} içinde
      if (email == null || pinHash == null) {
        final profileDoc = await _userDoc(userId).get();
        if (!profileDoc.exists) return 'Kullanıcı profili bulunamadı';
        final profile = profileDoc.data()!;
        email = profile['email'] as String? ?? '';
        pinHash = profile['pinHash'] as String?;
      }

      if (pinHash == null || pinHash != hashPin(pin)) {
        return 'Yanlış PIN';
      }
      if (email.isEmpty) return 'E-posta bulunamadı';

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: _firebasePasswordFromPin(pin),
      );
      await _auth.currentUser!.reload();
      await _loadProfile(_auth.currentUser!.uid);
      if (currentUser == null) {
        return 'Kullanıcı profili bulunamadı';
      }
      await _syncUsernameLoginFields(
        username: trimmedUser,
        userId: _auth.currentUser!.uid,
        email: email,
        pinHash: pinHash,
      );
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
      androidPackageName: 'com.example.deneme_app',
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

  Future<void> _syncUsernameLoginFields({
    required String username,
    required String userId,
    required String email,
    required String pinHash,
  }) async {
    try {
      await _db.collection('usernames').doc(username.toLowerCase()).set({
        'userId': userId,
        'email': email,
        'pinHash': pinHash,
      }, SetOptions(merge: true));
    } on FirebaseException {
      // Giriş başarılı; senkron başarısız olsa da devam et
    }
  }

  Future<void> _createAccountDocuments({
    required String userId,
    required String username,
    required String email,
    required String pinHash,
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
        'pinHash': pinHash,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.set(usernameRef, {
        'userId': userId,
        'email': email,
        'pinHash': pinHash,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
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
