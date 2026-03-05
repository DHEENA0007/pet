
import json
import logging
from django.conf import settings
from groq import Groq

logger = logging.getLogger(__name__)

class GroqService:
    def __init__(self):
        self.api_key = getattr(settings, 'GROQ_API_KEY', None)
        self.client = None
        if self.api_key:
            try:
                self.client = Groq(api_key=self.api_key)
            except Exception as e:
                logger.error(f"Failed to initialize Groq client: {e}")

    def is_available(self):
        return self.client is not None

    def analyze_compatibility(self, user_profile, pet_profile):
        """
        Analyze compatibility between user and pet using Groq LLM.
        Returns a tuple (score, reasons).
        """
        if not self.is_available():
            logger.warning("Groq API not available, falling back to rule-based logic")
            return None, None

        prompt = f"""
        Analyze the compatibility between a potential pet adopter and a pet.
        
        User Profile:
        - Living Space: {user_profile.get('living_space', 'Unknown')}
        - Has Yard: {'Yes' if user_profile.get('has_yard') else 'No'}
        - Has Children: {'Yes' if user_profile.get('has_children') else 'No'}
        - Has Other Pets: {'Yes' if user_profile.get('has_other_pets') else 'No'}
        - Activity Level: {user_profile.get('activity_level', 'Unknown')}
        - Pet Experience: {user_profile.get('experience_with_pets', 'Unknown')}
        
        Pet Profile:
        - Name: {pet_profile.get('name')}
        - Breed: {pet_profile.get('breed')}
        - Age: {pet_profile.get('age_years')} years
        - Size: {pet_profile.get('size')}
        - Activity Level: {pet_profile.get('activity_level', 'Unknown')}
        - Space Requirement: {pet_profile.get('space_requirement', 'Unknown')}
        - Good with Children: {'Yes' if pet_profile.get('good_with_children') else 'No'}
        - Good with Other Pets: {'Yes' if pet_profile.get('good_with_other_pets') else 'No'}
        - Special Needs: {'Yes' if pet_profile.get('special_needs') else 'No'}
        - Description: {pet_profile.get('description', '')}
        
        Provide a JSON response with:
        1. "score": An integer between 0 and 100 representing compatibility.
        2. "reasons": A list of short strings explaining the pros and cons of this match.
        Focus on safety, lifestyle fit, and animal welfare.
        """

        try:
            chat_completion = self.client.chat.completions.create(
                messages=[
                    {
                        "role": "system",
                        "content": "You are an expert pet adoption counselor. Output only valid JSON.",
                    },
                    {
                        "role": "user",
                        "content": prompt,
                    }
                ],
                model="llama-3.3-70b-versatile",
                response_format={"type": "json_object"},
            )
            
            response_content = chat_completion.choices[0].message.content
            data = json.loads(response_content)
            
            score = data.get('score', 50)
            reasons = data.get('reasons', [])
            
            # Sanity checks
            score = max(0, min(100, int(score)))
            if not isinstance(reasons, list):
                reasons = [str(reasons)]
                
            return score, reasons

        except Exception as e:
            logger.error(f"Error calling Groq API for compatibility: {e}")
            return None, None

    def get_care_tips(self, pet_profile):
        """
        Generate personalized care tips for a pet using Groq LLM.
        Returns a list of tips.
        """
        if not self.is_available():
            return None

        prompt = f"""
        Provide 5 essential, personalized care tips for this pet:
        
        - Type: {pet_profile.get('category')}
        - Breed: {pet_profile.get('breed')}
        - Age: {pet_profile.get('age_years')} years
        - Special Needs: {'Yes' if pet_profile.get('special_needs') else 'No'}
        - Activity Context: {pet_profile.get('activity_level', 'Medium')}
        - Description: {pet_profile.get('description', '')}
        
        Provide a JSON response with:
        "tips": A list of strings, each being a concise, actionable care tip.
        """

        try:
            chat_completion = self.client.chat.completions.create(
                messages=[
                    {
                        "role": "system",
                        "content": "You are a veterinarian and pet care expert. Output only valid JSON.",
                    },
                    {
                        "role": "user",
                        "content": prompt,
                    }
                ],
                model="llama-3.3-70b-versatile",
                response_format={"type": "json_object"},
            )
            
            response_content = chat_completion.choices[0].message.content
            data = json.loads(response_content)
            
            tips = data.get('tips', [])
            if not isinstance(tips, list):
                tips = []
                
            return tips

        except Exception as e:
            logger.error(f"Error calling Groq API for care tips: {e}")
            return None

    def generate_category_description(self, category_name):
        """
        Generate a short, engaging description for a pet category using Groq LLM.
        Returns a string description.
        """
        if not self.is_available():
            return None

        prompt = f"""
        Generate a very short, engaging description (max 10 words) for the pet category: "{category_name}".
        Focus on the general temperament.
        Do not include quotes around the description.
        """

        try:
            chat_completion = self.client.chat.completions.create(
                messages=[
                    {
                        "role": "system",
                        "content": "You are a pet adoption marketing expert. be concise.",
                    },
                    {
                        "role": "user",
                        "content": prompt,
                    }
                ],
                model="llama-3.3-70b-versatile",
            )
            
            response_content = chat_completion.choices[0].message.content
            return response_content.strip('" ')

        except Exception as e:
            logger.error(f"Error calling Groq API for category description: {e}")
            return None

    def generate_category_image_url(self, category_name):
        """
        Generate an image URL for a pet category using Pollinations.ai (free).
        Returns the image URL.
        """
        import urllib.parse
        
        # Use LoremFlickr as a reliable fallback since Pollinations.ai is rate-limiting (530)
        # We use strict dimensions and the category name as the search term
        return f"https://loremflickr.com/400/400/{category_name}"
