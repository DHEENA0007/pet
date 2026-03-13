"""
AI-Enabled Pet Adoption & Care Management System - Models
Database models for the complete pet adoption system
"""

from django.db import models
from django.contrib.auth.models import AbstractUser
from django.core.validators import MinValueValidator, MaxValueValidator
from datetime import date, timedelta


class User(AbstractUser):
    """Custom User model with role-based access"""
    
    ROLE_CHOICES = [
        ('admin', 'Admin'),
        ('user', 'User'),
    ]
    
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='user')
    phone = models.CharField(max_length=15, blank=True, null=True)
    address = models.TextField(blank=True, null=True)
    profile_image = models.ImageField(upload_to='profiles/', blank=True, null=True)
    
    # Lifestyle details for AI pet matching
    living_space = models.CharField(max_length=50, blank=True, null=True)  # apartment, house, farm
    has_yard = models.BooleanField(default=False)
    has_children = models.BooleanField(default=False)
    has_other_pets = models.BooleanField(default=False)
    activity_level = models.CharField(max_length=20, blank=True, null=True)  # low, medium, high
    experience_with_pets = models.CharField(max_length=20, blank=True, null=True)  # none, some, experienced
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'users'
    
    def __str__(self):
        return f"{self.username} ({self.role})"


class PetCategory(models.Model):
    """Pet categories (Dog, Cat, Bird, etc.)"""
    
    name = models.CharField(max_length=50, unique=True)
    description = models.TextField(blank=True, null=True)
    icon = models.ImageField(upload_to='categories/', blank=True, null=True)
    
    # Category-specific care information
    typical_lifespan = models.CharField(max_length=50, blank=True, null=True)
    care_difficulty = models.CharField(max_length=20, blank=True, null=True)  # easy, medium, hard
    space_requirement = models.CharField(max_length=20, blank=True, null=True)  # small, medium, large
    activity_needs = models.CharField(max_length=20, blank=True, null=True)  # low, medium, high
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'pet_categories'
        verbose_name_plural = 'Pet Categories'
    
    def __str__(self):
        return self.name


class Owner(models.Model):
    """Previous owners or shelters"""
    
    OWNER_TYPE_CHOICES = [
        ('individual', 'Individual'),
        ('shelter', 'Shelter'),
        ('rescue', 'Rescue Organization'),
    ]
    
    name = models.CharField(max_length=100)
    owner_type = models.CharField(max_length=20, choices=OWNER_TYPE_CHOICES, default='individual')
    email = models.EmailField(blank=True, null=True)
    phone = models.CharField(max_length=15, blank=True, null=True)
    address = models.TextField(blank=True, null=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'owners'
    
    def __str__(self):
        return f"{self.name} ({self.owner_type})"


class Pet(models.Model):
    """Main Pet model with complete lifecycle management"""
    
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
        ('adopted', 'Adopted'),
        ('returned', 'Returned'),
    ]
    
    GENDER_CHOICES = [
        ('male', 'Male'),
        ('female', 'Female'),
        ('unknown', 'Unknown'),
    ]
    
    SIZE_CHOICES = [
        ('small', 'Small'),
        ('medium', 'Medium'),
        ('large', 'Large'),
    ]
    
    # Basic Information
    name = models.CharField(max_length=100)
    category = models.ForeignKey(PetCategory, on_delete=models.CASCADE, related_name='pets')
    breed = models.CharField(max_length=100, blank=True, null=True)
    age_years = models.IntegerField(validators=[MinValueValidator(0)])
    age_months = models.IntegerField(validators=[MinValueValidator(0), MaxValueValidator(11)], default=0)
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES, default='unknown')
    size = models.CharField(max_length=10, choices=SIZE_CHOICES, default='medium')
    color = models.CharField(max_length=50, blank=True, null=True)
    weight = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    
    # Description
    description = models.TextField(blank=True, null=True)
    personality = models.TextField(blank=True, null=True)
    special_needs = models.TextField(blank=True, null=True)
    
    # Health Information
    is_vaccinated = models.BooleanField(default=False)
    is_neutered = models.BooleanField(default=False)
    is_microchipped = models.BooleanField(default=False)
    health_status = models.TextField(blank=True, null=True)
    
    # Images
    primary_image = models.ImageField(upload_to='pets/', blank=True, null=True)
    
    # Status Management
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    rejection_reason = models.TextField(blank=True, null=True)
    
    # Ownership
    posted_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name='posted_pets')
    previous_owner = models.ForeignKey(Owner, on_delete=models.SET_NULL, blank=True, null=True, related_name='previous_pets')
    current_owner = models.ForeignKey(User, on_delete=models.SET_NULL, blank=True, null=True, related_name='adopted_pets')
    
    # AI Compatibility Score factors
    good_with_children = models.BooleanField(default=True)
    good_with_other_pets = models.BooleanField(default=True)
    activity_level = models.CharField(max_length=20, default='medium')  # low, medium, high
    space_requirement = models.CharField(max_length=20, default='medium')  # small, medium, large
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    approved_at = models.DateTimeField(blank=True, null=True)
    adopted_at = models.DateTimeField(blank=True, null=True)
    
    class Meta:
        db_table = 'pets'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.name} ({self.category.name})"


