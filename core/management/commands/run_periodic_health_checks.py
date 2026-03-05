import time
import signal
import sys
from django.core.management.base import BaseCommand
from core.services.health_service import HealthCheckService

class Command(BaseCommand):
    help = 'Runs pet health and care checkups in an automated cycle'

    def handle(self, *args, **options):
        self.stdout.write(self.style.SUCCESS('Starting the health check daemon (Interval: 5 minutes)...'))
        
        # Initial run
        HealthCheckService.run_all_checks()
        
        # Setup signal handlers for graceful exit
        def handler(signum, frame):
            self.stdout.write(self.style.WARNING('\nStopping the daemon...'))
            sys.exit(0)
            
        signal.signal(signal.SIGINT, handler)
        signal.signal(signal.SIGTERM, handler)
        
        try:
            while True:
                time.sleep(300)  # Wait for 5 minutes (300 seconds)
                self.stdout.write('Running automated cycle...')
                HealthCheckService.run_all_checks()
        except KeyboardInterrupt:
            handler(None, None)
