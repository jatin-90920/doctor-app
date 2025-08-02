import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient.dart';

class PatientFirestoreService {
  final CollectionReference _patientRef =
      FirebaseFirestore.instance.collection('patients');
  final CollectionReference _treatmentsRef =
      FirebaseFirestore.instance.collection('treatments');

  Future<void> addPatient(Patient patient) async {
    await _patientRef.doc(patient.id).set(patient.toMap());
  }

  Future<void> updatePatient(Patient patient) async {
    await _patientRef.doc(patient.id).update(patient.toMap());
  }

  Future<void> deletePatient(String id) async {
    // Use a batch to ensure all operations succeed or fail together
    final batch = FirebaseFirestore.instance.batch();

    try {
      // 1. Find all treatments for this patient
      final treatmentsQuery =
          await _treatmentsRef.where('patient_id', isEqualTo: id).get();

      // 2. Add all treatment deletions to the batch
      for (final treatmentDoc in treatmentsQuery.docs) {
        batch.delete(treatmentDoc.reference);
      }

      // 3. Add patient deletion to the batch
      batch.delete(_patientRef.doc(id));

      // 4. Execute all deletions atomically
      await batch.commit();

      print(
          'Successfully deleted patient $id and ${treatmentsQuery.docs.length} related treatments');
    } catch (e) {
      print('Error deleting patient and treatments: $e');
      rethrow; // Re-throw so the UI can handle the error
    }
  }

  Stream<List<Patient>> getPatientsStream() {
    return _patientRef
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Patient.fromMap(data);
      }).toList();
    });
  }

  Future<List<Patient>> fetchPatientsOnce() async {
    final snapshot =
        await _patientRef.orderBy('created_at', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Patient.fromMap(data);
    }).toList();
  }

  Future<Patient?> getPatientById(String id) async {
    final doc = await _patientRef.doc(id).get();
    if (doc.exists) {
      return Patient.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<int> getTreatmentCountForPatient(String patientId) async {
    final snapshot =
        await _treatmentsRef.where('patient_id', isEqualTo: patientId).get();
    return snapshot.docs.length;
  }
}