class Message(models.Model):
    """Direct messages between users"""

    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_messages')
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_messages')
    pet = models.ForeignKey('Pet', on_delete=models.SET_NULL, null=True, blank=True, related_name='messages')
    content = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'messages'
        ordering = ['created_at']

    def __str__(self):
        return f"{self.sender.username} → {self.receiver.username}: {self.content[:30]}"


class PetImage(models.Model):
    """Additional images for pets"""
    
    pet = models.ForeignKey(Pet, on_delete=models.CASCADE, related_name='images')
    image = models.ImageField(upload_to='pets/')
    caption = models.CharField(max_length=200, blank=True, null=True)
    is_primary = models.BooleanField(default=False)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'pet_images'
    
    def __str__(self):
        return f"Image for {self.pet.name}"


class AdoptionRequest(models.Model):
    """Adoption request management"""
    
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
        ('cancelled', 'Cancelled'),
    ]
    
    pet = models.ForeignKey(Pet, on_delete=models.CASCADE, related_name='adoption_requests')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='adoption_requests')
    
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    request_message = models.TextField(blank=True, null=True)
    admin_notes = models.TextField(blank=True, null=True)
    rejection_reason = models.TextField(blank=True, null=True)
    
    # AI Compatibility Score
    compatibility_score = models.IntegerField(blank=True, null=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    processed_at = models.DateTimeField(blank=True, null=True)
    
    class Meta:
        db_table = 'adoption_requests'
        ordering = ['-created_at']
        unique_together = ['pet', 'user']
    
    def __str__(self):
        return f"{self.user.username} -> {self.pet.name} ({self.status})"


class ReturnRequest(models.Model):
    """Return adoption request management"""
    
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
    ]
    
    pet = models.ForeignKey(Pet, on_delete=models.CASCADE, related_name='return_requests')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='return_requests')
    
    reason = models.TextField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    admin_notes = models.TextField(blank=True, null=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    processed_at = models.DateTimeField(blank=True, null=True)
    
    class Meta:
        db_table = 'return_requests'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Return: {self.pet.name} by {self.user.username}"


class Vaccination(models.Model):
    """Vaccination records and alerts"""
    
    pet = models.ForeignKey(Pet, on_delete=models.CASCADE, related_name='vaccinations')
    
    vaccine_name = models.CharField(max_length=100)
    vaccine_type = models.CharField(max_length=100, blank=True, null=True)
    administered_date = models.DateField()
    next_due_date = models.DateField(blank=True, null=True)
    administered_by = models.CharField(max_length=100, blank=True, null=True)  # Vet name
    batch_number = models.CharField(max_length=50, blank=True, null=True)
    notes = models.TextField(blank=True, null=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'vaccinations'
        ordering = ['-administered_date']
    
    def __str__(self):
        return f"{self.vaccine_name} for {self.pet.name}"
    
    def save(self, *args, **kwargs):
        # Auto-calculate next due date if not provided (1 year default)
        if not self.next_due_date and self.administered_date:
            self.next_due_date = self.administered_date + timedelta(days=365)
        super().save(*args, **kwargs)
    
    @property
    def is_overdue(self):
        if self.next_due_date:
            return date.today() > self.next_due_date
        return False
    
    @property
    def days_until_due(self):
        if self.next_due_date:
            delta = self.next_due_date - date.today()
            return delta.days
        return None


class MedicalRecord(models.Model):
    """Medical history and health logs"""
    
    pet = models.ForeignKey(Pet, on_delete=models.CASCADE, related_name='medical_records')
    
    record_date = models.DateField()
    record_type = models.CharField(max_length=50)  # checkup, illness, surgery, etc.
    diagnosis = models.TextField(blank=True, null=True)
    treatment = models.TextField(blank=True, null=True)
    prescription = models.TextField(blank=True, null=True)
    vet_name = models.CharField(max_length=100, blank=True, null=True)
    vet_clinic = models.CharField(max_length=100, blank=True, null=True)
    notes = models.TextField(blank=True, null=True)
    
    # Attachments
    attachment = models.FileField(upload_to='medical_records/', blank=True, null=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'medical_records'
        ordering = ['-record_date']
    
    def __str__(self):
        return f"{self.record_type} for {self.pet.name} on {self.record_date}"


class CareSchedule(models.Model):
    """Care schedules by pet category"""
    
    category = models.ForeignKey(PetCategory, on_delete=models.CASCADE, related_name='care_schedules')
    
    care_type = models.CharField(max_length=50)  # feeding, grooming, exercise, etc.
    frequency = models.CharField(max_length=50)  # daily, weekly, monthly
    description = models.TextField()
    tips = models.TextField(blank=True, null=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'care_schedules'
    
    def __str__(self):
        return f"{self.care_type} for {self.category.name}"


class CareLog(models.Model):
    """Individual care logs for pets"""
    
    pet = models.ForeignKey(Pet, on_delete=models.CASCADE, related_name='care_logs')
    
    care_type = models.CharField(max_length=50)
    log_date = models.DateTimeField()
    details = models.TextField(blank=True, null=True)
    logged_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='care_logs')
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'care_logs'
        ordering = ['-log_date']
    
    def __str__(self):
        return f"{self.care_type} for {self.pet.name}"


class Notification(models.Model):
    """User notifications"""
    
    NOTIFICATION_TYPES = [
        ('adoption_request', 'Adoption Request'),
        ('adoption_approved', 'Adoption Approved'),
        ('adoption_rejected', 'Adoption Rejected'),
        ('pet_approved', 'Pet Approved'),
        ('pet_rejected', 'Pet Rejected'),
        ('vaccination_due', 'Vaccination Due'),
        ('vaccination_administered', 'Vaccination Administered'),
        ('care_reminder', 'Care Reminder'),
        ('general', 'General'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    notification_type = models.CharField(max_length=30, choices=NOTIFICATION_TYPES)
    title = models.CharField(max_length=200)
    message = models.TextField()
    is_read = models.BooleanField(default=False)
    
    # Optional reference to related objects
    pet = models.ForeignKey(Pet, on_delete=models.SET_NULL, blank=True, null=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'notifications'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.title} for {self.user.username}"


class AuditLog(models.Model):
    """Audit logs for admin actions"""
    
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='audit_logs')
    action = models.CharField(max_length=100)
    model_name = models.CharField(max_length=50)
    object_id = models.IntegerField(blank=True, null=True)
    old_values = models.JSONField(blank=True, null=True)
    new_values = models.JSONField(blank=True, null=True)
    ip_address = models.GenericIPAddressField(blank=True, null=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'audit_logs'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.action} by {self.user.username if self.user else 'Unknown'}"
