from django.core.management.base import BaseCommand
from core.models import PetCategory
from core.services.ai_service import GroqService

class Command(BaseCommand):
    help = 'Update pet category descriptions using AI'

    def handle(self, *args, **options):
        self.stdout.write('Updating category descriptions...')
        
        groq_service = GroqService()
        if not groq_service.is_available():
            self.stdout.write(self.style.ERROR('Groq API not available. Please check your settings.'))
            return

        categories = PetCategory.objects.all()
        for category in categories:
            self.stdout.write(f"Processing {category.name}...")
            
            # Always update description to ensure it matches the new short format
            description = groq_service.generate_category_description(category.name)
            if description:
                category.description = description
                category.save(update_fields=['description'])
                self.stdout.write(self.style.SUCCESS(f"  [+] Updated description for {category.name}"))
            
            # Check for missing or corrupt (tiny) images
            needs_image = False
            if not category.icon:
                needs_image = True
            elif category.icon:
                try:
                    if category.icon.size < 1000:  # Less than 1KB is definitely corrupt
                        self.stdout.write(self.style.WARNING(f"  [!] Found corrupt image for {category.name} ({category.icon.size} bytes). Regenerating..."))
                        needs_image = True
                except Exception:
                    needs_image = True

            if needs_image:
                url = groq_service.generate_category_image_url(category.name)
                if url:
                    import subprocess
                    import os
                    from django.core.files.base import ContentFile
                    
                    try:
                        # Use curl as fallback since python requests are getting 530 errors
                        temp_file = f"/tmp/{category.name.lower()}_temp.jpg"
                        
                        # Cleanup specific temp file if exists
                        if os.path.exists(temp_file):
                            os.remove(temp_file)
                            
                        # standardized user agent
                        user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
                        
                        cmd = [
                            'curl', 
                            '-L', 
                            '-A', user_agent,
                            '-o', temp_file,
                            url
                        ]
                        
                        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                        
                        if result.returncode == 0 and os.path.exists(temp_file):
                            with open(temp_file, 'rb') as f:
                                content = f.read()
                                if len(content) > 0:
                                    file_name = f"{category.name.lower()}_ai.jpg"
                                    category.icon.save(file_name, ContentFile(content), save=True)
                                    self.stdout.write(self.style.SUCCESS(f"  [+] Generated image for {category.name}"))
                                else:
                                    self.stdout.write(self.style.ERROR(f"  [-] Empty file downloaded for {category.name}"))
                            
                            # Cleanup
                            os.remove(temp_file)
                        else:
                            self.stdout.write(self.style.ERROR(f"  [-] Curl failed: {result.stderr.decode()}"))
                            
                    except Exception as e:
                        self.stdout.write(self.style.ERROR(f"  [-] Exception generating image for {category.name}: {e}"))

        self.stdout.write(self.style.SUCCESS('\n[OK] Category update complete!'))
