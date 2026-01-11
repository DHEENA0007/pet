"""
AI-Enabled Pet Adoption & Care Management System - Serializers
REST API serializers for all models
"""

from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from .models import (
    User, PetCategory, Owner, Pet, PetImage, AdoptionRequest,
    ReturnRequest, Vaccination, MedicalRecord, CareSchedule,
    CareLog, Notification, AuditLog
)


class UserRegistrationSerializer(serializers.ModelSerializer):
    """Serializer for user registration"""
    
    password = serializers.CharField(write_only=True, validators=[validate_password])
    password2 = serializers.CharField(write_only=True)
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'password', 'password2',
            'first_name', 'last_name', 'phone', 'address',
            'living_space', 'has_yard', 'has_children', 'has_other_pets',
            'activity_level', 'experience_with_pets'
        ]
    
    def validate(self, attrs):
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": "Passwords don't match"})
        return attrs
    
    def create(self, validated_data):
        validated_data.pop('password2')
        user = User.objects.create_user(**validated_data)
        return user


class UserSerializer(serializers.ModelSerializer):
    """Serializer for user profile"""
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name',
            'phone', 'address', 'profile_image', 'role',
            'living_space', 'has_yard', 'has_children', 'has_other_pets',
            'activity_level', 'experience_with_pets', 'created_at'
        ]
        read_only_fields = ['id', 'username', 'role', 'created_at']


class UserProfileUpdateSerializer(serializers.ModelSerializer):
    """Serializer for updating user profile with lifestyle details"""
    
    class Meta:
        model = User
        fields = [
            'first_name', 'last_name', 'phone', 'address', 'profile_image',
            'living_space', 'has_yard', 'has_children', 'has_other_pets',
            'activity_level', 'experience_with_pets'
        ]


