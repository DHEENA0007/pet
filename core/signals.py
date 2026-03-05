import logging
import urllib.request
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.core.files.base import ContentFile
from .models import PetCategory
from .services.ai_service import GroqService

logger = logging.getLogger(__name__)

@receiver(post_save, sender=PetCategory)
def generate_category_assets(sender, instance, created, **kwargs):
    """
    Automatically generate description and icon for new categories using AI.
    """
    if created:
        try:
            groq = GroqService()
            updated = False
            
            # 1. Generate Description (if missing)
            if not instance.description:
                desc = groq.generate_category_description(instance.name)
                if desc:
                    instance.description = desc
                    updated = True
            
            # 2. Generate Image (DISABLED as per request)
            # User wants manual upload or blank image
            # if not instance.icon:
            #    ... image generation logic removed ...
            pass
            
            # Save changes if any
            if updated:
                instance.save(update_fields=['description', 'icon'])
                logger.info(f"AI enhanced category: {instance.name}")

        except Exception as e:
            logger.error(f"Error in generate_category_assets signal: {e}")
