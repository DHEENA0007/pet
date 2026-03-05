"""
AI-Enabled Pet Adoption & Care Management System - Admin Configuration
Django admin panel configuration for all models
"""

from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.html import format_html
from .models import (
    User, PetCategory, Owner, Pet, PetImage, AdoptionRequest,
    ReturnRequest, Vaccination, MedicalRecord, CareSchedule,
    CareLog, Notification, AuditLog
)


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    """Custom User admin with role management"""
    
    list_display = ['username', 'email', 'role', 'first_name', 'last_name', 'is_active', 'created_at']
    list_filter = ['role', 'is_active', 'is_staff', 'created_at']
    search_fields = ['username', 'email', 'first_name', 'last_name']
    ordering = ['-created_at']
    
    fieldsets = BaseUserAdmin.fieldsets + (
        ('Role & Profile', {
            'fields': ('role', 'phone', 'address', 'profile_image')
        }),
        ('Lifestyle (for AI matching)', {
            'fields': ('living_space', 'has_yard', 'has_children', 'has_other_pets', 'activity_level', 'experience_with_pets')
        }),
    )
    
    add_fieldsets = BaseUserAdmin.add_fieldsets + (
        ('Role', {
            'fields': ('role',)
        }),
    )


@admin.register(PetCategory)
class PetCategoryAdmin(admin.ModelAdmin):
    """Pet category admin"""
    
    list_display = ['name', 'icon', 'care_difficulty', 'space_requirement', 'activity_needs', 'pet_count']
    search_fields = ['name', 'description']
    list_filter = ['care_difficulty', 'space_requirement']
    
    fieldsets = [
        ('Category Info', {
            'fields': ('name', 'description', 'icon')
        }),
        ('Care Requirements (AI Adjusted)', {
            'fields': ('typical_lifespan', 'care_difficulty', 'space_requirement', 'activity_needs')
        }),
    ]
    
    def pet_count(self, obj):
        return obj.pets.count()
    pet_count.short_description = 'Total Pets'


@admin.register(Owner)
class OwnerAdmin(admin.ModelAdmin):
    """Owner/Shelter admin"""
    
    list_display = ['name', 'owner_type', 'email', 'phone', 'created_at']
    list_filter = ['owner_type']
    search_fields = ['name', 'email']


class PetImageInline(admin.TabularInline):
    """Inline pet images"""
    model = PetImage
    extra = 1


@admin.register(Pet)
class PetAdmin(admin.ModelAdmin):
    """Pet admin with approval workflow"""
    
    list_display = ['name', 'category', 'breed', 'status_badge', 'posted_by', 'current_owner', 'created_at']
    list_filter = ['status', 'category', 'gender', 'size', 'is_vaccinated', 'is_neutered']
    search_fields = ['name', 'breed', 'description']
    ordering = ['-created_at']
    
    fieldsets = [
        ('Basic Information', {
            'fields': ('name', 'category', 'breed', 'age_years', 'age_months', 'gender', 'size', 'color', 'weight')
        }),
        ('Description', {
            'fields': ('description', 'personality', 'special_needs')
        }),
        ('Health Information', {
            'fields': ('is_vaccinated', 'is_neutered', 'is_microchipped', 'health_status')
        }),
        ('Images', {
            'fields': ('primary_image',)
        }),
        ('Status & Approval', {
            'fields': ('status', 'rejection_reason')
        }),
        ('Ownership', {
            'fields': ('posted_by', 'previous_owner', 'current_owner')
        }),
        ('AI Matching', {
            'fields': ('good_with_children', 'good_with_other_pets', 'activity_level', 'space_requirement')
        }),
    ]
    
    inlines = [PetImageInline]
    
    actions = ['approve_pets', 'reject_pets']
    
    def status_badge(self, obj):
        colors = {
            'pending': '#F2C94C',
            'approved': '#6FCF97',
            'rejected': '#EB5757',
            'adopted': '#56CCF2',
            'returned': '#F2C94C',
        }
        color = colors.get(obj.status, '#333333')
        return format_html(
            '<span style="background-color: {}; color: white; padding: 3px 10px; border-radius: 3px;">{}</span>',
            color,
            obj.status.upper()
        )
    status_badge.short_description = 'Status'
    
    @admin.action(description='Approve selected pets')
    def approve_pets(self, request, queryset):
        from django.utils import timezone
        queryset.filter(status='pending').update(status='approved', approved_at=timezone.now())
        self.message_user(request, f'{queryset.count()} pets approved.')
    
    @admin.action(description='Reject selected pets')
    def reject_pets(self, request, queryset):
        queryset.filter(status='pending').update(status='rejected', rejection_reason='Rejected by admin')
        self.message_user(request, f'{queryset.count()} pets rejected.')


@admin.register(PetImage)
class PetImageAdmin(admin.ModelAdmin):
    """Pet image admin"""
    
    list_display = ['pet', 'caption', 'is_primary', 'created_at']
    list_filter = ['is_primary']


