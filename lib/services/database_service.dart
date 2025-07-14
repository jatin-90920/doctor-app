import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ayurvedic_doctor_crm/models/patient.dart';
import 'package:ayurvedic_doctor_crm/models/treatment.dart';
import 'package:ayurvedic_doctor_crm/models/medicine.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ayurvedic_crm.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Create patients table
    await db.execute('''
      CREATE TABLE patients (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        age INTEGER,
        date_of_birth INTEGER,
        gender TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        medical_history TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER
      )
    ''');

    // Create treatments table
    await db.execute('''
      CREATE TABLE treatments (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        visit_date INTEGER NOT NULL,
        symptoms TEXT NOT NULL,
        diagnosis TEXT NOT NULL,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
      )
    ''');

    // Create medicines table (for prescribed medicines in treatments)
    await db.execute('''
      CREATE TABLE treatment_medicines (
        id TEXT PRIMARY KEY,
        treatment_id TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        dosage TEXT NOT NULL,
        duration TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (treatment_id) REFERENCES treatments (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_patients_name ON patients(full_name)');
    await db.execute('CREATE INDEX idx_treatments_patient ON treatments(patient_id)');
    await db.execute('CREATE INDEX idx_treatments_date ON treatments(visit_date)');
    await db.execute('CREATE INDEX idx_medicines_treatment ON treatment_medicines(treatment_id)');
  }

  // Patient CRUD operations
  Future<String> insertPatient(Patient patient) async {
    final db = await instance.database;
    await db.insert('patients', patient.toMap());
    return patient.id;
  }

  Future<List<Patient>> getAllPatients() async {
    final db = await instance.database;
    final result = await db.query(
      'patients',
      orderBy: 'full_name ASC',
    );
    return result.map((map) => Patient.fromMap(map)).toList();
  }

  Future<Patient?> getPatient(String id) async {
    final db = await instance.database;
    final result = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Patient.fromMap(result.first);
    }
    return null;
  }

  Future<List<Patient>> searchPatients(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'patients',
      where: 'full_name LIKE ? OR phone LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'full_name ASC',
    );
    return result.map((map) => Patient.fromMap(map)).toList();
  }

  Future<int> updatePatient(Patient patient) async {
    final db = await instance.database;
    return await db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  Future<int> deletePatient(String id) async {
    final db = await instance.database;
    return await db.delete(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Treatment CRUD operations
  Future<String> insertTreatment(Treatment treatment) async {
    final db = await instance.database;
    
    await db.transaction((txn) async {
      // Insert treatment
      await txn.insert('treatments', treatment.toMap());
      
      // Insert prescribed medicines
      for (final medicine in treatment.prescribedMedicines) {
        await txn.insert('treatment_medicines', {
          ...medicine.toMap(),
          'treatment_id': treatment.id,
        });
      }
    });
    
    return treatment.id;
  }

  Future<List<Treatment>> getTreatmentsByPatient(String patientId) async {
    final db = await instance.database;
    final result = await db.query(
      'treatments',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'visit_date DESC',
    );
    
    final List<Treatment> treatments = [];
    for (final map in result) {
      final treatment = Treatment.fromMap(map);
      final medicines = await getTreatmentMedicines(treatment.id);
      treatments.add(treatment.copyWith(prescribedMedicines: medicines));
    }
    
    return treatments;
  }

  Future<Treatment?> getTreatment(String id) async {
    final db = await instance.database;
    final result = await db.query(
      'treatments',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (result.isNotEmpty) {
      final treatment = Treatment.fromMap(result.first);
      final medicines = await getTreatmentMedicines(treatment.id);
      return treatment.copyWith(prescribedMedicines: medicines);
    }
    return null;
  }

  Future<List<Medicine>> getTreatmentMedicines(String treatmentId) async {
    final db = await instance.database;
    final result = await db.query(
      'treatment_medicines',
      where: 'treatment_id = ?',
      whereArgs: [treatmentId],
    );
    return result.map((map) => Medicine.fromMap(map)).toList();
  }

  Future<int> updateTreatment(Treatment treatment) async {
    final db = await instance.database;
    
    await db.transaction((txn) async {
      // Update treatment
      await txn.update(
        'treatments',
        treatment.toMap(),
        where: 'id = ?',
        whereArgs: [treatment.id],
      );
      
      // Delete existing medicines
      await txn.delete(
        'treatment_medicines',
        where: 'treatment_id = ?',
        whereArgs: [treatment.id],
      );
      
      // Insert updated medicines
      for (final medicine in treatment.prescribedMedicines) {
        await txn.insert('treatment_medicines', {
          ...medicine.toMap(),
          'treatment_id': treatment.id,
        });
      }
    });
    
    return 1;
  }

  Future<int> deleteTreatment(String id) async {
    final db = await instance.database;
    return await db.delete(
      'treatments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Analytics and reporting
  Future<int> getTotalPatients() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM patients');
    return result.first['count'] as int;
  }

  Future<int> getTotalTreatments() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM treatments');
    return result.first['count'] as int;
  }

  Future<List<Treatment>> getRecentTreatments({int limit = 10}) async {
    final db = await instance.database;
    final result = await db.query(
      'treatments',
      orderBy: 'visit_date DESC',
      limit: limit,
    );
    
    final List<Treatment> treatments = [];
    for (final map in result) {
      final treatment = Treatment.fromMap(map);
      final medicines = await getTreatmentMedicines(treatment.id);
      treatments.add(treatment.copyWith(prescribedMedicines: medicines));
    }
    
    return treatments;
  }

  // Export data for backup
  Future<Map<String, dynamic>> exportAllData() async {
    final patients = await getAllPatients();
    final treatments = <Treatment>[];
    
    for (final patient in patients) {
      final patientTreatments = await getTreatmentsByPatient(patient.id);
      treatments.addAll(patientTreatments);
    }
    
    return {
      'patients': patients.map((p) => p.toJson()).toList(),
      'treatments': treatments.map((t) => t.toJson()).toList(),
      'export_date': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}

