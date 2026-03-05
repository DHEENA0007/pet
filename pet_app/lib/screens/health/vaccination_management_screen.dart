/// Vaccination Management Screen
/// View and manage vaccination records for pets

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/health_provider.dart';
import '../../core/providers/pet_provider.dart';
import '../../models/health_models.dart';

class VaccinationManagementScreen extends StatefulWidget {
  final int? petId;
  final String? petName;

  const VaccinationManagementScreen({
    super.key,
    this.petId,
    this.petName,
  });

  @override
  State<VaccinationManagementScreen> createState() => _VaccinationManagementScreenState();
}

class _VaccinationManagementScreenState extends State<VaccinationManagementScreen> {
  bool _showDueOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVaccinations();
    });
  }

  Future<void> _loadVaccinations() async {
    final provider = Provider.of<HealthProvider>(context, listen: false);
    if (_showDueOnly) {
      await provider.fetchDueVaccinations();
    } else {
      await provider.fetchVaccinations(petId: widget.petId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.petName != null 
            ? '${widget.petName}\'s Vaccinations' 
            : 'Vaccination Records'),
        backgroundColor: AppColors.primaryGreen,
        actions: [
          if (widget.petId == null)
            IconButton(
              icon: Icon(_showDueOnly ? Icons.all_inclusive : Icons.alarm),
              tooltip: _showDueOnly ? 'Show All' : 'Show Due Soon',
              onPressed: () {
                setState(() => _showDueOnly = !_showDueOnly);
                _loadVaccinations();
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVaccinationDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Vaccination'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: Consumer<HealthProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.vaccinations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.vaccines, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    _showDueOnly 
                        ? 'No vaccinations due soon' 
                        : 'No vaccination records',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add vaccination records to track pet health',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadVaccinations,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.vaccinations.length,
              itemBuilder: (context, index) {
                return _buildVaccinationCard(provider.vaccinations[index], provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildVaccinationCard(Vaccination vaccination, HealthProvider provider) {
    final bool isOverdue = vaccination.isOverdue;
    final bool isDueSoon = vaccination.daysUntilDue != null && 
                           vaccination.daysUntilDue! <= 30 && 
                           !isOverdue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isOverdue 
                        ? AppColors.criticalRed.withOpacity(0.1)
                        : isDueSoon 
                            ? AppColors.accentAmber.withOpacity(0.1)
                            : AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.vaccines,
                    color: isOverdue 
                        ? AppColors.criticalRed
                        : isDueSoon 
                            ? AppColors.accentAmber
                            : AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vaccination.vaccineName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (vaccination.petName != null)
                        Text(
                          vaccination.petName!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.criticalRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'OVERDUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (isDueSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentAmber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${vaccination.daysUntilDue} days',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            
            // Details Grid
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildDetailItem(
                  Icons.calendar_today,
                  'Administered',
                  DateFormat('MMM d, yyyy').format(vaccination.administeredDate),
                ),
                if (vaccination.nextDueDate != null)
                  _buildDetailItem(
                    Icons.event,
                    'Next Due',
                    DateFormat('MMM d, yyyy').format(vaccination.nextDueDate!),
                  ),
                if (vaccination.administeredBy != null)
                  _buildDetailItem(
                    Icons.person,
                    'By',
                    vaccination.administeredBy!,
                  ),
                if (vaccination.vaccineType != null)
                  _buildDetailItem(
                    Icons.medical_information,
                    'Type',
                    vaccination.vaccineType!,
                  ),
              ],
            ),
            
            if (vaccination.notes != null && vaccination.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Notes: ${vaccination.notes}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  void _showAddVaccinationDialog() {
    final vaccineNameController = TextEditingController();
    final vaccineTypeController = TextEditingController();
    final administeredByController = TextEditingController();
    final batchNumberController = TextEditingController();
    final notesController = TextEditingController();
    
    DateTime selectedDate = DateTime.now();
    DateTime? nextDueDate;
    int? selectedPetId = widget.petId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Vaccination Record'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pet Selection (if not for specific pet)
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
                  
                  TextField(
                    controller: vaccineNameController,
                    decoration: const InputDecoration(
                      labelText: 'Vaccine Name *',
                      hintText: 'e.g., Rabies, Distemper',
                      prefixIcon: Icon(Icons.vaccines),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: vaccineTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Vaccine Type',
                      hintText: 'e.g., Core, Non-core',
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Date Picker
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Administered Date'),
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
                  
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Next Due Date'),
                    subtitle: Text(nextDueDate != null 
                        ? DateFormat('MMM d, yyyy').format(nextDueDate!) 
                        : 'Not set'),
                    trailing: const Icon(Icons.event),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 365)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setDialogState(() => nextDueDate = date);
                      }
                    },
                  ),
                  
                  TextField(
                    controller: administeredByController,
                    decoration: const InputDecoration(
                      labelText: 'Administered By',
                      hintText: 'Veterinarian name',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
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
                            if (selectedPetId == null || vaccineNameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill required fields'),
                                  backgroundColor: AppColors.criticalRed,
                                ),
                              );
                              return;
                            }

                            final success = await provider.createVaccination({
                              'pet': selectedPetId,
                              'vaccine_name': vaccineNameController.text,
                              'vaccine_type': vaccineTypeController.text.isNotEmpty 
                                  ? vaccineTypeController.text 
                                  : null,
                              'administered_date': selectedDate.toIso8601String().split('T')[0],
                              'next_due_date': nextDueDate?.toIso8601String().split('T')[0],
                              'administered_by': administeredByController.text.isNotEmpty 
                                  ? administeredByController.text 
                                  : null,
                              'batch_number': batchNumberController.text.isNotEmpty 
                                  ? batchNumberController.text 
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
                                      ? 'Vaccination added!' 
                                      : 'Failed to add vaccination'),
                                  backgroundColor: success 
                                      ? AppColors.primaryGreen 
                                      : AppColors.criticalRed,
                                ),
                              );
                              if (success) _loadVaccinations();
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
