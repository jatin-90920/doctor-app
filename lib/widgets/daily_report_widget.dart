import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ayurvedic_doctor_crm/services/daily_report_service.dart';

class DailyReportWidget extends StatefulWidget {
  const DailyReportWidget({super.key});

  @override
  State<DailyReportWidget> createState() => _DailyReportWidgetState();
}

class _DailyReportWidgetState extends State<DailyReportWidget> {
  final DailyReportService _reportService = DailyReportService();
  DailyReport? _dailyReport;
  List<DailyData>? _weeklyData;
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDailyReport();
  }

  Future<void> _loadDailyReport() async {
    setState(() => _isLoading = true);
    
    try {
      final report = await _reportService.generateDailyReport(date: _selectedDate);
      final weeklyData = await _reportService.getWeeklyData(endDate: _selectedDate);
      
      if (mounted) {
        setState(() {
          _dailyReport = report;
          _weeklyData = weeklyData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading daily report: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading daily report: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadDailyReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_dailyReport == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                MdiIcons.chartLine,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load daily report',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Please try again later',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadDailyReport,
                icon: Icon(MdiIcons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildSummaryCards(),
        const SizedBox(height: 16),
        _buildWeeklyChart(),
        const SizedBox(height: 16),
        _buildDetailedAnalysis(),
      ],
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              MdiIcons.chartLine,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Report',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _dailyReport!.formattedDate,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _selectDate,
              icon: Icon(MdiIcons.calendar),
              tooltip: 'Select Date',
            ),
            IconButton(
              onPressed: _loadDailyReport,
              icon: Icon(MdiIcons.refresh),
              tooltip: 'Refresh',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final report = _dailyReport!;
    
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Treatments',
            value: report.totalTreatments.toString(),
            subtitle: '${report.patientsSeenToday} patients',
            icon: MdiIcons.stethoscope,
            color: Theme.of(context).colorScheme.primary,
            growth: report.weeklyComparison.treatmentGrowthPercentage,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Collections',
            value: report.formattedCollections,
            subtitle: '${report.formattedAverageCharge} avg',
            icon: MdiIcons.currencyInr,
            color: Theme.of(context).colorScheme.tertiary,
            growth: report.weeklyComparison.collectionGrowthPercentage,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double growth,
  }) {
    final isPositiveGrowth = growth >= 0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isPositiveGrowth ? Colors.green : Colors.red).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositiveGrowth ? MdiIcons.trendingUp : MdiIcons.trendingDown,
                        size: 12,
                        color: isPositiveGrowth ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${growth.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isPositiveGrowth ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    if (_weeklyData == null || _weeklyData!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  MdiIcons.chartBar,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '7-Day Trend',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: _buildSimpleBarChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleBarChart() {
    final maxTreatments = _weeklyData!.map((d) => d.treatments).reduce((a, b) => a > b ? a : b);
    final maxCollections = _weeklyData!.map((d) => d.collections).reduce((a, b) => a > b ? a : b);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _weeklyData!.map((data) {
        final treatmentHeight = maxTreatments > 0 ? (data.treatments / maxTreatments) * 80 : 0.0;
        final collectionHeight = maxCollections > 0 ? (data.collections / maxCollections) * 80 : 0.0;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 8,
                  height: treatmentHeight,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 2),
                Container(
                  width: 8,
                  height: collectionHeight,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data.formattedDate,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
              ),
            ),
            Text(
              data.treatments.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 9,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDetailedAnalysis() {
    final report = _dailyReport!;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMedicineStatsCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildTreatmentTypesCard()),
          ],
        ),
        const SizedBox(height: 16),
        _buildTopDiagnosesCard(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildWeeklyComparisonCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildMonthlyComparisonCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildMedicineStatsCard() {
    final stats = _dailyReport!.medicineStats;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  MdiIcons.pill,
                  size: 20,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Medicine Stats',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatRow('Total Prescribed', stats.totalMedicinesPrescribed.toString()),
            _buildStatRow('Unique Medicines', stats.uniqueMedicines.toString()),
            _buildStatRow('Ayurvedic', stats.ayurvedicMedicines.toString()),
            _buildStatRow('Allopathic', stats.allopathicMedicines.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentTypesCard() {
    final stats = _dailyReport!.treatmentTypeStats;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  MdiIcons.chartPie,
                  size: 20,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Treatment Types',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...stats.entries.map((entry) => 
              _buildStatRow(entry.key, entry.value.toString())
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopDiagnosesCard() {
    final diagnoses = _dailyReport!.topDiagnoses;
    
    if (diagnoses.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  MdiIcons.clipboardText,
                  size: 20,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Top Diagnoses Today',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...diagnoses.take(5).map((diagnosis) => 
              _buildStatRow(diagnosis.diagnosis, diagnosis.count.toString())
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyComparisonCard() {
    final comparison = _dailyReport!.weeklyComparison;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  MdiIcons.calendarWeek,
                  size: 20,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weekly Comparison',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildComparisonRow(
              'Treatments',
              comparison.currentWeekTreatments.toString(),
              comparison.formattedTreatmentGrowth,
              comparison.treatmentGrowthPercentage >= 0,
            ),
            _buildComparisonRow(
              'Collections',
              comparison.formattedCurrentWeekCollections,
              comparison.formattedCollectionGrowth,
              comparison.collectionGrowthPercentage >= 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyComparisonCard() {
    final comparison = _dailyReport!.monthlyComparison;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  MdiIcons.calendarMonth,
                  size: 20,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Monthly Comparison',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildComparisonRow(
              'Treatments',
              comparison.currentMonthTreatments.toString(),
              comparison.formattedTreatmentGrowth,
              comparison.treatmentGrowthPercentage >= 0,
            ),
            _buildComparisonRow(
              'Collections',
              comparison.formattedCurrentMonthCollections,
              comparison.formattedCollectionGrowth,
              comparison.collectionGrowthPercentage >= 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String value, String growth, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                isPositive ? MdiIcons.trendingUp : MdiIcons.trendingDown,
                size: 12,
                color: isPositive ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 2),
              Text(
                growth,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

