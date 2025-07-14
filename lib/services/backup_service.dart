import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:ayurvedic_doctor_crm/models/patient.dart';
import 'package:ayurvedic_doctor_crm/models/treatment.dart';
import 'package:ayurvedic_doctor_crm/services/database_service.dart';

class BackupService {
  static const String _backupVersion = '1.0.0';

  // Export all data to Excel
  static Future<File> exportToExcel({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final excel = Excel.createExcel();
    
    // Remove default sheet
    excel.delete('Sheet1');
    
    // Create sheets
    final patientsSheet = excel['Patients'];
    final treatmentsSheet = excel['Treatments'];
    final medicinesSheet = excel['Medicines'];
    
    // Get data from database
    final databaseService = DatabaseService.instance;
    final patients = await databaseService.getAllPatients();
    
    // Export patients
    await _exportPatientsToSheet(patientsSheet, patients);
    
    // Export treatments and medicines
    await _exportTreatmentsToSheet(treatmentsSheet, medicinesSheet, patients, startDate, endDate);
    
    // Save Excel file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'ayurvedic_crm_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final file = File('${directory.path}/$fileName');
    
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }
    
    return file;
  }

  static Future<void> _exportPatientsToSheet(Sheet sheet, List<Patient> patients) async {
    // Add headers
    final headers = [
      'ID',
      'Full Name',
      'Age',
      'Date of Birth',
      'Gender',
      'Phone',
      'Email',
      'Address',
      'Medical History',
      'Created At',
      'Updated At',
    ];
    
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.blue100,
      );
    }
    
    // Add patient data
    for (int i = 0; i < patients.length; i++) {
      final patient = patients[i];
      final rowIndex = i + 1;
      
      final data = [
        patient.id,
        patient.fullName,
        patient.age?.toString() ?? '',
        patient.dateOfBirth != null ? DateFormat('dd/MM/yyyy').format(patient.dateOfBirth!) : '',
        patient.gender,
        patient.phone ?? '',
        patient.email ?? '',
        patient.address ?? '',
        patient.medicalHistory ?? '',
        DateFormat('dd/MM/yyyy HH:mm').format(patient.createdAt),
        patient.updatedAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(patient.updatedAt!) : '',
      ];
      
      for (int j = 0; j < data.length; j++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex));
        cell.value = TextCellValue(data[j]);
      }
    }
  }

  static Future<void> _exportTreatmentsToSheet(
    Sheet treatmentsSheet,
    Sheet medicinesSheet,
    List<Patient> patients,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final databaseService = DatabaseService.instance;
    
    // Treatment headers
    final treatmentHeaders = [
      'Treatment ID',
      'Patient ID',
      'Patient Name',
      'Visit Date',
      'Symptoms',
      'Diagnosis',
      'Notes',
      'Created At',
      'Updated At',
    ];
    
    for (int i = 0; i < treatmentHeaders.length; i++) {
      final cell = treatmentsSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(treatmentHeaders[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.green100,
      );
    }
    
    // Medicine headers
    final medicineHeaders = [
      'Medicine ID',
      'Treatment ID',
      'Patient Name',
      'Visit Date',
      'Medicine Name',
      'Type',
      'Dosage',
      'Duration',
      'Notes',
    ];
    
    for (int i = 0; i < medicineHeaders.length; i++) {
      final cell = medicinesSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(medicineHeaders[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.orange100,
      );
    }
    
    int treatmentRowIndex = 1;
    int medicineRowIndex = 1;
    
    // Export treatments for each patient
    for (final patient in patients) {
      final treatments = await databaseService.getTreatmentsByPatient(patient.id);
      
      for (final treatment in treatments) {
        // Filter by date range if specified
        if (startDate != null && treatment.visitDate.isBefore(startDate)) continue;
        if (endDate != null && treatment.visitDate.isAfter(endDate)) continue;
        
        // Add treatment data
        final treatmentData = [
          treatment.id,
          treatment.patientId,
          patient.fullName,
          DateFormat('dd/MM/yyyy').format(treatment.visitDate),
          treatment.symptoms,
          treatment.diagnosis,
          treatment.notes ?? '',
          DateFormat('dd/MM/yyyy HH:mm').format(treatment.createdAt),
          treatment.updatedAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(treatment.updatedAt!) : '',
        ];
        
        for (int j = 0; j < treatmentData.length; j++) {
          final cell = treatmentsSheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: treatmentRowIndex));
          cell.value = TextCellValue(treatmentData[j]);
        }
        treatmentRowIndex++;
        
        // Add medicine data
        for (final medicine in treatment.prescribedMedicines) {
          final medicineData = [
            medicine.id,
            treatment.id,
            patient.fullName,
            DateFormat('dd/MM/yyyy').format(treatment.visitDate),
            medicine.name,
            medicine.typeDisplayName,
            medicine.dosage,
            medicine.duration,
            medicine.notes ?? '',
          ];
          
          for (int j = 0; j < medicineData.length; j++) {
            final cell = medicinesSheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: medicineRowIndex));
            cell.value = TextCellValue(medicineData[j]);
          }
          medicineRowIndex++;
        }
      }
    }
  }

  // Create backup file
  static Future<File> createBackup() async {
    final databaseService = DatabaseService.instance;
    final backupData = await databaseService.exportAllData();
    
    // Add backup metadata
    backupData['backup_created_at'] = DateTime.now().toIso8601String();
    backupData['backup_version'] = _backupVersion;
    backupData['app_version'] = '1.0.0';
    
    // Save backup file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'ayurvedic_crm_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';
    final file = File('${directory.path}/$fileName');
    
    final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
    await file.writeAsString(jsonString);
    
    return file;
  }

  // Restore from backup file
  static Future<bool> restoreFromBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Backup file not found');
      }
      
      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate backup format
      if (!_validateBackupFormat(backupData)) {
        throw Exception('Invalid backup file format');
      }
      
      final databaseService = DatabaseService.instance;
      
      // Clear existing data (with confirmation in UI)
      // This would typically be handled in the UI layer
      
      // Restore patients
      final patientsData = backupData['patients'] as List<dynamic>;
      for (final patientJson in patientsData) {
        final patient = Patient.fromJson(patientJson as Map<String, dynamic>);
        await databaseService.insertPatient(patient);
      }
      
      // Restore treatments
      final treatmentsData = backupData['treatments'] as List<dynamic>;
      for (final treatmentJson in treatmentsData) {
        final treatment = Treatment.fromJson(treatmentJson as Map<String, dynamic>);
        await databaseService.insertTreatment(treatment);
      }
      
      return true;
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      return false;
    }
  }

  static bool _validateBackupFormat(Map<String, dynamic> backupData) {
    return backupData.containsKey('patients') &&
           backupData.containsKey('treatments') &&
           backupData.containsKey('export_date') &&
           backupData.containsKey('version');
  }

  // Share file
  static Future<void> shareFile(File file) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Ayurvedic CRM Export',
    );
  }

  // Pick backup file for restore
  static Future<String?> pickBackupFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );
    
    return result?.files.single.path;
  }

  // Get backup statistics
  static Future<Map<String, dynamic>> getBackupStatistics() async {
    final databaseService = DatabaseService.instance;
    
    final totalPatients = await databaseService.getTotalPatients();
    final totalTreatments = await databaseService.getTotalTreatments();
    
    return {
      'total_patients': totalPatients,
      'total_treatments': totalTreatments,
      'last_backup': null, // This would be stored in preferences
      'database_size': await _getDatabaseSize(),
    };
  }

  static Future<String> _getDatabaseSize() async {
    try {
      final databasePath = await DatabaseService.instance.database;
      final file = File(databasePath.path);
      final size = await file.length();
      
      if (size < 1024) {
        return '$size B';
      } else if (size < 1024 * 1024) {
        return '${(size / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  // Export patients only
  static Future<File> exportPatientsOnly() async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    
    final patientsSheet = excel['Patients'];
    final databaseService = DatabaseService.instance;
    final patients = await databaseService.getAllPatients();
    
    await _exportPatientsToSheet(patientsSheet, patients);
    
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'patients_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final file = File('${directory.path}/$fileName');
    
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }
    
    return file;
  }

  // Export treatments for date range
  static Future<File> exportTreatmentsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    
    final treatmentsSheet = excel['Treatments'];
    final medicinesSheet = excel['Medicines'];
    
    final databaseService = DatabaseService.instance;
    final patients = await databaseService.getAllPatients();
    
    await _exportTreatmentsToSheet(treatmentsSheet, medicinesSheet, patients, startDate, endDate);
    
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'treatments_${DateFormat('yyyyMMdd').format(startDate)}_to_${DateFormat('yyyyMMdd').format(endDate)}.xlsx';
    final file = File('${directory.path}/$fileName');
    
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }
    
    return file;
  }
}

