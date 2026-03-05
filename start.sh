#!/usr/bin/env bash
# Exit on error
set -o errexit

# Start server using Gunicorn
gunicorn pet_adoption_backend.wsgi:application --bind 0.0.0.0:$PORT
