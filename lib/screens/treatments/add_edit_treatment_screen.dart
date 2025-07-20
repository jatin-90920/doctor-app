import 'package:ayurvedic_doctor_crm/services/treatment_firestore_service.dart';
import 'package:ayurvedic_doctor_crm/services/medicine_firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ayurvedic_doctor_crm/models/treatment.dart';
import 'package:ayurvedic_doctor_crm/models/medicine.dart';
import 'package:ayurvedic_doctor_crm/services/treatment_service.dart';
import 'package:ayurvedic_doctor_crm/widgets/custom_app_bar.dart';

class AddEditTreatmentScreen extends StatefulWidget {
  final String patientId;
  final Treatment? treatment;

  const AddEditTreatmentScreen({
    super.key,
    required this.patientId,
    this.treatment,
  });

  @override
  State<AddEditTreatmentScreen> createState() => _AddEditTreatmentScreenState();
}

class _AddEditTreatmentScreenState extends State<AddEditTreatmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  List<Medicine> _prescribedMedicines = [];
  bool _isLoading = false;

  // Add medicine service
  late final MedicineFirestoreService _medicineService;
  List<Medicine> _availableMedicines = [];
  bool _medicinesLoading = false;

  bool get _isEditing => widget.treatment != null;

  @override
  void initState() {
    super.initState();
    _medicineService = MedicineFirestoreService();
    _loadAvailableMedicines();
    if (_isEditing) {
      _populateFields();
    }
  }

  Future<void> _loadAvailableMedicines() async {
    setState(() => _medicinesLoading = true);
    try {
      _availableMedicines = await _medicineService.fetchMedicinesOnce();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load medicines: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _medicinesLoading = false);
      }
    }
  }

  void _populateFields() {
    final treatment = widget.treatment!;
    _selectedDate = treatment.visitDate;
    _symptomsController.text = treatment.symptoms;
    _diagnosisController.text = treatment.diagnosis;
    _notesController.text = treatment.notes ?? '';
    _prescribedMedicines = List.from(treatment.prescribedMedicines);
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _isEditing ? 'Edit Treatment' : 'Add Treatment',
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTreatment,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isLoading
                    ? Theme.of(context).disabledColor
                    : Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildVisitDateSection(),
            const SizedBox(height: 24),
            _buildSymptomsSection(),
            const SizedBox(height: 24),
            _buildDiagnosisSection(),
            const SizedBox(height: 24),
            _buildMedicinesSection(),
            const SizedBox(height: 24),
            _buildNotesSection(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitDateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visit Date',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date of Visit',
                  prefixIcon: Icon(MdiIcons.calendar),
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  DateFormat('dd MMMM yyyy').format(_selectedDate),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Symptoms',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _symptomsController,
              decoration: InputDecoration(
                labelText: 'Patient Symptoms *',
                prefixIcon: Icon(MdiIcons.accountInjury),
                border: const OutlineInputBorder(),
                hintText: 'Describe the symptoms presented by the patient...',
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter symptoms';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diagnosis',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _diagnosisController,
              decoration: InputDecoration(
                labelText: 'Diagnosis *',
                prefixIcon: Icon(MdiIcons.stethoscope),
                border: const OutlineInputBorder(),
                hintText: 'Enter your diagnosis...',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter diagnosis';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicinesSection() {
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
                    'Prescribed Medicines',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (_medicinesLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Row(
                    children: [
                      IconButton(
                        onPressed: _createNewMedicine,
                        icon: Icon(MdiIcons.plus),
                        tooltip: 'Create New Medicine',
                      ),
                      IconButton(
                        onPressed: _addExistingMedicine,
                        icon: Icon(MdiIcons.pillar),
                        tooltip: 'Add Existing Medicine',
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_prescribedMedicines.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      MdiIcons.pill,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No medicines prescribed yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: _createNewMedicine,
                          icon: Icon(MdiIcons.plus),
                          label: const Text('Create New'),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: _addExistingMedicine,
                          icon: Icon(MdiIcons.pillar),
                          label: const Text('Add Existing'),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              ...List.generate(_prescribedMedicines.length, (index) {
                return _buildMedicineCard(index);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineCard(int index) {
    final medicine = _prescribedMedicines[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    medicine.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Chip(
                  label: Text(
                    medicine.typeDisplayName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                IconButton(
                  onPressed: () => _editMedicinePrescription(index),
                  icon: Icon(MdiIcons.pencil, size: 18),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
                IconButton(
                  onPressed: () => _removeMedicine(index),
                  icon: Icon(MdiIcons.delete, size: 18),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dosage',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      Text(medicine.dosage),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duration',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      Text(medicine.duration),
                    ],
                  ),
                ),
              ],
            ),
            if (medicine.notes != null && medicine.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(medicine.notes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Notes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                prefixIcon: Icon(MdiIcons.noteTextOutline),
                border: const OutlineInputBorder(),
                hintText: 'Any additional instructions or observations...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTreatment,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                _isEditing ? 'Update Treatment' : 'Save Treatment',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _createNewMedicine() {
    _showMedicineDialog();
  }

  void _addExistingMedicine() {
    _showExistingMedicineDialog();
  }

  void _editMedicinePrescription(int index) {
    _showMedicineDialog(medicine: _prescribedMedicines[index], index: index);
  }

  void _removeMedicine(int index) {
    setState(() {
      _prescribedMedicines.removeAt(index);
    });
  }

  void _showMedicineDialog({Medicine? medicine, int? index}) {
    showDialog(
      context: context,
      builder: (context) => MedicineDialog(
        medicine: medicine,
        medicineService: _medicineService,
        onSave: (newMedicine) async {
          // Save to Firestore if it's a new medicine
          if (medicine == null) {
            try {
              await _medicineService.addMedicine(newMedicine);
              // Reload available medicines
              await _loadAvailableMedicines();
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to save medicine: $e'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
              return;
            }
          }

          setState(() {
            if (index != null) {
              _prescribedMedicines[index] = newMedicine;
            } else {
              _prescribedMedicines.add(newMedicine);
            }
          });
        },
      ),
    );
  }

  void _showExistingMedicineDialog() {
    showDialog(
      context: context,
      builder: (context) => ExistingMedicineDialog(
        availableMedicines: _availableMedicines,
        onMedicineSelected: (selectedMedicine) {
          // Show prescription dialog for the selected medicine
          _showPrescriptionDialog(selectedMedicine);
        },
      ),
    );
  }

  void _showPrescriptionDialog(Medicine baseMedicine) {
    showDialog(
      context: context,
      builder: (context) => PrescriptionDialog(
        baseMedicine: baseMedicine,
        onSave: (prescribedMedicine) {
          setState(() {
            _prescribedMedicines.add(prescribedMedicine);
          });
        },
      ),
    );
  }

  Future<void> _saveTreatment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final treatment = Treatment(
        id: _isEditing ? widget.treatment!.id : UniqueKey().toString(),
        patientId: widget.patientId,
        visitDate: _selectedDate,
        symptoms: _symptomsController.text.trim(),
        diagnosis: _diagnosisController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        prescribedMedicines: _prescribedMedicines,
        createdAt: _isEditing ? widget.treatment!.createdAt : DateTime.now(),
      );

      final firestoreService = TreatmentFirestoreService();

      if (_isEditing) {
        await firestoreService.updateTreatment(treatment);
      } else {
        await firestoreService.addTreatment(treatment);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Treatment updated successfully'
                : 'Treatment saved successfully',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Enhanced Medicine Dialog with Firestore integration
class MedicineDialog extends StatefulWidget {
  final Medicine? medicine;
  final Function(Medicine) onSave;
  final MedicineFirestoreService medicineService;

  const MedicineDialog({
    super.key,
    this.medicine,
    required this.onSave,
    required this.medicineService,
  });

  @override
  State<MedicineDialog> createState() => _MedicineDialogState();
}

class _MedicineDialogState extends State<MedicineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  MedicineType _selectedType = MedicineType.ayurvedic;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final medicine = widget.medicine!;
    _nameController.text = medicine.name;
    _selectedType = medicine.type;
    _dosageController.text = medicine.dosage;
    _durationController.text = medicine.duration;
    _notesController.text = medicine.notes ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.medicine != null ? 'Edit Medicine' : 'Add Medicine'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMedicineNameField(),
              const SizedBox(height: 16),
              _buildMedicineTypeField(),
              const SizedBox(height: 16),
              _buildDosageField(),
              const SizedBox(height: 16),
              _buildDurationField(),
              const SizedBox(height: 16),
              _buildNotesField(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveMedicine,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildMedicineNameField() {
    final treatmentService = context.read<TreatmentService>();
    final suggestions = _selectedType == MedicineType.ayurvedic
        ? treatmentService.getCommonAyurvedicMedicines()
        : treatmentService.getCommonAllopathicMedicines();

    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return suggestions.where((option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (selection) {
        _nameController.text = selection;
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        _nameController.text = controller.text;
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Medicine Name *',
            border: const OutlineInputBorder(),
            suffixIcon: Icon(MdiIcons.pill),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter medicine name';
            }
            return null;
          },
          onChanged: (value) {
            _nameController.text = value;
          },
        );
      },
    );
  }

  Widget _buildMedicineTypeField() {
    return DropdownButtonFormField<MedicineType>(
      value: _selectedType,
      decoration: const InputDecoration(
        labelText: 'Medicine Type *',
        border: OutlineInputBorder(),
      ),
      items: MedicineType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.name.toUpperCase()),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedType = value!;
          _nameController.clear();
        });
      },
    );
  }

  Widget _buildDosageField() {
    final treatmentService = context.read<TreatmentService>();
    final suggestions = treatmentService.getCommonDosageInstructions();

    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return suggestions.where((option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (selection) {
        _dosageController.text = selection;
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        _dosageController.text = controller.text;
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Dosage *',
            border: OutlineInputBorder(),
            hintText: 'e.g., 1 tablet twice daily',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter dosage';
            }
            return null;
          },
          onChanged: (value) {
            _dosageController.text = value;
          },
        );
      },
    );
  }

  Widget _buildDurationField() {
    final treatmentService = context.read<TreatmentService>();
    final suggestions = treatmentService.getCommonDurations();

    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return suggestions.where((option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (selection) {
        _durationController.text = selection;
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        _durationController.text = controller.text;
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Duration *',
            border: OutlineInputBorder(),
            hintText: 'e.g., 5 days',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter duration';
            }
            return null;
          },
          onChanged: (value) {
            _durationController.text = value;
          },
        );
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notes (Optional)',
        border: OutlineInputBorder(),
        hintText: 'Additional instructions...',
      ),
      maxLines: 2,
    );
  }

  void _saveMedicine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final treatmentService = context.read<TreatmentService>();
      final medicine = treatmentService.createMedicine(
        name: _nameController.text.trim(),
        type: _selectedType,
        dosage: _dosageController.text.trim(),
        duration: _durationController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      widget.onSave(medicine);
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save medicine: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// New dialog for selecting existing medicines
class ExistingMedicineDialog extends StatefulWidget {
  final List<Medicine> availableMedicines;
  final Function(Medicine) onMedicineSelected;

  const ExistingMedicineDialog({
    super.key,
    required this.availableMedicines,
    required this.onMedicineSelected,
  });

  @override
  State<ExistingMedicineDialog> createState() => _ExistingMedicineDialogState();
}

class _ExistingMedicineDialogState extends State<ExistingMedicineDialog> {
  String _searchQuery = '';
  MedicineType? _filterType;

  List<Medicine> get _filteredMedicines {
    return widget.availableMedicines.where((medicine) {
      final matchesSearch = medicine.name
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesType = _filterType == null || medicine.type == _filterType;
      return matchesSearch && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Existing Medicine'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            // Search and filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search medicines',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<MedicineType?>(
                  value: _filterType,
                  hint: const Text('Filter'),
                  items: [
                    const DropdownMenuItem<MedicineType?>(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...MedicineType.values.map((type) {
                      return DropdownMenuItem<MedicineType?>(
                        value: type,
                        child: Text(type.name.toUpperCase()),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterType = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Medicine list
            Expanded(
              child: _filteredMedicines.isEmpty
                  ? const Center(
                      child: Text('No medicines found'),
                    )
                  : ListView.builder(
                      itemCount: _filteredMedicines.length,
                      itemBuilder: (context, index) {
                        final medicine = _filteredMedicines[index];
                        return Card(
                          child: ListTile(
                            title: Text(medicine.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Type: ${medicine.typeDisplayName}'),
                                if (medicine.notes != null && medicine.notes!.isNotEmpty)
                                  Text('Notes: ${medicine.notes}'),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onMedicineSelected(medicine);
                              },
                              child: const Text('Select'),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// New dialog for setting prescription details for existing medicines
class PrescriptionDialog extends StatefulWidget {
  final Medicine baseMedicine;
  final Function(Medicine) onSave;

  const PrescriptionDialog({
    super.key,
    required this.baseMedicine,
    required this.onSave,
  });

  @override
  State<PrescriptionDialog> createState() => _PrescriptionDialogState();
}

class _PrescriptionDialogState extends State<PrescriptionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _dosageController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _dosageController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Prescribe ${widget.baseMedicine.name}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicine info
              Card(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.baseMedicine.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        'Type: ${widget.baseMedicine.typeDisplayName}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (widget.baseMedicine.notes != null && 
                          widget.baseMedicine.notes!.isNotEmpty)
                        Text(
                          'Medicine Notes: ${widget.baseMedicine.notes}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Prescription details
              _buildDosageField(),
              const SizedBox(height: 16),
              _buildDurationField(),
              const SizedBox(height: 16),
              _buildNotesField(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _savePrescription,
          child: const Text('Add to Prescription'),
        ),
      ],
    );
  }

  Widget _buildDosageField() {
    final treatmentService = context.read<TreatmentService>();
    final suggestions = treatmentService.getCommonDosageInstructions();

    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return suggestions.where((option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (selection) {
        _dosageController.text = selection;
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        _dosageController.text = controller.text;
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Dosage *',
            border: OutlineInputBorder(),
            hintText: 'e.g., 1 tablet twice daily',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter dosage';
            }
            return null;
          },
          onChanged: (value) {
            _dosageController.text = value;
          },
        );
      },
    );
  }

  Widget _buildDurationField() {
    final treatmentService = context.read<TreatmentService>();
    final suggestions = treatmentService.getCommonDurations();

    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return suggestions.where((option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (selection) {
        _durationController.text = selection;
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        _durationController.text = controller.text;
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Duration *',
            border: OutlineInputBorder(),
            hintText: 'e.g., 5 days',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter duration';
            }
            return null;
          },
          onChanged: (value) {
            _durationController.text = value;
          },
        );
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Prescription Notes (Optional)',
        border: OutlineInputBorder(),
        hintText: 'Additional instructions for this prescription...',
      ),
      maxLines: 3,
    );
  }

  void _savePrescription() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Create a new medicine instance for prescription with custom dosage/duration
    final prescribedMedicine = Medicine(
      id: UniqueKey().toString(), // New ID for prescription instance
      name: widget.baseMedicine.name,
      type: widget.baseMedicine.type,
      dosage: _dosageController.text.trim(),
      duration: _durationController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? widget.baseMedicine.notes
          : _notesController.text.trim(),
      // createdAt: DateTime.now(),
    );

    widget.onSave(prescribedMedicine);
    Navigator.pop(context);
  }
}