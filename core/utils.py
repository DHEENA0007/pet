"""
AI-Enabled Pet Adoption & Care Management System - Utilities
Helper functions for notifications, audit logs, and AI logic
"""

from .models import Notification, AuditLog


def create_notification(user, notification_type, title, message, pet=None):
    """
    Create a notification for a user.
    
    Args:
        user: User object to notify
        notification_type: Type of notification
        title: Notification title
        message: Notification message
        pet: Optional pet reference
    """
    return Notification.objects.create(
        user=user,
        notification_type=notification_type,
        title=title,
        message=message,
        pet=pet
    )


def create_audit_log(user, action, model_name, object_id=None, old_values=None, new_values=None, request=None):
    """
    Create an audit log entry.
    
    Args:
        user: User who performed the action
        action: Action performed
        model_name: Name of the model affected
        object_id: ID of the object affected
        old_values: Previous values (dict)
        new_values: New values (dict)
        request: HTTP request object (for IP address)
    """
    ip_address = None
    if request:
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip_address = x_forwarded_for.split(',')[0]
        else:
            ip_address = request.META.get('REMOTE_ADDR')
    
    return AuditLog.objects.create(
        user=user,
        action=action,
        model_name=model_name,
        object_id=object_id,
        old_values=old_values,
        new_values=new_values,
        ip_address=ip_address
    )


from core.services.ai_service import GroqService

groq_service = GroqService()

def calculate_compatibility_score(user, pet):
    """
    Calculate AI compatibility score between a user and a pet.
    Prioritizes Groq LLM API if available, otherwise falls back to rule-based logic.
    """
    if groq_service.is_available():
        user_profile = {
            'living_space': getattr(user, 'living_space', 'Unknown'),
            'has_yard': getattr(user, 'has_yard', False),
            'has_children': getattr(user, 'has_children', False),
            'has_other_pets': getattr(user, 'has_other_pets', False),
            'activity_level': getattr(user, 'activity_level', 'Unknown'),
            'experience_with_pets': getattr(user, 'experience_with_pets', 'Unknown'),
        }
        
        pet_profile = {
            'name': pet.name,
            'breed': pet.breed,
            'age_years': pet.age_years,
            'size': pet.size,
            'activity_level': pet.activity_level,
            'space_requirement': pet.space_requirement,
            'good_with_children': pet.good_with_children,
            'good_with_other_pets': pet.good_with_other_pets,
            'special_needs': pet.special_needs,
            'description': pet.description,
            'category': pet.category.name,
        }
        
        score, reasons = groq_service.analyze_compatibility(user_profile, pet_profile)
        if score is not None:
            return score, reasons

    # Use simple rule-based logic as fallback
    score = 50  # Base score
    reasons = []
    
    # Space compatibility
    if user.living_space:
        if pet.space_requirement == 'small':
            score += 10
            reasons.append("This pet is suitable for any living space")
        elif pet.space_requirement == 'medium':
            if user.living_space in ['house', 'farm']:
                score += 10
                reasons.append("Your home provides adequate space")
            else:
                score -= 5
        elif pet.space_requirement == 'large':
            if user.living_space == 'farm':
                score += 15
                reasons.append("Your large property is perfect")
            elif user.living_space == 'apartment':
                score -= 15
                reasons.append("This pet may need more space")
    
    # Yard compatibility
    if user.has_yard:
        if pet.activity_level in ['medium', 'high']:
            score += 10
            reasons.append("Your yard is ideal for this active pet")
    elif pet.activity_level == 'high':
        score -= 10
        reasons.append("Consider: This pet needs outdoor space")
    
    # Children compatibility
    if user.has_children:
        if pet.good_with_children:
            score += 15
            reasons.append("Family-friendly! Great with kids")
        else:
            score -= 20
            reasons.append("Warning: May not be suitable for children")
    
    # Other pets compatibility
    if user.has_other_pets:
        if pet.good_with_other_pets:
            score += 10
            reasons.append("Gets along with other animals")
        else:
            score -= 15
            reasons.append("May have difficulty with other pets")
    
    # Activity level match
    if user.activity_level and pet.activity_level:
        if user.activity_level == pet.activity_level:
            score += 15
            reasons.append(f"Perfect activity match!")
        elif (user.activity_level == 'low' and pet.activity_level == 'high') or \
             (user.activity_level == 'high' and pet.activity_level == 'low'):
            score -= 10
            reasons.append("Activity levels differ significantly")
    
    # Experience bonus
    if user.experience_with_pets == 'experienced':
        score += 5
        if pet.special_needs:
            score += 10
            reasons.append("Your experience is valuable for special needs")
    elif user.experience_with_pets == 'none':
        if pet.category.care_difficulty == 'easy':
            score += 10
            reasons.append("Great choice for a first-time pet owner!")
        elif pet.category.care_difficulty == 'hard':
            score -= 10
            reasons.append("Consider starting with an easier pet")
    
    # Clamp score between 0 and 100
    score = min(max(score, 0), 100)
    
    return score, reasons


