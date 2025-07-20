import 'package:ayurvedic_doctor_crm/models/medicine.dart';
import 'package:ayurvedic_doctor_crm/models/treatment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TreatmentFirestoreService {
  final CollectionReference _treatmentsRef =
      FirebaseFirestore.instance.collection('treatments');

  Future<void> addTreatment(Treatment treatment) async {
    final data = treatment.toMap();

    data['prescribed_medicines'] =
        treatment.prescribedMedicines.map((m) => m.toMap()).toList();

    await _treatmentsRef.doc(treatment.id).set(data);
  }

  Future<void> updateTreatment(Treatment treatment) async {
    final data = treatment.toMap();
    data['prescribed_medicines'] =
        treatment.prescribedMedicines.map((m) => m.toMap()).toList();

    await _treatmentsRef.doc(treatment.id).update(data);
  }

  Future<void> deleteTreatment(String id) async {
    await _treatmentsRef.doc(id).delete();
  }

  Stream<List<Treatment>> getTreatmentsStream() {
    return _treatmentsRef
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final medicineList =
              (data['prescribed_medicines'] as List<dynamic>? ?? [])
                  .map((e) => Medicine.fromMap(Map<String, dynamic>.from(e)))
                  .toList();

          final treatment = Treatment.fromMap(data).copyWith(
            prescribedMedicines: medicineList,
          );

          return treatment;
        }).toList();
      },
    );
  }

  Future<List<Treatment>> fetchTreatmentsOnce() async {
    final snapshot =
        await _treatmentsRef.orderBy('created_at', descending: true).get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      final medicineList =
          (data['prescribed_medicines'] as List<dynamic>? ?? [])
              .map((e) => Medicine.fromMap(Map<String, dynamic>.from(e)))
              .toList();

      return Treatment.fromMap(data)
          .copyWith(prescribedMedicines: medicineList);
    }).toList();
  }

  Future<Treatment?> getTreatmentById(String id) async {
    final doc = await _treatmentsRef.doc(id).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;

      final medicineList =
          (data['prescribed_medicines'] as List<dynamic>? ?? [])
              .map((e) => Medicine.fromMap(Map<String, dynamic>.from(e)))
              .toList();

      return Treatment.fromMap(data)
          .copyWith(prescribedMedicines: medicineList);
    }
    return null;
  }

  Stream<List<Treatment>> getTreatmentsByPatientId(String patientId) {
    return _treatmentsRef
        .where('patient_id', isEqualTo: patientId)
        .orderBy('visit_date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final medicineList =
            (data['prescribed_medicines'] as List<dynamic>? ?? [])
                .map((e) => Medicine.fromMap(Map<String, dynamic>.from(e)))
                .toList();

        return Treatment.fromMap(data)
            .copyWith(prescribedMedicines: medicineList);
      }).toList();
    });
  }
}
