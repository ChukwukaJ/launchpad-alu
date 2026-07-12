import 'package:cloud_firestore/cloud_firestore.dart';

/// The two account types the platform supports. Kept as an enum (rather than
/// a raw string) so the compiler catches typos when we branch UI/logic by role.
enum UserRole { student, startup, admin }

UserRole roleFromString(String value) {
  return UserRole.values.firstWhere(
    (r) => r.name == value,
    orElse: () => UserRole.student,
  );
}

class AppUser {
  final String uid;
  final String email;
  final String fullName;
  final UserRole role;
  final String? photoUrl;
  final List<String> skills; // relevant mainly for students
  final String? bio;
  final DateTime createdAt;
  final bool onboardingComplete;

  const AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.photoUrl,
    this.skills = const [],
    this.bio,
    required this.createdAt,
    this.onboardingComplete = false,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      role: roleFromString(map['role'] ?? 'student'),
      photoUrl: map['photoUrl'],
      skills: List<String>.from(map['skills'] ?? const []),
      bio: map['bio'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      onboardingComplete: map['onboardingComplete'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'role': role.name,
      'photoUrl': photoUrl,
      'skills': skills,
      'bio': bio,
      'createdAt': Timestamp.fromDate(createdAt),
      'onboardingComplete': onboardingComplete,
    };
  }

  AppUser copyWith({
    String? fullName,
    String? photoUrl,
    List<String>? skills,
    String? bio,
    bool? onboardingComplete,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      fullName: fullName ?? this.fullName,
      role: role,
      photoUrl: photoUrl ?? this.photoUrl,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      createdAt: createdAt,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}
