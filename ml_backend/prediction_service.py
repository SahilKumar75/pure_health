"""
Water Quality Prediction Service
Provides 60-day forecasts for water quality parameters using time-series analysis
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from typing import Dict, List, Any
from sklearn.linear_model import LinearRegression
from utils import convert_to_serializable


class PredictionService:
    """Generate 60-day water quality predictions"""
    
    def __init__(self):
        self.prediction_days = 60
        self.prediction_weeks = 8  # 2 months = ~8 weeks
        
        # Define safe thresholds for parameters
        self.thresholds = {
            'pH': {'min': 6.5, 'max': 8.5, 'optimal': 7.0},
            'turbidity': {'max': 5.0, 'optimal': 1.0},
            'dissolved_oxygen': {'min': 5.0, 'optimal': 7.0},
            'DO': {'min': 5.0, 'optimal': 7.0},
            'temperature': {'min': 20.0, 'max': 30.0, 'optimal': 25.0},
            'conductivity': {'min': 300, 'max': 600, 'optimal': 450},
            'BOD': {'max': 3.0, 'optimal': 2.0},
            'TDS': {'max': 500, 'optimal': 300}
        }
    
    def generate_predictions(self, df: pd.DataFrame) -> Dict[str, Any]:
        """
        Generate 60-day predictions for all water quality parameters
        
        Args:
            df: DataFrame with water quality data
            
        Returns:
            Dictionary with predictions for each parameter
        """
        predictions = {}
        
        for column in df.columns:
            # Skip non-numeric columns
            if column.lower() in ['date', 'timestamp', 'location', 'station', 'id']:
                continue
            
            try:
                # Get clean numeric values
                values = pd.to_numeric(df[column], errors='coerce').dropna()
                
                if len(values) < 2:
                    continue
                
                # Generate prediction for this parameter
                param_prediction = self._predict_parameter(column, values.tolist())
                
                if param_prediction:
                    predictions[column] = param_prediction
                    
            except Exception as e:
                print(f"Error predicting {column}: {e}")
                continue
        
        return convert_to_serializable(predictions)
    
    def _predict_parameter(self, parameter: str, historical_values: List[float]) -> Dict[str, Any]:
        """
        Generate prediction for a single parameter
        
        Args:
            parameter: Parameter name (e.g., 'pH', 'turbidity')
            historical_values: List of historical values
            
        Returns:
            Prediction dictionary with forecasted values and metadata
        """
        if len(historical_values) < 2:
            return None
        
        # Calculate statistics
        current_value = historical_values[-1]
        mean_value = np.mean(historical_values)
        std_value = np.std(historical_values)
        
        # Detect trend using linear regression
        X = np.array(range(len(historical_values))).reshape(-1, 1)
        y = np.array(historical_values)
        
        model = LinearRegression()
        model.fit(X, y)
        
        trend_slope = model.coef_[0]
        
        # Determine trend direction
        if abs(trend_slope) < 0.01 * mean_value:  # Less than 1% change
            trend_direction = 'stable'
        elif trend_slope > 0:
            trend_direction = 'increasing'
        else:
            trend_direction = 'decreasing'
        
        # Generate weekly predictions (8 weeks = 2 months)
        predicted_values = []
        confidence_values = []
        
        for week in range(1, self.prediction_weeks + 1):
            # Future time step
            future_index = len(historical_values) + (week * 7)  # 7 days per week
            
            # Linear trend prediction
            base_prediction = model.predict([[future_index]])[0]
            
            # Add slight random variation based on historical std
            variation = np.random.normal(0, std_value * 0.1)
            predicted_value = base_prediction + variation
            
            # Ensure prediction stays within reasonable bounds
            if parameter.lower() in self.thresholds:
                threshold = self.thresholds[parameter.lower()]
                if 'min' in threshold and predicted_value < threshold['min'] * 0.8:
                    predicted_value = threshold['min'] * 0.9
                if 'max' in threshold and predicted_value > threshold['max'] * 1.2:
                    predicted_value = threshold['max'] * 1.1
            
            predicted_values.append(round(predicted_value, 2))
            
            # Confidence decreases with time (from 0.95 to 0.70)
            confidence = 0.95 - (week - 1) * 0.03
            confidence_values.append(round(confidence, 2))
        
        # Determine if parameter will exceed thresholds
        alerts = self._check_threshold_alerts(parameter, predicted_values)
        
        return {
            'current': round(current_value, 2),
            'mean': round(mean_value, 2),
            'predicted': predicted_values,
            'confidence': confidence_values,
            'trend': trend_direction,
            'trendSlope': round(trend_slope, 4),
            'alerts': alerts,
            'weeks': list(range(1, self.prediction_weeks + 1))
        }
    
    def _check_threshold_alerts(self, parameter: str, predicted_values: List[float]) -> List[Dict[str, Any]]:
        """Check if predicted values will exceed safe thresholds"""
        alerts = []
        
        param_lower = parameter.lower()
        if param_lower not in self.thresholds:
            return alerts
        
        threshold = self.thresholds[param_lower]
        
        for week, value in enumerate(predicted_values, start=1):
            alert = None
            
            # Check minimum threshold
            if 'min' in threshold and value < threshold['min']:
                alert = {
                    'week': week,
                    'type': 'below_minimum',
                    'message': f'{parameter} predicted to fall below safe minimum ({threshold["min"]}) in week {week}',
                    'predictedValue': value,
                    'thresholdValue': threshold['min'],
                    'severity': 'high' if value < threshold['min'] * 0.9 else 'medium'
                }
            
            # Check maximum threshold
            elif 'max' in threshold and value > threshold['max']:
                alert = {
                    'week': week,
                    'type': 'above_maximum',
                    'message': f'{parameter} predicted to exceed safe maximum ({threshold["max"]}) in week {week}',
                    'predictedValue': value,
                    'thresholdValue': threshold['max'],
                    'severity': 'critical' if value > threshold['max'] * 1.2 else 'high'
                }
            
            if alert:
                alerts.append(alert)
        
        return alerts
    
    def generate_prediction_summary(self, predictions: Dict[str, Any]) -> str:
        """Generate human-readable summary of predictions"""
        if not predictions:
            return "Insufficient data for predictions."
        
        summary_parts = []
        
        # Count trends
        increasing = sum(1 for p in predictions.values() if p['trend'] == 'increasing')
        decreasing = sum(1 for p in predictions.values() if p['trend'] == 'decreasing')
        stable = sum(1 for p in predictions.values() if p['trend'] == 'stable')
        
        summary_parts.append(f"📊 Prediction Summary for Next 60 Days:")
        summary_parts.append(f"• {increasing} parameters trending upward")
        summary_parts.append(f"• {decreasing} parameters trending downward")
        summary_parts.append(f"• {stable} parameters remaining stable")
        
        # Check for alerts
        all_alerts = []
        for param, pred in predictions.items():
            if pred['alerts']:
                all_alerts.extend([(param, alert) for alert in pred['alerts']])
        
        if all_alerts:
            summary_parts.append(f"\n⚠️ {len(all_alerts)} threshold alerts detected:")
            for param, alert in all_alerts[:3]:  # Show top 3
                summary_parts.append(f"• {param}: {alert['message']}")
        else:
            summary_parts.append("\n✅ All parameters predicted to stay within safe limits")
        
        return "\n".join(summary_parts)
