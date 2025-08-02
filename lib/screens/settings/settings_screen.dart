import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ayurvedic_doctor_crm/services/backup_service.dart';
import 'package:ayurvedic_doctor_crm/widgets/custom_app_bar.dart';
import 'package:ayurvedic_doctor_crm/widgets/loading_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? _backupStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBackupStats();
  }

  Future<void> _loadBackupStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await BackupService.getBackupStatistics();
      setState(() {
        _backupStats = stats;
      });
    } catch (e) {
      debugPrint('Error loading backup stats: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading settings...')
          : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildDataSection(),
                    const SizedBox(height: 16),
                    _buildBackupSection(),
                    const SizedBox(height: 16),
                    _buildExportSection(),
                    const SizedBox(height: 16),
                    _buildAboutSection(),
                  ],
                ),
            ),
          ),
    );
  }

  Widget _buildDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            if (_backupStats != null) ...[
              _buildStatRow(
                icon: MdiIcons.accountGroup,
                label: 'Total Patients',
                value: _backupStats!['total_patients'].toString(),
              ),
              const SizedBox(height: 8),
              _buildStatRow(
                icon: MdiIcons.stethoscope,
                label: 'Total Treatments',
                value: _backupStats!['total_treatments'].toString(),
              ),
              const SizedBox(height: 8),
              _buildStatRow(
                icon: MdiIcons.database,
                label: 'Database Size',
                value: _backupStats!['database_size'].toString(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup & Restore',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            _buildSettingsTile(
              icon: MdiIcons.cloudUpload,
              title: 'Create Backup',
              subtitle: 'Create a backup of all your data',
              onTap: _createBackup,
            ),
            const Divider(),
            _buildSettingsTile(
              icon: MdiIcons.restore,
              title: 'Restore from Backup',
              subtitle: 'Restore data from a backup file',
              onTap: _restoreBackup,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            _buildSettingsTile(
              icon: MdiIcons.fileExcelOutline,
              title: 'Export All Data',
              subtitle: 'Export all patients and treatments to Excel',
              onTap: _exportAllData,
            ),
            const Divider(),
            _buildSettingsTile(
              icon: MdiIcons.accountArrowRightOutline,
              title: 'Export Patients Only',
              subtitle: 'Export only patient information',
              onTap: _exportPatientsOnly,
            ),
            const Divider(),
            _buildSettingsTile(
              icon: MdiIcons.calendarExportOutline,
              title: 'Export by Date Range',
              subtitle: 'Export treatments for specific date range',
              onTap: _exportByDateRange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            _buildSettingsTile(
              icon: MdiIcons.information,
              title: 'App Version',
              subtitle: '1.0.0',
              onTap: null,
            ),
            const Divider(),
            _buildSettingsTile(
              icon: MdiIcons.leaf,
              title: 'Ayurvedic Doctor CRM',
              subtitle: 'Professional patient management system',
              onTap: null,
            ),
            const Divider(),
            _buildSettingsTile(
              icon: MdiIcons.heart,
              title: 'Made with Flutter',
              subtitle: 'Built for healthcare professionals',
              onTap: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      trailing: onTap != null
          ? Icon(
              MdiIcons.chevronRight,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )
          : null,
      onTap: onTap,
    );
  }

  Future<void> _createBackup() async {
    try {
      _showLoadingDialog('Creating backup...');
      
      final backupFile = await BackupService.createBackup();
      
      Navigator.pop(context); // Close loading dialog
      
      _showSuccessDialog(
        'Backup Created',
        'Backup file created successfully. Would you like to share it?',
        () async {
          await BackupService.shareFile(backupFile);
        },
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog('Failed to create backup: $e');
    }
  }

  Future<void> _restoreBackup() async {
    final confirmed = await _showConfirmationDialog(
      'Restore Backup',
      'This will replace all existing data. Are you sure you want to continue?',
    );
    
    if (!confirmed) return;
    
    try {
      final filePath = await BackupService.pickBackupFile();
      if (filePath == null) return;
      
      _showLoadingDialog('Restoring backup...');
      
      final success = await BackupService.restoreFromBackup(filePath);
      
      Navigator.pop(context); // Close loading dialog
      
      if (success) {
        _showSuccessDialog(
          'Backup Restored',
          'Data has been restored successfully.',
          () {
            _loadBackupStats();
          },
        );
      } else {
        _showErrorDialog('Failed to restore backup. Please check the file format.');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog('Failed to restore backup: $e');
    }
  }

  Future<void> _exportAllData() async {
    try {
      _showLoadingDialog('Exporting data...');
      
      final exportFile = await BackupService.exportToExcel();
      
      Navigator.pop(context); // Close loading dialog
      
      _showSuccessDialog(
        'Export Complete',
        'Data exported successfully. Would you like to share it?',
        () async {
          await BackupService.shareFile(exportFile);
        },
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog('Failed to export data: $e');
    }
  }

  Future<void> _exportPatientsOnly() async {
    try {
      _showLoadingDialog('Exporting patients...');
      
      final exportFile = await BackupService.exportPatientsOnly();
      
      Navigator.pop(context); // Close loading dialog
      
      _showSuccessDialog(
        'Export Complete',
        'Patients exported successfully. Would you like to share it?',
        () async {
          await BackupService.shareFile(exportFile);
        },
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog('Failed to export patients: $e');
    }
  }

  Future<void> _exportByDateRange() async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    );
    
    if (dateRange == null) return;
    
    try {
      _showLoadingDialog('Exporting treatments...');
      
      final exportFile = await BackupService.exportTreatmentsByDateRange(
        startDate: dateRange.start,
        endDate: dateRange.end,
      );
      
      Navigator.pop(context); // Close loading dialog
      
      _showSuccessDialog(
        'Export Complete',
        'Treatments exported successfully. Would you like to share it?',
        () async {
          await BackupService.shareFile(exportFile);
        },
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog('Failed to export treatments: $e');
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(String title, String message, VoidCallback? onAction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          if (onAction != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onAction();
              },
              child: const Text('Share'),
            ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}

