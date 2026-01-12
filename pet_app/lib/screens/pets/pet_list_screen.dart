/// Pet List Screen

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/pet_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/category_utils.dart';
import '../../widgets/pet_card.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  int? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<PetProvider>(context, listen: false);
    await provider.fetchCategories();
    await provider.fetchPets();
  }

  Future<void> _loadPets() async {
    await Provider.of<PetProvider>(context, listen: false)
        .fetchPets(category: _selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Pets'),
        actions: [
          // Category Filter
          Consumer<PetProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<int?>(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter by category',
                onSelected: (value) {
                  setState(() => _selectedCategory = value);
                  _loadPets();
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
      body: Consumer<PetProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final availablePets = provider.pets.where((p) => p.isAvailable).toList();

          if (availablePets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    _selectedCategory != null 
                        ? 'No pets in this category'
                        : 'No pets available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (_selectedCategory != null) ...[
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {
                        setState(() => _selectedCategory = null);
                        _loadPets();
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Filter'),
                    ),
                  ],
                ],
              ),
            );
          }

          return Column(
            children: [
              // Active Filter Chip
              if (_selectedCategory != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  child: Row(
                    children: [
                      Icon(
                        CategoryUtils.getCategoryIcon(
                          provider.categories
                              .firstWhere((c) => c.id == _selectedCategory)
                              .name,
                        ),
                        size: 18,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Showing: ${provider.categories.firstWhere((c) => c.id == _selectedCategory).name}',
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = null);
                          _loadPets();
                        },
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              // Pet Grid
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadPets,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: availablePets.length,
                    itemBuilder: (context, index) {
                      return PetCard(pet: availablePets[index]);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