class PetCategorySerializer(serializers.ModelSerializer):
    """Serializer for pet categories"""
    
    pet_count = serializers.SerializerMethodField()
    
    class Meta:
        model = PetCategory
        fields = [
            'id', 'name', 'description', 'icon',
            'typical_lifespan', 'care_difficulty', 'space_requirement',
            'activity_needs', 'pet_count', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']
    
    def get_pet_count(self, obj):
        return obj.pets.filter(status='approved').count()


class OwnerSerializer(serializers.ModelSerializer):
    """Serializer for owners/shelters"""
    
    class Meta:
        model = Owner
        fields = [
            'id', 'name', 'owner_type', 'email', 'phone',
            'address', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class PetImageSerializer(serializers.ModelSerializer):
    """Serializer for pet images"""
    
    class Meta:
        model = PetImage
        fields = ['id', 'pet', 'image', 'caption', 'is_primary', 'created_at']
        read_only_fields = ['id', 'created_at']


class PetListSerializer(serializers.ModelSerializer):
    """Serializer for pet list view (minimal data)"""
    
    category_name = serializers.CharField(source='category.name', read_only=True)
    posted_by_name = serializers.CharField(source='posted_by.username', read_only=True)
    
    class Meta:
        model = Pet
        fields = [
            'id', 'name', 'category', 'category_name', 'breed',
            'age_years', 'age_months', 'gender', 'size',
            'primary_image', 'status', 'posted_by_name', 'created_at'
        ]


class PetDetailSerializer(serializers.ModelSerializer):
    """Serializer for pet detail view (full data)"""
    
    category_name = serializers.CharField(source='category.name', read_only=True)
    posted_by_name = serializers.CharField(source='posted_by.username', read_only=True)
    previous_owner_name = serializers.CharField(source='previous_owner.name', read_only=True)
    current_owner_name = serializers.CharField(source='current_owner.username', read_only=True)
    images = PetImageSerializer(many=True, read_only=True)
    vaccination_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Pet
        fields = [
            'id', 'name', 'category', 'category_name', 'breed',
            'age_years', 'age_months', 'gender', 'size', 'color', 'weight',
            'description', 'personality', 'special_needs',
            'is_vaccinated', 'is_neutered', 'is_microchipped', 'health_status',
            'primary_image', 'images',
            'status', 'rejection_reason',
            'posted_by', 'posted_by_name', 'previous_owner', 'previous_owner_name',
            'current_owner', 'current_owner_name',
            'good_with_children', 'good_with_other_pets',
            'activity_level', 'space_requirement',
            'vaccination_count',
            'created_at', 'approved_at', 'adopted_at'
        ]
        read_only_fields = [
            'id', 'status', 'rejection_reason', 'posted_by',
            'current_owner', 'approved_at', 'adopted_at', 'created_at'
        ]
    
    def get_vaccination_count(self, obj):
        return obj.vaccinations.count()


class PetCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating/updating pets"""
    
    class Meta:
        model = Pet
        fields = [
            'name', 'category', 'breed', 'age_years', 'age_months',
            'gender', 'size', 'color', 'weight',
            'description', 'personality', 'special_needs',
            'is_vaccinated', 'is_neutered', 'is_microchipped', 'health_status',
            'primary_image', 'previous_owner',
            'good_with_children', 'good_with_other_pets',
            'activity_level', 'space_requirement'
        ]
    
    def create(self, validated_data):
        request = self.context.get('request')
        validated_data['posted_by'] = request.user
        
        # Admin-posted pets are auto-approved
        if request.user.role == 'admin':
            validated_data['status'] = 'approved'
        else:
            validated_data['status'] = 'pending'
        
        return super().create(validated_data)


class PetApprovalSerializer(serializers.ModelSerializer):
    """Serializer for admin pet approval/rejection"""
    
    class Meta:
        model = Pet
        fields = ['status', 'rejection_reason']
    
    def validate_status(self, value):
        if value not in ['approved', 'rejected', 'pending']:
            raise serializers.ValidationError("Invalid status")
        return value


class AdoptionRequestSerializer(serializers.ModelSerializer):
    """Serializer for adoption requests"""
    
    pet_name = serializers.CharField(source='pet.name', read_only=True)
    pet_image = serializers.ImageField(source='pet.primary_image', read_only=True)
    user_name = serializers.CharField(source='user.username', read_only=True)
    user_email = serializers.CharField(source='user.email', read_only=True)
    
    class Meta:
        model = AdoptionRequest
        fields = [
            'id', 'pet', 'pet_name', 'pet_image',
            'user', 'user_name', 'user_email',
            'status', 'request_message', 'admin_notes', 'rejection_reason',
            'compatibility_score', 'created_at', 'processed_at'
        ]
        read_only_fields = [
            'id', 'user', 'status', 'admin_notes', 'rejection_reason',
            'compatibility_score', 'created_at', 'processed_at'
        ]


class AdoptionRequestCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating adoption requests"""
    
    class Meta:
        model = AdoptionRequest
        fields = ['pet', 'request_message']
    
    def validate_pet(self, value):
        if value.status != 'approved':
            raise serializers.ValidationError("This pet is not available for adoption")
        return value
    
    def create(self, validated_data):
        request = self.context.get('request')
        validated_data['user'] = request.user
        
        # Calculate AI compatibility score
        validated_data['compatibility_score'] = self._calculate_compatibility(
            request.user, validated_data['pet']
        )
        
        return super().create(validated_data)
    
    def _calculate_compatibility(self, user, pet):
        """Simple rule-based AI compatibility scoring"""
        score = 50  # Base score
        
        # Space compatibility
        if user.living_space:
            if pet.space_requirement == 'small':
                score += 10
            elif pet.space_requirement == 'medium' and user.living_space in ['house', 'farm']:
                score += 10
            elif pet.space_requirement == 'large' and user.living_space == 'farm':
                score += 10
        
        # Yard compatibility
        if user.has_yard and pet.activity_level in ['medium', 'high']:
            score += 10
        
        # Children compatibility
        if user.has_children and pet.good_with_children:
            score += 10
        elif user.has_children and not pet.good_with_children:
            score -= 15
        
        # Other pets compatibility
        if user.has_other_pets and pet.good_with_other_pets:
            score += 10
        elif user.has_other_pets and not pet.good_with_other_pets:
            score -= 15
        
        # Activity level match
        if user.activity_level == pet.activity_level:
            score += 10
        
        # Experience bonus
        if user.experience_with_pets == 'experienced':
            score += 5
        
        return min(max(score, 0), 100)  # Clamp between 0-100


class AdoptionProcessSerializer(serializers.ModelSerializer):
    """Serializer for admin to process adoption requests"""
    
    class Meta:
        model = AdoptionRequest
        fields = ['status', 'admin_notes', 'rejection_reason']


class ReturnRequestSerializer(serializers.ModelSerializer):
    """Serializer for return requests"""
    
    pet_name = serializers.CharField(source='pet.name', read_only=True)
    user_name = serializers.CharField(source='user.username', read_only=True)
    
    class Meta:
        model = ReturnRequest
        fields = [
            'id', 'pet', 'pet_name', 'user', 'user_name',
            'reason', 'status', 'admin_notes',
            'created_at', 'processed_at'
        ]
        read_only_fields = ['id', 'user', 'status', 'admin_notes', 'created_at', 'processed_at']


class ReturnRequestCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating return requests"""
    
    class Meta:
        model = ReturnRequest
        fields = ['pet', 'reason']
    
    def validate_pet(self, value):
        request = self.context.get('request')
        if value.current_owner != request.user:
            raise serializers.ValidationError("You can only return pets you have adopted")
        return value
    
    def create(self, validated_data):
        request = self.context.get('request')
        validated_data['user'] = request.user
        return super().create(validated_data)


class VaccinationSerializer(serializers.ModelSerializer):
    """Serializer for vaccination records"""
    
    pet_name = serializers.CharField(source='pet.name', read_only=True)
    is_overdue = serializers.BooleanField(read_only=True)
    days_until_due = serializers.IntegerField(read_only=True)
    
    class Meta:
        model = Vaccination
        fields = [
            'id', 'pet', 'pet_name', 'vaccine_name', 'vaccine_type',
            'administered_date', 'next_due_date', 'administered_by',
            'batch_number', 'notes', 'is_overdue', 'days_until_due',
            'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class MedicalRecordSerializer(serializers.ModelSerializer):
    """Serializer for medical records"""
    
    pet_name = serializers.CharField(source='pet.name', read_only=True)
    
    class Meta:
        model = MedicalRecord
        fields = [
            'id', 'pet', 'pet_name', 'record_date', 'record_type',
            'diagnosis', 'treatment', 'prescription',
            'vet_name', 'vet_clinic', 'notes', 'attachment',
            'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class CareScheduleSerializer(serializers.ModelSerializer):
    """Serializer for care schedules"""
    
    category_name = serializers.CharField(source='category.name', read_only=True)
    
    class Meta:
        model = CareSchedule
        fields = [
            'id', 'category', 'category_name', 'care_type',
            'frequency', 'description', 'tips', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class CareLogSerializer(serializers.ModelSerializer):
    """Serializer for care logs"""
    
    pet_name = serializers.CharField(source='pet.name', read_only=True)
    logged_by_name = serializers.CharField(source='logged_by.username', read_only=True)
    
    class Meta:
        model = CareLog
        fields = [
            'id', 'pet', 'pet_name', 'care_type', 'log_date',
            'details', 'logged_by', 'logged_by_name', 'created_at'
        ]
        read_only_fields = ['id', 'logged_by', 'created_at']
    
    def create(self, validated_data):
        request = self.context.get('request')
        validated_data['logged_by'] = request.user
        return super().create(validated_data)


class NotificationSerializer(serializers.ModelSerializer):
    """Serializer for notifications"""
    
    pet_name = serializers.CharField(source='pet.name', read_only=True)
    
    class Meta:
        model = Notification
        fields = [
            'id', 'notification_type', 'title', 'message',
            'is_read', 'pet', 'pet_name', 'created_at'
        ]
        read_only_fields = ['id', 'notification_type', 'title', 'message', 'pet', 'created_at']


class AuditLogSerializer(serializers.ModelSerializer):
    """Serializer for audit logs"""
    
    user_name = serializers.CharField(source='user.username', read_only=True)
    
    class Meta:
        model = AuditLog
        fields = [
            'id', 'user', 'user_name', 'action', 'model_name',
            'object_id', 'old_values', 'new_values', 'ip_address',
            'created_at'
        ]
        read_only_fields = '__all__'


class DashboardStatsSerializer(serializers.Serializer):
    """Serializer for dashboard statistics"""
    
    total_pets = serializers.IntegerField()
    available_pets = serializers.IntegerField()
    adopted_pets = serializers.IntegerField()
    pending_approvals = serializers.IntegerField()
    pending_adoptions = serializers.IntegerField()
    upcoming_vaccinations = serializers.IntegerField()
    total_users = serializers.IntegerField()
    monthly_adoptions = serializers.ListField(child=serializers.DictField())


class AIRecommendationSerializer(serializers.Serializer):
    """Serializer for AI pet recommendations"""
    
    pet = PetListSerializer()
    compatibility_score = serializers.IntegerField()
    match_reasons = serializers.ListField(child=serializers.CharField())
