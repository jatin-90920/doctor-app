import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient.dart';

class PatientFirestoreService {
  final CollectionReference _patientRef =
      FirebaseFirestore.instance.collection('patients');

  Future<void> addPatient(Patient patient) async {
    await _patientRef.doc(patient.id).set(patient.toMap());
  }

  Future<void> updatePatient(Patient patient) async {
    await _patientRef.doc(patient.id).update(patient.toMap());
  }

  Future<void> deletePatient(String id) async {
    await _patientRef.doc(id).delete();
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
}
