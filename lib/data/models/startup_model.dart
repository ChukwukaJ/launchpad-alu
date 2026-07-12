import 'package:cloud_firestore/cloud_firestore.dart';

/// Startups must be verified by an ALU admin before their opportunities are
/// discoverable by students. This protects students from applying to
/// ventures with no real affiliation to the university.
enum VerificationStatus { pending, verified, rejected }

VerificationStatus verificationFromString(String value) {
  return VerificationStatus.values.firstWhere(
    (v) => v.name == value,
    orElse: () => VerificationStatus.pending,
  );
}

class Startup {
  final String id;
  final String ownerUid;
  final String name;
  final String tagline;
  final String description;
  final String? logoUrl;
  final String industry;
  final int teamSize;
  final String? website;
  final VerificationStatus status;
  final String? aluAffiliationProof; // storage URL to proof document/image
  final DateTime createdAt;

  const Startup({
    required this.id,
    required this.ownerUid,
    required this.name,
    required this.tagline,
    required this.description,
    this.logoUrl,
    required this.industry,
    required this.teamSize,
    this.website,
    this.status = VerificationStatus.pending,
    this.aluAffiliationProof,
    required this.createdAt,
  });

  factory Startup.fromMap(Map<String, dynamic> map, String id) {
    return Startup(
      id: id,
      ownerUid: map['ownerUid'] ?? '',
      name: map['name'] ?? '',
      tagline: map['tagline'] ?? '',
      description: map['description'] ?? '',
      logoUrl: map['logoUrl'],
      industry: map['industry'] ?? '',
      teamSize: map['teamSize'] ?? 1,
      website: map['website'],
      status: verificationFromString(map['status'] ?? 'pending'),
      aluAffiliationProof: map['aluAffiliationProof'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerUid': ownerUid,
      'name': name,
      'tagline': tagline,
      'description': description,
      'logoUrl': logoUrl,
      'industry': industry,
      'teamSize': teamSize,
      'website': website,
      'status': status.name,
      'aluAffiliationProof': aluAffiliationProof,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Startup copyWith({
    String? name,
    String? tagline,
    String? description,
    String? logoUrl,
    String? industry,
    int? teamSize,
    String? website,
    VerificationStatus? status,
  }) {
    return Startup(
      id: id,
      ownerUid: ownerUid,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      industry: industry ?? this.industry,
      teamSize: teamSize ?? this.teamSize,
      website: website ?? this.website,
      status: status ?? this.status,
      aluAffiliationProof: aluAffiliationProof,
      createdAt: createdAt,
    );
  }
}
