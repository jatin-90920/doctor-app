import 'package:ayurvedic_doctor_crm/services/patient_firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ayurvedic_doctor_crm/services/patient_service.dart';
import 'package:ayurvedic_doctor_crm/models/patient.dart';
import 'package:ayurvedic_doctor_crm/screens/patients/add_edit_patient_screen.dart';
import 'package:ayurvedic_doctor_crm/screens/patients/patient_detail_screen.dart';
import 'package:ayurvedic_doctor_crm/widgets/custom_app_bar.dart';
import 'package:ayurvedic_doctor_crm/widgets/loading_widget.dart';
import 'package:ayurvedic_doctor_crm/widgets/empty_state_widget.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PatientFirestoreService _patientService = PatientFirestoreService();
  List<Patient> _patients = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  void _loadPatients() async {
    setState(() => _isLoading = true);
    final result = await _patientService.fetchPatientsOnce();
    setState(() {
      _patients = result;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Patient> get _filteredPatients {
    if (_searchQuery.isEmpty) return _patients;
    return _patients.where((patient) {
      return patient.fullName.toLowerCase().contains(_searchQuery) ||
          (patient.phone?.toLowerCase().contains(_searchQuery) ?? false) ||
          (patient.email?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Patients',
        actions: [
          IconButton(
            icon: Icon(MdiIcons.accountPlus),
            onPressed: () => _navigateToAddPatient(),
            tooltip: 'Add Patient',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : _filteredPatients.isEmpty
                    ? EmptyStateWidget(
                        icon: MdiIcons.accountGroup,
                        title: _searchQuery.isEmpty
                            ? 'No Patients Yet'
                            : 'No Patients Found',
                        subtitle: _searchQuery.isEmpty
                            ? 'Add your first patient to get started'
                            : 'Try adjusting your search criteria',
                        actionText: _searchQuery.isEmpty ? 'Add Patient' : null,
                        onActionPressed:
                            _searchQuery.isEmpty ? _navigateToAddPatient : null,
                      )
                    : _buildPatientList(_filteredPatients),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search patients by name, phone, or email...',
          prefixIcon: Icon(MdiIcons.magnify),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(MdiIcons.close),
                  onPressed: () {
                    _searchController.clear();
                    context.read<PatientService>().clearSearch();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildPatientList(List<Patient> patients) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient = patients[index];
        return _buildPatientCard(patient);
      },
    );
  }

  Widget _buildPatientCard(Patient patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToPatientDetail(patient),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  patient.fullName.isNotEmpty
                      ? patient.fullName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          patient.gender == 'Male'
                              ? MdiIcons.genderMale
                              : patient.gender == 'Female'
                                  ? MdiIcons.genderFemale
                                  : MdiIcons.genderMaleFemale,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${patient.gender}, ${patient.displayAge} years',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                    if (patient.phone != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            MdiIcons.phone,
                            size: 16,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            patient.phone!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, patient),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(MdiIcons.pencil),
                        const SizedBox(width: 8),
                        const Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(MdiIcons.delete,
                            color: Theme.of(context).colorScheme.error),
                        const SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAddPatient() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditPatientScreen(),
      ),
    );
  }

  void _navigateToPatientDetail(Patient patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(patientId: patient.id),
      ),
    );
  }

  void _handleMenuAction(String action, Patient patient) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddEditPatientScreen(patient: patient),
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(patient);
        break;
    }
  }

  void _showDeleteConfirmation(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Patient'),
        content: Text(
          'Are you sure you want to delete ${patient.fullName}? This action cannot be undone and will also delete all associated treatment records.',
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
                await _patientService.deletePatient(patient.id);
                _loadPatients();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Patient deleted successfully'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }
              } catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Failed to delete patient'),
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
