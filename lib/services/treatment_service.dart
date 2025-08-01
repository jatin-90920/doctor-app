import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:ayurvedic_doctor_crm/models/treatment.dart';
import 'package:ayurvedic_doctor_crm/models/medicine.dart';
import 'package:ayurvedic_doctor_crm/services/database_service.dart';
import 'package:ayurvedic_doctor_crm/services/treatment_firestore_service.dart';

class TreatmentService extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  final TreatmentFirestoreService _firestoreService = TreatmentFirestoreService();
  final Uuid _uuid = const Uuid();
  
  List<Treatment> _treatments = [];
  bool _isLoading = false;

  List<Treatment> get treatments => _treatments;
  bool get isLoading => _isLoading;

  // Add real-time listener for treatments
  void startListeningToTreatments() {
    _firestoreService.getTreatmentsStream().listen(
      (treatments) {
        _treatments = treatments;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error listening to treatments: $error');
      },
    );
  }

  // Method to manually refresh treatments
  Future<void> refreshTreatments() async {
    try {
      _treatments = await _firestoreService.fetchTreatmentsOnce();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing treatments: $e');
    }
  }

  Future<void> loadTreatmentsByPatient(String patientId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _treatments = await _databaseService.getTreatmentsByPatient(patientId);
    } catch (e) {
      debugPrint('Error loading treatments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Treatment?> getTreatment(String id) async {
    try {
      return await _databaseService.getTreatment(id);
    } catch (e) {
      debugPrint('Error getting treatment: $e');
      return null;
    }
  }

  Future<bool> addTreatment({
    required String patientId,
    required DateTime visitDate,
    required String symptoms,
    required String diagnosis,
    String? notes,
    double? treatmentCharge,
    required List<Medicine> prescribedMedicines,
  }) async {
    try {
      final treatment = Treatment(
        id: _uuid.v4(),
        patientId: patientId,
        visitDate: visitDate,
        symptoms: symptoms,
        diagnosis: diagnosis,
        notes: notes,
        treatmentCharge: treatmentCharge,
        prescribedMedicines: prescribedMedicines,
        createdAt: DateTime.now(),
      );

      await _databaseService.insertTreatment(treatment);
      await loadTreatmentsByPatient(patientId);
      return true;
    } catch (e) {
      debugPrint('Error adding treatment: $e');
      return false;
    }
  }

  Future<bool> updateTreatment({
    required String id,
    required String patientId,
    required DateTime visitDate,
    required String symptoms,
    required String diagnosis,
    String? notes,
    double? treatmentCharge,
    required List<Medicine> prescribedMedicines,
  }) async {
    try {
      final existingTreatment = await _databaseService.getTreatment(id);
      if (existingTreatment == null) return false;

      final updatedTreatment = existingTreatment.copyWith(
        visitDate: visitDate,
        symptoms: symptoms,
        diagnosis: diagnosis,
        notes: notes,
        treatmentCharge: treatmentCharge,
        prescribedMedicines: prescribedMedicines,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updateTreatment(updatedTreatment);
      await loadTreatmentsByPatient(patientId);
      return true;
    } catch (e) {
      debugPrint('Error updating treatment: $e');
      return false;
    }
  }

  Future<bool> deleteTreatment(String id, String patientId) async {
    try {
      await _databaseService.deleteTreatment(id);
      await loadTreatmentsByPatient(patientId);
      return true;
    } catch (e) {
      debugPrint('Error deleting treatment: $e');
      return false;
    }
  }

  // Medicine helper methods
  Medicine createMedicine({
    required String name,
    required MedicineType type,
    required String dosage,
    required String duration,
    String? quantity,
    String? notes,
  }) {
    return Medicine(
      id: _uuid.v4(),
      name: name,
      type: type,
      dosage: dosage,
      duration: duration,
      quantity: quantity,
      notes: notes,
    );
  }

  // Analytics methods
  Future<List<Treatment>> getRecentTreatments({int limit = 10}) async {
    try {
      return await _databaseService.getRecentTreatments(limit: limit);
    } catch (e) {
      debugPrint('Error getting recent treatments: $e');
      return [];
    }
  }

  Future<int> getTotalTreatments() async {
    try {
      return await _databaseService.getTotalTreatments();
    } catch (e) {
      debugPrint('Error getting total treatments: $e');
      return 0;
    }
  }

  // Common medicine suggestions
  List<String> getCommonAyurvedicMedicines() {
    return [
      'Ashwagandha',
      'Triphala',
      'Brahmi',
      'Turmeric (Haldi)',
      'Neem',
      'Tulsi',
      'Amla',
      'Giloy',
      'Arjuna',
      'Shatavari',
      'Gokshura',
      'Punarnava',
      'Manjistha',
      'Haritaki',
      'Bibhitaki',
      'Amalaki',
      'Guduchi',
      'Shankhpushpi',
      'Jatamansi',
      'Yashtimadhu',
    ];
  }

  List<String> getCommonAllopathicMedicines() {
    return [
      'Paracetamol',
      'Ibuprofen',
      'Aspirin',
      'Amoxicillin',
      'Azithromycin',
      'Omeprazole',
      'Metformin',
      'Amlodipine',
      'Atorvastatin',
      'Levothyroxine',
      'Lisinopril',
      'Metoprolol',
      'Simvastatin',
      'Losartan',
      'Gabapentin',
    ];
  }

  List<String> getCommonDosageInstructions() {
    return [
      '1 tablet twice daily',
      '1 tablet once daily',
      '1 tablet thrice daily',
      '2 tablets twice daily',
      '1 teaspoon twice daily',
      '1 teaspoon once daily',
      '1 teaspoon thrice daily',
      '1 capsule twice daily',
      '1 capsule once daily',
      '1 capsule thrice daily',
      '5ml twice daily',
      '10ml twice daily',
      '1 tablet before meals',
      '1 tablet after meals',
      '1 tablet at bedtime',
    ];
  }

  List<String> getCommonDurations() {
    return [
      '3 days',
      '5 days',
      '7 days',
      '10 days',
      '14 days',
      '21 days',
      '1 month',
      '2 months',
      '3 months',
      'As needed',
      'Until symptoms improve',
      'Continue as advised',
    ];
  }

  List<String> getCommonQuantities() {
    return [
      '1 tablet',
      '2 tablets',
      '3 tablets',
      '1 capsule',
      '2 capsules',
      '3 capsules',
      '1 bottle',
      '2 bottles',
      '1 packet',
      '2 packets',
      '1 strip',
      '2 strips',
      '10 tablets',
      '20 tablets',
      '30 tablets',
      '100ml',
      '200ml',
      '500ml',
      '1 tube',
      '2 tubes',
      '1 vial',
      '2 vials',
      '1 box',
      '2 boxes',
      'As prescribed',
    ];
  }
}
