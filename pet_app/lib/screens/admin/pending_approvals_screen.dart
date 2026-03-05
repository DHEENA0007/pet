/// Pending Approvals Screen (Admin)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/pet_provider.dart';
import '../../core/utils/category_utils.dart';

class PendingApprovalsScreen extends StatefulWidget {
  const PendingApprovalsScreen({super.key});

  @override
  State<PendingApprovalsScreen> createState() => _PendingApprovalsScreenState();
}

class _PendingApprovalsScreenState extends State<PendingApprovalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPendingPets();
    });
  }

  Future<void> _loadPendingPets() async {
    await Provider.of<PetProvider>(context, listen: false)
        .fetchPets(status: 'pending');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        backgroundColor: AppColors.accentAmber,
      ),
      body: Consumer<PetProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final pendingPets = provider.pets.where((p) => p.isPending).toList();

          if (pendingPets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No pending approvals',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadPendingPets,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingPets.length,
              itemBuilder: (context, index) {
                final pet = pendingPets[index];
                return _buildPetCard(pet, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetCard(pet, PetProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.accentAmber.withOpacity(0.1),
              child: Icon(
                CategoryUtils.getCategoryIcon(pet.categoryName ?? ''),
                color: AppColors.accentAmber,
              ),
            ),
            title: Text(
              pet.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${pet.categoryName ?? 'Unknown'} • ${pet.breed ?? 'Unknown breed'}'),
                Text('Age: ${pet.ageString}'),
                Text('Posted by: ${pet.postedByName ?? 'Unknown'}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () => context.push('/pets/${pet.id}'),
            ),
          ),
          
          // Description
          if (pet.description != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                pet.description!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          
          // Action Buttons
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(pet.id, provider),
                    icon: const Icon(Icons.close, color: AppColors.criticalRed),
                    label: const Text(
                      'Reject',
                      style: TextStyle(color: AppColors.criticalRed),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.criticalRed),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approvePet(pet.id, provider),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approvePet(int petId, PetProvider provider) async {
    final success = await provider.approvePet(petId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Pet approved!' : 'Failed to approve'),
          backgroundColor: success ? AppColors.primaryGreen : AppColors.criticalRed,
        ),
      );
      if (success) {
        _loadPendingPets();
      }
    }
  }

  void _showRejectDialog(int petId, PetProvider provider) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Pet'),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Rejection Reason',
              hintText: 'Explain why this pet listing is rejected...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await provider.rejectPet(
                  petId,
                  reasonController.text,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Pet rejected' : 'Failed to reject'),
                      backgroundColor: success ? AppColors.accentAmber : AppColors.criticalRed,
                    ),
                  );
                  if (success) {
                    _loadPendingPets();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.criticalRed,
              ),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }
}
