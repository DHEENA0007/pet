"""
AI-Enabled Pet Adoption & Care Management System - URLs
API endpoint routing
"""

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from .views import (
    UserRegistrationView, UserProfileView, LogoutView,
    AdminDashboardView, UserDashboardView,
    PetCategoryViewSet, OwnerViewSet, PetViewSet, PetImageViewSet,
    AdoptionRequestViewSet, ReturnRequestViewSet,
    VaccinationViewSet, MedicalRecordViewSet,
    CareScheduleViewSet, CareLogViewSet,
    NotificationViewSet, AuditLogViewSet,
    AIRecommendationView, ReportView
)

# Create router
router = DefaultRouter()
router.register(r'categories', PetCategoryViewSet, basename='category')
router.register(r'owners', OwnerViewSet, basename='owner')
router.register(r'pets', PetViewSet, basename='pet')
router.register(r'pet-images', PetImageViewSet, basename='pet-image')
router.register(r'adoption-requests', AdoptionRequestViewSet, basename='adoption-request')
router.register(r'return-requests', ReturnRequestViewSet, basename='return-request')
router.register(r'vaccinations', VaccinationViewSet, basename='vaccination')
router.register(r'medical-records', MedicalRecordViewSet, basename='medical-record')
router.register(r'care-schedules', CareScheduleViewSet, basename='care-schedule')
router.register(r'care-logs', CareLogViewSet, basename='care-log')
router.register(r'notifications', NotificationViewSet, basename='notification')
router.register(r'audit-logs', AuditLogViewSet, basename='audit-log')

urlpatterns = [
    # Authentication endpoints
    path('auth/register/', UserRegistrationView.as_view(), name='register'),
    path('auth/login/', TokenObtainPairView.as_view(), name='login'),
    path('auth/refresh/', TokenRefreshView.as_view(), name='token-refresh'),
    path('auth/logout/', LogoutView.as_view(), name='logout'),
    path('auth/profile/', UserProfileView.as_view(), name='profile'),
    
    # Dashboard endpoints
    path('dashboard/admin/', AdminDashboardView.as_view(), name='admin-dashboard'),
    path('dashboard/user/', UserDashboardView.as_view(), name='user-dashboard'),
    
    # AI Recommendation endpoint
    path('recommendations/', AIRecommendationView.as_view(), name='recommendations'),
    
    # Report endpoints
    path('reports/adoptions/', ReportView.as_view(), name='adoption-report'),
    path('reports/inventory/', ReportView.as_view(), name='inventory-report'),
    path('reports/vaccinations/', ReportView.as_view(), name='vaccination-report'),
    
    # Router URLs
    path('', include(router.urls)),
]
