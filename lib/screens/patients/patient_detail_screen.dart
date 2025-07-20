import 'package:ayurvedic_doctor_crm/services/patient_firestore_service.dart';
import 'package:ayurvedic_doctor_crm/services/treatment_firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ayurvedic_doctor_crm/models/patient.dart';
import 'package:ayurvedic_doctor_crm/models/treatment.dart';
import 'package:ayurvedic_doctor_crm/screens/patients/add_edit_patient_screen.dart';
import 'package:ayurvedic_doctor_crm/screens/treatments/add_edit_treatment_screen.dart';
import 'package:ayurvedic_doctor_crm/screens/treatments/treatment_detail_screen.dart';
import 'package:ayurvedic_doctor_crm/widgets/custom_app_bar.dart';
import 'package:ayurvedic_doctor_crm/widgets/loading_widget.dart';
import 'package:ayurvedic_doctor_crm/widgets/empty_state_widget.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Patient? _patient;
  List<Treatment> _treatments = [];
  bool _isLoading = true;
  bool _isTreatmentsLoading = false;
  
  final _patientService = PatientFirestoreService();
  final _treatmentService = TreatmentFirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPatientData();
    _setupTreatmentListener();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final patient = await _patientService.getPatientById(widget.patientId);
      if (mounted) {
        setState(() {
          _patient = patient;
        });
      }
    } catch (e) {
      debugPrint('Error loading patient data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading patient data: ${e.toString()}'),
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

  void _setupTreatmentListener() {
    _treatmentService.getTreatmentsByPatientId(widget.patientId).listen(
      (treatments) {
        if (mounted) {
          setState(() {
            _treatments = treatments;
            _isTreatmentsLoading = false;
          });
        }
      },
      onError: (error) {
        debugPrint('Error listening to treatments: $error');
        if (mounted) {
          setState(() {
            _isTreatmentsLoading = false;
          });
        }
      },
    );
  }

  Future<void> _refreshData() async {
    await _loadPatientData();
    // Treatments will be automatically updated via stream
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        appBar: CustomAppBar(title: 'Patient Details'),
        body: LoadingWidget(),
      );
    }

    if (_patient == null) {
      return const Scaffold(
        appBar: CustomAppBar(title: 'Patient Details'),
        body: EmptyStateWidget(
          icon: Icons.error_outline,
          title: 'Patient Not Found',
          subtitle: 'The requested patient could not be found.',
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: _patient!.fullName,
        actions: [
          IconButton(
            icon: Icon(MdiIcons.pencil),
            onPressed: () => _editPatient(),
            tooltip: 'Edit Patient',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(MdiIcons.delete,
                        color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 8),
                    Text(
                      'Delete Patient',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            _buildPatientHeader(),
            TabBar(
              controller: _tabController,
              tabs: [
                const Tab(text: 'Basic Info'),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Treatment History'),
                      if (_treatments.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_treatments.length}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBasicInfoTab(),
                  _buildTreatmentHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: () => _addTreatment(),
              tooltip: 'Add Treatment',
              child: Icon(MdiIcons.plus),
            )
          : null,
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              _patient!.fullName.isNotEmpty
                  ? _patient!.fullName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _patient!.fullName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _patient!.gender == 'Male'
                          ? MdiIcons.genderMale
                          : _patient!.gender == 'Female'
                              ? MdiIcons.genderFemale
                              : MdiIcons.genderMaleFemale,
                      size: 18,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_patient!.gender}, ${_patient!.displayAge} years',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                    ),
                  ],
                ),
                if (_patient!.phone != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        MdiIcons.phone,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _patient!.phone!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                ],
                // Add treatment count indicator
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        MdiIcons.stethoscope,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_treatments.length} Treatment${_treatments.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          'Contact Information',
          [
            if (_patient!.phone != null)
              _buildInfoRow(MdiIcons.phone, 'Phone', _patient!.phone!),
            if (_patient!.email != null)
              _buildInfoRow(MdiIcons.email, 'Email', _patient!.email!),
            if (_patient!.address != null)
              _buildInfoRow(MdiIcons.mapMarker, 'Address', _patient!.address!),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Personal Information',
          [
            _buildInfoRow(
                MdiIcons.genderMaleFemale, 'Gender', _patient!.gender),
            _buildInfoRow(
                MdiIcons.calendar, 'Age', '${_patient!.displayAge} years'),
            if (_patient!.dateOfBirth != null)
              _buildInfoRow(
                MdiIcons.cake,
                'Date of Birth',
                DateFormat('dd MMMM yyyy').format(_patient!.dateOfBirth!),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_patient!.medicalHistory != null &&
            _patient!.medicalHistory!.isNotEmpty)
          _buildInfoCard(
            'Medical History',
            [
              _buildInfoRow(
                MdiIcons.fileDocumentOutline,
                'History & Allergies',
                _patient!.medicalHistory!,
                isMultiline: true,
              ),
            ],
          ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Record Information',
          [
            _buildInfoRow(
              MdiIcons.clockOutline,
              'Created',
              DateFormat('dd MMM yyyy, hh:mm a').format(_patient!.createdAt),
            ),
            if (_patient!.updatedAt != null)
              _buildInfoRow(
                MdiIcons.update,
                'Last Updated',
                DateFormat('dd MMM yyyy, hh:mm a').format(_patient!.updatedAt!),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTreatmentHistoryTab() {
    if (_isTreatmentsLoading) {
      return const LoadingWidget(message: 'Loading treatments...');
    }

    if (_treatments.isEmpty) {
      return EmptyStateWidget(
        icon: MdiIcons.stethoscope,
        title: 'No Treatments Yet',
        subtitle: 'Add the first treatment record for this patient',
        actionText: 'Add Treatment',
        onActionPressed: () => _addTreatment(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _treatments.length,
      itemBuilder: (context, index) {
        final treatment = _treatments[index];
        return _buildTreatmentCard(treatment, index);
      },
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentCard(Treatment treatment, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewTreatment(treatment),
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
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      MdiIcons.stethoscope,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Treatment #${_treatments.length - index}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const Spacer(),
                            Text(
                              DateFormat('dd MMM yyyy').format(treatment.visitDate),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                        Text(
                          DateFormat('hh:mm a').format(treatment.visitDate),
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
              const SizedBox(height: 12),
              
              // Symptoms
              _buildTreatmentInfoRow(
                MdiIcons.accountInjury,
                'Symptoms',
                treatment.symptoms,
              ),
              
              // Diagnosis
              _buildTreatmentInfoRow(
                MdiIcons.clipboardText,
                'Diagnosis',
                treatment.diagnosis,
              ),
              
              // Medicines
              if (treatment.prescribedMedicines.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      MdiIcons.pill,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${treatment.prescribedMedicines.length} medicine(s) prescribed',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  treatment.prescribedMedicines
                      .map((m) => m.name)
                      .take(3)
                      .join(', ') +
                      (treatment.prescribedMedicines.length > 3 
                          ? ' and ${treatment.prescribedMedicines.length - 3} more...' 
                          : ''),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Treatment notes (if any)
              if (treatment.notes != null && treatment.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildTreatmentInfoRow(
                  MdiIcons.noteText,
                  'Notes',
                  treatment.notes!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTreatmentInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _editPatient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditPatientScreen(patient: _patient),
      ),
    );
    
    if (result == true) {
      _loadPatientData();
    }
  }

  void _addTreatment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddEditTreatmentScreen(patientId: widget.patientId),
      ),
    );
    
    // No need to manually refresh treatments as they are updated via stream
    if (result == true) {
      // Optional: Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Treatment added successfully'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  void _viewTreatment(Treatment treatment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TreatmentDetailScreen(treatmentId: treatment.id),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Patient'),
        content: Text(
          'Are you sure you want to delete ${_patient!.fullName}? This action cannot be undone and will also delete all associated treatment records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                // Show loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 16),
                        Text('Deleting patient...'),
                      ],
                    ),
                  ),
                );
                
                // Delete patient
                await _patientService.deletePatient(_patient!.id);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Patient deleted successfully'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                  Navigator.pop(context, true); // Return true to indicate deletion
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete patient: ${e.toString()}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}