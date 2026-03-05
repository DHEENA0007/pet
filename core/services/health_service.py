from datetime import date
from django.utils import timezone
from ..models import Pet, Vaccination, CareSchedule, Notification, User

class HealthCheckService:
    @staticmethod
    def run_all_checks():
        """Run all automated health and care checks"""
        print(f"[{timezone.now()}] Starting automated health checks...")
        HealthCheckService.check_vaccinations()
        HealthCheckService.check_care_schedules()
        print(f"[{timezone.now()}] Health checks completed.")

    @staticmethod
    def check_vaccinations():
        """Check for upcoming or overdue vaccinations"""
        today = date.today()
        # Find vaccinations due in the next 3 days or already overdue
        due_vaccinations = Vaccination.objects.filter(
            next_due_date__lte=today + timezone.timedelta(days=3)
        ).select_related('pet', 'pet__current_owner')

        for vacc in due_vaccinations:
            owner = vacc.pet.current_owner or vacc.pet.posted_by
            title = "Vaccination Due Soon" if vacc.next_due_date >= today else "Vaccination Overdue!"
            message = f"Pet {vacc.pet.name} needs {vacc.vaccine_name} by {vacc.next_due_date}."
            
            # Use get_or_create to avoid duplicate notifications for the same day
            Notification.objects.get_or_create(
                user=owner,
                notification_type='vaccination_due',
                title=title,
                message=message,
                pet=vacc.pet,
                created_at__date=today
            )

    @staticmethod
    def check_care_schedules():
        """Generic care reminder (demonstration logic)"""
        # This could be expanded based on specific logic per category
        pass
