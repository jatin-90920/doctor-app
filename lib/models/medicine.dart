import 'package:json_annotation/json_annotation.dart';

part 'medicine.g.dart';

enum MedicineType {
  ayurvedic,
  allopathic,
  other,
}

@JsonSerializable()
class Medicine {
  final String id;
  final String name;
  final MedicineType type;
  final String dosage;
  final String duration;
  final String? quantity;
  final String? notes;

  Medicine({
    required this.id,
    required this.name,
    required this.type,
    required this.dosage,
    required this.duration,
    this.quantity,
    this.notes,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) => _$MedicineFromJson(json);
  Map<String, dynamic> toJson() => _$MedicineToJson(this);

  // Database conversion methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'dosage': dosage,
      'duration': duration,
      'quantity': quantity,
      'notes': notes,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      type: MedicineType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MedicineType.other,
      ),
      dosage: map['dosage'],
      duration: map['duration'],
      quantity: map['quantity'],
      notes: map['notes'],
    );
  }

  Medicine copyWith({
    String? id,
    String? name,
    MedicineType? type,
    String? dosage,
    String? duration,
    String? quantity,
    String? notes,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      dosage: dosage ?? this.dosage,
      duration: duration ?? this.duration,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case MedicineType.ayurvedic:
        return 'Ayurvedic';
      case MedicineType.allopathic:
        return 'Allopathic';
      case MedicineType.other:
        return 'Other';
    }
  }
}

