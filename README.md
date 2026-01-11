# AI-Enabled Pet Adoption & Care Management System

A complete mobile-based application designed to manage the pet adoption lifecycle, health tracking, and care management.

## Tech Stack

- **Backend**: Python Django (REST API)
- **Frontend**: Flutter (Mobile Application)
- **Database**: SQLite3
- **Authentication**: JWT (JSON Web Tokens)

## Features

### Admin Portal
- Dashboard with complete statistics
- Pet category management
- Pet registration (auto-approved)
- User-posted pet verification (approve/reject)
- Adoption request management
- Vaccination records & alerts
- Care, feeding & grooming management
- Medical history & health logs
- AI-based logic (compatibility scoring, care tips)
- Reports (PDF/CSV export)

### User Portal
- Registration & Login (JWT)
- Browse & search approved pets
- Post pets for adoption (requires approval)
- AI-based pet recommendations
- Adoption requests with compatibility score
- Adopted pet management
- Return adoption requests

## Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Care Green (Primary) | `#6FCF97` | Primary buttons, app bars, success |
| Trust Blue (Secondary) | `#56CCF2` | AI suggestions, status indicators |
| Warm Amber (Accent) | `#F2C94C` | Pending approvals, warnings |
| Soft Red (Critical) | `#EB5757` | Rejections, critical alerts |
| Comfort White (Background) | `#F9FAFB` | Main background |
| Charcoal Black (Text) | `#333333` | Body text |

## Typography

- **Primary Font**: Poppins (Headings, buttons)
- **Secondary Font**: Roboto (Body text, forms)

---

## Installation

### Prerequisites
- Python 3.10+
- Flutter SDK 3.10+
- pip

---

## Backend Setup (Django)

1. **Create and activate virtual environment**:
   ```bash
   # Windows
   python -m venv venv
   .\venv\Scripts\pip.exe install -r requirements.txt
   
   # Linux/Mac
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

2. **Run migrations**:
   ```bash
   .\venv\Scripts\python.exe manage.py migrate
   ```

3. **Setup initial data** (creates admin user and sample data):
   ```bash
   .\venv\Scripts\python.exe manage.py setup_initial_data
   ```

4. **Run the development server**:
   ```bash
   .\venv\Scripts\python.exe manage.py runserver
   ```

---

## Frontend Setup (Flutter)

1. **Navigate to the Flutter app**:
   ```bash
   cd pet_app
   ```

2. **Get dependencies**:
   ```bash
   flutter pub get
   ```

3. **Update API URL** (in `lib/core/constants/api_constants.dart`):
   - For Android emulator: `http://10.0.2.2:8000/api`
   - For iOS simulator: `http://localhost:8000/api`
   - For physical device: `http://YOUR_IP:8000/api`

4. **Run the app**:
   ```bash
   flutter run
   ```

---

## Default Credentials

- **Admin**: `admin` / `admin123`

---

## API Endpoints

### Authentication
- `POST /api/auth/register/` - User registration
- `POST /api/auth/login/` - Login (returns JWT tokens)
- `POST /api/auth/refresh/` - Refresh JWT token
- `GET/PUT /api/auth/profile/` - User profile

### Dashboard
- `GET /api/dashboard/admin/` - Admin dashboard stats
- `GET /api/dashboard/user/` - User dashboard stats

### Pets
- `GET /api/pets/` - List all available pets
- `POST /api/pets/` - Create new pet post
- `GET /api/pets/{id}/` - Get pet details
- `POST /api/pets/{id}/approve/` - Admin approve pet
- `POST /api/pets/{id}/reject/` - Admin reject pet
- `GET /api/pets/my_posts/` - User's posted pets
- `GET /api/pets/my_adopted/` - User's adopted pets

### Adoption
- `GET /api/adoption-requests/` - List adoption requests
- `POST /api/adoption-requests/` - Create adoption request
- `POST /api/adoption-requests/{id}/process/` - Admin process request

### Health Management
- `GET/POST /api/vaccinations/` - Vaccination records
- `GET /api/vaccinations/due_soon/` - Upcoming vaccinations
- `GET /api/vaccinations/overdue/` - Overdue vaccinations
- `GET/POST /api/medical-records/` - Medical records
- `GET/POST /api/care-logs/` - Care logs

### AI Features
- `GET /api/recommendations/` - AI pet recommendations based on user profile

### Categories & Care
- `GET /api/categories/` - Pet categories
- `GET /api/care-schedules/` - Care schedules by category

---

## Project Structure

```
Pet/
├── core/                           # Django app
│   ├── management/commands/        # Custom management commands
│   ├── migrations/                 # Database migrations
│   ├── admin.py                    # Admin configuration
│   ├── models.py                   # Database models
│   ├── serializers.py              # REST API serializers
│   ├── views.py                    # REST API views
│   ├── urls.py                     # API URL routing
│   ├── permissions.py              # Custom permissions
│   └── utils.py                    # Utility functions
├── pet_adoption_backend/           # Django project settings
│   ├── settings.py                 # Project settings
│   ├── urls.py                     # Main URL routing
│   └── wsgi.py                     # WSGI configuration
├── pet_app/                        # Flutter mobile app
│   ├── lib/
│   │   ├── core/
│   │   │   ├── constants/          # App constants (colors, API)
│   │   │   ├── providers/          # State management
│   │   │   ├── router/             # Navigation
│   │   │   ├── services/           # API service
│   │   │   └── theme/              # App theme
│   │   ├── models/                 # Data models
│   │   ├── screens/                # App screens
│   │   │   ├── admin/              # Admin screens
│   │   │   ├── adoption/           # Adoption screens
│   │   │   ├── auth/               # Login/Register
│   │   │   ├── home/               # Home screen
│   │   │   ├── pets/               # Pet screens
│   │   │   └── profile/            # Profile screen
│   │   ├── widgets/                # Reusable widgets
│   │   └── main.dart               # App entry point
│   └── pubspec.yaml                # Flutter dependencies
├── media/                          # Uploaded files
├── venv/                           # Python virtual environment
├── db.sqlite3                      # SQLite database
├── manage.py                       # Django management script
├── requirements.txt                # Python dependencies
├── Application.txt                 # Original specification
└── README.md                       # This file
```

---

## Flutter App Screens

1. **Splash Screen** - Animated loading screen
2. **Login Screen** - User authentication
3. **Register Screen** - New user registration
4. **Home Screen** - Main hub with tabs:
   - Home (pets, categories, AI recommendations)
   - Search (find pets)
   - My Pets (posted and adopted)
   - Profile (user settings)
5. **Pet List Screen** - Grid view of all pets
6. **Pet Detail Screen** - Full pet information with adopt button
7. **Add Pet Screen** - Post new pet for adoption
8. **Profile Screen** - Edit profile and lifestyle preferences
9. **My Requests Screen** - Track adoption requests
10. **Admin Dashboard** - Statistics and quick actions
11. **Pending Approvals** - Review and approve/reject pets

---

## License

This project is for academic purposes.
