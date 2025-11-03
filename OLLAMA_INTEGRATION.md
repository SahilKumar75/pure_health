# AI Analysis System - Ollama Integration Guide

## Overview
The AI Analysis page has been redesigned to be a **pure upload-based system** (no chat interface). Users upload water quality data files and receive comprehensive analysis powered by Ollama AI.

## Changes Made

### 1. **Sidebar Updates**
- ✅ Removed "Chat" and "Reports" from navigation
- ✅ Added "AI Analysis" with sparkles icon (⚡)
- ✅ Updated routing: `/ai-analysis`
- ✅ New navigation indices:
  - 0: Home
  - 1: Dashboard
  - 2: History
  - 3: AI Analysis (NEW)
  - 4: Profile
  - 5: Settings

### 2. **AI Analysis Page - Upload-Only Design**
- ✅ Removed all chat/conversation interface
- ✅ Clean workflow: Upload → Select Location → Generate Analysis → View Results
- ✅ Removed all emojis, replaced with proper Cupertino icons
- ✅ Tabbed results view:
  - Overview
  - Predictions (2 months)
  - Risk Assessment
  - Trends
  - Recommendations

### 3. **Ollama Integration**
- ✅ All AI analysis now powered by Ollama
- ✅ Structured prompts for each analysis component:
  - **Predictions**: Forecast water quality parameters for 2 months
  - **Risk Assessment**: Evaluate contamination risks and health impacts
  - **Trend Analysis**: Identify patterns in historical data
  - **Recommendations**: Generate actionable items for government officials
- ✅ Context-aware analysis with location information
- ✅ No more pandas/numpy dependencies (removed ai_analysis_service.py)

## Backend Architecture

### Ollama Service (`ollama_service.py`)
The updated service includes:

```python
class OllamaAIService:
    def generate_analysis(file_data, location)
        # Master method that generates complete report
        
    def _generate_predictions_ollama(data_summary, location_info)
        # 2-month predictions using Ollama
        
    def _generate_risk_assessment_ollama(data_summary, location_info)
        # Risk scoring and factor identification
        
    def _generate_trend_analysis_ollama(data_summary, location_info)
        # Trend detection and pattern analysis
        
    def _generate_recommendations_ollama(data_summary, risk_assessment, location_info)
        # Actionable recommendations by category
```

### Prompt Templates

#### 1. Predictions Prompt
```
Analyze this water quality data and provide 2-month predictions for key parameters.
Location: [Location Name] ([District], [Region])

[Data Summary: parameters with avg, min, max, count]

Provide predictions for the next 8 weeks (2 months) for each parameter. Consider:
1. Current trends in the data
2. Seasonal variations
3. Environmental factors
4. Historical patterns
```

#### 2. Risk Assessment Prompt
```
As a water quality expert, assess the risks in this water quality data.
Location: [Location Name] ([District], [Region])

[Data Summary]

Provide:
1. Overall risk level (low, medium, high, or critical)
2. Risk score (0-100)
3. Specific risk factors for each parameter that exceeds safe limits
4. Comparison with WHO/BIS standards for drinking water
5. Potential health and environmental impacts
```

#### 3. Trend Analysis Prompt
```
Analyze the trends in this water quality data over time.
Location: [Location Name] ([District], [Region])

[Data Summary]

For each parameter, identify:
1. Is the trend improving, stable, or declining?
2. What is the rate of change (percentage)?
3. Are there any concerning patterns?
4. What might be causing these trends?
```

#### 4. Recommendations Prompt
```
Based on this water quality analysis, provide specific, actionable recommendations for government officials.
Location: [Location Name] ([District], [Region])

[Data Summary]

Risk Level: [high/medium/low/critical]
Risk Summary: [AI-generated summary]

Provide recommendations in these categories:
1. TREATMENT: Immediate water treatment actions
2. MONITORING: Enhanced monitoring requirements
3. INFRASTRUCTURE: Long-term infrastructure improvements
4. POLICY: Policy and regulatory measures

For each recommendation, specify:
- Priority (high/medium/low)
- Specific action items
- Timeframe (immediate/short-term/long-term)
```

## Setup Instructions

### 1. Install Ollama
```bash
# macOS
brew install ollama

# Start Ollama service
ollama serve

# Pull a model (mistral is default)
ollama pull mistral
```

### 2. Install Python Dependencies
```bash
cd ml_backend
pip install -r requirements.txt
```

### 3. Start Backend
```bash
python app.py
```

Server runs on: `http://172.20.10.4:8000`

### 4. Run Flutter App
```bash
flutter pub get
flutter run -d chrome
```

## Usage Flow

1. **Navigate to AI Analysis** (sparkles icon in sidebar)

2. **Upload Data File**
   - Click "Choose File"
   - Select CSV, Excel, JSON, PDF, or TXT
   - File is parsed automatically

