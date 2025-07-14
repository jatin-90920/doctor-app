// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'treatment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Treatment _$TreatmentFromJson(Map<String, dynamic> json) => Treatment(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      visitDate: DateTime.parse(json['visitDate'] as String),
      symptoms: json['symptoms'] as String,
      diagnosis: json['diagnosis'] as String,
      notes: json['notes'] as String?,
      prescribedMedicines: (json['prescribedMedicines'] as List<dynamic>)
          .map((e) => Medicine.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TreatmentToJson(Treatment instance) => <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'visitDate': instance.visitDate.toIso8601String(),
      'symptoms': instance.symptoms,
      'diagnosis': instance.diagnosis,
      'notes': instance.notes,
      'prescribedMedicines': instance.prescribedMedicines,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

