import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:ayurvedic_doctor_crm/services/patient_firestore_service.dart';
import 'package:ayurvedic_doctor_crm/services/treatment_firestore_service.dart';
import 'package:ayurvedic_doctor_crm/screens/patients/patient_list_screen.dart';
import 'package:ayurvedic_doctor_crm/screens/patients/add_edit_patient_screen.dart';
import 'package:ayurvedic_doctor_crm/screens/settings/settings_screen.dart';
import 'package:ayurvedic_doctor_crm/widgets/loading_widget.dart';
import 'package:ayurvedic_doctor_crm/models/treatment.dart';
import 'package:ayurvedic_doctor_crm/models/patient.dart';
import 'package:ayurvedic_doctor_crm/utils/responsive_utils.dart';
import 'package:ayurvedic_doctor_crm/utils/enhanced_app_theme.dart';
import 'package:ayurvedic_doctor_crm/widgets/enhanced_cards.dart';

class ResponsiveHomeScreen extends StatefulWidget {
  const ResponsiveHomeScreen({super.key});

  @override
  State<ResponsiveHomeScreen> createState() => _ResponsiveHomeScreenState();
}

class _ResponsiveHomeScreenState extends State<ResponsiveHomeScreen> with WidgetsBindingObserver {
  int _totalPatients = 0;
  int _totalTreatments = 0;
  List<Treatment> _recentTreatments = [];
  bool _isLoading = true;

  // Create instances of Firestore services
  final PatientFirestoreService _patientFirestoreService =
      PatientFirestoreService();
  final TreatmentFirestoreService _treatmentFirestoreService =
      TreatmentFirestoreService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDashboardData();
    _setupRealtimeListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadDashboardData();
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<Patient> patients =
          await _patientFirestoreService.fetchPatientsOnce();
      _totalPatients = patients.length;

      final List<Treatment> treatments =
          await _treatmentFirestoreService.fetchTreatmentsOnce();
      _totalTreatments = treatments.length;

      _recentTreatments = treatments.take(5).toList();
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _setupRealtimeListeners() {
    _patientFirestoreService.getPatientsStream().listen(
      (patients) {
        if (mounted) {
          setState(() {
            _totalPatients = patients.length;
          });
        }
      },
      onError: (error) {
        debugPrint('Error listening to patients stream: $error');
      },
    );

    _treatmentFirestoreService.getTreatmentsStream().listen(
      (treatments) {
        if (mounted) {
          setState(() {
            _totalTreatments = treatments.length;
            _recentTreatments = treatments.take(5).toList();
          });
        }
      },
      onError: (error) {
        debugPrint('Error listening to treatments stream: $error');
      },
    );
  }

