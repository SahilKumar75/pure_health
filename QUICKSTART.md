# 🚀 Quick Start Guide - AI Water Quality Analysis

## Prerequisites
- Flutter SDK installed
- Python 3.8+ installed
- VS Code or Android Studio

## 🔧 Backend Setup

### 1. Install Python Dependencies
```bash
cd ml_backend
pip install -r requirements.txt
```

This will install:
- Flask (web framework)
- Flask-CORS (cross-origin support)
- pandas (data processing)
- numpy (numerical operations)
- werkzeug (file handling)

### 2. Start the Backend Server
```bash
python app.py
```

Server will start on: `http://172.20.10.4:8000`

**Available Endpoints:**
- `POST /api/ai/upload` - Upload water quality data file
- `POST /api/ai/analyze` - Generate comprehensive analysis
- `POST /api/ai/save-report` - Save report to history
- `GET /api/ai/reports` - Get all saved reports
- `DELETE /api/ai/reports/:id` - Delete a report

## 📱 Flutter Frontend Setup

### 1. Get Dependencies
```bash
flutter pub get
```

### 2. Run the App
```bash
flutter run -d chrome
# or
flutter run -d macos
```

## 🎯 Using the AI Analysis Feature

### Step 1: Navigate to AI Analysis Page
- Open the app
- Click on the AI Analysis icon in the sidebar (should be index 4)

### Step 2: Upload Data
1. Click "Choose File" button
2. Select a CSV or Excel file with water quality data
3. File should have columns like: pH, DO, BOD, Temperature, Turbidity, TDS, etc.

**Sample CSV Format:**
```csv
pH,DO,BOD,Temperature,Turbidity,TDS
7.2,6.5,2.1,25.3,3.2,450
7.5,6.8,2.3,26.1,3.5,460
7.1,6.2,2.5,25.8,3.8,455
```

### Step 3: Select Location (Optional but Recommended)
1. Search for a water body by name
2. Or filter by type: Rivers, Lakes, Dams, Reservoirs, Coastal
3. Click on a location to select it
4. View coordinates and details

**Example Locations:**
- Godavari River - Nashik
- Krishna River - Sangli
- Koyna Dam
- Powai Lake
- Jayakwadi Dam

### Step 4: Generate Analysis
1. Click "Generate Comprehensive Analysis" button
2. Wait for processing (usually 5-10 seconds)
3. View results in tabbed interface

### Step 5: Review Results

**Overview Tab:**
- Prediction period (2 months)
- Risk level and score
- Overall trend
- Number of recommendations
- Location map (if selected)

**Predictions Tab:**
- 2-month forecasts for each parameter
- Trend indicators
- Confidence scores

**Risk Assessment Tab:**
- Overall risk level: Low/Medium/High/Critical
- Risk score (0-100)
- Individual parameter risk factors
- Current vs. threshold values
- Detailed descriptions

**Trends Tab:**
- Parameter trends (improving/stable/declining)
- Change percentages
- Historical data visualization
- Overall trend summary

**Recommendations Tab:**
- High priority actions (immediate)
- Medium priority actions (short-term)
- Low priority actions (long-term)
- Categories: Treatment, Monitoring, Infrastructure, Policy
- Detailed action items for each

### Step 6: Save Report
1. Click "Save Report" button in header
2. Report is saved with timestamp and location
3. Access later from history page

## 📊 Sample Test Data

Create a test CSV file (`sample_water_quality.csv`):

```csv
pH,DO,BOD,Temperature,Turbidity,TDS,Nitrate,Phosphate
7.2,6.5,2.1,25.3,3.2,450,5.2,0.8
7.5,6.8,2.3,26.1,3.5,460,5.5,0.9
7.1,6.2,2.5,25.8,3.8,455,5.8,1.0
7.3,6.7,2.2,25.5,3.3,448,5.4,0.85
7.4,6.6,2.4,25.9,3.6,462,5.6,0.92
7.0,6.4,2.6,26.2,4.0,470,6.0,1.1
7.2,6.5,2.3,25.7,3.4,452,5.3,0.88
```

