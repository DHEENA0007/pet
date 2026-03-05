"""
WSGI config for pet_adoption_backend project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/6.0/howto/deployment/wsgi/
"""

import os

from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'pet_adoption_backend.settings')

application = get_wsgi_application()

# Start background health check thread if in production (Render)
if os.environ.get('RUN_BACKGROUND_TASKS', 'False') == 'True':
    import threading
    import time
    from core.services.health_service import HealthCheckService

    def run_health_checks_loop():
        # Delay start to ensure Django is fully loaded
        time.sleep(10)
        while True:
            try:
                HealthCheckService.run_all_checks()
            except Exception as e:
                print(f"Error in background health check: {e}")
            time.sleep(300) # 5 minutes

    thread = threading.Thread(target=run_health_checks_loop, daemon=True)
    thread.start()
    print("Background health check service started.")
