import os
import sys
import threading
import time
import urllib.request
from django.apps import AppConfig


def health_check_task():
    while True:
        try:
            url = 'https://pet-vew4.onrender.com/api'
            req = urllib.request.Request(url, headers={'User-Agent': 'HealthCheckPing/1.0'})
            urllib.request.urlopen(req, timeout=10)
            print("Auto health check: Pinged successfully to web service")
        except Exception as e:
            print(f"Auto health check failed: {e}")
        # Wait for 4 minutes (240 seconds)
        time.sleep(240)


class CoreConfig(AppConfig):
    name = 'core'

    def ready(self):
        import core.signals

        # Auto health check to ping every 4 mins to keep the app alive
        is_manage = any(arg.endswith('manage.py') for arg in sys.argv)
        is_runserver = 'runserver' in sys.argv

        if not is_manage or is_runserver:
            # Prevent duplicate thread in Django's auto-reloader
            if is_runserver and os.environ.get('RUN_MAIN') != 'true':
                pass
            else:
                thread = threading.Thread(target=health_check_task, daemon=True)
                thread.start()