## 🗺️ Maharashtra Water Bodies Coverage

The system includes **70+ water bodies** across Maharashtra:

### By Region:
- **North Maharashtra**: 15+ locations
- **Western Maharashtra**: 20+ locations  
- **Marathwada**: 12+ locations
- **Vidarbha**: 15+ locations
- **Konkan**: 8+ locations

### By Type:
- **Rivers** (25+): Godavari, Krishna, Bhima, Tapi, Narmada, etc.
- **Dams** (20+): Jayakwadi, Koyna, Mulshi, Ujjani, etc.
- **Lakes** (12+): Lonar, Powai, Vihar, Rankala, etc.
- **Reservoirs** (5+): Mula, Pravara, etc.
- **Coastal** (4): Mumbai, Ratnagiri, Sindhudurg, Palghar

Each location includes:
- Precise latitude and longitude
- District name
- Region classification
- Water body type

## 🛠️ Troubleshooting

### Backend Issues:

**"Module not found" error:**
```bash
pip install -r requirements.txt
```

**"Port already in use":**
- Kill existing process: `lsof -ti:8000 | xargs kill -9`
- Or change port in `app.py`: `app.run(host='0.0.0.0', port=8001)`

**CORS errors:**
- Check that Flask-CORS is installed
- Verify CORS settings in `app.py`

### Frontend Issues:

**"URI doesn't exist" errors:**
```bash
flutter pub get
flutter clean
flutter run
```

**API connection failed:**
- Check backend is running: `http://172.20.10.4:8000/api/status`
- Update IP address in `ai_analysis_service.dart` if needed
- Check firewall settings

**File upload fails:**
- Check file format (CSV, Excel, JSON, PDF, TXT only)
- File size limit: 16MB max
- Check file has proper column headers

## 📝 API Testing

Test the backend independently using curl:

### Upload File:
```bash
curl -X POST http://172.20.10.4:8000/api/ai/upload \
  -F "file=@sample_water_quality.csv"
```

### Generate Analysis:
```bash
curl -X POST http://172.20.10.4:8000/api/ai/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "file_data": {
      "data": {
        "pH": [7.2, 7.5, 7.1],
        "DO": [6.5, 6.8, 6.2]
      }
    },
    "location": {
      "name": "Godavari River - Nashik",
      "type": "river",
      "latitude": 19.9975,
      "longitude": 73.7898,
      "district": "Nashik",
      "region": "North Maharashtra"
    }
  }'
```

### Get Saved Reports:
```bash
curl http://172.20.10.4:8000/api/ai/reports
```

## 🎨 Customization

### Change Backend IP:
Edit `lib/features/ai_analysis/data/services/ai_analysis_service.dart`:
```dart
AIAnalysisService({
  String baseUrl = 'http://YOUR_IP:8000',  // Change here
})
```

### Add More Water Bodies:
Edit `lib/features/ai_analysis/data/water_bodies_maharashtra.dart`:
```dart
WaterBodyLocation(
  name: 'Your Water Body',
  type: 'river', // or lake, dam, reservoir, coastal
  latitude: 00.0000,
  longitude: 00.0000,
  district: 'District Name',
  region: 'Region Name',
),
```

### Customize Risk Thresholds:
Edit `ml_backend/ai_analysis_service.py` in `_generate_risk_assessment()`:
```python
thresholds = {
    'pH': {'min': 6.5, 'max': 8.5, 'optimal': 7.0},
    # Add or modify thresholds
}
```

## 📖 Next Steps

1. **Map Integration**: Add interactive map with markers
2. **Charts**: Visualize trends and predictions
3. **Export**: PDF report generation
4. **Authentication**: User login and permissions
5. **Database**: Replace JSON files with proper database
6. **Real-time**: WebSocket for live analysis updates

## 🆘 Support

For issues or questions:
1. Check the implementation doc: `AI_ANALYSIS_IMPLEMENTATION.md`
2. Review error messages in terminal/console
3. Test API endpoints individually
4. Verify data format matches examples

Happy analyzing! 🎉
