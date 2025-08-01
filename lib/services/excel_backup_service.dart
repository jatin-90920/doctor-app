import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ayurvedic_doctor_crm/models/patient.dart';
import 'package:ayurvedic_doctor_crm/models/treatment.dart';
import 'package:ayurvedic_doctor_crm/models/medicine.dart';
import 'package:ayurvedic_doctor_crm/services/patient_firestore_service.dart';
import 'package:ayurvedic_doctor_crm/services/treatment_firestore_service.dart';

class ExcelBackupService {
  final PatientFirestoreService _patientService = PatientFirestoreService();
  final TreatmentFirestoreService _treatmentService = TreatmentFirestoreService();

  // Comprehensive backup with patients and their treatment history
  Future<String> createComprehensiveBackup() async {
    try {
      // Fetch all data
      final patients = await _patientService.fetchPatientsOnce();
      final treatments = await _treatmentService.fetchTreatmentsOnce();

      // Create Excel workbook
      var excel = Excel.createExcel();
      
      // Remove default sheet
      excel.delete('Sheet1');

      // Create sheets
      await _createPatientsSheet(excel, patients);
      await _createTreatmentsSheet(excel, treatments, patients);
      await _createPatientTreatmentSummarySheet(excel, patients, treatments);
      await _createMedicineAnalysisSheet(excel, treatments);
      await _createFinancialSummarySheet(excel, treatments);

      // Generate file
      return await _saveAndShareExcel(excel, 'comprehensive_backup');
    } catch (e) {
      debugPrint('Error creating comprehensive backup: $e');
      rethrow;
    }
  }

  // Patients only backup
  Future<String> createPatientsBackup() async {
    try {
      final patients = await _patientService.fetchPatientsOnce();
      var excel = Excel.createExcel();
      excel.delete('Sheet1');
      
      await _createPatientsSheet(excel, patients);
      
      return await _saveAndShareExcel(excel, 'patients_backup');
    } catch (e) {
      debugPrint('Error creating patients backup: $e');
      rethrow;
    }
  }

  // Treatments only backup
  Future<String> createTreatmentsBackup() async {
    try {
      final treatments = await _treatmentService.fetchTreatmentsOnce();
      final patients = await _patientService.fetchPatientsOnce();
      var excel = Excel.createExcel();
      excel.delete('Sheet1');
      
      await _createTreatmentsSheet(excel, treatments, patients);
      
      return await _saveAndShareExcel(excel, 'treatments_backup');
    } catch (e) {
      debugPrint('Error creating treatments backup: $e');
      rethrow;
    }
  }

  // Date range backup
  Future<String> createDateRangeBackup(DateTime startDate, DateTime endDate) async {
    try {
      final allTreatments = await _treatmentService.fetchTreatmentsOnce();
      final patients = await _patientService.fetchPatientsOnce();
      
      // Filter treatments by date range
      final filteredTreatments = allTreatments.where((treatment) {
        return treatment.visitDate.isAfter(startDate.subtract(const Duration(milliseconds: 1))) &&
               treatment.visitDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      // Get patients who had treatments in this period
      final patientIds = filteredTreatments.map((t) => t.patientId).toSet();
      final filteredPatients = patients.where((p) => patientIds.contains(p.id)).toList();

      var excel = Excel.createExcel();
      excel.delete('Sheet1');
      
      await _createPatientsSheet(excel, filteredPatients);
      await _createTreatmentsSheet(excel, filteredTreatments, patients);
      await _createPatientTreatmentSummarySheet(excel, filteredPatients, filteredTreatments);
      
      final dateRange = '${DateFormat('yyyy-MM-dd').format(startDate)}_to_${DateFormat('yyyy-MM-dd').format(endDate)}';
      return await _saveAndShareExcel(excel, 'backup_$dateRange');
    } catch (e) {
      debugPrint('Error creating date range backup: $e');
      rethrow;
    }
  }

  Future<void> _createPatientsSheet(Excel excel, List<Patient> patients) async {
    Sheet patientsSheet = excel['Patients'];
    
    // Headers
    final headers = [
      'Patient ID',
      'Full Name',
      'Phone',
      'Email',
      'Gender',
      'Date of Birth',
      'Age',
      'Address',
      'Medical History',
      'Total Treatments',
      'Last Visit',
      'Total Spent',
      'Created At',
      'Updated At'
    ];

    // Style headers
    for (int i = 0; i < headers.length; i++) {
      var cell = patientsSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('FF2E7D32'),
        fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
        fontSize: 12,
      );
    }

    // Get treatment data for each patient
    final allTreatments = await _treatmentService.fetchTreatmentsOnce();
    final treatmentsByPatient = <String, List<Treatment>>{};
    for (final treatment in allTreatments) {
      treatmentsByPatient.putIfAbsent(treatment.patientId, () => []).add(treatment);
    }

    // Add patient data
    for (int i = 0; i < patients.length; i++) {
      final patient = patients[i];
      final patientTreatments = treatmentsByPatient[patient.id] ?? [];
      final totalSpent = patientTreatments.fold(0.0, (sum, t) => sum + (t.treatmentCharge ?? 0.0));
      final lastVisit = patientTreatments.isNotEmpty 
          ? patientTreatments.map((t) => t.visitDate).reduce((a, b) => a.isAfter(b) ? a : b)
          : null;

      final rowIndex = i + 1;
      final rowData = [
        patient.id,
        patient.fullName,
        patient.phone ?? '',
        patient.email ?? '',
        patient.gender,
        patient.dateOfBirth != null ? DateFormat('dd/MM/yyyy').format(patient.dateOfBirth!) : '',
        patient.displayAge.toString(),
        patient.address ?? '',
        patient.medicalHistory ?? '',
        patientTreatments.length.toString(),
        lastVisit != null ? DateFormat('dd/MM/yyyy').format(lastVisit) : '',
        '₹${totalSpent.toStringAsFixed(2)}',
        DateFormat('dd/MM/yyyy HH:mm:ss').format(patient.createdAt),
        patient.updatedAt != null ? DateFormat('dd/MM/yyyy HH:mm:ss').format(patient.updatedAt!) : '',
      ];

      for (int j = 0; j < rowData.length; j++) {
        var cell = patientsSheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex));
        cell.value = TextCellValue(rowData[j]);
        
        // Alternate row colors
        if (i % 2 == 1) {
          cell.cellStyle = CellStyle(
            backgroundColorHex: ExcelColor.fromHexString('FFF5F5F5'),
          );
        }
      }
    }

