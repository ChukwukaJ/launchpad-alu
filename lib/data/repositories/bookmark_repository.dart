import 'package:cloud_firestore/cloud_firestore.dart';

/// Bookmarks are stored as a subcollection under each student user document
/// (`users/{uid}/bookmarks/{opportunityId}`) rather than a top-level
/// collection. This keeps security rules simple (a student can only ever
/// read/write their own subcollection) and avoids needing a composite index
/// for "my bookmarks" queries.
class BookmarkRepository {
  final FirebaseFirestore _firestore;
  BookmarkRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _firestore.collection('users').doc(uid).collection('bookmarks');

  Future<void> addBookmark(String uid, String opportunityId) {
    return _col(uid).doc(opportunityId).set({'savedAt': Timestamp.now()});
  }

  Future<void> removeBookmark(String uid, String opportunityId) {
    return _col(uid).doc(opportunityId).delete();
  }

  Stream<Set<String>> watchBookmarkedIds(String uid) {
    return _col(uid).snapshots().map((s) => s.docs.map((d) => d.id).toSet());
  }
}
