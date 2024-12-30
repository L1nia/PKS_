import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String uid;
  final String email;
  final String role;
  final DateTime createdAt;

  ProfileModel({
    required this.uid,
    required this.email,
    this.role = 'user', // По умолчанию роль 'user'
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Метод для создания нового профиля в Firestore
  static Future<void> createProfile(String uid, String email) async {
    final profile = ProfileModel(
      uid: uid,
      email: email,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(profile.toMap());
  }
}