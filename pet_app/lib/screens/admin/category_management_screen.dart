/// Category Management Screen - Admin only
/// Allows administrators to add, edit, and delete pet categories dynamically

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/providers/pet_provider.dart';
import '../../core/utils/category_utils.dart';
import '../../models/category.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    await Provider.of<PetProvider>(context, listen: false).fetchCategories();
  }

  void _showAddCategoryDialog() {
    _showCategoryDialog(null);
  }

  void _showEditCategoryDialog(PetCategory category) {
    _showCategoryDialog(category);
  }

  void _showCategoryDialog(PetCategory? category) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController = TextEditingController(text: category?.description ?? '');
    final lifespanController = TextEditingController(text: category?.typicalLifespan ?? '');
    
    String? selectedCareDifficulty = category?.careDifficulty;
    String? selectedSpaceRequirement = category?.spaceRequirement;
    String? selectedActivityNeeds = category?.activityNeeds;
    File? selectedImage;
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          
          Future<void> pickImage() async {
            final XFile? image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              setDialogState(() {
                selectedImage = File(image.path);
              });
            }
          }

          return AlertDialog(
            title: Text(isEditing ? 'Edit Category' : 'Add New Category'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image Picker
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                        image: selectedImage != null
                            ? DecorationImage(
                                image: FileImage(selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : (category?.icon != null && category!.icon!.isNotEmpty)
                                ? DecorationImage(
                                    image: NetworkImage(category.icon!.startsWith('http') 
                                        ? category.icon! 
                                        : '${ApiConstants.baseUrl.replaceAll('/api', '')}${category.icon}'),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                      ),
                      child: selectedImage == null && (category?.icon == null || category!.icon!.isEmpty)
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: Colors.grey.shade500),
                                Text('Add Icon', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Name
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category Name *',
                      hintText: 'e.g., Dog, Cat, Bird',
                      prefixIcon: Icon(Icons.category),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Brief description of this category',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Typical Lifespan
                  TextField(
                    controller: lifespanController,
                    decoration: const InputDecoration(
                      labelText: 'Typical Lifespan',
                      hintText: 'e.g., 10-15 years',
                      prefixIcon: Icon(Icons.timelapse),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Care Difficulty
                  DropdownButtonFormField<String>(
                    value: selectedCareDifficulty,
                    decoration: const InputDecoration(
                      labelText: 'Care Difficulty',
                      prefixIcon: Icon(Icons.fitness_center),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'easy', child: Text('Easy')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'hard', child: Text('Hard')),
                    ],
                    onChanged: (value) {
                      setDialogState(() => selectedCareDifficulty = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Space Requirement
                  DropdownButtonFormField<String>(
                    value: selectedSpaceRequirement,
                    decoration: const InputDecoration(
                      labelText: 'Space Requirement',
                      prefixIcon: Icon(Icons.home),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'small', child: Text('Small')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'large', child: Text('Large')),
                    ],
                    onChanged: (value) {
                      setDialogState(() => selectedSpaceRequirement = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Activity Needs
                  DropdownButtonFormField<String>(
                    value: selectedActivityNeeds,
                    decoration: const InputDecoration(
                      labelText: 'Activity Needs',
                      prefixIcon: Icon(Icons.directions_run),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Low')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'high', child: Text('High')),
                    ],
                    onChanged: (value) {
                      setDialogState(() => selectedActivityNeeds = value);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              Consumer<PetProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton(
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            if (nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Category name is required'),
                                  backgroundColor: AppColors.criticalRed,
                                ),
                              );
                              return;
                            }

                            final categoryData = {
                              'name': nameController.text.trim(),
                              'description': descriptionController.text.trim().isNotEmpty
                                  ? descriptionController.text.trim()
                                  : null,
                              'typical_lifespan': lifespanController.text.trim().isNotEmpty
                                  ? lifespanController.text.trim()
                                  : null,
                              'care_difficulty': selectedCareDifficulty,
                              'space_requirement': selectedSpaceRequirement,
                              'activity_needs': selectedActivityNeeds,
                            };

                            bool success;
                            if (isEditing) {
                              success = await provider.updateCategory(
                                category.id, 
                                categoryData,
                                imagePath: selectedImage?.path,
                              );
                            } else {
                              success = await provider.createCategory(
                                categoryData,
                                imagePath: selectedImage?.path,
                              );
                            }

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? isEditing
                                            ? 'Category updated successfully!'
                                            : 'Category added successfully!'
                                        : provider.error ?? 'Operation failed',
                                  ),
                                  backgroundColor: success
                                      ? AppColors.primaryGreen
                                      : AppColors.criticalRed,
                                ),
                              );
                            }
                          },
                    child: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEditing ? 'Update' : 'Add'),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(PetCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${category.name}"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.criticalRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.criticalRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. ${category.petCount ?? 0} pets use this category.',
                      style: const TextStyle(
                        color: AppColors.criticalRed,
                        fontSize: 12,
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<PetProvider>(
            builder: (context, provider, child) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.criticalRed,
                ),
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        final success = await provider.deleteCategory(category.id);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Category deleted successfully!'
                                    : provider.error ?? 'Failed to delete category',
                              ),
                              backgroundColor: success
                                  ? AppColors.primaryGreen
                                  : AppColors.criticalRed,
                            ),
                          );
                        }
                      },
                child: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Delete', style: TextStyle(color: Colors.white)),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    return CategoryUtils.getCategoryIcon(name);
  }

  Color _getDifficultyColor(String? difficulty) {
    return CategoryUtils.getDifficultyColor(difficulty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: AppColors.secondaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCategories,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCategoryDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: Consumer<PetProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No categories yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add your first pet category to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddCategoryDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Category'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadCategories,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon(category.name),
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Row(
                      children: [
                        if (category.petCount != null) ...[
                          Icon(
                            Icons.pets,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${category.petCount} pets',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (category.careDifficulty != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(category.careDifficulty)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              category.careDifficulty!.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getDifficultyColor(category.careDifficulty),
                              ),
                            ),
                          ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (category.description != null) ...[
                              Text(
                                category.description!,
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 16),
                            ],
                            // Category Details
                            Row(
                              children: [
                                if (category.typicalLifespan != null)
                                  Expanded(
                                    child: _buildDetailChip(
                                      Icons.timelapse,
                                      'Lifespan',
                                      category.typicalLifespan!,
                                    ),
                                  ),
                                if (category.spaceRequirement != null)
                                  Expanded(
                                    child: _buildDetailChip(
                                      Icons.home,
                                      'Space',
                                      category.spaceRequirement!,
                                    ),
                                  ),
                                if (category.activityNeeds != null)
                                  Expanded(
                                    child: _buildDetailChip(
                                      Icons.directions_run,
                                      'Activity',
                                      category.activityNeeds!,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _showEditCategoryDialog(category),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit'),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () => _showDeleteConfirmation(category),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.criticalRed,
                                  ),
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.secondaryBlue),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
