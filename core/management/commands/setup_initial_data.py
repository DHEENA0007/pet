"""
Management command to set up initial data for the Pet Adoption System
Creates admin user, pet categories, care schedules, and sample data
"""

from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import date, timedelta
from core.models import (
    User, PetCategory, Owner, Pet, CareSchedule, Vaccination
)


class Command(BaseCommand):
    help = 'Set up initial data for the Pet Adoption System'

    def handle(self, *args, **options):
        self.stdout.write('Setting up Pet Adoption System...\n')
        
        # Create Admin User
        self.create_admin()
        
        # Create Pet Categories
        self.create_categories()
        
        # Create Owners/Shelters
        self.create_owners()
        
        # Create Care Schedules
        self.create_care_schedules()
        
        # Create Sample Pets
        self.create_sample_pets()
        
        self.stdout.write(self.style.SUCCESS('\n[OK] Setup complete!'))
        self.stdout.write(self.style.SUCCESS('Admin credentials: admin / admin123'))
    
    def create_admin(self):
        self.stdout.write('Creating admin user...')
        
        if not User.objects.filter(username='admin').exists():
            User.objects.create_superuser(
                username='admin',
                email='admin@petadoption.com',
                password='admin123',
                role='admin',
                first_name='System',
                last_name='Administrator'
            )
            self.stdout.write(self.style.SUCCESS('  [+] Admin user created'))
        else:
            self.stdout.write(self.style.WARNING('  [-] Admin user already exists'))
    
    def create_categories(self):
        self.stdout.write('Creating pet categories...')
        
        categories = [
            {
                'name': 'Dog',
                'description': 'Loyal companions known for their affection and playfulness',
                'typical_lifespan': '10-15 years',
                'care_difficulty': 'medium',
                'space_requirement': 'medium',
                'activity_needs': 'high',
            },
            {
                'name': 'Cat',
                'description': 'Independent yet affectionate pets perfect for various living spaces',
                'typical_lifespan': '12-18 years',
                'care_difficulty': 'easy',
                'space_requirement': 'small',
                'activity_needs': 'medium',
            },
            {
                'name': 'Bird',
                'description': 'Colorful and intelligent companions with beautiful songs',
                'typical_lifespan': '5-20 years',
                'care_difficulty': 'medium',
                'space_requirement': 'small',
                'activity_needs': 'medium',
            },
            {
                'name': 'Rabbit',
                'description': 'Gentle and social pets that are great for families',
                'typical_lifespan': '8-12 years',
                'care_difficulty': 'medium',
                'space_requirement': 'small',
                'activity_needs': 'low',
            },
            {
                'name': 'Fish',
                'description': 'Peaceful aquatic pets that add beauty to any space',
                'typical_lifespan': '2-10 years',
                'care_difficulty': 'easy',
                'space_requirement': 'small',
                'activity_needs': 'low',
            },
            {
                'name': 'Hamster',
                'description': 'Small, adorable pets ideal for beginners',
                'typical_lifespan': '2-3 years',
                'care_difficulty': 'easy',
                'space_requirement': 'small',
                'activity_needs': 'medium',
            },
        ]
        
        for cat_data in categories:
            category, created = PetCategory.objects.get_or_create(
                name=cat_data['name'],
                defaults=cat_data
            )
            if created:
                self.stdout.write(self.style.SUCCESS(f"  [+] Created category: {cat_data['name']}"))
    
    def create_owners(self):
        self.stdout.write('Creating owners/shelters...')
        
        owners = [
            {
                'name': 'Happy Paws Shelter',
                'owner_type': 'shelter',
                'email': 'contact@happypaws.org',
                'phone': '+91-9876543210',
                'address': 'Chennai, Tamil Nadu',
            },
            {
                'name': 'Rescue Friends Foundation',
                'owner_type': 'rescue',
                'email': 'info@rescuefriends.org',
                'phone': '+91-9876543211',
                'address': 'Bangalore, Karnataka',
            },
            {
                'name': 'City Animal Shelter',
                'owner_type': 'shelter',
                'email': 'shelter@city.gov',
                'phone': '+91-9876543212',
                'address': 'Mumbai, Maharashtra',
            },
        ]
        
        for owner_data in owners:
            owner, created = Owner.objects.get_or_create(
                name=owner_data['name'],
                defaults=owner_data
            )
            if created:
                self.stdout.write(self.style.SUCCESS(f"  [+] Created owner: {owner_data['name']}"))
    
    def create_care_schedules(self):
        self.stdout.write('Creating care schedules...')
        
        schedules = {
            'Dog': [
                {'care_type': 'feeding', 'frequency': 'twice daily', 
                 'description': 'Feed twice a day with appropriate portion sizes based on weight',
                 'tips': 'Avoid feeding immediately before or after exercise'},
                {'care_type': 'exercise', 'frequency': 'daily', 
                 'description': 'At least 30 minutes of exercise daily',
                 'tips': 'Adjust based on breed and age'},
                {'care_type': 'grooming', 'frequency': 'weekly', 
                 'description': 'Regular brushing to maintain healthy coat',
                 'tips': 'Bath once a month unless needed sooner'},
            ],
            'Cat': [
                {'care_type': 'feeding', 'frequency': 'twice daily', 
                 'description': 'Measured meals twice a day',
                 'tips': 'Always provide fresh water'},
                {'care_type': 'litter', 'frequency': 'daily', 
                 'description': 'Scoop litter box daily, full clean weekly',
                 'tips': 'One box per cat plus one extra'},
                {'care_type': 'grooming', 'frequency': 'weekly', 
                 'description': 'Brush weekly to reduce shedding',
                 'tips': 'Long-haired cats may need daily brushing'},
            ],
            'Bird': [
                {'care_type': 'feeding', 'frequency': 'daily', 
                 'description': 'Fresh food and water daily',
                 'tips': 'Include variety: seeds, fruits, vegetables'},
                {'care_type': 'cage cleaning', 'frequency': 'weekly', 
                 'description': 'Full cage cleaning weekly',
                 'tips': 'Daily spot cleaning of droppings'},
                {'care_type': 'interaction', 'frequency': 'daily', 
                 'description': 'Daily interaction and out-of-cage time',
                 'tips': 'At least 30 minutes of interaction'},
            ],
            'Rabbit': [
                {'care_type': 'feeding', 'frequency': 'daily', 
                 'description': 'Unlimited hay, fresh vegetables, pellets',
                 'tips': 'Hay should be 80% of diet'},
                {'care_type': 'exercise', 'frequency': 'daily', 
                 'description': 'Several hours of exercise time daily',
                 'tips': 'Rabbit-proof the play area'},
                {'care_type': 'grooming', 'frequency': 'weekly', 
                 'description': 'Regular brushing and nail trimming',
                 'tips': 'Check teeth and ears regularly'},
            ],
        }
        
        for category_name, schedule_list in schedules.items():
            try:
                category = PetCategory.objects.get(name=category_name)
                for schedule_data in schedule_list:
                    schedule, created = CareSchedule.objects.get_or_create(
                        category=category,
                        care_type=schedule_data['care_type'],
                        defaults=schedule_data
                    )
                    if created:
                        self.stdout.write(self.style.SUCCESS(f"  [+] Created schedule: {category_name} - {schedule_data['care_type']}"))
            except PetCategory.DoesNotExist:
                pass
    
    def create_sample_pets(self):
        self.stdout.write('Creating sample pets...')
        
        admin = User.objects.get(username='admin')
        
        sample_pets = [
            {
                'name': 'Buddy',
                'category': 'Dog',
                'breed': 'Golden Retriever',
                'age_years': 3,
                'gender': 'male',
                'size': 'large',
                'color': 'Golden',
                'description': 'Friendly and energetic Golden Retriever looking for a loving family',
                'personality': 'Playful, loyal, gentle with children',
                'is_vaccinated': True,
                'is_neutered': True,
                'good_with_children': True,
                'good_with_other_pets': True,
                'activity_level': 'high',
                'space_requirement': 'large',
                'status': 'approved',
            },
            {
                'name': 'Luna',
                'category': 'Cat',
                'breed': 'Persian',
                'age_years': 2,
                'gender': 'female',
                'size': 'medium',
                'color': 'White',
                'description': 'Beautiful Persian cat with a calm demeanor',
                'personality': 'Calm, affectionate, loves to be petted',
                'is_vaccinated': True,
                'is_neutered': True,
                'good_with_children': True,
                'good_with_other_pets': True,
                'activity_level': 'low',
                'space_requirement': 'small',
                'status': 'approved',
            },
            {
                'name': 'Max',
                'category': 'Dog',
                'breed': 'Labrador',
                'age_years': 1,
                'gender': 'male',
                'size': 'large',
                'color': 'Black',
                'description': 'Young and playful Labrador full of energy',
                'personality': 'Energetic, friendly, loves to play fetch',
                'is_vaccinated': True,
                'is_neutered': False,
                'good_with_children': True,
                'good_with_other_pets': True,
                'activity_level': 'high',
                'space_requirement': 'large',
                'status': 'approved',
            },
            {
                'name': 'Whiskers',
                'category': 'Cat',
                'breed': 'Tabby',
                'age_years': 4,
                'gender': 'male',
                'size': 'medium',
                'color': 'Orange Tabby',
                'description': 'Sweet tabby cat who loves cuddles',
                'personality': 'Gentle, curious, loves window watching',
                'is_vaccinated': True,
                'is_neutered': True,
                'good_with_children': True,
                'good_with_other_pets': False,
                'activity_level': 'medium',
                'space_requirement': 'small',
                'status': 'pending',  # Pending approval
            },
            {
                'name': 'Coco',
                'category': 'Bird',
                'breed': 'Cockatiel',
                'age_years': 1,
                'gender': 'female',
                'size': 'small',
                'color': 'Grey and Yellow',
                'description': 'Beautiful cockatiel with lovely songs',
                'personality': 'Friendly, loves to sing, social',
                'is_vaccinated': False,
                'is_neutered': False,
                'good_with_children': True,
                'good_with_other_pets': True,
                'activity_level': 'medium',
                'space_requirement': 'small',
                'status': 'approved',
            },
        ]
        
        for pet_data in sample_pets:
            category_name = pet_data.pop('category')
            try:
                category = PetCategory.objects.get(name=category_name)
                
                if not Pet.objects.filter(name=pet_data['name'], category=category).exists():
                    pet = Pet.objects.create(
                        category=category,
                        posted_by=admin,
                        approved_at=timezone.now() if pet_data['status'] == 'approved' else None,
                        **pet_data
                    )
                    
                    # Add vaccinations for approved pets
                    if pet_data['is_vaccinated'] and pet_data['status'] == 'approved':
                        Vaccination.objects.create(
                            pet=pet,
                            vaccine_name='Rabies',
                            administered_date=date.today() - timedelta(days=180),
                            next_due_date=date.today() + timedelta(days=185),
                            administered_by='Dr. Smith',
                        )
                    
                    self.stdout.write(self.style.SUCCESS(f"  [+] Created pet: {pet_data['name']}"))
            except PetCategory.DoesNotExist:
                self.stdout.write(self.style.ERROR(f"  [X] Category not found: {category_name}"))
