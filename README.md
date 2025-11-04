# PureHealth - Maharashtra Water Quality Monitoring System

A comprehensive water quality monitoring and analysis platform for Maharashtra, India. This application provides real-time water quality data visualization, AI-powered predictions, risk assessments, and trend analysis for monitoring stations across Maharashtra, following Maharashtra Pollution Control Board (MPCB) standards.

## Overview

PureHealth integrates a Flutter-based frontend with a Python/Flask ML backend to deliver:

- Real-time water quality monitoring across 30+ stations in Maharashtra
- Interactive map visualization with live location tracking
- AI-powered 60-day water quality predictions
- Risk assessment and trend analysis
- Comprehensive PDF report generation
- Historical data analysis and insights
- MPCB-compliant water quality standards monitoring

## Features

### Frontend (Flutter)
- Interactive map with Maharashtra monitoring stations
- Real-time GPS location with pulsing blue dot indicator
- Color-coded station markers (Green: Safe, Amber: Warning, Red: Critical)
- Detailed station information panels with live data
- Dashboard with system status and statistics
- AI Analysis page with predictions, trends, and recommendations
- History page for viewing saved reports
- Responsive design for web and mobile platforms

### Backend (Python/Flask)
- 5 AI-powered services:
  - Water quality predictions (60-day forecast)
  - Risk assessment analysis
  - Trend analysis (improving/stable/declining)
  - Personalized recommendations
  - Professional PDF report generation
- RESTful API endpoints
- Real-time data processing
- CSV data import and analysis

## Technology Stack

### Frontend
- Flutter 3.9.2
- Dart SDK
- Provider (State Management)
- FlutterMap (OpenStreetMap integration)
- Geolocator (GPS location services)
- Dio (HTTP client)
- PDF generation and printing

### Backend
- Python 3.13
- Flask 3.1.2
- NumPy & Pandas (Data processing)
- Scikit-learn (Machine learning)
- FPDF (PDF generation)
- CSV data handling

## Prerequisites

### For Flutter App
- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher
- Chrome browser (for web development)
- Android Studio or Xcode (for mobile development)

### For Python Backend
- Python 3.13 or higher
- pip package manager

## Installation

### 1. Clone the Repository
```bash
git clone https://github.com/SahilKumar75/pure_health.git
cd pure_health
```

### 2. Setup Flutter Frontend

```bash
# Install Flutter dependencies
flutter pub get

# Verify Flutter installation
flutter doctor
```

### 3. Setup Python Backend

```bash
# Navigate to backend directory
cd ml_backend

# Install Python dependencies
pip install -r requirements.txt
```

## Running the Application

### Step 1: Start the Backend Server

```bash
# From the ml_backend directory
cd ml_backend

# Run the Flask server
python app.py
```

The backend server will start on `http://localhost:8000`

### Step 2: Run the Flutter App

Open a new terminal window:

```bash
# From the project root directory
cd pure_health

# Run on Chrome (recommended for development)
flutter run -d chrome

# Or run on other platforms:
# flutter run -d macos     # macOS
# flutter run -d windows   # Windows
# flutter run -d linux     # Linux
```

## Project Structure

```
pure_health/
├── lib/
│   ├── app/                    # App configuration
│   ├── config/                 # Environment and route configuration
│   ├── core/                   # Core utilities and data models
│   │   ├── constants/          # Color constants and borders
│   │   ├── data/              # Maharashtra water data
│   │   └── models/            # Monitoring location models
│   ├── features/              # Feature modules
│   │   ├── ai_analysis/       # AI predictions and analysis
│   │   ├── authentication/    # User authentication
│   │   ├── dashboard/         # Main dashboard
│   │   ├── history/           # Historical reports
│   │   └── home/              # Home page with map
│   └── shared/                # Shared widgets and utilities
├── ml_backend/
│   ├── app.py                 # Main Flask application
│   ├── ml_models.py           # ML prediction models
│   ├── risk_assessment_service.py  # Risk analysis
│   ├── trend_analysis_service.py   # Trend detection
│   ├── recommendations_service.py  # Recommendations engine
│   ├── pdf_generation_service.py   # PDF report generator
│   ├── requirements.txt       # Python dependencies
│   └── test_water_quality.csv # Sample water quality data
└── README.md
```

## API Endpoints

The backend provides the following REST APIs:

- `POST /api/predict` - Get 60-day water quality predictions
- `POST /api/risk-assessment` - Analyze contamination risks
- `POST /api/trend-analysis` - Detect quality trends
- `POST /api/recommendations` - Get personalized recommendations
- `POST /api/generate-pdf-report` - Generate comprehensive PDF report
- `GET /api/reports/:filename` - Download saved reports
- `GET /api/reports` - List all saved reports

## Water Quality Parameters

The system monitors the following parameters according to WHO/BIS/MPCB standards:

- pH Level (6.5 - 8.5)
- Turbidity (Max 5 NTU)
- Dissolved Oxygen (Min 4 mg/L)
- Temperature (20-30 degrees C)
- Conductivity
- BOD (Biological Oxygen Demand)
- Nitrate levels
- Fecal Coliform count

## Monitoring Stations

The application tracks 30+ water monitoring stations across Maharashtra, including:

- Mumbai: Powai Lake, Vihar Lake, Tulsi Lake, Mithi River, Bhandup WTP
- Pune: Mula-Mutha River, Khadakwasla Dam, Panshet Dam
- Nagpur: Ambazari Lake, Nag River, Gorewada Lake
- Nashik: Godavari River, Gangapur Dam, Darna Dam
- And many more across all districts

## Location Permissions

The app requires location permissions to show your current position on the map:

### Web Browser
When running in Chrome, you'll see a permission prompt:
- Click "Allow" to use your actual GPS location
- Click "Block" to use the default location (Pune, Maharashtra)

### Mobile Devices
The app will automatically request location permissions on first launch.

## Development

### Hot Reload
While running the Flutter app in development mode:
- Press `r` in the terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Building for Production

```bash
# Web
flutter build web

# Android
flutter build apk

# iOS
flutter build ios

# Desktop
flutter build macos
flutter build windows
flutter build linux
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Contact

Sahil Kumar Singh - SahilKumar75

Project Link: https://github.com/SahilKumar75/pure_health

## Acknowledgments

- Maharashtra Pollution Control Board (MPCB) for water quality standards
- OpenStreetMap for mapping services
- Flutter and Dart communities
- All contributors and testers