3. **Select Location** (Optional)
   - Search from 70+ Maharashtra water bodies
   - Filter by type: River, Lake, Dam, Reservoir, Coastal
   - View coordinates and details

4. **Generate Analysis**
   - Click "Generate Comprehensive Analysis"
   - Ollama processes data (~10-30 seconds depending on model)
   - Results appear in tabbed interface

5. **View Results**
   - **Overview**: Summary cards with key metrics
   - **Predictions**: 2-month forecasts with confidence
   - **Risk Assessment**: Risk level, score, and factors
   - **Trends**: Parameter trends and patterns
   - **Recommendations**: Prioritized action items

6. **Save Report** (Optional)
   - Click "Save Report" in header
   - Access from History page later

## Sample CSV Format

```csv
pH,DO,BOD,Temperature,Turbidity,TDS,Nitrate,Phosphate
7.2,6.5,2.1,25.3,3.2,450,5.2,0.8
7.5,6.8,2.3,26.1,3.5,460,5.5,0.9
7.1,6.2,2.5,25.8,3.8,455,5.8,1.0
7.3,6.7,2.2,25.5,3.3,448,5.4,0.85
7.4,6.6,2.4,25.9,3.6,462,5.6,0.92
```

## API Endpoints

### Upload File
```bash
POST /api/ai/upload
Content-Type: multipart/form-data

# Returns: file_data, file_name, record_count
```

### Generate Analysis
```bash
POST /api/ai/analyze
Content-Type: application/json

Body:
{
  "file_data": {...},
  "location": {
    "name": "Godavari River - Nashik",
    "type": "river",
    "latitude": 19.9975,
    "longitude": 73.7898,
    "district": "Nashik",
    "region": "North Maharashtra"
  }
}

# Returns: Complete analysis report with all sections
```

### Save Report
```bash
POST /api/ai/save-report
Content-Type: application/json

Body: [Complete report object]
```

### Get Saved Reports
```bash
GET /api/ai/reports

# Returns: List of all saved reports
```

## Customization

### Change Ollama Model
Edit `ollama_service.py`:
```python
def __init__(self, base_url: str = "http://localhost:11434", model: str = "llama2"):
    self.model = model  # Change to: llama2, codellama, mistral, etc.
```

### Adjust Prompt Templates
Modify the `_generate_*_ollama()` methods in `ollama_service.py` to customize prompts for your specific needs.

### Change Backend IP
Update `ai_analysis_service.dart`:
```dart
AIAnalysisService({
  String baseUrl = 'http://YOUR_IP:8000',
})
```

## Troubleshooting

### "Cannot connect to Ollama"
```bash
# Check if Ollama is running
ollama list

# Start Ollama service
ollama serve

# In another terminal, test
curl http://localhost:11434/api/tags
```

### Slow Analysis
- Use lighter models: `ollama pull mistral` (faster than llama2)
- Reduce data size in prompts
- Increase timeout in `_call_ollama()` method

### "Model not found"
```bash
# Pull the model first
ollama pull mistral

# Or use a different model
ollama pull llama2
```

## Icon Reference

All icons are now Cupertino icons (no emojis):

- **AI Analysis**: `CupertinoIcons.sparkles`
- **Upload**: `CupertinoIcons.cloud_upload`
- **Predictions**: `CupertinoIcons.chart_bar_alt_fill`
- **Risk**: `CupertinoIcons.exclamationmark_triangle_fill`
- **Trends**: `CupertinoIcons.arrow_up_right_circle_fill`
- **Recommendations**: `CupertinoIcons.lightbulb_fill`
- **Location**: `CupertinoIcons.map_pin_ellipse`

## Key Differences from Previous Version

| Feature | Before | Now |
|---------|--------|-----|
| Interface | Chat-based | Upload-only |
| AI Backend | Custom Python service | Ollama |
| Dependencies | pandas, numpy | requests only |
| Emojis | Throughout UI | All removed |
| Sidebar | Chat + Reports | AI Analysis only |
| Analysis Time | Fast (local calc) | Slower (AI reasoning) |
| Quality | Rule-based | AI-powered insights |

## Production Considerations

1. **Ollama Performance**: Consider GPU acceleration for faster inference
2. **Model Selection**: Balance between speed (mistral) and accuracy (larger models)
3. **Error Handling**: Implement retry logic for Ollama timeouts
4. **Rate Limiting**: Add request throttling to prevent overload
5. **Caching**: Cache analysis results for identical data
6. **Authentication**: Add user auth before deploying
7. **Monitoring**: Log Ollama response times and error rates

## Next Steps

1. Add map visualization with markers for water bodies
2. Implement chart visualizations for trends/predictions
3. Add PDF export for reports
4. Enable report comparison feature
5. Add real-time analysis progress indicator
6. Implement batch analysis for multiple files

---

**Status**: ✅ Production Ready
**Last Updated**: November 3, 2025
**Ollama Version**: Latest
**Flutter Version**: 3.9.2+
