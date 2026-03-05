/// Care Schedule Management Screen
/// Define and manage care schedules by pet category

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/health_provider.dart';
import '../../core/providers/pet_provider.dart';
import '../../core/utils/category_utils.dart';
import '../../models/health_models.dart';

class CareScheduleManagementScreen extends StatefulWidget {
  const CareScheduleManagementScreen({super.key});

  @override
  State<CareScheduleManagementScreen> createState() => _CareScheduleManagementScreenState();
}

class _CareScheduleManagementScreenState extends State<CareScheduleManagementScreen> {
  int? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    
    await petProvider.fetchCategories();
    await healthProvider.fetchCareSchedules(categoryId: _selectedCategory);
  }

  Future<void> _loadSchedules() async {
    await Provider.of<HealthProvider>(context, listen: false)
        .fetchCareSchedules(categoryId: _selectedCategory);
  }

  IconData _getCareTypeIcon(String type) {
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
      case 'training':
        return Icons.psychology;
      default:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Care Schedules'),
        backgroundColor: AppColors.primaryGreen,
        actions: [
          // Category Filter
          Consumer<PetProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<int?>(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter by category',
                onSelected: (value) {
                  setState(() => _selectedCategory = value);
                  _loadSchedules();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<int?>(
                    value: null,
                    child: Row(
                      children: [
                        Icon(Icons.apps, color: AppColors.primaryGreen),
                        SizedBox(width: 12),
                        Text('All Categories'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  ...provider.categories.map((cat) => PopupMenuItem<int>(
                        value: cat.id,
                        child: Row(
                          children: [
                            Icon(
                              CategoryUtils.getCategoryIcon(cat.name),
                              color: CategoryUtils.getCategoryColor(cat.name),
                            ),
                            const SizedBox(width: 12),
                            Text(cat.name),
                          ],
                        ),
                      )),
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddScheduleDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Schedule'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: Consumer<HealthProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.careSchedules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No care schedules defined',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add care schedules for different pet categories',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Group schedules by category
          final groupedSchedules = <String, List<CareSchedule>>{};
          for (var schedule in provider.careSchedules) {
            final key = schedule.categoryName ?? 'Unknown';
            groupedSchedules.putIfAbsent(key, () => []).add(schedule);
          }

          return RefreshIndicator(
            onRefresh: _loadSchedules,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedSchedules.length,
              itemBuilder: (context, index) {
                final category = groupedSchedules.keys.elementAt(index);
                final schedules = groupedSchedules[category]!;
                return _buildCategorySection(category, schedules, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(String category, List<CareSchedule> schedules, HealthProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: CategoryUtils.getCategoryColor(category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                CategoryUtils.getCategoryIcon(category),
                color: CategoryUtils.getCategoryColor(category),
              ),
              const SizedBox(width: 8),
              Text(
                category,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CategoryUtils.getCategoryColor(category),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Schedule Cards
        ...schedules.map((schedule) => _buildScheduleCard(schedule, provider)),
        
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildScheduleCard(CareSchedule schedule, HealthProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCareTypeIcon(schedule.careType),
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
                Text(
                  schedule.frequency,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              schedule.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: AppColors.criticalRed),
          onPressed: () => _showDeleteConfirmation(schedule, provider),
        ),
        isThreeLine: true,
        onTap: () => _showScheduleDetails(schedule),
      ),
    );
  }

  void _showScheduleDetails(CareSchedule schedule) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getCareTypeIcon(schedule.careType),
                  color: AppColors.primaryGreen,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.careType.toUpperCase().replaceAll('_', ' '),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        '${schedule.categoryName} • ${schedule.frequency}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Text(
              'Description',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(schedule.description),
            
            if (schedule.tips != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentAmber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb, color: AppColors.accentAmber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tips',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentAmber,
                            ),
                          ),
                          Text(schedule.tips!),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(CareSchedule schedule, HealthProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: Text('Delete ${schedule.careType} schedule for ${schedule.categoryName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.criticalRed),
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteCareSchedule(schedule.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Schedule deleted' : 'Failed to delete'),
                    backgroundColor: success ? AppColors.primaryGreen : AppColors.criticalRed,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddScheduleDialog() {
    final descriptionController = TextEditingController();
    final tipsController = TextEditingController();
    
    int? selectedCategoryId;
    String selectedCareType = 'feeding';
    String selectedFrequency = 'daily';

    final careTypes = ['feeding', 'grooming', 'exercise', 'cleaning', 'health_check', 'training'];
    final frequencies = ['daily', 'twice_daily', 'weekly', 'bi_weekly', 'monthly', 'quarterly', 'yearly'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Care Schedule'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category Selection
                  Consumer<PetProvider>(
                    builder: (context, petProvider, child) {
                      return DropdownButtonFormField<int>(
                        value: selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Pet Category *',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: petProvider.categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat.id,
                            child: Row(
                              children: [
                                Icon(
                                  CategoryUtils.getCategoryIcon(cat.name),
                                  size: 20,
                                  color: CategoryUtils.getCategoryColor(cat.name),
                                ),
                                const SizedBox(width: 8),
                                Text(cat.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() => selectedCategoryId = value);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Care Type
                  DropdownButtonFormField<String>(
                    value: selectedCareType,
                    decoration: const InputDecoration(
                      labelText: 'Care Type *',
                      prefixIcon: Icon(Icons.build),
                    ),
                    items: careTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(_getCareTypeIcon(type), size: 20),
                            const SizedBox(width: 8),
                            Text(type.toUpperCase().replaceAll('_', ' ')),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedCareType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Frequency
                  DropdownButtonFormField<String>(
                    value: selectedFrequency,
                    decoration: const InputDecoration(
                      labelText: 'Frequency *',
                      prefixIcon: Icon(Icons.repeat),
                    ),
                    items: frequencies.map((freq) {
                      return DropdownMenuItem(
                        value: freq,
                        child: Text(freq.toUpperCase().replaceAll('_', ' ')),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedFrequency = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description *',
                      hintText: 'Describe the care routine...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: tipsController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Tips (Optional)',
                      hintText: 'Helpful tips for this care routine...',
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
                            if (selectedCategoryId == null || descriptionController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill required fields'),
                                  backgroundColor: AppColors.criticalRed,
                                ),
                              );
                              return;
                            }

                            final success = await provider.createCareSchedule({
                              'category': selectedCategoryId,
                              'care_type': selectedCareType,
                              'frequency': selectedFrequency,
                              'description': descriptionController.text,
                              'tips': tipsController.text.isNotEmpty 
                                  ? tipsController.text 
                                  : null,
                            });

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(success 
                                      ? 'Schedule added!' 
                                      : 'Failed to add schedule'),
                                  backgroundColor: success 
                                      ? AppColors.primaryGreen 
                                      : AppColors.criticalRed,
                                ),
                              );
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