  Future<void> _refreshData() async {
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveUtils.isMobile(context) 
        ? AppBar(
            title: const Text('Doctor CRM', style: TextStyle(color: Colors.white),),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(MdiIcons.refresh, color: Colors.white),
                onPressed: _refreshData,
                tooltip: 'Refresh Data',
              ),
            ],
          )
        : null,
      body: _isLoading
          ? const LoadingWidget(message: 'Loading dashboard...')
          : ResponsiveLayout(
              mobile: _buildMobileLayout(),
              tablet: _buildTabletLayout(),
              desktop: _buildDesktopLayout(),
            ),
      floatingActionButton: ResponsiveUtils.isMobile(context)
          ? FloatingActionButton.small(
              onPressed: _refreshData,
              tooltip: 'Refresh Data',
              child: Icon(MdiIcons.refresh),
            )
          : null,
    );
  }

  Widget _buildMobileLayout() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView(
        padding: ResponsiveUtils.getResponsivePadding(context),
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 16),
          _buildStatsCards(),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 16),
          _buildRecentTreatments(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView(
        padding: ResponsiveUtils.getResponsivePadding(context),
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildStatsCards(),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: _buildRecentTreatments(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          children: [
            // Header section
            _buildDesktopHeader(),
            const SizedBox(height: 32),
            
            // Main content grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildStatsCards(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),

                    ],
                  ),
                ),
                const SizedBox(width: 32),
                
                // Right column
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildRecentTreatments(),

                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return ResponsiveCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              MdiIcons.leaf,
              size: 48,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Doctor',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your patients and treatments with ease',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton.filled(
                onPressed: _refreshData,
                icon: Icon(MdiIcons.refresh),
                tooltip: 'Refresh Data',
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () => _navigateToSettings(),
                icon: Icon(MdiIcons.cog),
                tooltip: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return EnhancedGradientCard(
      gradient: EnhancedAppTheme.getPrimaryGradient(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ResponsiveIcon(
                MdiIcons.leaf,
                color: Colors.white,
                mobileSize: 32,
                tabletSize: 36,
                desktopSize: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      'Welcome, Doctor',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      mobileFontSize: 20,
                      tabletFontSize: 24,
                      desktopFontSize: 28,
                    ),
                    ResponsiveText(
                      DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      mobileFontSize: 14,
                      tabletFontSize: 16,
                      desktopFontSize: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ResponsiveText(
            'Manage your patients and treatments with ease. Your holistic healthcare management system.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            mobileFontSize: 14,
            tabletFontSize: 16,
            desktopFontSize: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return ResponsiveGrid(
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 2,
      children: [
        EnhancedStatCard(
          icon: MdiIcons.accountGroup,
          title: 'Total Patients',
          value: _totalPatients.toString(),
          subtitle: 'Active patients in system',
          color: EnhancedAppTheme.primaryTeal,
          showTrend: true,
          trendValue: 5.2,
          onTap: () => _navigateToPatients(),
        ),
        EnhancedStatCard(
          icon: MdiIcons.stethoscope,
          title: 'Total Treatments',
          value: _totalTreatments.toString(),
          subtitle: 'Completed treatments',
          color: EnhancedAppTheme.secondaryAmber,
          showTrend: true,
          trendValue: 12.8,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return ResponsiveCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 8.0,
                  tablet: 12.0,
                  desktop: 16.0,
                )),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ResponsiveIcon(
                  icon,
                  color: color,
                  mobileSize: 24,
                  tabletSize: 28,
                  desktopSize: 32,
                ),
              ),
              const Spacer(),
              if (onTap != null)
                ResponsiveIcon(
                  MdiIcons.chevronRight,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  mobileSize: 20,
                  tabletSize: 22,
                  desktopSize: 24,
                ),
            ],
          ),
          const SizedBox(height: 16),
          ResponsiveText(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            mobileFontSize: 28,
            tabletFontSize: 32,
            desktopFontSize: 36,
          ),
          const SizedBox(height: 4),
          ResponsiveText(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            mobileFontSize: 14,
            tabletFontSize: 16,
            desktopFontSize: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return EnhancedInfoCard(
      title: 'Quick Actions',
      icon: MdiIcons.flash,
      color: EnhancedAppTheme.accentGreen,
      content: ResponsiveGrid(
        mobileColumns: 2,
        tabletColumns: 2,
        desktopColumns: 4,
        children: [
          EnhancedActionCard(
            icon: MdiIcons.accountPlus,
            title: 'Add Patient',
            subtitle: 'Register new patient',
            color: EnhancedAppTheme.primaryTeal,
            onPressed: () => _navigateToAddPatient(),
          ),
          EnhancedActionCard(
            icon: MdiIcons.accountGroup,
            title: 'View Patients',
            subtitle: 'Browse all patients',
            color: EnhancedAppTheme.secondaryAmber,
            onPressed: () => _navigateToPatients(),
          ),
          EnhancedActionCard(
            icon: MdiIcons.fileImport,
            title: 'Import Data',
            subtitle: 'Import from Excel',
            color: EnhancedAppTheme.infoBlue,
            onPressed: () => _importPatientsData(),
          ),
          EnhancedActionCard(
            icon: MdiIcons.cloudUpload,
            title: 'Backup',
            subtitle: 'Export to Excel',
            color: EnhancedAppTheme.accentGreen,
            onPressed: () => _exportPatientsData(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveUtils.getResponsiveValue(
            context,
            mobile: 16.0,
            tablet: 20.0,
            desktop: 24.0,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
      ),
      child: Column(
        children: [
          ResponsiveIcon(
            icon,
            mobileSize: 24,
            tabletSize: 28,
            desktopSize: 32,
          ),
          const SizedBox(height: 8),
          ResponsiveText(
            label,
            mobileFontSize: 12,
            tabletFontSize: 14,
            desktopFontSize: 14,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTreatments() {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ResponsiveText(
                  'Recent Treatments',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  mobileFontSize: 16,
                  tabletFontSize: 18,
                  desktopFontSize: 20,
                ),
              ),
              TextButton(
                onPressed: () => _navigateToPatients(),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_recentTreatments.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ResponsiveIcon(
                    MdiIcons.stethoscope,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    mobileSize: 48,
                    tabletSize: 56,
                    desktopSize: 64,
                  ),
                  const SizedBox(height: 8),
                  ResponsiveText(
                    'No recent treatments',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    mobileFontSize: 14,
                    tabletFontSize: 16,
                    desktopFontSize: 16,
                  ),
                ],
              ),
            )
          else
            ...List.generate(_recentTreatments.length, (index) {
              final treatment = _recentTreatments[index];
              return _buildTreatmentItem(treatment, index < _recentTreatments.length - 1);
            }),
        ],
      ),
    );
  }

  Widget _buildTreatmentItem(Treatment treatment, bool showDivider) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: ResponsiveIcon(
              MdiIcons.stethoscope,
              color: Theme.of(context).colorScheme.primary,
              mobileSize: 20,
              tabletSize: 22,
              desktopSize: 24,
            ),
          ),
          title: ResponsiveText(
            'Treatment Record',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            mobileFontSize: 14,
            tabletFontSize: 16,
            desktopFontSize: 16,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText(
                DateFormat('dd MMM yyyy').format(treatment.visitDate),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                mobileFontSize: 12,
                tabletFontSize: 14,
                desktopFontSize: 14,
              ),
              ResponsiveText(
                treatment.diagnosis,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                mobileFontSize: 12,
                tabletFontSize: 14,
                desktopFontSize: 14,
              ),
            ],
          ),
          trailing: ResponsiveIcon(
            MdiIcons.chevronRight,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            mobileSize: 20,
            tabletSize: 22,
            desktopSize: 24,
          ),
          onTap: () {
            // Navigate to treatment detail
          },
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }

  Widget _buildAnalyticsCard() {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'Analytics Overview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            mobileFontSize: 16,
            tabletFontSize: 18,
            desktopFontSize: 20,
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ResponsiveIcon(
                    MdiIcons.chartLine,
                    color: Theme.of(context).colorScheme.primary,
                    mobileSize: 48,
                    tabletSize: 56,
                    desktopSize: 64,
                  ),
                  const SizedBox(height: 8),
                  ResponsiveText(
                    'Analytics Coming Soon',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    mobileFontSize: 14,
                    tabletFontSize: 16,
                    desktopFontSize: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'Upcoming Appointments',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            mobileFontSize: 16,
            tabletFontSize: 18,
            desktopFontSize: 20,
          ),
          const SizedBox(height: 16),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ResponsiveIcon(
                    MdiIcons.calendar,
                    color: Theme.of(context).colorScheme.primary,
                    mobileSize: 48,
                    tabletSize: 56,
                    desktopSize: 64,
                  ),
                  const SizedBox(height: 8),
                  ResponsiveText(
                    'No upcoming appointments',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    mobileFontSize: 14,
                    tabletFontSize: 16,
                    desktopFontSize: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToPatients() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PatientListScreen()),
    );
    _loadDashboardData();
  }

  void _navigateToAddPatient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditPatientScreen()),
    );
    if (result == true) {
      _loadDashboardData();
    }
  }

  void _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    _loadDashboardData();
  }

  // Data import/export methods (simplified for brevity)
  // Export patients data to Excel
  Future<void> _exportPatientsData() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Exporting patient data...'),
            ],
          ),
        ),
      );

      // Fetch all patients
      final patients = await _patientFirestoreService.fetchPatientsOnce();

      if (patients.isEmpty) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No patient data to export'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Create Excel workbook
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Patients_Backup'];

      // Define headers
      final headers = [
        'ID',
        'Full Name',
        'Phone',
        'Email',
        'Gender',
        'Date of Birth',
        'Age',
        'Address',
        'Medical History',
        'Created At',
        'Updated At'
      ];

      // Add headers to the first row
      for (int i = 0; i < headers.length; i++) {
        var cell = sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('FF4CAF50'),
          fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
        );
      }

      // Add patient data
      for (int i = 0; i < patients.length; i++) {
        final patient = patients[i];
        final rowIndex = i + 1;

        final rowData = [
          patient.id,
          patient.fullName,
          patient.phone ?? '',
          patient.email ?? '',
          patient.gender,
          patient.dateOfBirth != null
              ? DateFormat('dd/MM/yyyy').format(patient.dateOfBirth!)
              : '',
          patient.displayAge.toString(),
          patient.address ?? '',
          patient.medicalHistory ?? '',
          DateFormat('dd/MM/yyyy HH:mm:ss').format(patient.createdAt),
          patient.updatedAt != null
              ? DateFormat('dd/MM/yyyy HH:mm:ss').format(patient.updatedAt!)
              : '',
        ];

        for (int j = 0; j < rowData.length; j++) {
          var cell = sheetObject.cell(
              CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex));
          cell.value = TextCellValue(rowData[j]);
        }
      }

      // Auto-fit columns
      for (int i = 0; i < headers.length; i++) {
        sheetObject.setColumnAutoFit(i);
      }

      // Generate file bytes
      var fileBytes = excel.save();

      // Get app directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'patients_backup_$timestamp.xlsx';
      final filePath = '${directory.path}/$fileName';

      // Save file
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes!);

      Navigator.pop(context); // Close loading dialog

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Patient data backup - ${patients.length} patients exported',
        subject: 'Patient Data Backup',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully exported ${patients.length} patients'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          action: SnackBarAction(
            label: 'Share Again',
            textColor: Colors.white,
            onPressed: () async {
              await Share.shareXFiles([XFile(filePath)]);
            },
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Import patients data from Excel
  Future<void> _importPatientsData() async {
    try {
      // Pick Excel file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return; // User canceled file picking
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Importing patient data...'),
            ],
          ),
        ),
      );

      final file = result.files.first;
      Uint8List? fileBytes;

      if (file.bytes != null) {
        fileBytes = file.bytes!;
      } else if (file.path != null) {
        fileBytes = await File(file.path!).readAsBytes();
      } else {
        throw Exception('Unable to read file');
      }

      // Parse Excel file
      var excel = Excel.decodeBytes(fileBytes);
      var table = excel.tables[excel.tables.keys.first];

      if (table == null || table.rows.isEmpty) {
        throw Exception('Excel file is empty or invalid');
      }

      // Validate headers
      final expectedHeaders = [
        'ID',
        'Full Name',
        'Phone',
        'Email',
        'Gender',
        'Date of Birth',
        'Age',
        'Address',
        'Medical History',
        'Created At',
        'Updated At'
      ];

      final headerRow = table.rows.first;
      final actualHeaders =
          headerRow.map((cell) => cell?.value?.toString() ?? '').toList();

      bool headersMatch = true;
      for (int i = 0;
          i < expectedHeaders.length && i < actualHeaders.length;
          i++) {
        if (actualHeaders[i] != expectedHeaders[i]) {
          headersMatch = false;
          break;
        }
      }

      if (!headersMatch) {
        Navigator.pop(context);
        _showImportErrorDialog(
            'Invalid file format. Please use a file exported from this app.');
        return;
      }

      // Parse patient data
      List<Patient> patientsToImport = [];
      List<String> errors = [];

      for (int i = 1; i < table.rows.length; i++) {
        final row = table.rows[i];

        try {
          if (row.length < expectedHeaders.length) {
            errors.add('Row ${i + 1}: Insufficient data columns');
            continue;
          }

          final fullName = row[1]?.value?.toString().trim();
          if (fullName == null || fullName.isEmpty) {
            errors.add('Row ${i + 1}: Full name is required');
            continue;
          }

          final gender = row[4]?.value?.toString().trim();
          if (gender == null || !['Male', 'Female', 'Other'].contains(gender)) {
            errors.add(
                'Row ${i + 1}: Invalid gender (must be Male, Female, or Other)');
            continue;
          }

          // Parse date of birth
          DateTime? dateOfBirth;
          final dobString = row[5]?.value?.toString().trim();
          if (dobString != null && dobString.isNotEmpty) {
            try {
              dateOfBirth = DateFormat('dd/MM/yyyy').parse(dobString);
            } catch (e) {
              errors.add(
                  'Row ${i + 1}: Invalid date format for Date of Birth (use dd/MM/yyyy)');
              continue;
            }
          }

          // Create patient object
          final patient = Patient(
            id: '${DateTime.now().millisecondsSinceEpoch}_$i',
            fullName: fullName,
            phone: row[2]?.value?.toString().trim(),
            email: row[3]?.value?.toString().trim(),
            gender: gender,
            dateOfBirth: dateOfBirth,
            address: row[7]?.value?.toString().trim(),
            medicalHistory: row[8]?.value?.toString().trim(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          patientsToImport.add(patient);
        } catch (e) {
          errors.add('Row ${i + 1}: ${e.toString()}');
        }
      }

      Navigator.pop(context); // Close loading dialog

      if (patientsToImport.isEmpty) {
        _showImportErrorDialog(
            'No valid patient records found in the file.', errors);
        return;
      }

      // Show confirmation dialog
      final shouldImport = await _showImportConfirmationDialog(
          patientsToImport.length, errors.length);

      if (!shouldImport) return;

      // Show importing progress
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Importing ${patientsToImport.length} patients...'),
            ],
          ),
        ),
      );

      // Import patients to Firestore
      int successCount = 0;
      List<String> importErrors = [];

      for (final patient in patientsToImport) {
        try {
          await _patientFirestoreService.addPatient(patient);
          successCount++;
        } catch (e) {
          importErrors
              .add('Failed to import ${patient.fullName}: ${e.toString()}');
        }
      }

      Navigator.pop(context); // Close importing dialog

      // Show result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Import completed: $successCount patients imported successfully${importErrors.isNotEmpty
                    ? ', ${importErrors.length} failed'
                    : ''}',
          ),
          backgroundColor: successCount > 0
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
        ),
      );

      // Refresh data
      _loadDashboardData();
    } catch (e) {
      Navigator.pop(context); // Close any open dialogs
      _showImportErrorDialog('Import failed: ${e.toString()}');
    }
  }

  Future<bool> _showImportConfirmationDialog(
      int validRecords, int errorCount) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Import'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ready to import $validRecords patient records.'),
                if (errorCount > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '$errorCount rows had errors and will be skipped.',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                    'This will add new patients to your database. Continue?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Import'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showImportErrorDialog(String message, [List<String>? errors]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline,
                color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            const Text('Import Error'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (errors != null && errors.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Errors:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 150,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    errors.take(10).join('\n') +
                        (errors.length > 10
                            ? '\n... and ${errors.length - 10} more errors'
                            : ''),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

