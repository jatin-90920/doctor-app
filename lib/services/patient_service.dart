import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:ayurvedic_doctor_crm/models/patient.dart';
import 'package:ayurvedic_doctor_crm/services/database_service.dart';

class PatientService extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  final Uuid _uuid = const Uuid();
  
  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Patient> get patients => _filteredPatients;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> loadPatients() async {
    _isLoading = true;
    notifyListeners();

    try {
      _patients = await _databaseService.getAllPatients();
      _applyFilter();
    } catch (e) {
      debugPrint('Error loading patients: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Patient?> getPatient(String id) async {
    try {
      return await _databaseService.getPatient(id);
    } catch (e) {
      debugPrint('Error getting patient: $e');
      return null;
    }
  }

  Future<bool> addPatient({
    required String fullName,
    int? age,
    DateTime? dateOfBirth,
    required String gender,
    String? phone,
    String? email,
    String? address,
    String? medicalHistory,
  }) async {
    try {
      final patient = Patient(
        id: _uuid.v4(),
        fullName: fullName,
        age: age,
        dateOfBirth: dateOfBirth,
        gender: gender,
        phone: phone,
        email: email,
        address: address,
        medicalHistory: medicalHistory,
        createdAt: DateTime.now(),
      );

      await _databaseService.insertPatient(patient);
      await loadPatients();
      return true;
    } catch (e) {
      debugPrint('Error adding patient: $e');
      return false;
    }
  }

  Future<bool> updatePatient({
    required String id,
    required String fullName,
    int? age,
    DateTime? dateOfBirth,
    required String gender,
    String? phone,
    String? email,
    String? address,
    String? medicalHistory,
  }) async {
    try {
      final existingPatient = await _databaseService.getPatient(id);
      if (existingPatient == null) return false;

      final updatedPatient = existingPatient.copyWith(
        fullName: fullName,
        age: age,
        dateOfBirth: dateOfBirth,
        gender: gender,
        phone: phone,
        email: email,
        address: address,
        medicalHistory: medicalHistory,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updatePatient(updatedPatient);
      await loadPatients();
      return true;
    } catch (e) {
      debugPrint('Error updating patient: $e');
      return false;
    }
  }

  Future<bool> deletePatient(String id) async {
    try {
      await _databaseService.deletePatient(id);
      await loadPatients();
      return true;
    } catch (e) {
      debugPrint('Error deleting patient: $e');
      return false;
    }
  }

  void searchPatients(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredPatients = List.from(_patients);
    } else {
      _filteredPatients = _patients.where((patient) {
        final query = _searchQuery.toLowerCase();
        return patient.fullName.toLowerCase().contains(query) ||
               (patient.phone?.toLowerCase().contains(query) ?? false) ||
               (patient.email?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilter();
    notifyListeners();
  }

  // Filter methods
  List<Patient> getPatientsByGender(String gender) {
    return _patients.where((patient) => patient.gender == gender).toList();
  }

  List<Patient> getRecentPatients({int limit = 10}) {
    final sortedPatients = List<Patient>.from(_patients);
    sortedPatients.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedPatients.take(limit).toList();
  }

  int get totalPatients => _patients.length;
  int get malePatients => getPatientsByGender('Male').length;
  int get femalePatients => getPatientsByGender('Female').length;
}

