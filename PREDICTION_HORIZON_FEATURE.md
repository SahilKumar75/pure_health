# Prediction Horizon Feature

## Overview
Enhanced the AI Analysis page with a **Prediction Horizon Selector** that allows users to choose how far into the future they want predictions (up to 60 days).

## User Flow

### 1. **Select Historical Data Range**
Users first select the range of historical data to base predictions on:
- **Quick Options**: 24 Hours, 7 Days, 30 Days, 60 Days
- **Custom Range**: Date picker (up to 60 days back)
- This provides the ML model with training data

### 2. **Choose Prediction Horizon** (Prediction Analysis Only)
Users then select how many days ahead to predict:
- **Quick Options**: 7 Days, 2 Weeks, 1 Month, 2 Months
- **Custom Slider**: 1-60 days (continuous selection)
- **Default**: 30 days

### 3. **Perform Analysis**
- System analyzes historical patterns
- Generates predictions for the selected horizon
- Displays prediction timeline with end date

## Components Created

### 1. **PredictionHorizonSelector Widget**
**Location**: `lib/features/ai_analysis/presentation/widgets/prediction_horizon_selector.dart`

**Features**:
- 4 Quick selection chips (7, 14, 30, 60 days)
- Continuous slider (1-60 days) with real-time updates
- Info message about prediction accuracy
- Dark theme styling with pink accent

**Usage**:
```dart
PredictionHorizonSelector(
  selectedDays: _predictionHorizonDays,
  onDaysSelected: (days) {
    setState(() {
      _predictionHorizonDays = days;
    });
  },
)
```

### 2. **Enhanced Analysis Page**
**Location**: `lib/features/ai_analysis/presentation/pages/station_ai_analysis_page_with_sidebar.dart`

**Changes**:
- Added `_predictionHorizonDays` state variable (default: 30)
- Conditional rendering (only shows for `analysisType == 'prediction'`)
- Passes prediction horizon to analysis result
- Displays prediction timeline in results

## UI Components

### Prediction Horizon Card
```
┌─────────────────────────────────────────┐
│ 🔄 Prediction Horizon                   │
│ How many days ahead do you want to predict? │
│                                         │
│ [7 Days] [2 Weeks] [1 Month] [2 Months]│
│                                         │
│ 🎚️ Custom: 30 days                     │
│ ●──────────────────────────────O        │
│ 1                               60      │
│                                         │
│ ℹ️ Predictions are based on historical │
│   patterns. Accuracy decreases for     │
│   longer horizons.                     │
└─────────────────────────────────────────┘
```

### Prediction Results Display
```
┌─────────────────────────────────────────┐
│ ✓ Analysis Results                      │
│                                         │
│ ┌───────────────────────────────────┐   │
│ │ 📈  Prediction Horizon            │   │
│ │     30 days ahead                 │   │
│ │     Predictions until Dec 12, 2025│   │
│ └───────────────────────────────────┘   │
│                                         │
│ Total Data Points: 45                   │
│ Average WQI: 78.50                      │
│ Min WQI: 65.00                          │
│ Max WQI: 92.00                          │
└─────────────────────────────────────────┘
```

## Technical Implementation

### State Management
```dart
class _StationAIAnalysisPageWithSidebarState {
  int _predictionHorizonDays = 30; // Default 30 days
  
  // Updated when user changes selection
  void onDaysSelected(int days) {
    setState(() {
      _predictionHorizonDays = days;
    });
  }
}
```

### Analysis Integration
```dart
case 'prediction':
  result = await _historicalService!.getMLPredictionData(widget.stationId);
  
  // Add prediction metadata
  result['predictionHorizon'] = _predictionHorizonDays;
  result['predictionEndDate'] = DateTime.now()
    .add(Duration(days: _predictionHorizonDays))
    .toIso8601String();
  break;
```

### Conditional Rendering
```dart
// Only show for prediction analysis
if (widget.analysisType == 'prediction') ...[
  PredictionHorizonSelector(
    selectedDays: _predictionHorizonDays,
    onDaysSelected: (days) {
      setState(() {
        _predictionHorizonDays = days;
      });
    },
  ),
  const SizedBox(height: 24),
],
```

## Color Scheme

### Prediction Horizon Card
- **Background**: `AppColors.darkBg3`
- **Border**: `AppColors.borderLight`
- **Icon**: `AppColors.accentPink`
- **Selected Chip**: `AppColors.accentPink` background
- **Slider**: `AppColors.accentPink` active track

### Results Display
- **Gradient Background**: Pink opacity gradient (0.2 → 0.05)
- **Border**: `AppColors.accentPink` with 0.4 opacity
- **Icon Container**: Solid `AppColors.accentPink`

## User Benefits

### 1. **Flexible Forecasting**
- Short-term predictions (7 days) for immediate planning
- Long-term predictions (60 days) for strategic decisions

### 2. **Data-Driven Decisions**
- Historical data range + prediction horizon = complete picture
- Users understand both past patterns and future expectations

### 3. **Transparency**
- Clear display of prediction timeline
- Warning about accuracy for longer horizons
- Shows exact end date of predictions

### 4. **Ease of Use**
- Quick options for common scenarios
- Slider for precise control
- Real-time feedback on selection

## Testing Checklist

- [ ] Select each quick option (7, 14, 30, 60 days)
- [ ] Use slider to select custom values (1-60)
- [ ] Verify only shows for prediction analysis type
- [ ] Check risk/trends/recommendations don't show selector
- [ ] Perform prediction with different horizons
- [ ] Verify results show correct prediction end date
- [ ] Test on different screen sizes (responsive)
- [ ] Verify dark theme colors display correctly

## Future Enhancements

### Potential Features
1. **Confidence Intervals**: Show prediction uncertainty
2. **Multiple Scenarios**: Best/worst/average case predictions
3. **Comparison**: Compare different prediction horizons
4. **Historical Accuracy**: Show past prediction accuracy
5. **Auto-suggest**: Recommend optimal horizon based on data quality
6. **Export**: Download prediction charts/reports

### Backend Integration
When ML backend is ready:
- Pass `predictionHorizon` to ML API
- Receive predicted values for each day
- Display timeline chart with predictions
- Show confidence scores per day

## Files Modified

1. ✅ Created `prediction_horizon_selector.dart`
2. ✅ Updated `station_ai_analysis_page_with_sidebar.dart`
   - Added import
   - Added state variable
   - Added conditional rendering
   - Updated analysis method
   - Enhanced results display
   - Added date formatter

## Summary

The Prediction Horizon feature gives users **full control over both historical data range and prediction timeframe**. Combined with the existing time range selector (max 60 days back), users now have:

- **Historical Range**: Past 1-60 days (training data)
- **Prediction Horizon**: Future 1-60 days (forecast window)

This creates a complete temporal analysis workflow for water quality predictions! 🎯
