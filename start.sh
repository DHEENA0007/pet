#!/usr/bin/env bash
# Exit on error
set -o errexit

# Reset / Create Django admin user
python manage.py shell << END
from django.contrib.auth import get_user_model
User = get_user_model()

username = "admin"
password = "admin123"

user, created = User.objects.get_or_create(username=username)

user.is_staff = True
user.is_superuser = True
user.set_password(password)
user.save()

print("Admin user reset successfully")
END

# Start server using Gunicorn
gunicorn pet_adoption_backend.wsgi:application --bind 0.0.0.0:$PORT