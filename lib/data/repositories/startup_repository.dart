import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/startup_model.dart';

class StartupRepository {
  final FirebaseFirestore _firestore;
  StartupRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('startups');

  Future<String> createStartup(Startup startup) async {
    final doc = await _col.add(startup.toMap());
    return doc.id;
  }

  Future<void> updateStartup(Startup startup) {
    return _col.doc(startup.id).update(startup.toMap());
  }

  Stream<Startup?> watchStartupByOwner(String ownerUid) {
    return _col.where('ownerUid', isEqualTo: ownerUid).limit(1).snapshots().map(
          (snap) => snap.docs.isEmpty
              ? null
              : Startup.fromMap(snap.docs.first.data(), snap.docs.first.id),
        );
  }

  Stream<Startup> watchStartup(String id) {
    return _col.doc(id).snapshots().map(
          (doc) => Startup.fromMap(doc.data() ?? {}, id),
        );
  }

  /// Only verified startups should ever surface in student-facing discovery.
  Stream<List<Startup>> watchVerifiedStartups() {
    return _col
        .where('status', isEqualTo: VerificationStatus.verified.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Startup.fromMap(d.data(), d.id)).toList());
  }

  /// Admin queue: startups awaiting review.
  Stream<List<Startup>> watchPendingStartups() {
    return _col
        .where('status', isEqualTo: VerificationStatus.pending.name)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map((d) => Startup.fromMap(d.data(), d.id)).toList());
  }

  Future<void> setVerificationStatus(String startupId, VerificationStatus status) {
    return _col.doc(startupId).update({'status': status.name});
  }
}
