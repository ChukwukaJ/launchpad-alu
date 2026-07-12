import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;
  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('notifications');

  Stream<List<AppNotification>> watchNotifications(String uid) {
    return _col
        .where('recipientUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map((d) => AppNotification.fromMap(d.data(), d.id)).toList());
  }

  Future<void> markRead(String notificationId) {
    return _col.doc(notificationId).update({'read': true});
  }

  Future<void> markAllRead(List<String> ids) async {
    final batch = _firestore.batch();
    for (final id in ids) {
      batch.update(_col.doc(id), {'read': true});
    }
    await batch.commit();
  }
}
