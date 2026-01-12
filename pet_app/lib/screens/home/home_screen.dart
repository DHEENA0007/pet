/// Home Screen - Main navigation hub

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/pet_provider.dart';
import '../../core/providers/adoption_provider.dart';
import '../../widgets/pet_card.dart';
import '../../widgets/category_chip.dart';
import '../../core/utils/category_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final adoptionProvider = Provider.of<AdoptionProvider>(context, listen: false);
    
    await petProvider.fetchCategories();
    await petProvider.fetchPets();
    await adoptionProvider.fetchRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Adoption'),
        actions: [
          if (authProvider.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => context.push('/admin'),
              tooltip: 'Admin Dashboard',
            ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _buildSearchTab(),
          _buildMyPetsTab(),
          _buildProfileTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-pet'),
        icon: const Icon(Icons.add),
        label: const Text('Post Pet'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'My Pets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Consumer2<PetProvider, AdoptionProvider>(
      builder: (context, petProvider, adoptionProvider, child) {
        if (petProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                _buildWelcomeCard(),
                const SizedBox(height: 24),
                
                // Categories
                Text(
                  'Categories',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                _buildCategoryList(petProvider),
                const SizedBox(height: 24),
                
                // AI Recommendations
                if (adoptionProvider.recommendations.isNotEmpty) ...[
                  Text(
                    'Recommended for You',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  _buildRecommendations(adoptionProvider),
                  const SizedBox(height: 24),
                ],
                
                // Available Pets
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available Pets',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextButton(
                      onPressed: () => context.push('/pets'),
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildPetGrid(petProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.pets, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${authProvider.user?.firstName ?? authProvider.user?.username ?? 'Friend'}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find your perfect companion today',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(PetProvider provider) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CategoryChip(
                label: 'All',
                icon: Icons.apps,
                isSelected: _selectedCategory == null,
                onTap: () {
                  setState(() => _selectedCategory = null);
                  provider.fetchPets();
                },
              ),
            );
          }
          
          final category = provider.categories[index - 1];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CategoryChip(
              label: category.name,
              icon: _getCategoryIcon(category.name),
              isSelected: _selectedCategory == category.id,
              onTap: () {
                setState(() => _selectedCategory = category.id);
                provider.fetchPets(category: category.id);
              },
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    return CategoryUtils.getCategoryIcon(name);
  }

  Widget _buildRecommendations(AdoptionProvider provider) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.recommendations.take(5).length,
        itemBuilder: (context, index) {
          final rec = provider.recommendations[index];
          final pet = rec['pet'];
          final score = rec['compatibility_score'] as int;
          
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            child: Card(
              child: InkWell(
                onTap: () => context.push('/pets/${pet['id']}'),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Match Score Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: AppColors.secondaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$score% Match',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Pet Icon
                      Center(
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                          child: const Icon(
                            Icons.pets,
                            size: 30,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Pet Name
                      Text(
                        pet['name'] ?? 'Unknown',
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        pet['category_name'] ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetGrid(PetProvider provider) {
    final availablePets = provider.pets.where((p) => p.isAvailable).toList();
    
    if (availablePets.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.pets, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No pets available',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: availablePets.take(6).length,
      itemBuilder: (context, index) {
        return PetCard(pet: availablePets[index]);
      },
    );
  }

  Widget _buildSearchTab() {
    return Consumer<PetProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search pets...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  // Implement search
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.pets.where((p) => p.isAvailable).length,
                itemBuilder: (context, index) {
                  final pet = provider.pets.where((p) => p.isAvailable).toList()[index];
                  return _buildPetListItem(pet);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPetListItem(pet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
          child: const Icon(Icons.pets, color: AppColors.primaryGreen),
        ),
        title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${pet.categoryName ?? ''} • ${pet.ageString}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/pets/${pet.id}'),
      ),
    );
  }

  Widget _buildMyPetsTab() {
    return Consumer<PetProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: () async {
            await provider.fetchMyPets();
            await provider.fetchAdoptedPets();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // My Posted Pets
                Text(
                  'My Posted Pets',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                if (provider.myPets.isEmpty)
                  _buildEmptyState('You haven\'t posted any pets yet')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.myPets.length,
                    itemBuilder: (context, index) {
                      return _buildPetListItem(provider.myPets[index]);
                    },
                  ),
                const SizedBox(height: 24),
                
                // My Adopted Pets
                Text(
                  'Adopted Pets',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                if (provider.adoptedPets.isEmpty)
                  _buildEmptyState('You haven\'t adopted any pets yet')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.adoptedPets.length,
                    itemBuilder: (context, index) {
                      return _buildAdoptedPetItem(provider.adoptedPets[index]);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdoptedPetItem(pet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
          child: Icon(
            CategoryUtils.getCategoryIcon(pet.categoryName ?? ''),
            color: AppColors.primaryGreen,
          ),
        ),
        title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${pet.categoryName ?? ''} • ${pet.ageString}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.favorite, size: 14, color: AppColors.primaryGreen),
                const SizedBox(width: 4),
                Text(
                  'Tap to manage care',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        isThreeLine: true,
        onTap: () => context.push('/my-pets/${pet.id}'),
      ),
    );
  }


  Widget _buildProfileTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                    child: Text(
                      (user?.firstName?.isNotEmpty == true 
                          ? user!.firstName![0] 
                          : user?.username[0] ?? 'U').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullName.isNotEmpty == true 
                        ? user!.fullName 
                        : user?.username ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  if (user?.isAdmin == true) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ADMIN',
                        style: TextStyle(
                          color: AppColors.secondaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Menu Items
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () => context.push('/profile'),
          ),
          _buildMenuItem(
            icon: Icons.assignment_outlined,
            title: 'My Adoption Requests',
            onTap: () => context.push('/my-requests'),
          ),
          _buildMenuItem(
            icon: Icons.description_outlined,
            title: 'Download Reports',
            onTap: () => context.push('/reports'),
          ),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            color: AppColors.criticalRed,
            onTap: () async {
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color)),
        trailing: Icon(Icons.chevron_right, color: color ?? Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
