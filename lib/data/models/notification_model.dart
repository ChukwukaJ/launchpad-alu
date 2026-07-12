import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  newApplication,
  statusChange,
  newOpportunityMatch,
  startupVerified,
}

NotificationType notifTypeFromString(String v) => NotificationType.values
    .firstWhere((e) => e.name == v, orElse: () => NotificationType.statusChange);

class AppNotification {
  final String id;
  final String recipientUid;
  final NotificationType type;
  final String title;
  final String body;
  final String? relatedId; // opportunityId or applicationId
  final bool read;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.recipientUid,
    required this.type,
    required this.title,
    required this.body,
    this.relatedId,
    this.read = false,
    required this.createdAt,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map, String id) {
    return AppNotification(
      id: id,
      recipientUid: map['recipientUid'] ?? '',
      type: notifTypeFromString(map['type'] ?? 'statusChange'),
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      relatedId: map['relatedId'],
      read: map['read'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipientUid': recipientUid,
      'type': type.name,
      'title': title,
      'body': body,
      'relatedId': relatedId,
      'read': read,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
