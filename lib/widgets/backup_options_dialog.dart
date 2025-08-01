import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ayurvedic_doctor_crm/services/excel_backup_service.dart';

class BackupOptionsDialog extends StatefulWidget {
  const BackupOptionsDialog({super.key});

  @override
  State<BackupOptionsDialog> createState() => _BackupOptionsDialogState();
}

class _BackupOptionsDialogState extends State<BackupOptionsDialog> {
  final ExcelBackupService _backupService = ExcelBackupService();
  bool _isLoading = false;
  String _loadingMessage = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            MdiIcons.fileExcel,
            color: Colors.green,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text('Export Data to Excel'),
        ],
      ),
      content: _isLoading
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(_loadingMessage),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose what data to export:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                _buildBackupOption(
                  icon: MdiIcons.fileMultiple,
                  title: 'Complete Backup',
                  subtitle: 'All patients, treatments, and analysis',
                  color: Theme.of(context).colorScheme.primary,
                  onTap: _createComprehensiveBackup,
                ),
                const SizedBox(height: 12),
                _buildBackupOption(
                  icon: MdiIcons.accountGroup,
                  title: 'Patients Only',
                  subtitle: 'Patient records and basic information',
                  color: Theme.of(context).colorScheme.secondary,
                  onTap: _createPatientsBackup,
                ),
                const SizedBox(height: 12),
                _buildBackupOption(
                  icon: MdiIcons.stethoscope,
                  title: 'Treatments Only',
                  subtitle: 'Treatment records and prescriptions',
                  color: Theme.of(context).colorScheme.tertiary,
                  onTap: _createTreatmentsBackup,
                ),
                const SizedBox(height: 12),
                _buildBackupOption(
                  icon: MdiIcons.calendarRange,
                  title: 'Date Range Export',
                  subtitle: 'Select specific date range',
                  color: Colors.orange,
                  onTap: _showDateRangeDialog,
                ),
              ],
            ),
      actions: _isLoading
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
    );
  }

  Widget _buildBackupOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              MdiIcons.chevronRight,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createComprehensiveBackup() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Creating comprehensive backup...';
    });

    try {
      final filePath = await _backupService.createComprehensiveBackup();
      
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show success dialog
        _showSuccessDialog(
          'Complete Backup Created',
          'All patient data, treatments, and analysis have been exported successfully.',
          filePath,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to create comprehensive backup: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = '';
        });
      }
    }
  }

  Future<void> _createPatientsBackup() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Exporting patient data...';
    });

    try {
      final filePath = await _backupService.createPatientsBackup();
      
      if (mounted) {
        Navigator.of(context).pop();
        
        _showSuccessDialog(
          'Patients Backup Created',
          'All patient records have been exported successfully.',
          filePath,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to create patients backup: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = '';
        });
      }
    }
  }

  Future<void> _createTreatmentsBackup() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Exporting treatment data...';
    });

    try {
      final filePath = await _backupService.createTreatmentsBackup();
      
      if (mounted) {
        Navigator.of(context).pop();
        
        _showSuccessDialog(
          'Treatments Backup Created',
          'All treatment records have been exported successfully.',
          filePath,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to create treatments backup: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = '';
        });
      }
    }
  }

  Future<void> _showDateRangeDialog() async {
    final now = DateTime.now();
    final startDate = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year, now.month, 1),
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Select Start Date',
    );

    if (startDate == null) return;

    if (!mounted) return;

    final endDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: startDate,
      lastDate: now,
      helpText: 'Select End Date',
    );

    if (endDate == null) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Exporting data for selected date range...';
    });

    try {
      final filePath = await _backupService.createDateRangeBackup(startDate, endDate);
      
      if (mounted) {
        Navigator.of(context).pop();
        
        final dateRangeText = '${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}';
        _showSuccessDialog(
          'Date Range Export Created',
          'Data for $dateRangeText has been exported successfully.',
          filePath,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to create date range export: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = '';
        });
      }
    }
  }

  void _showSuccessDialog(String title, String message, String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              MdiIcons.checkCircle,
              color: Colors.green,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    MdiIcons.fileExcel,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      filePath.split('/').last,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await _backupService.shareBackupFile(
                  filePath,
                  'Ayurvedic Doctor CRM - $title',
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to share file: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            icon: Icon(MdiIcons.share),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              MdiIcons.alertCircle,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text('Export Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isLoading = false;
                _loadingMessage = '';
              });
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