@admin.register(AdoptionRequest)
class AdoptionRequestAdmin(admin.ModelAdmin):
    """Adoption request admin with approval workflow"""
    
    list_display = ['pet', 'user', 'status_badge', 'compatibility_score', 'created_at', 'processed_at']
    list_filter = ['status', 'created_at']
    search_fields = ['pet__name', 'user__username']
    ordering = ['-created_at']
    
    actions = ['approve_requests', 'reject_requests']
    
    def status_badge(self, obj):
        colors = {
            'pending': '#F2C94C',
            'approved': '#6FCF97',
            'rejected': '#EB5757',
            'cancelled': '#333333',
        }
        color = colors.get(obj.status, '#333333')
        return format_html(
            '<span style="background-color: {}; color: white; padding: 3px 10px; border-radius: 3px;">{}</span>',
            color,
            obj.status.upper()
        )
    status_badge.short_description = 'Status'
    
    @admin.action(description='Approve selected requests')
    def approve_requests(self, request, queryset):
        from django.utils import timezone
        for adoption_request in queryset.filter(status='pending'):
            adoption_request.status = 'approved'
            adoption_request.processed_at = timezone.now()
            adoption_request.save()
            
            # Update pet status
            pet = adoption_request.pet
            pet.status = 'adopted'
            pet.current_owner = adoption_request.user
            pet.adopted_at = timezone.now()
            pet.save()
        
        self.message_user(request, f'{queryset.count()} adoption requests approved.')
    
    @admin.action(description='Reject selected requests')
    def reject_requests(self, request, queryset):
        from django.utils import timezone
        queryset.filter(status='pending').update(
            status='rejected',
            rejection_reason='Rejected by admin',
            processed_at=timezone.now()
        )
        self.message_user(request, f'{queryset.count()} adoption requests rejected.')


@admin.register(ReturnRequest)
class ReturnRequestAdmin(admin.ModelAdmin):
    """Return request admin"""
    
    list_display = ['pet', 'user', 'status', 'reason', 'created_at']
    list_filter = ['status']
    search_fields = ['pet__name', 'user__username']


@admin.register(Vaccination)
class VaccinationAdmin(admin.ModelAdmin):
    """Vaccination admin with due date tracking"""
    
    list_display = ['pet', 'vaccine_name', 'administered_date', 'next_due_date', 'is_overdue_badge']
    list_filter = ['vaccine_name', 'administered_date']
    search_fields = ['pet__name', 'vaccine_name']
    ordering = ['next_due_date']
    
    def is_overdue_badge(self, obj):
        if obj.is_overdue:
            return format_html(
                '<span style="background-color: #EB5757; color: white; padding: 3px 10px; border-radius: 3px;">OVERDUE</span>'
            )
        elif obj.days_until_due and obj.days_until_due <= 30:
            return format_html(
                '<span style="background-color: #F2C94C; color: black; padding: 3px 10px; border-radius: 3px;">DUE SOON</span>'
            )
        return format_html(
            '<span style="background-color: #6FCF97; color: white; padding: 3px 10px; border-radius: 3px;">OK</span>'
        )
    is_overdue_badge.short_description = 'Status'


@admin.register(MedicalRecord)
class MedicalRecordAdmin(admin.ModelAdmin):
    """Medical record admin"""
    
    list_display = ['pet', 'record_type', 'record_date', 'vet_name', 'vet_clinic']
    list_filter = ['record_type', 'record_date']
    search_fields = ['pet__name', 'diagnosis', 'treatment']


@admin.register(CareSchedule)
class CareScheduleAdmin(admin.ModelAdmin):
    """Care schedule admin"""
    
    list_display = ['category', 'care_type', 'frequency', 'description']
    list_filter = ['category', 'care_type', 'frequency']


@admin.register(CareLog)
class CareLogAdmin(admin.ModelAdmin):
    """Care log admin"""
    
    list_display = ['pet', 'care_type', 'log_date', 'logged_by']
    list_filter = ['care_type', 'log_date']


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    """Notification admin"""
    
    list_display = ['user', 'notification_type', 'title', 'is_read', 'created_at']
    list_filter = ['notification_type', 'is_read', 'created_at']
    search_fields = ['user__username', 'title', 'message']


@admin.register(AuditLog)
class AuditLogAdmin(admin.ModelAdmin):
    """Audit log admin (read-only)"""
    
    list_display = ['user', 'action', 'model_name', 'object_id', 'ip_address', 'created_at']
    list_filter = ['action', 'model_name', 'created_at']
    search_fields = ['user__username', 'action']
    readonly_fields = ['user', 'action', 'model_name', 'object_id', 'old_values', 'new_values', 'ip_address', 'created_at']
    
    def has_add_permission(self, request):
        return False
    
    def has_change_permission(self, request, obj=None):
        return False
    
    def has_delete_permission(self, request, obj=None):
        return False


# Admin site customization
admin.site.site_header = '🐾 Pet Adoption Admin'
admin.site.site_title = 'Pet Adoption Management'
admin.site.index_title = 'AI-Enabled Pet Adoption & Care Management System'