def get_care_tips(pet):
    """
    Generate AI-based care tips for a pet based on its category.
    Prioritizes Groq LLM API if available, otherwise falls back to rule-based logic.
    """
    if groq_service.is_available():
        pet_profile = {
            'name': pet.name,
            'breed': pet.breed,
            'age_years': pet.age_years,
            'category': pet.category.name,
            'activity_level': pet.activity_level,
            'special_needs': pet.special_needs,
            'description': pet.description,
        }
        tips = groq_service.get_care_tips(pet_profile)
        if tips:
            return tips

    tips = []
    category = pet.category.name.lower()
    
    # General tips based on category
    if category == 'dog':
        tips.extend([
            f"Dogs need daily exercise - aim for at least 30 minutes",
            "Regular grooming prevents matting and keeps coat healthy",
            "Schedule annual vet checkups",
            "Socialization is key for a well-behaved dog"
        ])
    elif category == 'cat':
        tips.extend([
            "Cats are independent but still need daily interaction",
            "Keep the litter box clean - scoop daily",
            "Provide scratching posts to save your furniture",
            "Regular playtime helps prevent obesity"
        ])
    elif category == 'bird':
        tips.extend([
            "Birds need social interaction daily",
            "Clean the cage at least once a week",
            "Provide a variety of perches and toys",
            "Keep away from kitchen fumes and smoke"
        ])
    elif category == 'rabbit':
        tips.extend([
            "Rabbits need hay as the main part of their diet",
            "Provide a spacious enclosure with room to hop",
            "Handle gently - rabbits can be fragile",
            "Regular nail trimming is essential"
        ])
    else:
        tips.extend([
            "Research specific care requirements for this pet type",
            "Consult with a veterinarian for detailed care advice",
            "Ensure proper housing and nutrition"
        ])
    
    # Activity-based tips
    if pet.activity_level == 'high':
        tips.append("This pet has high energy - plan for plenty of exercise!")
    elif pet.activity_level == 'low':
        tips.append("This pet is calm - perfect for relaxed environments")
    
    # Age-based tips
    if pet.age_years < 1:
        tips.append("Young pets require extra patience and training")
    elif pet.age_years > 10:
        tips.append("Senior pets may need more frequent vet visits")
    
    return tips


def predict_vaccination_due(pet):
    """
    Predict upcoming vaccinations based on pet's vaccination history.
    """
    from datetime import date, timedelta
    
    predictions = []
    vaccinations = pet.vaccinations.all()
    
    for vaccination in vaccinations:
        if vaccination.next_due_date:
            days_until = (vaccination.next_due_date - date.today()).days
            
            if days_until < 0:
                predictions.append({
                    'vaccine': vaccination.vaccine_name,
                    'status': 'overdue',
                    'days': abs(days_until),
                    'message': f"{vaccination.vaccine_name} is {abs(days_until)} days overdue!"
                })
            elif days_until <= 30:
                predictions.append({
                    'vaccine': vaccination.vaccine_name,
                    'status': 'due_soon',
                    'days': days_until,
                    'message': f"{vaccination.vaccine_name} due in {days_until} days"
                })
    
    # Add common vaccinations if missing
    common_vaccines = {
        'dog': ['Rabies', 'DHPP', 'Bordetella'],
        'cat': ['Rabies', 'FVRCP', 'FeLV'],
    }
    
    category = pet.category.name.lower()
    if category in common_vaccines:
        existing = [v.vaccine_name for v in vaccinations]
        for vaccine in common_vaccines[category]:
            if vaccine not in existing:
                predictions.append({
                    'vaccine': vaccine,
                    'status': 'missing',
                    'message': f"{vaccine} vaccination record not found"
                })
    
    return predictions
