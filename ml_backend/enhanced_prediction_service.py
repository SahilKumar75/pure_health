"""
Enhanced Water Quality Prediction Service - Phase 5
Uses trained ML models for multi-parameter predictions with confidence intervals
"""

import os
import numpy as np
import pandas as pd
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional
from ml_models import WaterQualityMLModels
from utils import convert_to_serializable


class EnhancedPredictionService:
    """
    Advanced prediction service using Phase 5 ML models
    Provides 7/30/90-day forecasts with confidence intervals and anomaly detection
    """
    
    def __init__(self):
        self.ml_models = WaterQualityMLModels()
        self._load_models()
        
        # CPCB thresholds for water quality
        self.thresholds = {
            'ph': {'min': 6.5, 'max': 8.5, 'optimal': 7.0, 'unit': ''},
            'bod': {'max': 3.0, 'optimal': 2.0, 'unit': 'mg/L'},
            'dissolved_oxygen': {'min': 4.0, 'optimal': 6.0, 'unit': 'mg/L'},
            'fecal_coliform': {'max': 2500, 'optimal': 500, 'unit': 'MPN/100mL'},
            'turbidity': {'max': 5.0, 'optimal': 1.0, 'unit': 'NTU'},
            'tds': {'max': 500, 'optimal': 300, 'unit': 'mg/L'},
            'temperature': {'min': 20, 'max': 30, 'optimal': 25, 'unit': '°C'}
        }
    
    def _load_models(self):
        """Load trained ML models"""
        try:
            models_dir = os.path.join(os.path.dirname(__file__), 'models')
            if os.path.exists(os.path.join(models_dir, 'wqi_model.pkl')):
                self.ml_models.load_models()
                print("✓ ML models loaded successfully")
            else:
                print("⚠️ ML models not found. Please train models first.")
        except Exception as e:
            print(f"⚠️ Error loading models: {e}")
    
    def generate_multi_parameter_forecast(
        self, 
        current_data: Dict[str, float],
        season: str = 'monsoon',
        horizons: List[int] = [7, 30, 90]
    ) -> Dict[str, Any]:
        """
        Generate comprehensive forecasts for multiple time horizons
        
        Args:
            current_data: Current water quality parameters
            season: Current season (monsoon, summer, winter, post_monsoon)
            horizons: Forecast horizons in days (default: 7, 30, 90)
        
        Returns:
            Comprehensive forecast with predictions, trends, and anomalies
        """
        try:
            # Generate ML-based predictions
            predictions = self.ml_models.predict_multi_parameter(
                current_data=current_data,
                days_ahead=horizons,
                season=season
            )
            
            # Enrich predictions with additional analysis
            enhanced_forecast = {
                'timestamp': datetime.now().isoformat(),
                'season': season,
                'current_conditions': self._analyze_current_conditions(current_data),
                'forecasts': self._format_forecasts(predictions, horizons),
                'trends': predictions.get('trends', {}),
                'anomalies': predictions.get('anomalies', []),
                'recommendations': self._generate_recommendations(predictions),
                'risk_assessment': self._assess_risk(predictions),
                'metadata': {
                    'model_version': 'Phase 5 - Multi-Parameter',
                    'training_samples': 1900,
                    'forecast_horizons': horizons
                }
            }
            
            return convert_to_serializable(enhanced_forecast)
            
        except Exception as e:
            print(f"Error generating forecast: {e}")
            return self._fallback_prediction(current_data, horizons)
    
    def _format_forecasts(self, predictions: Dict, horizons: List[int]) -> Dict[str, Any]:
        """Format ML predictions into structured forecast"""
        forecasts = {}
        
        for days in horizons:
            key = f'{days}_days'
            if key in predictions:
                pred = predictions[key]
                forecasts[str(days)] = {
                    'days_ahead': days,
                    'forecast_date': pred['forecast_date'],
                    'parameters': {
                        'pH': {
                            'value': pred['ph']['value'],
                            'confidence': pred['ph']['confidence'],
                            'status': self._get_parameter_status('ph', pred['ph']['value']),
                            'unit': ''
                        },
                        'BOD': {
                            'value': pred['bod']['value'],
                            'confidence': pred['bod']['confidence'],
                            'status': self._get_parameter_status('bod', pred['bod']['value']),
                            'unit': 'mg/L'
                        },
                        'DO': {
                            'value': pred['dissolved_oxygen']['value'],
                            'confidence': pred['dissolved_oxygen']['confidence'],
                            'status': self._get_parameter_status('dissolved_oxygen', pred['dissolved_oxygen']['value']),
                            'unit': 'mg/L'
                        },
                        'Fecal_Coliform': {
                            'value': pred['fecal_coliform']['value'],
                            'confidence': pred['fecal_coliform']['confidence'],
                            'status': self._get_parameter_status('fecal_coliform', pred['fecal_coliform']['value']),
                            'unit': 'MPN/100mL'
                        },
                        'TDS': {
                            'value': pred.get('tds', {}).get('value', 0),
                            'confidence': pred.get('tds', {}).get('confidence', 0),
                            'status': self._get_parameter_status('tds', pred.get('tds', {}).get('value', 0)),
                            'unit': 'mg/L'
                        }
                    },
                    'wqi': {
                        'value': pred['wqi']['value'],
                        'confidence': pred['wqi']['confidence'],
                        'classification': pred['wqi']['classification']
                    }
                }
        
        return forecasts
    
    def _get_parameter_status(self, param: str, value: float) -> str:
        """Determine parameter status against thresholds"""
        if param not in self.thresholds:
            return 'unknown'
        
        threshold = self.thresholds[param]
        
        # Check minimum
        if 'min' in threshold:
            if value < threshold['min']:
                return 'critical' if value < threshold['min'] * 0.8 else 'warning'
        
        # Check maximum
        if 'max' in threshold:
            if value > threshold['max']:
                return 'critical' if value > threshold['max'] * 1.2 else 'warning'
        
        # Check optimal range
        if 'optimal' in threshold:
            optimal = threshold['optimal']
            if abs(value - optimal) < optimal * 0.1:
                return 'optimal'
        
        return 'acceptable'
    
    def _analyze_current_conditions(self, current_data: Dict[str, float]) -> Dict[str, Any]:
        """Analyze current water quality conditions"""
        analysis = {
            'overall_status': 'good',
            'critical_parameters': [],
            'warning_parameters': [],
            'optimal_parameters': []
        }
        
        critical_count = 0
        warning_count = 0
        
        for param, value in current_data.items():
            status = self._get_parameter_status(param, value)
            
            param_info = {
                'name': param,
                'value': value,
                'status': status
            }
            
            if status == 'critical':
                analysis['critical_parameters'].append(param_info)
                critical_count += 1
            elif status == 'warning':
                analysis['warning_parameters'].append(param_info)
                warning_count += 1
            elif status == 'optimal':
                analysis['optimal_parameters'].append(param_info)
        
        # Determine overall status
        if critical_count > 0:
            analysis['overall_status'] = 'critical'
        elif warning_count > 2:
            analysis['overall_status'] = 'warning'
        elif warning_count > 0:
            analysis['overall_status'] = 'caution'
        else:
            analysis['overall_status'] = 'good'
        
        return analysis
    
    def _generate_recommendations(self, predictions: Dict) -> List[str]:
        """Generate actionable recommendations based on predictions"""
        recommendations = []
        
        # Check trends
        trends = predictions.get('trends', {})
        
        if 'dissolved_oxygen' in trends:
            do_trend = trends['dissolved_oxygen']
            if do_trend['direction'] == 'decreasing' and do_trend['change_percent'] < -10:
                recommendations.append("⚠️ Dissolved Oxygen declining rapidly. Increase aeration immediately.")
        
        if 'fecal_coliform' in trends:
            fc_trend = trends['fecal_coliform']
            if fc_trend['direction'] == 'increasing' and fc_trend['change_percent'] > 20:
                recommendations.append("🦠 Fecal coliform increasing. Enhance disinfection protocols.")
        
        if 'bod' in trends:
            bod_trend = trends['bod']
            if bod_trend['direction'] == 'increasing' and bod_trend['change_percent'] > 15:
                recommendations.append("🌊 BOD rising. Check for organic pollution sources.")
        
        # Check anomalies
        anomalies = predictions.get('anomalies', [])
        if anomalies:
            for anomaly in anomalies:
                if anomaly['severity'] == 'critical':
                    recommendations.append(f"🚨 CRITICAL: {anomaly['parameter']} predicted to violate safety limits.")
                elif anomaly['severity'] == 'high':
                    recommendations.append(f"⚠️ HIGH: {anomaly['parameter']} approaching unsafe levels.")
        
        # General recommendations
        if not recommendations:
            recommendations.append("✓ All parameters stable. Continue routine monitoring.")
        else:
            recommendations.append("📊 Increase monitoring frequency for flagged parameters.")
            recommendations.append("🔬 Conduct detailed analysis if trends persist.")
        
        return recommendations
    
    def _assess_risk(self, predictions: Dict) -> Dict[str, Any]:
        """Assess overall risk level from predictions"""
        risk_score = 0
        risk_factors = []
        
        # Check 30-day predictions
        if '30_days' in predictions:
            pred_30 = predictions['30_days']
            
            # DO risk
            if 'dissolved_oxygen' in pred_30:
                do_val = pred_30['dissolved_oxygen']['value']
                if do_val < 4.0:
                    risk_score += 30
                    risk_factors.append('Critical DO levels predicted')
                elif do_val < 5.0:
                    risk_score += 15
                    risk_factors.append('Low DO levels predicted')
            
            # FC risk
            if 'fecal_coliform' in pred_30:
                fc_val = pred_30['fecal_coliform']['value']
                if fc_val > 2500:
                    risk_score += 25
                    risk_factors.append('High microbial contamination predicted')
                elif fc_val > 1000:
                    risk_score += 10
                    risk_factors.append('Elevated microbial levels predicted')
            
            # pH risk
            if 'ph' in pred_30:
                ph_val = pred_30['ph']['value']
                if ph_val < 6.0 or ph_val > 9.0:
                    risk_score += 20
                    risk_factors.append('pH outside safe range')
                elif ph_val < 6.5 or ph_val > 8.5:
                    risk_score += 10
                    risk_factors.append('pH approaching limits')
        
        # Determine risk level
        if risk_score >= 50:
            risk_level = 'CRITICAL'
        elif risk_score >= 30:
            risk_level = 'HIGH'
        elif risk_score >= 15:
            risk_level = 'MEDIUM'
        else:
            risk_level = 'LOW'
        
        return {
            'level': risk_level,
            'score': risk_score,
            'factors': risk_factors,
            'action_required': risk_score >= 30
        }
    
    def _fallback_prediction(self, current_data: Dict, horizons: List[int]) -> Dict[str, Any]:
        """Fallback prediction when ML models are not available"""
        return {
            'timestamp': datetime.now().isoformat(),
            'status': 'fallback',
            'message': 'ML models not available. Using simplified predictions.',
            'current_data': current_data,
            'horizons': horizons
        }


# Example usage
if __name__ == '__main__':
    print("=== Enhanced Prediction Service - Phase 5 ===\n")
    
    # Initialize service
    service = EnhancedPredictionService()
    
    # Test with sample data
    current_data = {
        'ph': 7.5,
        'bod': 2.5,
        'dissolved_oxygen': 6.2,
        'fecal_coliform': 450,
        'temperature': 26.5,
        'turbidity': 4.2,
        'tds': 320
    }
    
    print("Testing forecast generation...")
    print(f"Current conditions: pH={current_data['ph']}, BOD={current_data['bod']}, DO={current_data['dissolved_oxygen']}")
    
    # Generate forecast
    forecast = service.generate_multi_parameter_forecast(
        current_data=current_data,
        season='monsoon',
        horizons=[7, 30, 90]
    )
    
    print(f"\n✓ Forecast generated for {len(forecast['forecasts'])} time horizons")
    print(f"  Current status: {forecast['current_conditions']['overall_status']}")
    print(f"  Risk level: {forecast['risk_assessment']['level']}")
    print(f"\nRecommendations:")
    for rec in forecast['recommendations']:
        print(f"  {rec}")
    
    print("\n=== Service Ready ===")
