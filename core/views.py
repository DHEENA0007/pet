"""
AI-Enabled Pet Adoption & Care Management System - Views
REST API views for all endpoints
"""

from rest_framework import viewsets, status, generics, permissions, serializers, filters
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from django.utils import timezone
from django.db.models import Count, Q, Max, OuterRef, Subquery
from django.db.models.functions import TruncMonth
from datetime import date, timedelta
import json
import logging

logger = logging.getLogger(__name__)

from .models import (
    User, PetCategory, Owner, Pet, PetImage, AdoptionRequest,
    ReturnRequest, Vaccination, MedicalRecord, CareSchedule,
    CareLog, Notification, AuditLog, Message
)
from .serializers import (
    UserRegistrationSerializer, UserSerializer, UserProfileUpdateSerializer,
    PetCategorySerializer, OwnerSerializer, PetImageSerializer,
    PetListSerializer, PetDetailSerializer, PetCreateSerializer, PetApprovalSerializer,
    AdoptionRequestSerializer, AdoptionRequestCreateSerializer, AdoptionProcessSerializer,
    ReturnRequestSerializer, ReturnRequestCreateSerializer,
    VaccinationSerializer, MedicalRecordSerializer,
    CareScheduleSerializer, CareLogSerializer,
    NotificationSerializer, AuditLogSerializer,
    DashboardStatsSerializer, AIRecommendationSerializer,
    MessageSerializer, ConversationSerializer,
)
from .permissions import IsAdmin, IsOwnerOrAdmin
from .utils import create_notification, create_audit_log, calculate_compatibility_score


# ==================== Authentication Views ====================

