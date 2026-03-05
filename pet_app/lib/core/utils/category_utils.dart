/// Category Utils - Helper functions for category icons and colors
/// This centralizes the icon mapping for dynamic categories

import 'package:flutter/material.dart';

class CategoryUtils {
  /// Get icon for a category based on its name
  /// Handles common pet types with specific icons, defaults to pets icon for others
  static IconData getCategoryIcon(String name) {
    switch (name.toLowerCase().trim()) {
      case 'dog':
      case 'dogs':
        return Icons.pets;
      case 'cat':
      case 'cats':
        return Icons.catching_pokemon;
      case 'bird':
      case 'birds':
      case 'parrot':
      case 'parrots':
        return Icons.flutter_dash;
      case 'fish':
      case 'fishes':
      case 'aquatic':
        return Icons.water;
      case 'rabbit':
      case 'rabbits':
      case 'bunny':
        return Icons.cruelty_free;
      case 'hamster':
      case 'hamsters':
      case 'guinea pig':
      case 'rodent':
      case 'rodents':
        return Icons.pest_control_rodent;
      case 'turtle':
      case 'turtles':
      case 'tortoise':
        return Icons.egg;
      case 'snake':
      case 'snakes':
      case 'reptile':
      case 'reptiles':
      case 'lizard':
      case 'lizards':
        return Icons.pest_control;
      case 'horse':
      case 'horses':
      case 'pony':
        return Icons.agriculture;
      case 'cow':
      case 'cows':
      case 'cattle':
      case 'goat':
      case 'goats':
      case 'sheep':
        return Icons.agriculture;
      case 'pig':
      case 'pigs':
        return Icons.agriculture;
      case 'chicken':
      case 'chickens':
      case 'hen':
      case 'rooster':
      case 'poultry':
        return Icons.egg;
      case 'duck':
      case 'ducks':
      case 'goose':
      case 'geese':
        return Icons.water_drop;
      case 'exotic':
        return Icons.emoji_nature;
      case 'insect':
      case 'insects':
      case 'spider':
      case 'tarantula':
        return Icons.bug_report;
      default:
        return Icons.pets;
    }
  }

  /// Get a color for a category based on its name
  /// Provides visual distinction for different pet types
  static Color getCategoryColor(String name) {
    switch (name.toLowerCase().trim()) {
      case 'dog':
      case 'dogs':
        return const Color(0xFF8B4513); // Brown
      case 'cat':
      case 'cats':
        return const Color(0xFFFF8C00); // Orange
      case 'bird':
      case 'birds':
      case 'parrot':
      case 'parrots':
        return const Color(0xFF00CED1); // Cyan
      case 'fish':
      case 'fishes':
      case 'aquatic':
        return const Color(0xFF1E90FF); // Blue
      case 'rabbit':
      case 'rabbits':
      case 'bunny':
        return const Color(0xFFFFB6C1); // Pink
      case 'hamster':
      case 'hamsters':
      case 'guinea pig':
      case 'rodent':
      case 'rodents':
        return const Color(0xFFDEB887); // Tan
      case 'turtle':
      case 'turtles':
      case 'tortoise':
        return const Color(0xFF228B22); // Green
      case 'snake':
      case 'snakes':
      case 'reptile':
      case 'reptiles':
      case 'lizard':
      case 'lizards':
        return const Color(0xFF6B8E23); // Olive
      case 'exotic':
        return const Color(0xFF9932CC); // Purple
      case 'insect':
      case 'insects':
      case 'spider':
      case 'tarantula':
        return const Color(0xFF800080); // Purple
      case 'farm':
      case 'horse':
      case 'cow':
      case 'pig':
      case 'chicken':
      case 'duck':
        return const Color(0xFFA0522D); // Sienna
      default:
        return const Color(0xFF2E8B57); // SeaGreen
    }
  }

  /// Get difficulty color for care difficulty levels
  static Color getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return const Color(0xFF4CAF50); // Green
      case 'medium':
        return const Color(0xFFFFC107); // Amber
      case 'hard':
        return const Color(0xFFF44336); // Red
      default:
        return Colors.grey;
    }
  }

  /// Get an emoji representation for a category
  static String getCategoryEmoji(String name) {
    switch (name.toLowerCase().trim()) {
      case 'dog':
      case 'dogs':
        return '🐕';
      case 'cat':
      case 'cats':
        return '🐈';
      case 'bird':
      case 'birds':
      case 'parrot':
      case 'parrots':
        return '🦜';
      case 'fish':
      case 'fishes':
      case 'aquatic':
        return '🐠';
      case 'rabbit':
      case 'rabbits':
      case 'bunny':
        return '🐰';
      case 'hamster':
      case 'hamsters':
        return '🐹';
      case 'turtle':
      case 'turtles':
      case 'tortoise':
        return '🐢';
      case 'snake':
      case 'snakes':
        return '🐍';
      case 'horse':
      case 'horses':
        return '🐴';
      case 'exotic':
        return '🦎';
      default:
        return '🐾';
    }
  }
}
