import 'package:json_annotation/json_annotation.dart';

part 'patient.g.dart';

@JsonSerializable()
class Patient {
  final String id;
  final String fullName;
  final int? age;
  final DateTime? dateOfBirth;
  final String gender;
  final String? phone;
  final String? email;
  final String? address;
  final String? medicalHistory;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Patient({
    required this.id,
    required this.fullName,
    this.age,
    this.dateOfBirth,
    required this.gender,
    this.phone,
    this.email,
    this.address,
    this.medicalHistory,
    required this.createdAt,
    this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => _$PatientFromJson(json);
  Map<String, dynamic> toJson() => _$PatientToJson(this);

  // Database conversion methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'age': age,
      'date_of_birth': dateOfBirth?.millisecondsSinceEpoch,
      'gender': gender,
      'phone': phone,
      'email': email,
      'address': address,
      'medical_history': medicalHistory,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      fullName: map['full_name'],
      age: map['age'],
      dateOfBirth: map['date_of_birth'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['date_of_birth'])
          : null,
      gender: map['gender'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      medicalHistory: map['medical_history'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : null,
    );
  }

  Patient copyWith({
    String? id,
    String? fullName,
    int? age,
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
    String? email,
    String? address,
    String? medicalHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to get display age
  int get displayAge {
    if (age != null) return age!;
    if (dateOfBirth != null) {
      final now = DateTime.now();
      final difference = now.difference(dateOfBirth!);
      return (difference.inDays / 365).floor();
    }
    return 0;
  }
}

