/// Adoption Requests Model

class AdoptionRequest {
  final int id;
  final int petId;
  final String? petName;
  final String? petImage;
  final int userId;
  final String? userName;
  final String? userEmail;
  final String status;
  final String? requestMessage;
  final String? adminNotes;
  final String? rejectionReason;
  final int? compatibilityScore;
  final DateTime? createdAt;
  final DateTime? processedAt;

  AdoptionRequest({
    required this.id,
    required this.petId,
    this.petName,
    this.petImage,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.status,
    this.requestMessage,
    this.adminNotes,
    this.rejectionReason,
    this.compatibilityScore,
    this.createdAt,
    this.processedAt,
  });

  factory AdoptionRequest.fromJson(Map<String, dynamic> json) {
    return AdoptionRequest(
      id: json['id'],
      petId: json['pet'] ?? 0,
      petName: json['pet_name'],
      petImage: json['pet_image'],
      userId: json['user'] ?? 0,
      userName: json['user_name'],
      userEmail: json['user_email'],
      status: json['status'] ?? 'pending',
      requestMessage: json['request_message'],
      adminNotes: json['admin_notes'],
      rejectionReason: json['rejection_reason'],
      compatibilityScore: json['compatibility_score'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at']) 
          : null,
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}

/// Vaccination Record Model
class Vaccination {
  final int id;
  final int petId;
  final String? petName;
  final String vaccineName;
  final String? vaccineType;
  final DateTime administeredDate;
  final DateTime? nextDueDate;
  final String? administeredBy;
  final String? batchNumber;
  final String? notes;
  final bool isOverdue;
  final int? daysUntilDue;

  Vaccination({
    required this.id,
    required this.petId,
    this.petName,
    required this.vaccineName,
    this.vaccineType,
    required this.administeredDate,
    this.nextDueDate,
    this.administeredBy,
    this.batchNumber,
    this.notes,
    this.isOverdue = false,
    this.daysUntilDue,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      id: json['id'],
      petId: json['pet'] ?? 0,
      petName: json['pet_name'],
      vaccineName: json['vaccine_name'] ?? '',
      vaccineType: json['vaccine_type'],
      administeredDate: DateTime.parse(json['administered_date']),
      nextDueDate: json['next_due_date'] != null 
          ? DateTime.parse(json['next_due_date']) 
          : null,
      administeredBy: json['administered_by'],
      batchNumber: json['batch_number'],
      notes: json['notes'],
      isOverdue: json['is_overdue'] ?? false,
      daysUntilDue: json['days_until_due'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pet': petId,
      'vaccine_name': vaccineName,
      'vaccine_type': vaccineType,
      'administered_date': administeredDate.toIso8601String().split('T')[0],
      if (nextDueDate != null) 
        'next_due_date': nextDueDate!.toIso8601String().split('T')[0],
      'administered_by': administeredBy,
      'batch_number': batchNumber,
      'notes': notes,
    };
  }
}

/// Medical Record Model
class MedicalRecord {
  final int id;
  final int petId;
  final String? petName;
  final DateTime recordDate;
  final String recordType;
  final String? diagnosis;
  final String? treatment;
  final String? prescription;
  final String? vetName;
  final String? vetClinic;
  final String? notes;
  final String? attachment;

  MedicalRecord({
    required this.id,
    required this.petId,
    this.petName,
    required this.recordDate,
    required this.recordType,
    this.diagnosis,
    this.treatment,
    this.prescription,
    this.vetName,
    this.vetClinic,
    this.notes,
    this.attachment,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'],
      petId: json['pet'] ?? 0,
      petName: json['pet_name'],
      recordDate: DateTime.parse(json['record_date']),
      recordType: json['record_type'] ?? '',
      diagnosis: json['diagnosis'],
      treatment: json['treatment'],
      prescription: json['prescription'],
      vetName: json['vet_name'],
      vetClinic: json['vet_clinic'],
      notes: json['notes'],
      attachment: json['attachment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pet': petId,
      'record_date': recordDate.toIso8601String().split('T')[0],
      'record_type': recordType,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'prescription': prescription,
      'vet_name': vetName,
      'vet_clinic': vetClinic,
      'notes': notes,
    };
  }
}

/// Care Schedule Model
class CareSchedule {
  final int id;
  final int categoryId;
  final String? categoryName;
  final String careType;
  final String frequency;
  final String description;
  final String? tips;

  CareSchedule({
    required this.id,
    required this.categoryId,
    this.categoryName,
    required this.careType,
    required this.frequency,
    required this.description,
    this.tips,
  });

  factory CareSchedule.fromJson(Map<String, dynamic> json) {
    return CareSchedule(
      id: json['id'],
      categoryId: json['category'] ?? 0,
      categoryName: json['category_name'],
      careType: json['care_type'] ?? '',
      frequency: json['frequency'] ?? '',
      description: json['description'] ?? '',
      tips: json['tips'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': categoryId,
      'care_type': careType,
      'frequency': frequency,
      'description': description,
      'tips': tips,
    };
  }
}

/// Owner/Shelter Model
class Owner {
  final int id;
  final String name;
  final String ownerType;
  final String? email;
  final String? phone;
  final String? address;
  final DateTime? createdAt;

  Owner({
    required this.id,
    required this.name,
    required this.ownerType,
    this.email,
    this.phone,
    this.address,
    this.createdAt,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'],
      name: json['name'] ?? '',
      ownerType: json['owner_type'] ?? 'individual',
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'owner_type': ownerType,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }
}

/// Return Request Model
class ReturnRequest {
  final int id;
  final int petId;
  final String? petName;
  final int userId;
  final String? userName;
  final String reason;
  final String status;
  final String? adminNotes;
  final DateTime? createdAt;
  final DateTime? processedAt;

  ReturnRequest({
    required this.id,
    required this.petId,
    this.petName,
    required this.userId,
    this.userName,
    required this.reason,
    required this.status,
    this.adminNotes,
    this.createdAt,
    this.processedAt,
  });

  factory ReturnRequest.fromJson(Map<String, dynamic> json) {
    return ReturnRequest(
      id: json['id'],
      petId: json['pet'] ?? 0,
      petName: json['pet_name'],
      userId: json['user'] ?? 0,
      userName: json['user_name'],
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      adminNotes: json['admin_notes'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at']) 
          : null,
    );
  }
}
