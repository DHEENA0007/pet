/// My Adopted Pet Detail Screen
/// Shows full details of an adopted pet including care, vaccinations, medical history

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/pet_provider.dart';
import '../../core/providers/health_provider.dart';
import '../../core/utils/category_utils.dart';
import '../../models/pet.dart';

class MyAdoptedPetScreen extends StatefulWidget {
  final int petId;

  const MyAdoptedPetScreen({super.key, required this.petId});

  @override
  State<MyAdoptedPetScreen> createState() => _MyAdoptedPetScreenState();
}

class _MyAdoptedPetScreenState extends State<MyAdoptedPetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Pet? _pet;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    
    await petProvider.fetchPetDetails(widget.petId);
    _pet = petProvider.selectedPet;
    await healthProvider.fetchVaccinations(petId: widget.petId);
    await healthProvider.fetchMedicalRecords(petId: widget.petId);
    await healthProvider.fetchCareSchedules(categoryId: _pet?.categoryId);
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Pet')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_pet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Pet')),
        body: const Center(child: Text('Pet not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_pet!.name),
        backgroundColor: CategoryUtils.getCategoryColor(_pet!.categoryName ?? ''),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'return',
                child: Row(
                  children: [
                    Icon(Icons.assignment_return, color: AppColors.accentAmber),
                    SizedBox(width: 8),
                    Text('Request Return'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'return') {
                _showReturnDialog();
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Care'),
            Tab(text: 'Vaccines'),
            Tab(text: 'Medical'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildCareTab(),
          _buildVaccinationsTab(),
          _buildMedicalTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet Image/Icon
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: CategoryUtils.getCategoryColor(_pet!.categoryName ?? '').withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CategoryUtils.getCategoryIcon(_pet!.categoryName ?? ''),
                size: 80,
                color: CategoryUtils.getCategoryColor(_pet!.categoryName ?? ''),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Quick Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoChip(Icons.pets, _pet!.categoryName ?? 'Unknown'),
              _buildInfoChip(Icons.cake, _pet!.ageString),
              _buildInfoChip(
                _pet!.gender == 'male' ? Icons.male : Icons.female,
                _pet!.gender.toUpperCase(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Adoption Date
          Card(
            color: AppColors.primaryGreen.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: AppColors.primaryGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Adopted on',
                          style: TextStyle(color: AppColors.primaryGreen),
                        ),
                        Text(
                          _pet!.adoptedAt != null
                              ? DateFormat('MMMM d, yyyy').format(_pet!.adoptedAt!)
                              : 'N/A',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Description
          if (_pet!.description != null) ...[
            Text(
              'About ${_pet!.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_pet!.description!),
            const SizedBox(height: 16),
          ],
          
          // Personality
          if (_pet!.personality != null) ...[
            Text(
              'Personality',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_pet!.personality!),
            const SizedBox(height: 16),
          ],
          
          // Special Needs
          if (_pet!.specialNeeds != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentAmber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning, color: AppColors.accentAmber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Special Needs',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentAmber,
                          ),
                        ),
                        Text(_pet!.specialNeeds!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryGreen),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildCareTab() {
    return Consumer<HealthProvider>(
      builder: (context, provider, child) {
        if (provider.careSchedules.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No care schedule defined yet',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.careSchedules.length,
          itemBuilder: (context, index) {
            final schedule = provider.careSchedules[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCareIcon(schedule.careType),
                    color: AppColors.primaryGreen,
                  ),
                ),
                title: Text(
                  schedule.careType.toUpperCase().replaceAll('_', ' '),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.repeat, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(schedule.frequency.replaceAll('_', ' ')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(schedule.description),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  IconData _getCareIcon(String type) {
    switch (type.toLowerCase()) {
      case 'feeding':
        return Icons.restaurant;
      case 'grooming':
        return Icons.content_cut;
      case 'exercise':
        return Icons.directions_run;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'health_check':
        return Icons.health_and_safety;
      default:
        return Icons.schedule;
    }
  }

  Widget _buildVaccinationsTab() {
    return Consumer<HealthProvider>(
      builder: (context, provider, child) {
        if (provider.vaccinations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.vaccines, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No vaccination records',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.vaccinations.length,
          itemBuilder: (context, index) {
            final vaccine = provider.vaccinations[index];
            final isOverdue = vaccine.isOverdue;
            final isDueSoon = vaccine.daysUntilDue != null && 
                              vaccine.daysUntilDue! <= 30 && 
                              !isOverdue;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isOverdue 
                        ? AppColors.criticalRed.withOpacity(0.1)
                        : isDueSoon 
                            ? AppColors.accentAmber.withOpacity(0.1)
                            : AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
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
                title: Text(
                  vaccine.vaccineName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Given: ${DateFormat('MMM d, yyyy').format(vaccine.administeredDate)}'),
                    if (vaccine.nextDueDate != null)
                      Text(
                        'Due: ${DateFormat('MMM d, yyyy').format(vaccine.nextDueDate!)}',
                        style: TextStyle(
                          color: isOverdue 
                              ? AppColors.criticalRed 
                              : isDueSoon 
                                  ? AppColors.accentAmber 
                                  : null,
                          fontWeight: isOverdue || isDueSoon ? FontWeight.bold : null,
                        ),
                      ),
                  ],
                ),
                trailing: isOverdue
                    ? Container(
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
                    : isDueSoon
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentAmber,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${vaccine.daysUntilDue} days',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMedicalTab() {
    return Consumer<HealthProvider>(
      builder: (context, provider, child) {
        if (provider.medicalRecords.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medical_information, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No medical records',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.medicalRecords.length,
          itemBuilder: (context, index) {
            final record = provider.medicalRecords[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    color: AppColors.secondaryBlue,
                  ),
                ),
                title: Text(
                  record.recordType.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(DateFormat('MMM d, yyyy').format(record.recordDate)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (record.diagnosis != null) ...[
                          _buildRecordSection('Diagnosis', record.diagnosis!),
                          const SizedBox(height: 8),
                        ],
                        if (record.treatment != null) ...[
                          _buildRecordSection('Treatment', record.treatment!),
                          const SizedBox(height: 8),
                        ],
                        if (record.prescription != null) ...[
                          _buildRecordSection('Prescription', record.prescription!),
                          const SizedBox(height: 8),
                        ],
                        if (record.vetName != null)
                          Text(
                            'Vet: ${record.vetName}${record.vetClinic != null ? ' @ ${record.vetClinic}' : ''}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecordSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        Text(content),
      ],
    );
  }

  void _showReturnDialog() {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Return'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to return ${_pet!.name}? Please provide a reason.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason for Return',
                hintText: 'Please explain why you need to return this pet...',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<HealthProvider>(
            builder: (context, provider, child) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentAmber,
                ),
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        if (reasonController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please provide a reason'),
                              backgroundColor: AppColors.criticalRed,
                            ),
                          );
                          return;
                        }

                        final success = await provider.createReturnRequest(
                          widget.petId,
                          reasonController.text,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? 'Return request submitted'
                                  : 'Failed to submit request'),
                              backgroundColor: success
                                  ? AppColors.primaryGreen
                                  : AppColors.criticalRed,
                            ),
                          );
                          if (success) {
                            context.pop();
                          }
                        }
                      },
                child: const Text('Submit Request'),
              );
            },
          ),
        ],
      ),
    );
  }
}
