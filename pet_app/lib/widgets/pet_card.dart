/// Pet Card Widget

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../models/pet.dart';

class PetCard extends StatelessWidget {
  final Pet pet;

  const PetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/pets/${pet.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image/Icon Area
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getCategoryColor(pet.categoryName).withOpacity(0.2),
                      _getCategoryColor(pet.categoryName).withOpacity(0.4),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    // Pet Icon
                    Center(
                      child: Icon(
                        _getCategoryIcon(pet.categoryName),
                        size: 50,
                        color: _getCategoryColor(pet.categoryName),
                      ),
                    ),
                    
                    // Gender Badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          pet.gender == 'male' ? Icons.male : Icons.female,
                          size: 16,
                          color: pet.gender == 'male' 
                              ? Colors.blue 
                              : Colors.pink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Info Area
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pet.breed ?? pet.categoryName ?? '',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pet.ageString,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'dog':
        return Colors.brown;
      case 'cat':
        return Colors.orange;
      case 'bird':
        return Colors.blue;
      case 'rabbit':
        return Colors.pink;
      case 'fish':
        return Colors.cyan;
      default:
        return AppColors.primaryGreen;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.catching_pokemon;
      case 'bird':
        return Icons.flutter_dash;
      case 'rabbit':
        return Icons.cruelty_free;
      case 'fish':
        return Icons.water;
      default:
        return Icons.pets;
    }
  }
}
