import 'dart:async';

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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  Patient? _patient;
  List<Treatment> _treatments = [];
  bool _isLoading = true;
  bool _isTreatmentsLoading = false;

  final _patientService = PatientFirestoreService();
  final _treatmentService = TreatmentFirestoreService();

  // Add stream subscription to manage it properly
  StreamSubscription<List<Treatment>>? _treatmentsSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add lifecycle observer
    _tabController = TabController(length: 2, vsync: this);
    _loadPatientData();
    _setupTreatmentListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    _tabController.dispose();
    _treatmentsSubscription?.cancel(); // Cancel subscription
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

  // Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh treatment listener when app resumes
      _setupTreatmentListener();
    }
  }

  // Updated method to properly manage stream subscription
  void _setupTreatmentListener() {
    setState(() => _isTreatmentsLoading = true);

    // Cancel existing subscription if any
    _treatmentsSubscription?.cancel();

    // Set up new subscription
    _treatmentsSubscription =
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading treatments: $error'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
    );
  }

  Future<void> _refreshData() async {
    await _loadPatientData();
    // Re-establish treatment listener on manual refresh
    _setupTreatmentListener();
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
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: _getMaxWidth(context), // Responsive max width
            ),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_treatments.length}',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
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
        ),
      ),
      // Enhanced FloatingActionButton - Always show when on treatment tab
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          return _tabController.index == 1
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Quick add treatment button - always visible
                    FloatingActionButton(
                      heroTag: "add_treatment",
                      onPressed: () => _addTreatment(),
                      tooltip: 'Add New Treatment',
                      child: Icon(MdiIcons.plus),
                    ),
                    const SizedBox(height: 16),
                    // Additional quick action - view all treatments summary
                    if (_treatments.isNotEmpty)
                      FloatingActionButton.small(
                        heroTag: "treatment_summary",
                        onPressed: () => _showTreatmentSummary(),
                        tooltip: 'Treatment Summary',
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        child: Icon(MdiIcons.chartLine, size: 20),
                      ),
                  ],
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }

  // Add this helper method to determine responsive max width
  double _getMaxWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 1200) {
      return 800.0; // Large desktop screens
    } else if (screenWidth > 800) {
      return 600.0; // Tablet and small desktop
    } else {
      return double.infinity; // Mobile - full width
    }
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
              style: const TextStyle(
                color: Colors.white,
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
                        color: Colors.white,
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
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_patient!.gender}, ${_patient!.displayAge} years',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
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
                // Enhanced treatment count indicator with more details
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
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
                    if (_treatments.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              MdiIcons.calendar,
                              size: 14,
                              color: Theme.of(context).colorScheme.onTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Last: ${DateFormat('dd MMM').format(_treatments.first.visitDate)}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onTertiary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
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
      itemCount: _treatments.length + 1, // +1 for the add button at the end
      itemBuilder: (context, index) {
        if (index == _treatments.length) {
          // Add treatment button at the end of the list
          return Container(
            margin: const EdgeInsets.only(
                top: 16, bottom: 80), // Extra bottom margin for FAB
            child: Card(
              child: InkWell(
                onTap: () => _addTreatment(),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        MdiIcons.plus,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add New Treatment',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Record another treatment session',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final treatment = _treatments[index];
        return _buildEnhancedTreatmentCard(treatment, index);
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

  // Enhanced treatment card with quick view details
  Widget _buildEnhancedTreatmentCard(Treatment treatment, int index) {
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
              // Header with treatment number and date
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const Spacer(),
                            // Visit Date - Enhanced
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    MdiIcons.calendar,
                                    size: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('dd MMM yyyy')
                                        .format(treatment.visitDate),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          DateFormat('hh:mm a').format(treatment.visitDate),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
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
              const SizedBox(height: 16),

              // Quick view details in a grid layout
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // First row: Symptoms and Diagnosis
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildQuickInfoItem(
                            MdiIcons.accountInjury,
                            'Symptoms',
                            treatment.symptoms,
                            Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickInfoItem(
                            MdiIcons.clipboardText,
                            'Diagnosis',
                            treatment.diagnosis,
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Second row: Charges and Medicine count
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickInfoItem(
                            MdiIcons.currencyInr,
                            'Charges',
                            treatment.treatmentCharge != null
                                ? '₹${treatment.treatmentCharge!.toStringAsFixed(0)}'
                                : 'Not specified',
                            Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickInfoItem(
                            MdiIcons.pill,
                            'Medicines',
                            '${treatment.prescribedMedicines.length} prescribed',
                            // Enhanced medicine badge color - more visible
                            const Color(
                                0xFF2E7D32), // Dark green for better visibility
                          ),
                        ),
                      ],
                    ),

                    // Medicine details if any
                    if (treatment.prescribedMedicines.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32)
                              .withValues(alpha: 0.1), // Enhanced visibility
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color:
                                const Color(0xFF2E7D32).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  MdiIcons.pill,
                                  size: 14,
                                  color: const Color(0xFF2E7D32),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Prescribed Medicines:',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: const Color(0xFF2E7D32),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ...treatment.prescribedMedicines.take(2).map(
                                  (medicine) => Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '• ${medicine.name}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 11,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          medicine.dosage,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontSize: 10,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (medicine.quantity != null &&
                                            medicine.quantity!.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline
                                                  .withValues(alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              medicine.quantity!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    fontSize: 9,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                            if (treatment.prescribedMedicines.length > 2)
                              Text(
                                '... and ${treatment.prescribedMedicines.length - 2} more',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ],

                    // Treatment notes (if any)
                    if (treatment.notes != null &&
                        treatment.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              MdiIcons.noteText,
                              size: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                treatment.notes!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontSize: 11,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInfoItem(
      IconData icon, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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

  // Updated _addTreatment method with explicit refresh
  void _addTreatment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddEditTreatmentScreen(patientId: widget.patientId),
      ),
    );

    // Force refresh the treatment stream when returning
    if (result == true) {
      // Re-establish the stream listener
      _setupTreatmentListener();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Treatment added successfully'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          action: SnackBarAction(
            label: 'Add Another',
            textColor: Theme.of(context).colorScheme.onPrimary,
            onPressed: () => _addTreatment(),
          ),
        ),
      );

      // Ensure we're on the treatment history tab
      if (_tabController.index != 1) {
        _tabController.animateTo(1);
      }
    } else {
      // Even if result is not true, refresh the stream to ensure data is up-to-date
      _setupTreatmentListener();
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

  void _showTreatmentSummary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(MdiIcons.chartLine),
            const SizedBox(width: 8),
            const Text('Treatment Summary'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryRow('Total Treatments', '${_treatments.length}'),
              _buildSummaryRow(
                  'First Visit',
                  _treatments.isNotEmpty
                      ? DateFormat('dd MMM yyyy')
                          .format(_treatments.last.visitDate)
                      : 'N/A'),
              _buildSummaryRow(
                  'Last Visit',
                  _treatments.isNotEmpty
                      ? DateFormat('dd MMM yyyy')
                          .format(_treatments.first.visitDate)
                      : 'N/A'),
              _buildSummaryRow('Total Medicines',
                  '${_treatments.fold<int>(0, (sum, t) => sum + t.prescribedMedicines.length)}'),
              _buildSummaryRow(
                  'Total Charges',
                  _treatments.where((t) => t.treatmentCharge != null).isNotEmpty
                      ? '₹${_treatments.where((t) => t.treatmentCharge != null).fold<double>(0, (sum, t) => sum + t.treatmentCharge!).toStringAsFixed(0)}'
                      : 'Not specified'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
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
                  Navigator.pop(
                      context, true); // Return true to indicate deletion
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Failed to delete patient: ${e.toString()}'),
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
