/// Medical Records Screen
/// View and manage medical history for pets

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/health_provider.dart';
import '../../core/providers/pet_provider.dart';
import '../../models/health_models.dart';

class MedicalRecordsScreen extends StatefulWidget {
  final int? petId;
  final String? petName;

  const MedicalRecordsScreen({
    super.key,
    this.petId,
    this.petName,
  });

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecords();
    });
  }

  Future<void> _loadRecords() async {
    await Provider.of<HealthProvider>(context, listen: false)
        .fetchMedicalRecords(petId: widget.petId);
  }

  IconData _getRecordTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'checkup':
        return Icons.health_and_safety;
      case 'surgery':
        return Icons.medical_services;
      case 'emergency':
        return Icons.emergency;
      case 'dental':
        return Icons.face;
      case 'vaccination':
        return Icons.vaccines;
      default:
        return Icons.description;
    }
  }

  Color _getRecordTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'checkup':
        return AppColors.primaryGreen;
      case 'surgery':
        return AppColors.secondaryBlue;
      case 'emergency':
        return AppColors.criticalRed;
      case 'dental':
        return Colors.purple;
      case 'vaccination':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.petName != null 
            ? '${widget.petName}\'s Medical History' 
            : 'Medical Records'),
        backgroundColor: AppColors.secondaryBlue,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRecordDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
        backgroundColor: AppColors.secondaryBlue,
      ),
      body: Consumer<HealthProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.medicalRecords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_information, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No medical records',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add medical records to track pet health history',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadRecords,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.medicalRecords.length,
              itemBuilder: (context, index) {
                return _buildRecordCard(provider.medicalRecords[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(MedicalRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getRecordTypeColor(record.recordType).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getRecordTypeIcon(record.recordType),
            color: _getRecordTypeColor(record.recordType),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                record.recordType.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              DateFormat('MMM d, y').format(record.recordDate),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        subtitle: record.petName != null
            ? Text(record.petName!)
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (record.diagnosis != null) ...[
                  _buildSection('Diagnosis', record.diagnosis!),
                  const SizedBox(height: 12),
                ],
                if (record.treatment != null) ...[
                  _buildSection('Treatment', record.treatment!),
                  const SizedBox(height: 12),
                ],
                if (record.prescription != null) ...[
                  _buildSection('Prescription', record.prescription!),
                  const SizedBox(height: 12),
                ],
                if (record.vetName != null || record.vetClinic != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_hospital, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (record.vetName != null)
                                Text(
                                  record.vetName!,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              if (record.vetClinic != null)
                                Text(
                                  record.vetClinic!,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (record.notes != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Notes: ${record.notes}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(content),
      ],
    );
  }

  void _showAddRecordDialog() {
    final diagnosisController = TextEditingController();
    final treatmentController = TextEditingController();
    final prescriptionController = TextEditingController();
    final vetNameController = TextEditingController();
    final vetClinicController = TextEditingController();
    final notesController = TextEditingController();
    
    DateTime selectedDate = DateTime.now();
    String selectedType = 'checkup';
    int? selectedPetId = widget.petId;

    final recordTypes = ['checkup', 'surgery', 'emergency', 'dental', 'vaccination', 'other'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Medical Record'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pet Selection
                  if (widget.petId == null)
                    Consumer<PetProvider>(
                      builder: (context, petProvider, child) {
                        return DropdownButtonFormField<int>(
                          value: selectedPetId,
                          decoration: const InputDecoration(
                            labelText: 'Select Pet *',
                            prefixIcon: Icon(Icons.pets),
                          ),
                          items: petProvider.pets.map((pet) {
                            return DropdownMenuItem(
                              value: pet.id,
                              child: Text(pet.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() => selectedPetId = value);
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  
                  // Record Type
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Record Type *',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: recordTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Date
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Record Date'),
                    subtitle: Text(DateFormat('MMM d, yyyy').format(selectedDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setDialogState(() => selectedDate = date);
                      }
                    },
                  ),
                  
                  TextField(
                    controller: diagnosisController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Diagnosis',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: treatmentController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Treatment',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: prescriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Prescription',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: vetNameController,
                          decoration: const InputDecoration(
                            labelText: 'Vet Name',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: vetClinicController,
                          decoration: const InputDecoration(
                            labelText: 'Clinic',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      alignLabelWithHint: true,
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
              Consumer<HealthProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton(
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            if (selectedPetId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a pet'),
                                  backgroundColor: AppColors.criticalRed,
                                ),
                              );
                              return;
                            }

                            final success = await provider.createMedicalRecord({
                              'pet': selectedPetId,
                              'record_type': selectedType,
                              'record_date': selectedDate.toIso8601String().split('T')[0],
                              'diagnosis': diagnosisController.text.isNotEmpty 
                                  ? diagnosisController.text 
                                  : null,
                              'treatment': treatmentController.text.isNotEmpty 
                                  ? treatmentController.text 
                                  : null,
                              'prescription': prescriptionController.text.isNotEmpty 
                                  ? prescriptionController.text 
                                  : null,
                              'vet_name': vetNameController.text.isNotEmpty 
                                  ? vetNameController.text 
                                  : null,
                              'vet_clinic': vetClinicController.text.isNotEmpty 
                                  ? vetClinicController.text 
                                  : null,
                              'notes': notesController.text.isNotEmpty 
                                  ? notesController.text 
                                  : null,
                            });

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(success 
                                      ? 'Record added!' 
                                      : 'Failed to add record'),
                                  backgroundColor: success 
                                      ? AppColors.primaryGreen 
                                      : AppColors.criticalRed,
                                ),
                              );
                              if (success) _loadRecords();
                            }
                          },
                    child: const Text('Add'),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
