import 'package:ayurvedic_doctor_crm/models/medicine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineFirestoreService {
  final CollectionReference _medicinesRef =
      FirebaseFirestore.instance.collection('medicines');

  Future<void> addMedicine(Medicine medicine) async {
    await _medicinesRef.doc(medicine.id).set(medicine.toMap());
  }

  Future<void> updateMedicine(Medicine medicine) async {
    await _medicinesRef.doc(medicine.id).update(medicine.toMap());
  }

  Future<void> deleteMedicine(String id) async {
    await _medicinesRef.doc(id).delete();
  }

  Stream<List<Medicine>> getMedicinesStream() {
    return _medicinesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Medicine.fromMap(data);
      }).toList();
    });
  }

  Future<List<Medicine>> fetchMedicinesOnce() async {
    final snapshot = await _medicinesRef.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Medicine.fromMap(data);
    }).toList();
  }

  Future<Medicine?> getMedicineById(String id) async {
    final doc = await _medicinesRef.doc(id).get();
    if (doc.exists) {
      return Medicine.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}
