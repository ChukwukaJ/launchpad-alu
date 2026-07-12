import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Wraps FirebaseAuth + the `users` Firestore collection behind a single
/// interface. Cubits never talk to Firebase directly — they only ever touch
/// a repository. This keeps Firebase swappable/mockable and keeps the Cubit
/// layer free of SDK-specific error types.
class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentFirebaseUser => _auth.currentUser;

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    final appUser = AppUser(
      uid: uid,
      email: email,
      fullName: fullName,
      role: role,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(uid).set(appUser.toMap());
    await credential.user!.updateDisplayName(fullName);
    return appUser;
  }

  Future<AppUser> signIn({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return fetchUserProfile(credential.user!.uid);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<AppUser> fetchUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception('User profile not found for uid: $uid');
    }
    return AppUser.fromMap(doc.data()!, uid);
  }

  Stream<AppUser> watchUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map(
          (doc) => AppUser.fromMap(doc.data() ?? {}, uid),
        );
  }

  Future<void> updateProfile(AppUser user) {
    return _firestore.collection('users').doc(user.uid).update(user.toMap());
  }
}
