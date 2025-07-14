// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Medicine _$MedicineFromJson(Map<String, dynamic> json) => Medicine(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$MedicineTypeEnumMap, json['type']),
      dosage: json['dosage'] as String,
      duration: json['duration'] as String,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$MedicineToJson(Medicine instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$MedicineTypeEnumMap[instance.type]!,
      'dosage': instance.dosage,
      'duration': instance.duration,
      'notes': instance.notes,
    };

const _$MedicineTypeEnumMap = {
  MedicineType.ayurvedic: 'ayurvedic',
  MedicineType.allopathic: 'allopathic',
  MedicineType.other: 'other',
};

