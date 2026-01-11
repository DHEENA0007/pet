/// Adoption Request Model

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
      petId: json['pet'] is int ? json['pet'] : json['pet']['id'],
      petName: json['pet_name'],
      petImage: json['pet_image'],
      userId: json['user'] is int ? json['user'] : json['user']['id'],
      userName: json['user_name'],
      userEmail: json['user_email'],
      status: json['status'],
      requestMessage: json['request_message'],
      adminNotes: json['admin_notes'],
      rejectionReason: json['rejection_reason'],
      compatibilityScore: json['compatibility_score'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      processedAt: json['processed_at'] != null ? DateTime.parse(json['processed_at']) : null,
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