class LogoutView(APIView):
    """Blacklist the refresh token so it can no longer be used."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        refresh_token = request.data.get('refresh')
        if not refresh_token:
            return Response({'detail': 'Refresh token required.'}, status=status.HTTP_400_BAD_REQUEST)
        try:
            token = RefreshToken(refresh_token)
            token.blacklist()
            return Response({'detail': 'Logged out successfully.'}, status=status.HTTP_200_OK)
        except TokenError:
            return Response({'detail': 'Invalid or expired token.'}, status=status.HTTP_400_BAD_REQUEST)


class UserRegistrationView(generics.CreateAPIView):
    """User registration endpoint"""
    queryset = User.objects.all()
    serializer_class = UserRegistrationSerializer
    permission_classes = [permissions.AllowAny]


class UserProfileView(generics.RetrieveUpdateAPIView):
    """User profile view and update"""
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_object(self):
        return self.request.user
    
    def get_serializer_class(self):
        if self.request.method in ['PUT', 'PATCH']:
            return UserProfileUpdateSerializer
        return UserSerializer


# ==================== Dashboard Views ====================

class AdminDashboardView(APIView):
    """Admin dashboard with complete statistics"""
    permission_classes = [IsAdmin]
    
    def get(self, request):
        today = date.today()
        six_months_ago = today - timedelta(days=180)
        
        # Basic counts
        total_pets = Pet.objects.count()
        available_pets = Pet.objects.filter(status='approved').count()
        adopted_pets = Pet.objects.filter(status='adopted').count()
        pending_approvals = Pet.objects.filter(status='pending').count()
        pending_adoptions = AdoptionRequest.objects.filter(status='pending').count()
        
        # Vaccination alerts (due within 30 days)
        upcoming_vaccinations = Vaccination.objects.filter(
            next_due_date__lte=today + timedelta(days=30),
            next_due_date__gte=today
        ).count()
        
        total_users = User.objects.filter(role='user').count()
        
        # Monthly adoption statistics
        monthly_adoptions = (
            Pet.objects.filter(
                status='adopted',
                adopted_at__gte=six_months_ago
            )
            .annotate(month=TruncMonth('adopted_at'))
            .values('month')
            .annotate(count=Count('id'))
            .order_by('month')
        )
        
        data = {
            'total_pets': total_pets,
            'available_pets': available_pets,
            'adopted_pets': adopted_pets,
            'pending_approvals': pending_approvals,
            'pending_adoptions': pending_adoptions,
            'upcoming_vaccinations': upcoming_vaccinations,
            'total_users': total_users,
            'monthly_adoptions': list(monthly_adoptions)
        }
        
        serializer = DashboardStatsSerializer(data)
        return Response(serializer.data)


class UserDashboardView(APIView):
    """User dashboard with personalized data"""
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request):
        user = request.user
        
        data = {
            'adopted_pets': Pet.objects.filter(current_owner=user, status='adopted').count(),
            'pending_adoptions': AdoptionRequest.objects.filter(user=user, status='pending').count(),
            'pending_pet_posts': Pet.objects.filter(posted_by=user, status='pending').count(),
            'unread_notifications': Notification.objects.filter(user=user, is_read=False).count(),
        }
        
        return Response(data)


# ==================== Pet Category Views ====================

class PetCategoryViewSet(viewsets.ModelViewSet):
    """CRUD for pet categories"""
    queryset = PetCategory.objects.all()
    serializer_class = PetCategorySerializer
    
    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsAdmin()]
        return [permissions.AllowAny()]
    
    def perform_destroy(self, instance):
        """Prevent deletion of categories that have pets"""
        pet_count = instance.pets.count()
        if pet_count > 0:
            raise serializers.ValidationError({
                'detail': f'Cannot delete category "{instance.name}". It has {pet_count} pet(s) associated with it. Please reassign or remove those pets first.'
            })
        instance.delete()


# ==================== Owner Views ====================

class OwnerViewSet(viewsets.ModelViewSet):
    """CRUD for owners/shelters"""
    queryset = Owner.objects.all()
    serializer_class = OwnerSerializer
    permission_classes = [IsAdmin]


# ==================== Pet Views ====================

class PetViewSet(viewsets.ModelViewSet):
    """Complete pet management"""
    
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name', 'breed', 'category__name', 'description']
    ordering_fields = ['created_at', 'name', 'age_years']
    ordering = ['-created_at']
    
    def get_queryset(self):
        user = self.request.user
        queryset = Pet.objects.select_related('category', 'posted_by', 'current_owner')

        # Filter based on user role and action
        if not user.is_authenticated:
            queryset = queryset.filter(status='approved')
        elif user.role == 'admin':
            status_filter = self.request.query_params.get('status')
            if status_filter:
                queryset = queryset.filter(status=status_filter)
        elif self.action == 'list':
            queryset = queryset.filter(Q(status='approved') | Q(posted_by=user))

        # Apply category filter (works for all roles)
        category_id = self.request.query_params.get('category')
        if category_id:
            queryset = queryset.filter(category_id=category_id)

        return queryset
    
    def get_serializer_class(self):
        if self.action == 'list':
            return PetListSerializer
        if self.action in ['create', 'update', 'partial_update']:
            return PetCreateSerializer
        return PetDetailSerializer
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.AllowAny()]
        if self.action in ['create']:
            return [permissions.IsAuthenticated()]
        if self.action in ['update', 'partial_update', 'destroy']:
            return [IsOwnerOrAdmin()]
        return [IsAdmin()]
    
    @action(detail=True, methods=['post'], permission_classes=[IsAdmin])
    def approve(self, request, pk=None):
        """Admin approves a pet"""
        pet = self.get_object()
        pet.status = 'approved'
        pet.approved_at = timezone.now()
        pet.save()
        
        # Create notification for the pet owner
        create_notification(
            user=pet.posted_by,
            notification_type='pet_approved',
            title='Pet Approved!',
            message=f'Your pet "{pet.name}" has been approved and is now visible to potential adopters.',
            pet=pet
        )
        
        # Create audit log
        create_audit_log(
            user=request.user,
            action='approve_pet',
            model_name='Pet',
            object_id=pet.id,
            new_values={'status': 'approved'},
            request=request
        )
        
        return Response({'message': 'Pet approved successfully'})
    
    @action(detail=True, methods=['post'], permission_classes=[IsAdmin])
    def reject(self, request, pk=None):
        """Admin rejects a pet"""
        pet = self.get_object()
        reason = request.data.get('reason', 'No reason provided')
        
        pet.status = 'rejected'
        pet.rejection_reason = reason
        pet.save()
        
        # Create notification
        create_notification(
            user=pet.posted_by,
            notification_type='pet_rejected',
            title='Pet Listing Rejected',
            message=f'Your pet "{pet.name}" was rejected. Reason: {reason}',
            pet=pet
        )
        
        # Create audit log
        create_audit_log(
            user=request.user,
            action='reject_pet',
            model_name='Pet',
            object_id=pet.id,
            new_values={'status': 'rejected', 'reason': reason},
            request=request
        )
        
        return Response({'message': 'Pet rejected'})
    
    @action(detail=False, methods=['get'])
    def my_posts(self, request):
        """Get pets posted by current user"""
        pets = Pet.objects.filter(posted_by=request.user)
        serializer = PetListSerializer(pets, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def my_adopted(self, request):
        """Get pets adopted by current user"""
        pets = Pet.objects.filter(current_owner=request.user, status='adopted')
        serializer = PetDetailSerializer(pets, many=True)
        return Response(serializer.data)


# ==================== Pet Image Views ====================

class PetImageViewSet(viewsets.ModelViewSet):
    """Pet image management"""
    queryset = PetImage.objects.all()
    serializer_class = PetImageSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        pet_id = self.request.query_params.get('pet')
        if pet_id:
            return PetImage.objects.filter(pet_id=pet_id)
        return PetImage.objects.none()


# ==================== Adoption Request Views ====================

class AdoptionRequestViewSet(viewsets.ModelViewSet):
    """Adoption request management"""
    
    def get_queryset(self):
        user = self.request.user
        
        if user.role == 'admin':
            return AdoptionRequest.objects.select_related('pet', 'user').all()
        
        return AdoptionRequest.objects.filter(user=user)
    
    def get_serializer_class(self):
        if self.action == 'create':
            return AdoptionRequestCreateSerializer
        if self.action in ['process']:
            return AdoptionProcessSerializer
        return AdoptionRequestSerializer
    
    def get_permissions(self):
        if self.action in ['process']:
            return [IsAdmin()]
        return [permissions.IsAuthenticated()]
    
    @action(detail=True, methods=['post'], permission_classes=[IsAdmin])
    def process(self, request, pk=None):
        """Admin processes an adoption request"""
        adoption_request = self.get_object()
        new_status = request.data.get('status')
        
        if new_status == 'approved':
            # Update pet status
            pet = adoption_request.pet
            pet.status = 'adopted'
            pet.current_owner = adoption_request.user
            pet.adopted_at = timezone.now()
            pet.save()
            
            # Reject other pending requests for this pet
            AdoptionRequest.objects.filter(
                pet=pet, status='pending'
            ).exclude(pk=adoption_request.pk).update(
                status='rejected',
                rejection_reason='Pet adopted by another user',
                processed_at=timezone.now()
            )
            
            # Create notification
            create_notification(
                user=adoption_request.user,
                notification_type='adoption_approved',
                title='Adoption Approved! 🎉',
                message=f'Congratulations! Your adoption request for "{pet.name}" has been approved!',
                pet=pet
            )
        
        elif new_status == 'rejected':
            reason = request.data.get('rejection_reason', 'No reason provided')
            adoption_request.rejection_reason = reason
            
            create_notification(
                user=adoption_request.user,
                notification_type='adoption_rejected',
                title='Adoption Request Declined',
                message=f'Your adoption request for "{adoption_request.pet.name}" was declined. Reason: {reason}',
                pet=adoption_request.pet
            )
        
        adoption_request.status = new_status
        adoption_request.admin_notes = request.data.get('admin_notes', '')
        adoption_request.processed_at = timezone.now()
        adoption_request.save()
        
        # Create audit log
        create_audit_log(
            user=request.user,
            action=f'process_adoption_{new_status}',
            model_name='AdoptionRequest',
            object_id=adoption_request.id,
            new_values={'status': new_status},
            request=request
        )
        
        return Response({'message': f'Adoption request {new_status}'})


# ==================== Return Request Views ====================

class ReturnRequestViewSet(viewsets.ModelViewSet):
    """Return request management"""
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        
        if user.role == 'admin':
            return ReturnRequest.objects.select_related('pet', 'user').all()
        
        return ReturnRequest.objects.filter(user=user)
    
    def get_serializer_class(self):
        if self.action == 'create':
            return ReturnRequestCreateSerializer
        return ReturnRequestSerializer
    
    def get_permissions(self):
        if self.action in ['process']:
            return [IsAdmin()]
        return [permissions.IsAuthenticated()]
    
    @action(detail=True, methods=['post'], permission_classes=[IsAdmin])
    def process(self, request, pk=None):
        """Admin processes a return request"""
        return_request = self.get_object()
        new_status = request.data.get('status')
        
        if new_status == 'approved':
            pet = return_request.pet
            pet.status = 'approved'  # Make available again
            pet.current_owner = None
            pet.save()
            
            # Create notification
            create_notification(
                user=return_request.user,
                notification_type='return_approved',
                title='Return Request Approved',
                message=f'Your return request for "{pet.name}" has been approved.',
                pet=pet
            )
        elif new_status == 'rejected':
            create_notification(
                user=return_request.user,
                notification_type='return_rejected',
                title='Return Request Rejected',
                message=f'Your return request for "{return_request.pet.name}" was rejected.',
                pet=return_request.pet
            )
        
        return_request.status = new_status
        return_request.admin_notes = request.data.get('admin_notes', '')
        return_request.processed_at = timezone.now()
        return_request.save()
        
        return Response({'message': f'Return request {new_status}'})


# ==================== Vaccination Views ====================

class VaccinationViewSet(viewsets.ModelViewSet):
    """Vaccination record management"""
    queryset = Vaccination.objects.select_related('pet').all()
    serializer_class = VaccinationSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        pet_id = self.request.query_params.get('pet')
        
        queryset = Vaccination.objects.select_related('pet')
        
        if pet_id:
            queryset = queryset.filter(pet_id=pet_id)
        elif user.role != 'admin':
            # Users can only see vaccinations for their adopted pets
            queryset = queryset.filter(pet__current_owner=user)
        
        return queryset
    
    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsAdmin()]
        return [permissions.IsAuthenticated()]
    
    def create(self, request, *args, **kwargs):
        """Create vaccination record and send notification if pet is adopted"""
        response = super().create(request, *args, **kwargs)
        
        if response.status_code == 201:
            vaccination_data = response.data
            pet_id = vaccination_data.get('pet')
            
            try:
                pet = Pet.objects.get(id=pet_id)
                if pet.status == 'adopted' and pet.current_owner:
                    # Send notification to the adopted user
                    Notification.objects.create(
                        user=pet.current_owner,
                        notification_type='vaccination_administered',
                        title=f'Vaccination Update for {pet.name}',
                        message=f'Your pet {pet.name} has received a vaccination: {vaccination_data.get("vaccine_name")}. '
                               f'Next due date: {vaccination_data.get("next_due_date") or "N/A"}',
                        pet=pet
                    )
            except Pet.DoesNotExist:
                pass  # Pet doesn't exist, but vaccination was created
        
        return response
    
    @action(detail=False, methods=['get'], permission_classes=[IsAdmin])
    def due_soon(self, request):
        """Get vaccinations due within 30 days"""
        today = date.today()
        vaccinations = Vaccination.objects.filter(
            next_due_date__lte=today + timedelta(days=30),
            next_due_date__gte=today
        ).select_related('pet')
        
        serializer = VaccinationSerializer(vaccinations, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'], permission_classes=[IsAdmin])
    def overdue(self, request):
        """Get overdue vaccinations"""
        today = date.today()
        vaccinations = Vaccination.objects.filter(
            next_due_date__lt=today
        ).select_related('pet')
        
        serializer = VaccinationSerializer(vaccinations, many=True)
        return Response(serializer.data)


# ==================== Medical Record Views ====================

class MedicalRecordViewSet(viewsets.ModelViewSet):
    """Medical record management"""
    serializer_class = MedicalRecordSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        pet_id = self.request.query_params.get('pet')
        
        queryset = MedicalRecord.objects.select_related('pet')
        
        if pet_id:
            queryset = queryset.filter(pet_id=pet_id)
        elif user.role != 'admin':
            queryset = queryset.filter(pet__current_owner=user)
        
        return queryset
    
    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsAdmin()]
        return [permissions.IsAuthenticated()]


# ==================== Care Schedule Views ====================

class CareScheduleViewSet(viewsets.ModelViewSet):
    """Care schedule management"""
    queryset = CareSchedule.objects.select_related('category').all()
    serializer_class = CareScheduleSerializer
    
    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsAdmin()]
        return [permissions.AllowAny()]
    
    def get_queryset(self):
        category_id = self.request.query_params.get('category')
        if category_id:
            return CareSchedule.objects.filter(category_id=category_id)
        return CareSchedule.objects.all()


# ==================== Care Log Views ====================

class CareLogViewSet(viewsets.ModelViewSet):
    """Care log management"""
    serializer_class = CareLogSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        pet_id = self.request.query_params.get('pet')
        
        queryset = CareLog.objects.select_related('pet', 'logged_by')
        
        if pet_id:
            queryset = queryset.filter(pet_id=pet_id)
        elif user.role != 'admin':
            queryset = queryset.filter(
                Q(pet__current_owner=user) | Q(logged_by=user)
            )
        
        return queryset


# ==================== Notification Views ====================

class NotificationViewSet(viewsets.ModelViewSet):
    """Notification management"""
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user)
    
    @action(detail=True, methods=['post'])
    def mark_read(self, request, pk=None):
        """Mark notification as read"""
        notification = self.get_object()
        notification.is_read = True
        notification.save()
        return Response({'message': 'Marked as read'})
    
    @action(detail=False, methods=['post'])
    def mark_all_read(self, request):
        """Mark all notifications as read"""
        Notification.objects.filter(user=request.user, is_read=False).update(is_read=True)
        return Response({'message': 'All notifications marked as read'})


# ==================== Audit Log Views ====================

class AuditLogViewSet(viewsets.ReadOnlyModelViewSet):
    """Audit log viewing (admin only)"""
    queryset = AuditLog.objects.select_related('user').all()
    serializer_class = AuditLogSerializer
    permission_classes = [IsAdmin]


# ==================== AI Recommendation Views ====================

class AIRecommendationView(APIView):
    """AI-based pet recommendations for users"""
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request):
        user = request.user
        
        # Get available pets
        available_pets = Pet.objects.filter(status='approved').select_related('category')
        
        recommendations = []
        
        for pet in available_pets:
            # Use the shared utility function which now supports Groq AI
            score, reasons = calculate_compatibility_score(user, pet)
            recommendations.append({
                'pet': PetListSerializer(pet).data,
                'compatibility_score': score,
                'match_reasons': reasons
            })
        
        # Sort by compatibility score (descending)
        recommendations.sort(key=lambda x: x['compatibility_score'], reverse=True)
        
        # Return top 10 recommendations
        return Response(recommendations[:10])


# ==================== Report Views ====================

class ReportView(APIView):
    """Generate reports"""
    permission_classes = [IsAdmin]
    
    @action(detail=False, methods=['get'])
    def adoption_report(self, request):
        """Generate adoption report"""
        from_date = request.query_params.get('from_date')
        to_date = request.query_params.get('to_date')
        
        queryset = Pet.objects.filter(status='adopted')
        
        if from_date:
            queryset = queryset.filter(adopted_at__gte=from_date)
        if to_date:
            queryset = queryset.filter(adopted_at__lte=to_date)
        
        data = queryset.values(
            'name', 'category__name', 'breed',
            'current_owner__username', 'adopted_at'
        )
        
        return Response(list(data))
    
    @action(detail=False, methods=['get'])
    def pet_inventory(self, request):
        """Generate pet inventory report"""
        data = Pet.objects.values('status').annotate(count=Count('id'))
        return Response(list(data))
    
    @action(detail=False, methods=['get'])
    def vaccination_schedule(self, request):
        """Generate vaccination schedule report"""
        today = date.today()
        thirty_days = today + timedelta(days=30)
        
        upcoming = Vaccination.objects.filter(
            next_due_date__gte=today,
            next_due_date__lte=thirty_days
        ).select_related('pet').values(
            'pet__name', 'vaccine_name', 'next_due_date'
        )
        
        return Response(list(upcoming))


# ==================== Messaging Views ====================

class MessageViewSet(viewsets.ModelViewSet):
    """Direct messaging between users"""
    serializer_class = MessageSerializer
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ['get', 'post', 'delete']

    def get_queryset(self):
        user = self.request.user
        other_user_id = self.request.query_params.get('with')
        if other_user_id:
            # Mark as read all messages FROM the other user to current user
            Message.objects.filter(
                sender_id=other_user_id, receiver=user, is_read=False
            ).update(is_read=True)
            return Message.objects.filter(
                Q(sender=user, receiver_id=other_user_id) |
                Q(sender_id=other_user_id, receiver=user)
            ).select_related('sender', 'receiver', 'pet')
        return Message.objects.none()

    def create(self, request, *args, **kwargs):
        receiver_id = request.data.get('receiver')
        content = request.data.get('content', '').strip()
        pet_id = request.data.get('pet')

        if not receiver_id or not content:
            return Response({'detail': 'receiver and content are required.'},
                            status=status.HTTP_400_BAD_REQUEST)
        try:
            receiver = User.objects.get(id=receiver_id)
        except User.DoesNotExist:
            return Response({'detail': 'Receiver not found.'}, status=status.HTTP_404_NOT_FOUND)

        if receiver == request.user:
            return Response({'detail': 'Cannot message yourself.'}, status=status.HTTP_400_BAD_REQUEST)

        msg = Message(sender=request.user, receiver=receiver, content=content)
        if pet_id:
            try:
                msg.pet = Pet.objects.get(id=pet_id)
            except Pet.DoesNotExist:
                pass
        msg.save()
        serializer = MessageSerializer(msg)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    @action(detail=False, methods=['get'])
    def conversations(self, request):
        """List all unique conversations for current user with last message preview."""
        user = request.user

        # Get IDs of all people user has chatted with
        sent_to = Message.objects.filter(sender=user).values_list('receiver_id', flat=True)
        received_from = Message.objects.filter(receiver=user).values_list('sender_id', flat=True)
        other_ids = set(list(sent_to) + list(received_from))

        conversations = []
        for other_id in other_ids:
            last_msg = Message.objects.filter(
                Q(sender=user, receiver_id=other_id) |
                Q(sender_id=other_id, receiver=user)
            ).order_by('-created_at').first()

            if not last_msg:
                continue

            other_user = User.objects.get(id=other_id)
            other_name = other_user.get_full_name() or other_user.username
            unread = Message.objects.filter(sender_id=other_id, receiver=user, is_read=False).count()

            conversations.append({
                'other_user_id': other_id,
                'other_user_name': other_name,
                'other_user_username': other_user.username,
                'last_message': last_msg.content,
                'last_message_time': last_msg.created_at,
                'unread_count': unread,
                'is_last_mine': last_msg.sender == user,
            })

        conversations.sort(key=lambda c: c['last_message_time'], reverse=True)
        serializer = ConversationSerializer(conversations, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def unread_count(self, request):
        count = Message.objects.filter(receiver=request.user, is_read=False).count()
        return Response({'unread_count': count})


# ==================== AI Chatbot View ====================

class ChatbotView(APIView):
    """AI Chatbot powered by Groq to answer questions about pets and the app."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        question = request.data.get('question', '').strip()
        if not question:
            return Response({'detail': 'question is required.'}, status=status.HTTP_400_BAD_REQUEST)

        # Build context: list of available pets
        pets = Pet.objects.filter(status='approved').select_related('category')[:30]
        pets_context = '\n'.join([
            f"- {p.name} ({p.category.name}, {p.breed or 'unknown breed'}, "
            f"{p.age_years}y {p.age_months}m, {p.gender}, {p.size}, "
            f"vaccinated={'yes' if p.is_vaccinated else 'no'}, "
            f"{'available' if p.status == 'approved' else p.status})"
            for p in pets
        ])

        categories = PetCategory.objects.all()
        cats_context = ', '.join([c.name for c in categories])

        system_prompt = f"""You are a friendly AI assistant for a Pet Adoption & Care Management App.

App features:
- Browse and adopt pets (Dogs, Cats, Birds, Rabbits, Fish, Hamsters)
- Post pets for adoption
- Track pet health: vaccinations, medical records, care schedules
- AI pet compatibility matching
- Direct messaging with pet owners
- Adoption request management
- Admin dashboard for approvals

Available pet categories: {cats_context}

Currently available pets for adoption:
{pets_context if pets_context else 'No pets currently listed.'}

Answer the user's question helpfully and concisely. If asked about a specific pet, use the info above.
If asked about adopting, explain the process: browse → view pet → tap 'Adopt Now' → admin approves.
If you don't know something specific, say so honestly."""

        try:
            from groq import Groq
            from django.conf import settings
            client = Groq(api_key=settings.GROQ_API_KEY)
            completion = client.chat.completions.create(
                model="llama-3.3-70b-versatile",
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": question},
                ],
                max_tokens=512,
            )
            answer = completion.choices[0].message.content
        except Exception as e:
            logger.error(f"Chatbot Groq error: {e}")
            answer = ("I'm having trouble connecting to the AI right now. "
                      "Please try again shortly, or browse the Pets section to find your perfect companion!")

        return Response({'answer': answer})
