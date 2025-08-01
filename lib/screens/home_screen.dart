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
import 'package:ayurvedic_doctor_crm/widgets/custom_app_bar.dart';
import 'package:ayurvedic_doctor_crm/widgets/loading_widget.dart';
import 'package:ayurvedic_doctor_crm/widgets/daily_report_widget.dart';
import 'package:ayurvedic_doctor_crm/widgets/backup_options_dialog.dart';
import 'package:ayurvedic_doctor_crm/models/treatment.dart';
import 'package:ayurvedic_doctor_crm/models/patient.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
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
    // Enable real-time updates
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
    // Refresh data when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _loadDashboardData();
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load patients from Firestore and get count
      final List<Patient> patients =
          await _patientFirestoreService.fetchPatientsOnce();
      _totalPatients = patients.length;

      // Load treatments from Firestore and get count
      final List<Treatment> treatments =
          await _treatmentFirestoreService.fetchTreatmentsOnce();
      _totalTreatments = treatments.length;

      // Get recent treatments (limit to 5)
      _recentTreatments = treatments.take(5).toList();
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      // Show error message to user
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

  // Alternative method using Stream (real-time updates)
  void _setupRealtimeListeners() {
    // Listen to patients stream for real-time patient count updates
    _patientFirestoreService.getPatientsStream().listen(
      (patients) {
        if (mounted) {
          setState(() {
            _totalPatients = patients.length;
          });
          debugPrint('Patients count updated in real-time: ${patients.length}');
        }
      },
      onError: (error) {
        debugPrint('Error listening to patients stream: $error');
      },
    );

    // Listen to treatments stream for real-time treatment count updates
    _treatmentFirestoreService.getTreatmentsStream().listen(
      (treatments) {
        if (mounted) {
          setState(() {
            _totalTreatments = treatments.length;
            _recentTreatments = treatments.take(5).toList();
          });
          debugPrint(
              'Treatments count updated in real-time: ${treatments.length}');
        }
      },
      onError: (error) {
        debugPrint('Error listening to treatments stream: $error');
      },
    );
  }

  // Manual refresh method
  Future<void> _refreshData() async {
    debugPrint('Manual refresh triggered');
    await _loadDashboardData();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Ayurvedic Doctor CRM',
        subtitle: 'Dashboard & Overview',
        showGradient: true,
        actions: [
          IconButton(
            icon: Icon(MdiIcons.cog),
            onPressed: () => _navigateToSettings(),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading dashboard...')
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 16),
                  _buildStatsCards(),
                  const SizedBox(height: 16),
                  const DailyReportWidget(),
                  const SizedBox(height: 16),
                  _buildQuickActions(),
                  const SizedBox(height: 16),
                  _buildRecentTreatments(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _refreshData,
        tooltip: 'Refresh Data',
        child: Icon(MdiIcons.refresh),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  MdiIcons.leaf,
                  size: 32,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, Doctor',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        DateFormat('EEEE, MMMM dd, yyyy')
                            .format(DateTime.now()),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withValues(alpha: 0.9),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Manage your patients and treatments with ease. Your holistic healthcare management system.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withValues(alpha: 0.9),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: MdiIcons.accountGroup,
            title: 'Total Patients',
            value: _totalPatients.toString(),
            color: Theme.of(context).colorScheme.primary,
            onTap: () => _navigateToPatients(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: MdiIcons.stethoscope,
            title: 'Total Treatments',
            value: _totalTreatments.toString(),
            color: Theme.of(context).colorScheme.secondary,
          ),
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
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(
                      MdiIcons.chevronRight,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: MdiIcons.accountPlus,
                    label: 'Add Patient',
                    onPressed: () => _navigateToAddPatient(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: MdiIcons.accountGroup,
                    label: 'View Patients',
                    onPressed: () => _navigateToPatients(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: MdiIcons.fileImport,
                    label: 'Import Data',
                    onPressed: () => _importPatientsData(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: MdiIcons.fileExcel,
                    label: 'Excel Backup',
                    onPressed: () => _showBackupOptionsDialog(),
                  ),
                ),
              ],
            ),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTreatments() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Treatments',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
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
                    Icon(
                      MdiIcons.stethoscope,
                      size: 48,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No recent treatments',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(_recentTreatments.length, (index) {
                final treatment = _recentTreatments[index];
                return _buildTreatmentItem(
                    treatment, index < _recentTreatments.length - 1);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentItem(Treatment treatment, bool showDivider) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(
              MdiIcons.stethoscope,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            'Treatment Record',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('dd MMM yyyy').format(treatment.visitDate),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                treatment.diagnosis,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          trailing: Icon(
            MdiIcons.chevronRight,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 20,
          ),
          onTap: () {
            // Navigate to treatment detail
          },
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }

  void _navigateToPatients() async {
    // Navigate and refresh when returning
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PatientListScreen(),
      ),
    );
    // Refresh data when returning from patient list
    _loadDashboardData();
  }

  void _navigateToAddPatient() async {
    // Navigate to add patient and refresh data when returning
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditPatientScreen(),
      ),
    );

    // Refresh dashboard data if a patient was added
    if (result == true) {
      _loadDashboardData();
    }
  }

  void _navigateToSettings() async {
    // Navigate and refresh when returning
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
    // Refresh data when returning from settings
    _loadDashboardData();
  }

  void _showBackupOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => const BackupOptionsDialog(),
    );
  }
}
