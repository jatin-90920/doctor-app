import 'package:json_annotation/json_annotation.dart';
import 'package:ayurvedic_doctor_crm/models/medicine.dart';

part 'treatment.g.dart';

@JsonSerializable()
class Treatment {
  final String id;
  final String patientId;
  final DateTime visitDate;
  final String symptoms;
  final String diagnosis;
  final String? notes;
  final List<Medicine> prescribedMedicines;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Treatment({
    required this.id,
    required this.patientId,
    required this.visitDate,
    required this.symptoms,
    required this.diagnosis,
    this.notes,
    required this.prescribedMedicines,
    required this.createdAt,
    this.updatedAt,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) => _$TreatmentFromJson(json);
  Map<String, dynamic> toJson() => _$TreatmentToJson(this);

  // Database conversion methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'visit_date': visitDate.millisecondsSinceEpoch,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory Treatment.fromMap(Map<String, dynamic> map) {
    return Treatment(
      id: map['id'],
      patientId: map['patient_id'],
      visitDate: DateTime.fromMillisecondsSinceEpoch(map['visit_date']),
      symptoms: map['symptoms'],
      diagnosis: map['diagnosis'],
      notes: map['notes'],
      prescribedMedicines: [], // Will be loaded separately
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : null,
    );
  }

  Treatment copyWith({
    String? id,
    String? patientId,
    DateTime? visitDate,
    String? symptoms,
    String? diagnosis,
    String? notes,
    List<Medicine>? prescribedMedicines,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Treatment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      visitDate: visitDate ?? this.visitDate,
      symptoms: symptoms ?? this.symptoms,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      prescribedMedicines: prescribedMedicines ?? this.prescribedMedicines,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