    // Auto-fit columns
    for (int i = 0; i < headers.length; i++) {
      patientsSheet.setColumnAutoFit(i);
    }
  }

  Future<void> _createTreatmentsSheet(Excel excel, List<Treatment> treatments, List<Patient> patients) async {
    Sheet treatmentsSheet = excel['Treatments'];
    
    // Create patient lookup map
    final patientMap = {for (var p in patients) p.id: p};
    
    // Headers
    final headers = [
      'Treatment ID',
      'Patient ID',
      'Patient Name',
      'Visit Date',
      'Symptoms',
      'Diagnosis',
      'Treatment Charge',
      'Medicines Prescribed',
      'Medicine Details',
      'Notes',
      'Created At'
    ];

    // Style headers
    for (int i = 0; i < headers.length; i++) {
      var cell = treatmentsSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('FF1565C0'),
        fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
        fontSize: 12,
      );
    }

    // Add treatment data
    for (int i = 0; i < treatments.length; i++) {
      final treatment = treatments[i];
      final patient = patientMap[treatment.patientId];
      
      // Format medicines
      final medicineNames = treatment.prescribedMedicines.map((m) => m.name).join(', ');
      final medicineDetails = treatment.prescribedMedicines.map((m) => 
        '${m.name} (${m.typeDisplayName}) - ${m.dosage} for ${m.duration}'
      ).join('\n');

      final rowIndex = i + 1;
      final rowData = [
        treatment.id,
        treatment.patientId,
        patient?.fullName ?? 'Unknown Patient',
        DateFormat('dd/MM/yyyy').format(treatment.visitDate),
        treatment.symptoms,
        treatment.diagnosis,
        treatment.treatmentCharge != null ? '₹${treatment.treatmentCharge!.toStringAsFixed(2)}' : '',
        medicineNames,
        medicineDetails,
        treatment.notes ?? '',
        DateFormat('dd/MM/yyyy HH:mm:ss').format(treatment.createdAt),
      ];

      for (int j = 0; j < rowData.length; j++) {
        var cell = treatmentsSheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex));
        cell.value = TextCellValue(rowData[j]);
        
        // Alternate row colors
        if (i % 2 == 1) {
          cell.cellStyle = CellStyle(
            backgroundColorHex: ExcelColor.fromHexString('FFF5F5F5'),
          );
        }
      }
    }

    // Auto-fit columns
    for (int i = 0; i < headers.length; i++) {
      treatmentsSheet.setColumnAutoFit(i);
    }
  }

  Future<void> _createPatientTreatmentSummarySheet(Excel excel, List<Patient> patients, List<Treatment> treatments) async {
    Sheet summarySheet = excel['Patient Summary'];
    
    // Group treatments by patient
    final treatmentsByPatient = <String, List<Treatment>>{};
    for (final treatment in treatments) {
      treatmentsByPatient.putIfAbsent(treatment.patientId, () => []).add(treatment);
    }

    // Headers
    final headers = [
      'Patient Name',
      'Phone',
      'Total Visits',
      'First Visit',
      'Last Visit',
      'Total Amount Paid',
      'Average Per Visit',
      'Most Common Diagnosis',
      'Total Medicines Prescribed',
      'Preferred Medicine Type'
    ];

    // Style headers
    for (int i = 0; i < headers.length; i++) {
      var cell = summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('FF6A1B9A'),
        fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
        fontSize: 12,
      );
    }

    // Add summary data
    for (int i = 0; i < patients.length; i++) {
      final patient = patients[i];
      final patientTreatments = treatmentsByPatient[patient.id] ?? [];
      
      if (patientTreatments.isEmpty) continue;

      // Calculate statistics
      final totalAmount = patientTreatments.fold(0.0, (sum, t) => sum + (t.treatmentCharge ?? 0.0));
      final averagePerVisit = totalAmount / patientTreatments.length;
      
      final firstVisit = patientTreatments.map((t) => t.visitDate).reduce((a, b) => a.isBefore(b) ? a : b);
      final lastVisit = patientTreatments.map((t) => t.visitDate).reduce((a, b) => a.isAfter(b) ? a : b);
      
      // Most common diagnosis
      final diagnosisCount = <String, int>{};
      for (final treatment in patientTreatments) {
        diagnosisCount[treatment.diagnosis] = (diagnosisCount[treatment.diagnosis] ?? 0) + 1;
      }
      final mostCommonDiagnosis = diagnosisCount.entries.isNotEmpty 
          ? diagnosisCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : '';

      // Medicine statistics
      final allMedicines = patientTreatments.expand((t) => t.prescribedMedicines).toList();
      final medicineTypeCount = <MedicineType, int>{};
      for (final medicine in allMedicines) {
        medicineTypeCount[medicine.type] = (medicineTypeCount[medicine.type] ?? 0) + 1;
      }
      final preferredType = medicineTypeCount.entries.isNotEmpty
          ? medicineTypeCount.entries.reduce((a, b) => a.value > b.value ? a : b).key.name
          : '';

      final rowIndex = i + 1;
      final rowData = [
        patient.fullName,
        patient.phone ?? '',
        patientTreatments.length.toString(),
        DateFormat('dd/MM/yyyy').format(firstVisit),
        DateFormat('dd/MM/yyyy').format(lastVisit),
        '₹${totalAmount.toStringAsFixed(2)}',
        '₹${averagePerVisit.toStringAsFixed(2)}',
        mostCommonDiagnosis,
        allMedicines.length.toString(),
        preferredType,
      ];

      for (int j = 0; j < rowData.length; j++) {
        var cell = summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex));
        cell.value = TextCellValue(rowData[j]);
        
        // Alternate row colors
        if (i % 2 == 1) {
          cell.cellStyle = CellStyle(
            backgroundColorHex: ExcelColor.fromHexString('FFF5F5F5'),
          );
        }
      }
    }

    // Auto-fit columns
    for (int i = 0; i < headers.length; i++) {
      summarySheet.setColumnAutoFit(i);
    }
  }

  Future<void> _createMedicineAnalysisSheet(Excel excel, List<Treatment> treatments) async {
    Sheet medicineSheet = excel['Medicine Analysis'];
    
    // Collect all medicines
    final medicineCount = <String, Map<String, dynamic>>{};
    
    for (final treatment in treatments) {
      for (final medicine in treatment.prescribedMedicines) {
        if (!medicineCount.containsKey(medicine.name)) {
          medicineCount[medicine.name] = {
            'count': 0,
            'type': medicine.type.name,
            'dosages': <String>{},
            'durations': <String>{},
          };
        }
        medicineCount[medicine.name]!['count']++;
        medicineCount[medicine.name]!['dosages'].add(medicine.dosage);
        medicineCount[medicine.name]!['durations'].add(medicine.duration);
      }
    }

    // Headers
    final headers = [
      'Medicine Name',
      'Type',
      'Times Prescribed',
      'Common Dosages',
      'Common Durations',
      'Percentage of Total'
    ];

    // Style headers
    for (int i = 0; i < headers.length; i++) {
      var cell = medicineSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('FFFF8F00'),
        fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
        fontSize: 12,
      );
    }

    // Sort medicines by count
    final sortedMedicines = medicineCount.entries.toList()
      ..sort((a, b) => b.value['count'].compareTo(a.value['count']));

    final totalPrescriptions = treatments.expand((t) => t.prescribedMedicines).length;

    // Add medicine data
    for (int i = 0; i < sortedMedicines.length; i++) {
      final entry = sortedMedicines[i];
      final medicineName = entry.key;
      final data = entry.value;
      
      final percentage = (data['count'] / totalPrescriptions * 100).toStringAsFixed(1);
      final dosages = (data['dosages'] as Set<String>).join(', ');
      final durations = (data['durations'] as Set<String>).join(', ');

      final rowIndex = i + 1;
      final rowData = [
        medicineName,
        data['type'],
        data['count'].toString(),
        dosages,
        durations,
        '$percentage%',
      ];

      for (int j = 0; j < rowData.length; j++) {
        var cell = medicineSheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex));
        cell.value = TextCellValue(rowData[j]);
        
        // Alternate row colors
        if (i % 2 == 1) {
          cell.cellStyle = CellStyle(
            backgroundColorHex: ExcelColor.fromHexString('FFF5F5F5'),
          );
        }
      }
    }

    // Auto-fit columns
    for (int i = 0; i < headers.length; i++) {
      medicineSheet.setColumnAutoFit(i);
    }
  }

  Future<void> _createFinancialSummarySheet(Excel excel, List<Treatment> treatments) async {
    Sheet financialSheet = excel['Financial Summary'];
    
    // Group treatments by month
    final monthlyData = <String, List<Treatment>>{};
    for (final treatment in treatments) {
      final monthKey = DateFormat('yyyy-MM').format(treatment.visitDate);
      monthlyData.putIfAbsent(monthKey, () => []).add(treatment);
    }

    // Headers
    final headers = [
      'Month',
      'Total Treatments',
      'Total Collections',
      'Average Per Treatment',
      'Paid Treatments',
      'Free Treatments',
      'Collection Rate'
    ];

    // Style headers
    for (int i = 0; i < headers.length; i++) {
      var cell = financialSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('FF4CAF50'),
        fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
        fontSize: 12,
      );
    }

    // Sort months
    final sortedMonths = monthlyData.keys.toList()..sort();

    // Add financial data
    for (int i = 0; i < sortedMonths.length; i++) {
      final month = sortedMonths[i];
      final monthTreatments = monthlyData[month]!;
      
      final totalTreatments = monthTreatments.length;
      final totalCollections = monthTreatments.fold(0.0, (sum, t) => sum + (t.treatmentCharge ?? 0.0));
      final paidTreatments = monthTreatments.where((t) => (t.treatmentCharge ?? 0.0) > 0).length;
      final freeTreatments = totalTreatments - paidTreatments;
      final averagePerTreatment = totalTreatments > 0 ? totalCollections / totalTreatments : 0.0;
      final collectionRate = totalTreatments > 0 ? (paidTreatments / totalTreatments * 100) : 0.0;

      final rowIndex = i + 1;
      final rowData = [
        DateFormat('MMMM yyyy').format(DateTime.parse('$month-01')),
        totalTreatments.toString(),
        '₹${totalCollections.toStringAsFixed(2)}',
        '₹${averagePerTreatment.toStringAsFixed(2)}',
        paidTreatments.toString(),
        freeTreatments.toString(),
        '${collectionRate.toStringAsFixed(1)}%',
      ];

      for (int j = 0; j < rowData.length; j++) {
        var cell = financialSheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex));
        cell.value = TextCellValue(rowData[j]);
        
        // Alternate row colors
        if (i % 2 == 1) {
          cell.cellStyle = CellStyle(
            backgroundColorHex: ExcelColor.fromHexString('FFF5F5F5'),
          );
        }
      }
    }

    // Auto-fit columns
    for (int i = 0; i < headers.length; i++) {
      financialSheet.setColumnAutoFit(i);
    }
  }

  Future<String> _saveAndShareExcel(Excel excel, String filePrefix) async {
    // Generate file bytes
    var fileBytes = excel.save();
    
    if (fileBytes == null) {
      throw Exception('Failed to generate Excel file');
    }

    // Get app directory
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '${filePrefix}_$timestamp.xlsx';
    final filePath = '${directory.path}/$fileName';

    // Save file
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes);

    return filePath;
  }

  Future<void> shareBackupFile(String filePath, String description) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      text: description,
      subject: 'Ayurvedic Doctor CRM Backup',
    );
  }
}

