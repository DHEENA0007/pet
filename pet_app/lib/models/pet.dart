/// Pet Model

class Pet {
  final int id;
  final String name;
  final int categoryId;
  final String? categoryName;
  final String? breed;
  final int ageYears;
  final int ageMonths;
  final String gender;
  final String size;
  final String? color;
  final double? weight;
  final String? description;
  final String? personality;
  final String? specialNeeds;
  final bool isVaccinated;
  final bool isNeutered;
  final bool isMicrochipped;
  final String? healthStatus;
  final String? primaryImage;
  final String status;
  final String? rejectionReason;
  final int? postedById;
  final String? postedByName;
  final int? currentOwnerId;
  final String? currentOwnerName;
  final bool goodWithChildren;
  final bool goodWithOtherPets;
  final String activityLevel;
  final String spaceRequirement;
  final DateTime? createdAt;
  final DateTime? approvedAt;
  final DateTime? adoptedAt;

  Pet({
    required this.id,
    required this.name,
    required this.categoryId,
    this.categoryName,
    this.breed,
    required this.ageYears,
    this.ageMonths = 0,
    required this.gender,
    required this.size,
    this.color,
    this.weight,
    this.description,
    this.personality,
    this.specialNeeds,
    this.isVaccinated = false,
    this.isNeutered = false,
    this.isMicrochipped = false,
    this.healthStatus,
    this.primaryImage,
    required this.status,
    this.rejectionReason,
    this.postedById,
    this.postedByName,
    this.currentOwnerId,
    this.currentOwnerName,
    this.goodWithChildren = true,
    this.goodWithOtherPets = true,
    this.activityLevel = 'medium',
    this.spaceRequirement = 'medium',
    this.createdAt,
    this.approvedAt,
    this.adoptedAt,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      categoryId: json['category'] is int ? json['category'] : json['category']['id'],
      categoryName: json['category_name'] ?? (json['category'] is Map ? json['category']['name'] : null),
      breed: json['breed'],
      ageYears: json['age_years'] ?? 0,
      ageMonths: json['age_months'] ?? 0,
      gender: json['gender'] ?? 'unknown',
      size: json['size'] ?? 'medium',
      color: json['color'],
      weight: json['weight'] != null ? double.tryParse(json['weight'].toString()) : null,
      description: json['description'],
      personality: json['personality'],
      specialNeeds: json['special_needs'],
      isVaccinated: json['is_vaccinated'] ?? false,
      isNeutered: json['is_neutered'] ?? false,
      isMicrochipped: json['is_microchipped'] ?? false,
      healthStatus: json['health_status'],
      primaryImage: json['primary_image'],
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
      postedById: json['posted_by'],
      postedByName: json['posted_by_name'],
      currentOwnerId: json['current_owner'],
      currentOwnerName: json['current_owner_name'],
      goodWithChildren: json['good_with_children'] ?? true,
      goodWithOtherPets: json['good_with_other_pets'] ?? true,
      activityLevel: json['activity_level'] ?? 'medium',
      spaceRequirement: json['space_requirement'] ?? 'medium',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      approvedAt: json['approved_at'] != null ? DateTime.parse(json['approved_at']) : null,
      adoptedAt: json['adopted_at'] != null ? DateTime.parse(json['adopted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': categoryId,
      'breed': breed,
      'age_years': ageYears,
      'age_months': ageMonths,
      'gender': gender,
      'size': size,
      'color': color,
      'weight': weight,
      'description': description,
      'personality': personality,
      'special_needs': specialNeeds,
      'is_vaccinated': isVaccinated,
      'is_neutered': isNeutered,
      'is_microchipped': isMicrochipped,
      'health_status': healthStatus,
      'good_with_children': goodWithChildren,
      'good_with_other_pets': goodWithOtherPets,
      'activity_level': activityLevel,
      'space_requirement': spaceRequirement,
    };
  }

  String get ageString {
    if (ageYears == 0) {
      return '$ageMonths months';
    } else if (ageMonths == 0) {
      return '$ageYears ${ageYears == 1 ? 'year' : 'years'}';
    } else {
      return '$ageYears ${ageYears == 1 ? 'year' : 'years'}, $ageMonths months';
    }
  }

  bool get isAvailable => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isAdopted => status == 'adopted';
}
