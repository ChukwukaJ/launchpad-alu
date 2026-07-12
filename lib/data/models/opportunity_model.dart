import 'package:cloud_firestore/cloud_firestore.dart';

enum WorkMode { remote, onsite, hybrid }
enum OpportunityStatus { open, closed }

WorkMode workModeFromString(String v) =>
    WorkMode.values.firstWhere((e) => e.name == v, orElse: () => WorkMode.remote);

OpportunityStatus statusFromString(String v) => OpportunityStatus.values
    .firstWhere((e) => e.name == v, orElse: () => OpportunityStatus.open);

class Opportunity {
  final String id;
  final String startupId;
  final String startupName;
  final String? startupLogoUrl;
  final String title;
  final String category; // e.g. Software Development, Design, Marketing
  final String description;
  final List<String> requiredSkills;
  final WorkMode workMode;
  final String duration; // e.g. "3 months"
  final bool isPaid;
  final OpportunityStatus status;
  final DateTime postedAt;
  final DateTime? deadline;
  final int applicantCount;

  const Opportunity({
    required this.id,
    required this.startupId,
    required this.startupName,
    this.startupLogoUrl,
    required this.title,
    required this.category,
    required this.description,
    this.requiredSkills = const [],
    required this.workMode,
    required this.duration,
    this.isPaid = false,
    this.status = OpportunityStatus.open,
    required this.postedAt,
    this.deadline,
    this.applicantCount = 0,
  });

  factory Opportunity.fromMap(Map<String, dynamic> map, String id) {
    return Opportunity(
      id: id,
      startupId: map['startupId'] ?? '',
      startupName: map['startupName'] ?? '',
      startupLogoUrl: map['startupLogoUrl'],
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      requiredSkills: List<String>.from(map['requiredSkills'] ?? const []),
      workMode: workModeFromString(map['workMode'] ?? 'remote'),
      duration: map['duration'] ?? '',
      isPaid: map['isPaid'] ?? false,
      status: statusFromString(map['status'] ?? 'open'),
      postedAt: (map['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deadline: (map['deadline'] as Timestamp?)?.toDate(),
      applicantCount: map['applicantCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startupId': startupId,
      'startupName': startupName,
      'startupLogoUrl': startupLogoUrl,
      'title': title,
      'category': category,
      'description': description,
      'requiredSkills': requiredSkills,
      'workMode': workMode.name,
      'duration': duration,
      'isPaid': isPaid,
      'status': status.name,
      'postedAt': Timestamp.fromDate(postedAt),
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'applicantCount': applicantCount,
    };
  }

  /// Simple, explainable match score used for the recommendation feature:
  /// percentage overlap between the student's declared skills and the
  /// opportunity's required skills. Deliberately transparent (no black-box
  /// ML) so it can be justified in the report/demo.
  double matchScore(List<String> studentSkills) {
    if (requiredSkills.isEmpty) return 0;
    final studentSet = studentSkills.map((s) => s.toLowerCase()).toSet();
    final required = requiredSkills.map((s) => s.toLowerCase()).toSet();
    final overlap = required.intersection(studentSet).length;
    return overlap / required.length;
  }
}
