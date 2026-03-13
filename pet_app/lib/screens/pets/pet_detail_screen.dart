/// Pet Detail Screen

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/pet_provider.dart';
import '../../core/providers/adoption_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/utils/category_utils.dart';
import '../../core/providers/chat_provider.dart';

class PetDetailScreen extends StatefulWidget {
  final int petId;

  const PetDetailScreen({super.key, required this.petId});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPetDetails();
    });
  }

  Future<void> _loadPetDetails() async {
    await Provider.of<PetProvider>(context, listen: false)
        .fetchPetDetails(widget.petId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PetProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final pet = provider.selectedPet;
          if (pet == null) {
            return const Center(child: Text('Pet not found'));
          }

          return CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryGreen.withOpacity(0.8),
                          AppColors.primaryGreen,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Icon(
                              CategoryUtils.getCategoryIcon(pet.categoryName ?? ''),
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            pet.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${pet.categoryName ?? ''} • ${pet.breed ?? 'Unknown breed'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      _buildStatusBadge(pet.status),
                      const SizedBox(height: 16),
                      
                      // Quick Info
                      _buildQuickInfo(pet),
                      const SizedBox(height: 24),
                      
                      // About
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pet.description ?? 'No description available',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      
                      // Personality
                      if (pet.personality != null) ...[
                        Text(
                          'Personality',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pet.personality!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Compatibility
                      Text(
                        'Compatibility',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      _buildCompatibilityInfo(pet),
                      const SizedBox(height: 24),
                      
                      // Health Info
                      Text(
                        'Health Information',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      _buildHealthInfo(pet),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer2<PetProvider, AuthProvider>(
        builder: (context, petProv, authProv, child) {
          final pet = petProv.selectedPet;
          if (pet == null) return const SizedBox.shrink();

          final currentUserId = authProv.user?.id;
          final isOwner = pet.postedById != null && pet.postedById == currentUserId;

          return Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Message Owner button (not shown if viewing own pet)
                  if (!isOwner && pet.postedById != null) ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        context.push(
                          '/chat/${pet.postedById}',
                          extra: pet.postedByName ?? 'Owner',
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: Text('Message ${pet.postedByName ?? "Owner"}'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 46),
                        side: BorderSide(color: AppColors.primaryWarmBrown),
                        foregroundColor: AppColors.primaryWarmBrown,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (pet.isAvailable && !isOwner)
                    ElevatedButton(
                      onPressed: () => _showAdoptDialog(pet.id),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Adopt Now',
                          style: TextStyle(fontSize: 16)),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: AppColors.getStatusColor(status),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildQuickInfo(pet) {
    return Row(
      children: [
        _buildInfoCard(Icons.cake, 'Age', pet.ageString),
        const SizedBox(width: 12),
        _buildInfoCard(
          pet.gender == 'male' ? Icons.male : Icons.female,
          'Gender',
          pet.gender.toString().split('.').last,
        ),
        const SizedBox(width: 12),
        _buildInfoCard(Icons.straighten, 'Size', pet.size),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryGreen),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilityInfo(pet) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildChip(
          Icons.child_care,
          'Good with kids',
          pet.goodWithChildren,
        ),
        _buildChip(
          Icons.pets,
          'Good with pets',
          pet.goodWithOtherPets,
        ),
        _buildChip(
          Icons.directions_run,
          pet.activityLevel,
          true,
        ),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active 
            ? AppColors.primaryGreen.withOpacity(0.1) 
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? AppColors.primaryGreen : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: active ? AppColors.primaryGreen : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? AppColors.primaryGreen : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInfo(pet) {
    return Column(
      children: [
        _buildHealthRow('Vaccinated', pet.isVaccinated),
        _buildHealthRow('Neutered/Spayed', pet.isNeutered),
        _buildHealthRow('Microchipped', pet.isMicrochipped),
      ],
    );
  }

  Widget _buildHealthRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? AppColors.primaryGreen : Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
          Text(
            value ? 'Yes' : 'No',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: value ? AppColors.primaryGreen : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showAdoptDialog(int petId) {
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Adoption Request',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Message (optional)',
                  hintText: 'Tell us why you want to adopt this pet...',
                ),
              ),
              const SizedBox(height: 24),
              Consumer<AdoptionProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton(
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            final success = await provider.createRequest(
                              petId,
                              messageController.text,
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Adoption request submitted!'
                                        : provider.error ?? 'Request failed',
                                  ),
                                  backgroundColor: success
                                      ? AppColors.primaryGreen
                                      : AppColors.criticalRed,
                                ),
                              );
                            }
                          },
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit Request'),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
