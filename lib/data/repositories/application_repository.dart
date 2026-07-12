import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application_model.dart';
import '../models/notification_model.dart';
import 'opportunity_repository.dart';

class ApplicationRepository {
  final FirebaseFirestore _firestore;
  final OpportunityRepository _opportunityRepository;

  ApplicationRepository({
    FirebaseFirestore? firestore,
    OpportunityRepository? opportunityRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _opportunityRepository = opportunityRepository ?? OpportunityRepository();

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('applications');

  /// Submits an application, bumps the opportunity's applicant counter, and
  /// writes a notification for the startup owner — all inside one Firestore
  /// batch so partial failure never leaves the counters out of sync.
  Future<void> submitApplication(Application application) async {
    final batch = _firestore.batch();

    final appDoc = _col.doc();
    batch.set(appDoc, application.toMap());

    final oppDoc = _firestore.collection('opportunities').doc(application.opportunityId);
    batch.update(oppDoc, {'applicantCount': FieldValue.increment(1)});

    final startupDoc = await _firestore.collection('startups').doc(application.startupId).get();
    final ownerUid = startupDoc.data()?['ownerUid'];
    if (ownerUid != null) {
      final notifDoc = _firestore.collection('notifications').doc();
      final notification = AppNotification(
        id: notifDoc.id,
        recipientUid: ownerUid,
        type: NotificationType.newApplication,
        title: 'New application received',
        body: '${application.studentName} applied to ${application.opportunityTitle}',
        relatedId: appDoc.id,
        createdAt: DateTime.now(),
      );
      batch.set(notifDoc, notification.toMap());
    }

    await batch.commit();
  }

  Stream<List<Application>> watchApplicationsByStudent(String studentUid) {
    return _col
        .where('studentUid', isEqualTo: studentUid)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Application.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<Application>> watchApplicationsForOpportunity(String opportunityId) {
    return _col
        .where('opportunityId', isEqualTo: opportunityId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Application.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<Application>> watchApplicationsForStartup(String startupId) {
    return _col
        .where('startupId', isEqualTo: startupId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Application.fromMap(d.data(), d.id)).toList());
  }

  /// Updates status and notifies the student in the same batch, so the
  /// student's tracker and notification bell update together in real time.
  Future<void> updateStatus(Application application, ApplicationStatus newStatus) async {
    final batch = _firestore.batch();

    batch.update(_col.doc(application.id), {
      'status': newStatus.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    final notifDoc = _firestore.collection('notifications').doc();
    final notification = AppNotification(
      id: notifDoc.id,
      recipientUid: application.studentUid,
      type: NotificationType.statusChange,
      title: 'Application update',
      body: '${application.opportunityTitle} at ${application.startupName} is now "${_readable(newStatus)}"',
      relatedId: application.id,
      createdAt: DateTime.now(),
    );
    batch.set(notifDoc, notification.toMap());

    await batch.commit();
  }

  String _readable(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.submitted:
        return 'Submitted';
      case ApplicationStatus.underReview:
        return 'Under Review';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }
}
