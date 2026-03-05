/// Owner/Shelter Management Screen
/// Admin can manage pet owners and shelters

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/health_provider.dart';
import '../../models/health_models.dart';

class OwnerManagementScreen extends StatefulWidget {
  const OwnerManagementScreen({super.key});

  @override
  State<OwnerManagementScreen> createState() => _OwnerManagementScreenState();
}

class _OwnerManagementScreenState extends State<OwnerManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOwners();
    });
  }

  Future<void> _loadOwners() async {
    await Provider.of<HealthProvider>(context, listen: false).fetchOwners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owners & Shelters'),
        backgroundColor: AppColors.secondaryBlue,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showOwnerDialog(null),
        icon: const Icon(Icons.add),
        label: const Text('Add Owner'),
        backgroundColor: AppColors.secondaryBlue,
      ),
      body: Consumer<HealthProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.owners.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No owners or shelters registered',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadOwners,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.owners.length,
              itemBuilder: (context, index) {
                return _buildOwnerCard(provider.owners[index], provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOwnerCard(Owner owner, HealthProvider provider) {
    final bool isShelter = owner.ownerType == 'shelter';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isShelter 
              ? AppColors.secondaryBlue.withOpacity(0.1)
              : AppColors.primaryGreen.withOpacity(0.1),
          child: Icon(
            isShelter ? Icons.home_work : Icons.person,
            color: isShelter ? AppColors.secondaryBlue : AppColors.primaryGreen,
          ),
        ),
        title: Text(
          owner.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isShelter 
                    ? AppColors.secondaryBlue.withOpacity(0.1)
                    : AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                owner.ownerType.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isShelter ? AppColors.secondaryBlue : AppColors.primaryGreen,
                ),
              ),
            ),
            if (owner.email != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.email, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(owner.email!, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ],
            if (owner.phone != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(owner.phone!, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ],
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.criticalRed),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: AppColors.criticalRed)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showOwnerDialog(owner);
            } else if (value == 'delete') {
              _showDeleteConfirmation(owner, provider);
            }
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Owner owner, HealthProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Owner'),
        content: Text('Are you sure you want to delete "${owner.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.criticalRed),
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteOwner(owner.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Owner deleted' : 'Failed to delete'),
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

  void _showOwnerDialog(Owner? owner) {
    final isEditing = owner != null;
    final nameController = TextEditingController(text: owner?.name ?? '');
    final emailController = TextEditingController(text: owner?.email ?? '');
    final phoneController = TextEditingController(text: owner?.phone ?? '');
    final addressController = TextEditingController(text: owner?.address ?? '');
    String selectedType = owner?.ownerType ?? 'individual';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEditing ? 'Edit Owner' : 'Add Owner/Shelter'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type *',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'individual', child: Text('Individual')),
                      DropdownMenuItem(value: 'shelter', child: Text('Shelter')),
                      DropdownMenuItem(value: 'breeder', child: Text('Breeder')),
                      DropdownMenuItem(value: 'rescue', child: Text('Rescue Organization')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.location_on),
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
                            if (nameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Name is required'),
                                  backgroundColor: AppColors.criticalRed,
                                ),
                              );
                              return;
                            }

                            final data = {
                              'name': nameController.text,
                              'owner_type': selectedType,
                              'email': emailController.text.isNotEmpty ? emailController.text : null,
                              'phone': phoneController.text.isNotEmpty ? phoneController.text : null,
                              'address': addressController.text.isNotEmpty ? addressController.text : null,
                            };

                            bool success;
                            if (isEditing) {
                              success = await provider.updateOwner(owner.id, data);
                            } else {
                              success = await provider.createOwner(data);
                            }

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(success 
                                      ? isEditing ? 'Owner updated!' : 'Owner added!'
                                      : 'Operation failed'),
                                  backgroundColor: success 
                                      ? AppColors.primaryGreen 
                                      : AppColors.criticalRed,
                                ),
                              );
                            }
                          },
                    child: Text(isEditing ? 'Update' : 'Add'),
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
