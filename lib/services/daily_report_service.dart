import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:ayurvedic_doctor_crm/models/treatment.dart';
import 'package:ayurvedic_doctor_crm/models/patient.dart';
import 'package:ayurvedic_doctor_crm/models/medicine.dart';
import 'package:ayurvedic_doctor_crm/services/treatment_firestore_service.dart';
import 'package:ayurvedic_doctor_crm/services/patient_firestore_service.dart';

class DailyReportService {
  final TreatmentFirestoreService _treatmentService = TreatmentFirestoreService();
  final PatientFirestoreService _patientService = PatientFirestoreService();

  // Daily report data model
  Future<DailyReport> generateDailyReport({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      // Fetch all treatments and patients
      final allTreatments = await _treatmentService.fetchTreatmentsOnce();
      final allPatients = await _patientService.fetchPatientsOnce();

      // Filter treatments for the target date
      final dailyTreatments = allTreatments.where((treatment) {
        return treatment.visitDate.isAfter(startOfDay.subtract(const Duration(milliseconds: 1))) &&
               treatment.visitDate.isBefore(endOfDay);
      }).toList();

      // Calculate daily statistics
      final totalTreatments = dailyTreatments.length;
      final totalCollections = _calculateTotalCollections(dailyTreatments);
      final averageChargePerTreatment = totalTreatments > 0 ? totalCollections / totalTreatments : 0.0;

      // Get unique patients treated today
      final uniquePatientIds = dailyTreatments.map((t) => t.patientId).toSet();
      final patientsSeenToday = uniquePatientIds.length;

      // Calculate medicine statistics
      final medicineStats = _calculateMedicineStats(dailyTreatments);

      // Get treatment type distribution
      final treatmentTypeStats = _calculateTreatmentTypeStats(dailyTreatments);

      // Calculate hourly distribution
      final hourlyDistribution = _calculateHourlyDistribution(dailyTreatments);

      // Get top diagnoses
      final topDiagnoses = _getTopDiagnoses(dailyTreatments);

      // Calculate weekly comparison
      final weeklyComparison = await _calculateWeeklyComparison(targetDate, allTreatments);

      // Calculate monthly comparison
      final monthlyComparison = await _calculateMonthlyComparison(targetDate, allTreatments);

      return DailyReport(
        date: targetDate,
        totalTreatments: totalTreatments,
        totalCollections: totalCollections,
        averageChargePerTreatment: averageChargePerTreatment,
        patientsSeenToday: patientsSeenToday,
        totalPatients: allPatients.length,
        medicineStats: medicineStats,
        treatmentTypeStats: treatmentTypeStats,
        hourlyDistribution: hourlyDistribution,
        topDiagnoses: topDiagnoses,
        weeklyComparison: weeklyComparison,
        monthlyComparison: monthlyComparison,
        treatments: dailyTreatments,
      );
    } catch (e) {
      debugPrint('Error generating daily report: $e');
      rethrow;
    }
  }

  double _calculateTotalCollections(List<Treatment> treatments) {
    return treatments.fold(0.0, (sum, treatment) {
      return sum + (treatment.treatmentCharge ?? 0.0);
    });
  }

  MedicineStats _calculateMedicineStats(List<Treatment> treatments) {
    final allMedicines = <String>[];
    final ayurvedicCount = <String, int>{};
    final allopathicCount = <String, int>{};
    final otherCount = <String, int>{};

    for (final treatment in treatments) {
      for (final medicine in treatment.prescribedMedicines) {
        allMedicines.add(medicine.name);
        
        switch (medicine.type) {
          case MedicineType.ayurvedic:
            ayurvedicCount[medicine.name] = (ayurvedicCount[medicine.name] ?? 0) + 1;
            break;
          case MedicineType.allopathic:
            allopathicCount[medicine.name] = (allopathicCount[medicine.name] ?? 0) + 1;
            break;
          case MedicineType.other:
            otherCount[medicine.name] = (otherCount[medicine.name] ?? 0) + 1;
            break;
        }
      }
    }

    return MedicineStats(
      totalMedicinesPrescribed: allMedicines.length,
      uniqueMedicines: allMedicines.toSet().length,
      ayurvedicMedicines: ayurvedicCount.length,
      allopathicMedicines: allopathicCount.length,
      otherMedicines: otherCount.length,
      topAyurvedicMedicines: _getTopMedicines(ayurvedicCount),
      topAllopathicMedicines: _getTopMedicines(allopathicCount),
    );
  }

  List<MedicineCount> _getTopMedicines(Map<String, int> medicineCount) {
    final sorted = medicineCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(5).map((entry) => 
      MedicineCount(name: entry.key, count: entry.value)
    ).toList();
  }

