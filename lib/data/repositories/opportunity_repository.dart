import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opportunity_model.dart';

class OpportunityRepository {
  final FirebaseFirestore _firestore;
  OpportunityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('opportunities');

  Future<String> postOpportunity(Opportunity opportunity) async {
    final doc = await _col.add(opportunity.toMap());
    return doc.id;
  }

  Future<void> updateOpportunity(Opportunity opportunity) {
    return _col.doc(opportunity.id).update(opportunity.toMap());
  }

  Future<void> closeOpportunity(String id) {
    return _col.doc(id).update({'status': OpportunityStatus.closed.name});
  }

  Future<void> deleteOpportunity(String id) => _col.doc(id).delete();

  /// Real-time discovery feed — every student's home screen listens here.
  /// Firestore doesn't support full-text search natively, so free-text
  /// query is applied client-side over this live snapshot (see
  /// SearchCubit); category/workMode/paid filters that map cleanly to
  /// equality are pushed server-side to keep the payload small.
  Stream<List<Opportunity>> watchOpenOpportunities({
    String? category,
    WorkMode? workMode,
  }) {
    Query<Map<String, dynamic>> query =
        _col.where('status', isEqualTo: OpportunityStatus.open.name);
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    if (workMode != null) {
      query = query.where('workMode', isEqualTo: workMode.name);
    }
    query = query.orderBy('postedAt', descending: true);
    return query.snapshots().map(
          (s) => s.docs.map((d) => Opportunity.fromMap(d.data(), d.id)).toList(),
        );
  }

  Stream<List<Opportunity>> watchOpportunitiesByStartup(String startupId) {
    return _col
        .where('startupId', isEqualTo: startupId)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Opportunity.fromMap(d.data(), d.id)).toList());
  }

  Stream<Opportunity> watchOpportunity(String id) {
    return _col.doc(id).snapshots().map(
          (doc) => Opportunity.fromMap(doc.data() ?? {}, id),
        );
  }

  Future<void> incrementApplicantCount(String opportunityId) {
    return _col.doc(opportunityId).update({
      'applicantCount': FieldValue.increment(1),
    });
  }
}
