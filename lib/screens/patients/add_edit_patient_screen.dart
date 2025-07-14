import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ayurvedic_doctor_crm/models/patient.dart';
import 'package:ayurvedic_doctor_crm/services/patient_service.dart';
import 'package:ayurvedic_doctor_crm/widgets/custom_app_bar.dart';

class AddEditPatientScreen extends StatefulWidget {
  final Patient? patient;

  const AddEditPatientScreen({super.key, this.patient});

  @override
  State<AddEditPatientScreen> createState() => _AddEditPatientScreenState();
}

class _AddEditPatientScreenState extends State<AddEditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  String _selectedGender = 'Male';
  DateTime? _selectedDateOfBirth;
  bool _useAge = true;
  bool _isLoading = false;

  bool get _isEditing => widget.patient != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final patient = widget.patient!;
    _fullNameController.text = patient.fullName;
    _selectedGender = patient.gender;
    
    if (patient.age != null) {
      _ageController.text = patient.age.toString();
      _useAge = true;
    } else if (patient.dateOfBirth != null) {
      _selectedDateOfBirth = patient.dateOfBirth;
      _useAge = false;
    }
    
    _phoneController.text = patient.phone ?? '';
    _emailController.text = patient.email ?? '';
    _addressController.text = patient.address ?? '';
    _medicalHistoryController.text = patient.medicalHistory ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _isEditing ? 'Edit Patient' : 'Add Patient',
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePatient,
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
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildContactInfoSection(),
            const SizedBox(height: 24),
            _buildMedicalHistorySection(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(MdiIcons.account),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                labelText: 'Gender *',
                prefixIcon: Icon(MdiIcons.genderMaleFemale),
                border: const OutlineInputBorder(),
              ),
              items: ['Male', 'Female', 'Other'].map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Age'),
                    value: true,
                    groupValue: _useAge,
                    onChanged: (value) {
                      setState(() {
                        _useAge = value!;
                        if (_useAge) {
                          _selectedDateOfBirth = null;
                        } else {
                          _ageController.clear();
                        }
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Date of Birth'),
                    value: false,
                    groupValue: _useAge,
                    onChanged: (value) {
                      setState(() {
                        _useAge = value!;
                        if (_useAge) {
                          _selectedDateOfBirth = null;
                        } else {
                          _ageController.clear();
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            if (_useAge)
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Age',
                  prefixIcon: Icon(MdiIcons.calendar),
                  border: const OutlineInputBorder(),
                  suffixText: 'years',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final age = int.tryParse(value);
                    if (age == null || age < 0 || age > 150) {
                      return 'Please enter a valid age';
                    }
                  }
                  return null;
                },
              )
            else
              InkWell(
                onTap: _selectDateOfBirth,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: Icon(MdiIcons.calendar),
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDateOfBirth != null
                        ? DateFormat('dd/MM/yyyy').format(_selectedDateOfBirth!)
                        : 'Select date of birth',
                    style: TextStyle(
                      color: _selectedDateOfBirth != null
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(MdiIcons.phone),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(MdiIcons.email),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(MdiIcons.mapMarker),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalHistorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medical History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _medicalHistoryController,
              decoration: InputDecoration(
                labelText: 'Medical History & Allergies',
                prefixIcon: Icon(MdiIcons.fileDocumentOutline),
                border: const OutlineInputBorder(),
                hintText: 'e.g., Diabetes, Hypertension, Drug allergies...',
              ),
              maxLines: 4,
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
        onPressed: _isLoading ? null : _savePatient,
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
                _isEditing ? 'Update Patient' : 'Add Patient',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDateOfBirth = date;
      });
    }
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final patientService = context.read<PatientService>();
      
      int? age;
      DateTime? dateOfBirth;
      
      if (_useAge && _ageController.text.isNotEmpty) {
        age = int.parse(_ageController.text);
      } else if (!_useAge && _selectedDateOfBirth != null) {
        dateOfBirth = _selectedDateOfBirth;
      }

      bool success;
      if (_isEditing) {
        success = await patientService.updatePatient(
          id: widget.patient!.id,
          fullName: _fullNameController.text.trim(),
          age: age,
          dateOfBirth: dateOfBirth,
          gender: _selectedGender,
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          medicalHistory: _medicalHistoryController.text.trim().isEmpty ? null : _medicalHistoryController.text.trim(),
        );
      } else {
        success = await patientService.addPatient(
          fullName: _fullNameController.text.trim(),
          age: age,
          dateOfBirth: dateOfBirth,
          gender: _selectedGender,
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          medicalHistory: _medicalHistoryController.text.trim().isEmpty ? null : _medicalHistoryController.text.trim(),
        );
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing 
                    ? 'Patient updated successfully'
                    : 'Patient added successfully',
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing 
                    ? 'Failed to update patient'
                    : 'Failed to add patient',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