  Map<String, int> _calculateTreatmentTypeStats(List<Treatment> treatments) {
    final stats = <String, int>{};
    
    for (final treatment in treatments) {
      // Categorize based on medicine types used
      final hasAyurvedic = treatment.prescribedMedicines.any((m) => m.type == MedicineType.ayurvedic);
      final hasAllopathic = treatment.prescribedMedicines.any((m) => m.type == MedicineType.allopathic);
      
      String category;
      if (hasAyurvedic && hasAllopathic) {
        category = 'Mixed Treatment';
      } else if (hasAyurvedic) {
        category = 'Ayurvedic Treatment';
      } else if (hasAllopathic) {
        category = 'Allopathic Treatment';
      } else {
        category = 'Consultation Only';
      }
      
      stats[category] = (stats[category] ?? 0) + 1;
    }
    
    return stats;
  }

  Map<int, int> _calculateHourlyDistribution(List<Treatment> treatments) {
    final distribution = <int, int>{};
    
    for (final treatment in treatments) {
      final hour = treatment.visitDate.hour;
      distribution[hour] = (distribution[hour] ?? 0) + 1;
    }
    
    return distribution;
  }

  List<DiagnosisCount> _getTopDiagnoses(List<Treatment> treatments) {
    final diagnosisCount = <String, int>{};
    
    for (final treatment in treatments) {
      final diagnosis = treatment.diagnosis.trim();
      if (diagnosis.isNotEmpty) {
        diagnosisCount[diagnosis] = (diagnosisCount[diagnosis] ?? 0) + 1;
      }
    }
    
    final sorted = diagnosisCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(10).map((entry) => 
      DiagnosisCount(diagnosis: entry.key, count: entry.value)
    ).toList();
  }

  Future<WeeklyComparison> _calculateWeeklyComparison(DateTime targetDate, List<Treatment> allTreatments) async {
    final weekStart = targetDate.subtract(Duration(days: targetDate.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    
    final previousWeekStart = weekStart.subtract(const Duration(days: 7));
    final previousWeekEnd = previousWeekStart.add(const Duration(days: 7));
    
    final currentWeekTreatments = allTreatments.where((t) =>
      t.visitDate.isAfter(weekStart.subtract(const Duration(milliseconds: 1))) &&
      t.visitDate.isBefore(weekEnd)
    ).toList();
    
    final previousWeekTreatments = allTreatments.where((t) =>
      t.visitDate.isAfter(previousWeekStart.subtract(const Duration(milliseconds: 1))) &&
      t.visitDate.isBefore(previousWeekEnd)
    ).toList();
    
    final currentWeekCollections = _calculateTotalCollections(currentWeekTreatments);
    final previousWeekCollections = _calculateTotalCollections(previousWeekTreatments);
    
    return WeeklyComparison(
      currentWeekTreatments: currentWeekTreatments.length,
      previousWeekTreatments: previousWeekTreatments.length,
      currentWeekCollections: currentWeekCollections,
      previousWeekCollections: previousWeekCollections,
      treatmentGrowthPercentage: _calculateGrowthPercentage(
        previousWeekTreatments.length.toDouble(),
        currentWeekTreatments.length.toDouble(),
      ),
      collectionGrowthPercentage: _calculateGrowthPercentage(
        previousWeekCollections,
        currentWeekCollections,
      ),
    );
  }

  Future<MonthlyComparison> _calculateMonthlyComparison(DateTime targetDate, List<Treatment> allTreatments) async {
    final monthStart = DateTime(targetDate.year, targetDate.month, 1);
    final monthEnd = DateTime(targetDate.year, targetDate.month + 1, 1);
    
    final previousMonthStart = DateTime(targetDate.year, targetDate.month - 1, 1);
    final previousMonthEnd = DateTime(targetDate.year, targetDate.month, 1);
    
    final currentMonthTreatments = allTreatments.where((t) =>
      t.visitDate.isAfter(monthStart.subtract(const Duration(milliseconds: 1))) &&
      t.visitDate.isBefore(monthEnd)
    ).toList();
    
    final previousMonthTreatments = allTreatments.where((t) =>
      t.visitDate.isAfter(previousMonthStart.subtract(const Duration(milliseconds: 1))) &&
      t.visitDate.isBefore(previousMonthEnd)
    ).toList();
    
    final currentMonthCollections = _calculateTotalCollections(currentMonthTreatments);
    final previousMonthCollections = _calculateTotalCollections(previousMonthTreatments);
    
    return MonthlyComparison(
      currentMonthTreatments: currentMonthTreatments.length,
      previousMonthTreatments: previousMonthTreatments.length,
      currentMonthCollections: currentMonthCollections,
      previousMonthCollections: previousMonthCollections,
      treatmentGrowthPercentage: _calculateGrowthPercentage(
        previousMonthTreatments.length.toDouble(),
        currentMonthTreatments.length.toDouble(),
      ),
      collectionGrowthPercentage: _calculateGrowthPercentage(
        previousMonthCollections,
        currentMonthCollections,
      ),
    );
  }

  double _calculateGrowthPercentage(double previous, double current) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous) * 100;
  }

