/// Pet Category Model

class PetCategory {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final String? typicalLifespan;
  final String? careDifficulty;
  final String? spaceRequirement;
  final String? activityNeeds;
  final int? petCount;

  PetCategory({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.typicalLifespan,
    this.careDifficulty,
    this.spaceRequirement,
    this.activityNeeds,
    this.petCount,
  });

  factory PetCategory.fromJson(Map<String, dynamic> json) {
    return PetCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      typicalLifespan: json['typical_lifespan'],
      careDifficulty: json['care_difficulty'],
      spaceRequirement: json['space_requirement'],
      activityNeeds: json['activity_needs'],
      petCount: json['pet_count'],
    );
  }
}
