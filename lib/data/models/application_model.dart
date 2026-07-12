import 'package:cloud_firestore/cloud_firestore.dart';

/// Status pipeline for an application. Modeled explicitly as an ordered
/// enum (not a free-text string) so the tracker UI can render a consistent
/// stepper regardless of who last updated the document.
enum ApplicationStatus { submitted, underReview, interview, accepted, rejected }

ApplicationStatus appStatusFromString(String v) => ApplicationStatus.values
    .firstWhere((e) => e.name == v, orElse: () => ApplicationStatus.submitted);

class Application {
  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;
  final String studentUid;
  final String studentName;
  final String? studentPhotoUrl;
  final String coverNote;
  final ApplicationStatus status;
  final DateTime submittedAt;
  final DateTime updatedAt;

  const Application({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.startupName,
    required this.studentUid,
    required this.studentName,
    this.studentPhotoUrl,
    required this.coverNote,
    this.status = ApplicationStatus.submitted,
    required this.submittedAt,
    required this.updatedAt,
  });

  factory Application.fromMap(Map<String, dynamic> map, String id) {
    return Application(
      id: id,
      opportunityId: map['opportunityId'] ?? '',
      opportunityTitle: map['opportunityTitle'] ?? '',
      startupId: map['startupId'] ?? '',
      startupName: map['startupName'] ?? '',
      studentUid: map['studentUid'] ?? '',
      studentName: map['studentName'] ?? '',
      studentPhotoUrl: map['studentPhotoUrl'],
      coverNote: map['coverNote'] ?? '',
      status: appStatusFromString(map['status'] ?? 'submitted'),
      submittedAt: (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'startupId': startupId,
      'startupName': startupName,
      'studentUid': studentUid,
      'studentName': studentName,
      'studentPhotoUrl': studentPhotoUrl,
      'coverNote': coverNote,
      'status': status.name,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