  // Get weekly report data for charts
  Future<List<DailyData>> getWeeklyData({DateTime? endDate}) async {
    final targetDate = endDate ?? DateTime.now();
    final weekStart = targetDate.subtract(const Duration(days: 6)); // Last 7 days including today
    
    final allTreatments = await _treatmentService.fetchTreatmentsOnce();
    final weeklyData = <DailyData>[];
    
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final dayTreatments = allTreatments.where((t) =>
        t.visitDate.isAfter(dayStart.subtract(const Duration(milliseconds: 1))) &&
        t.visitDate.isBefore(dayEnd)
      ).toList();
      
      weeklyData.add(DailyData(
        date: date,
        treatments: dayTreatments.length,
        collections: _calculateTotalCollections(dayTreatments),
      ));
    }
    
    return weeklyData;
  }
}

// Data models for daily report
class DailyReport {
  final DateTime date;
  final int totalTreatments;
  final double totalCollections;
  final double averageChargePerTreatment;
  final int patientsSeenToday;
  final int totalPatients;
  final MedicineStats medicineStats;
  final Map<String, int> treatmentTypeStats;
  final Map<int, int> hourlyDistribution;
  final List<DiagnosisCount> topDiagnoses;
  final WeeklyComparison weeklyComparison;
  final MonthlyComparison monthlyComparison;
  final List<Treatment> treatments;

  DailyReport({
    required this.date,
    required this.totalTreatments,
    required this.totalCollections,
    required this.averageChargePerTreatment,
    required this.patientsSeenToday,
    required this.totalPatients,
    required this.medicineStats,
    required this.treatmentTypeStats,
    required this.hourlyDistribution,
    required this.topDiagnoses,
    required this.weeklyComparison,
    required this.monthlyComparison,
    required this.treatments,
  });

  String get formattedDate => DateFormat('EEEE, MMMM d, y').format(date);
  String get formattedCollections => '₹${totalCollections.toStringAsFixed(2)}';
  String get formattedAverageCharge => '₹${averageChargePerTreatment.toStringAsFixed(2)}';
}

class MedicineStats {
  final int totalMedicinesPrescribed;
  final int uniqueMedicines;
  final int ayurvedicMedicines;
  final int allopathicMedicines;
  final int otherMedicines;
  final List<MedicineCount> topAyurvedicMedicines;
  final List<MedicineCount> topAllopathicMedicines;

  MedicineStats({
    required this.totalMedicinesPrescribed,
    required this.uniqueMedicines,
    required this.ayurvedicMedicines,
    required this.allopathicMedicines,
    required this.otherMedicines,
    required this.topAyurvedicMedicines,
    required this.topAllopathicMedicines,
  });
}

class MedicineCount {
  final String name;
  final int count;

  MedicineCount({required this.name, required this.count});
}

class DiagnosisCount {
  final String diagnosis;
  final int count;

  DiagnosisCount({required this.diagnosis, required this.count});
}

class WeeklyComparison {
  final int currentWeekTreatments;
  final int previousWeekTreatments;
  final double currentWeekCollections;
  final double previousWeekCollections;
  final double treatmentGrowthPercentage;
  final double collectionGrowthPercentage;

  WeeklyComparison({
    required this.currentWeekTreatments,
    required this.previousWeekTreatments,
    required this.currentWeekCollections,
    required this.previousWeekCollections,
    required this.treatmentGrowthPercentage,
    required this.collectionGrowthPercentage,
  });

  String get formattedCurrentWeekCollections => '₹${currentWeekCollections.toStringAsFixed(2)}';
  String get formattedPreviousWeekCollections => '₹${previousWeekCollections.toStringAsFixed(2)}';
  String get formattedTreatmentGrowth => '${treatmentGrowthPercentage >= 0 ? '+' : ''}${treatmentGrowthPercentage.toStringAsFixed(1)}%';
  String get formattedCollectionGrowth => '${collectionGrowthPercentage >= 0 ? '+' : ''}${collectionGrowthPercentage.toStringAsFixed(1)}%';
}

class MonthlyComparison {
  final int currentMonthTreatments;
  final int previousMonthTreatments;
  final double currentMonthCollections;
  final double previousMonthCollections;
  final double treatmentGrowthPercentage;
  final double collectionGrowthPercentage;

  MonthlyComparison({
    required this.currentMonthTreatments,
    required this.previousMonthTreatments,
    required this.currentMonthCollections,
    required this.previousMonthCollections,
    required this.treatmentGrowthPercentage,
    required this.collectionGrowthPercentage,
  });

  String get formattedCurrentMonthCollections => '₹${currentMonthCollections.toStringAsFixed(2)}';
  String get formattedPreviousMonthCollections => '₹${previousMonthCollections.toStringAsFixed(2)}';
  String get formattedTreatmentGrowth => '${treatmentGrowthPercentage >= 0 ? '+' : ''}${treatmentGrowthPercentage.toStringAsFixed(1)}%';
  String get formattedCollectionGrowth => '${collectionGrowthPercentage >= 0 ? '+' : ''}${collectionGrowthPercentage.toStringAsFixed(1)}%';
}

class DailyData {
  final DateTime date;
  final int treatments;
  final double collections;

  DailyData({
    required this.date,
    required this.treatments,
    required this.collections,
  });

  String get formattedDate => DateFormat('MMM d').format(date);
  String get formattedCollections => '₹${collections.toStringAsFixed(0)}';
}

