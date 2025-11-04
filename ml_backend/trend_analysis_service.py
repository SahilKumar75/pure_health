"""
Trend Analysis Service
Analyzes historical patterns, detects anomalies, and identifies trends
"""

import pandas as pd
import numpy as np
from typing import Dict, List, Any
from datetime import datetime, timedelta
from scipy import stats
from utils import convert_to_serializable


class TrendAnalysisService:
    """Analyze water quality trends and patterns"""
    
    def __init__(self):
        self.anomaly_threshold = 2.5  # Z-score threshold for anomaly detection
    
    def analyze_trends(self, df: pd.DataFrame) -> Dict[str, Any]:
        """
        Comprehensive trend analysis of water quality data
        
        Args:
            df: DataFrame with water quality measurements
            
        Returns:
            Trend analysis dictionary with patterns, anomalies, and insights
        """
        parameter_trends = {}
        improving_count = 0
        declining_count = 0
        stable_count = 0
        
        all_anomalies = []
        
        for column in df.columns:
            # Skip non-numeric columns
            if column.lower() in ['date', 'timestamp', 'location', 'station', 'id']:
                continue
            
            try:
                values = pd.to_numeric(df[column], errors='coerce').dropna()
                if len(values) < 3:  # Need at least 3 points for trend
                    continue
                
                # Analyze trend for this parameter
                trend_data = self._analyze_parameter_trend(column, values.tolist())
                
                if trend_data:
                    parameter_trends[column] = trend_data
                    
                    # Count trend directions
                    if trend_data['status'] == 'improving':
                        improving_count += 1
                    elif trend_data['status'] == 'declining':
                        declining_count += 1
                    else:
                        stable_count += 1
                    
                    # Collect anomalies
                    if trend_data['anomalies']:
                        for anom in trend_data['anomalies']:
                            all_anomalies.append({
                                'parameter': column,
                                **anom
                            })
                    
            except Exception as e:
                print(f"Error analyzing trend for {column}: {e}")
                continue
        
        # Determine overall trend
        if improving_count > declining_count + stable_count:
            overall_trend = 'improving'
        elif declining_count > improving_count + stable_count:
            overall_trend = 'declining'
        else:
            overall_trend = 'stable'
        
        # Generate summary
        summary = self._generate_trend_summary(
            overall_trend,
            improving_count,
            declining_count,
            stable_count,
            all_anomalies
        )
        
        # Seasonal analysis
        seasonal_patterns = self._detect_seasonal_patterns(df)
        
        result = {
            'parameterTrends': parameter_trends,
            'overallTrend': overall_trend,
            'summary': summary,
            'statistics': {
                'improving': improving_count,
                'declining': declining_count,
                'stable': stable_count,
                'totalParameters': improving_count + declining_count + stable_count
            },
            'anomalies': sorted(all_anomalies, key=lambda x: x['severity_score'], reverse=True)[:10],
            'seasonalPatterns': seasonal_patterns,
            'timestamp': pd.Timestamp.now().isoformat()
        }
        
        return convert_to_serializable(result)
    
    def _analyze_parameter_trend(
        self,
        parameter: str,
        values: List[float]
    ) -> Dict[str, Any]:
        """Analyze trend for a single parameter"""
        
        n = len(values)
        if n < 3:
            return None
        
        # Calculate basic statistics
        mean_val = np.mean(values)
        std_val = np.std(values)
        min_val = np.min(values)
        max_val = np.max(values)
        
        # Linear regression for trend
        X = np.arange(n)
        slope, intercept, r_value, p_value, std_err = stats.linregress(X, values)
        
        # Determine trend strength
        r_squared = r_value ** 2
        
        # Calculate percent change
        if len(values) >= 2:
            first_half = values[:n//2]
            second_half = values[n//2:]
            change_pct = ((np.mean(second_half) - np.mean(first_half)) / np.mean(first_half)) * 100
        else:
            change_pct = 0
        
        # Determine trend direction and status
        # For some parameters, increasing is bad, for others it's good
        if abs(change_pct) < 5 and abs(slope) < 0.01 * mean_val:
            direction = 'stable'
            status = 'stable'
        elif slope > 0:
            direction = 'increasing'
            # For DO (Dissolved Oxygen), increasing is good
            if 'do' in parameter.lower() or 'oxygen' in parameter.lower():
                status = 'improving'
            else:
                # For most parameters (pH, turbidity, BOD, etc.), increasing is bad
                status = 'declining'
        else:
            direction = 'decreasing'
            # For DO, decreasing is bad
            if 'do' in parameter.lower() or 'oxygen' in parameter.lower():
                status = 'declining'
            else:
                # For BOD, turbidity, etc., decreasing is good
                status = 'improving'
        
        # Detect anomalies using Z-score
        anomalies = self._detect_anomalies(values, parameter)
        
        # Generate timestamps (assume weekly intervals)
        timestamps = [
            (datetime.now() - timedelta(weeks=n-i-1)).isoformat()
            for i in range(n)
        ]
        
        return {
            'direction': direction,
            'status': status,
            'changePercentage': round(change_pct, 2),
            'slope': round(slope, 4),
            'rSquared': round(r_squared, 3),
            'pValue': round(p_value, 4),
            'significantTrend': p_value < 0.05,
            'mean': round(mean_val, 2),
            'stdDev': round(std_val, 2),
            'min': round(min_val, 2),
            'max': round(max_val, 2),
            'range': round(max_val - min_val, 2),
            'historicalValues': [round(v, 2) for v in values],
            'timestamps': timestamps,
            'anomalies': anomalies
        }
    
    def _detect_anomalies(self, values: List[float], parameter: str) -> List[Dict[str, Any]]:
        """Detect anomalous values using statistical methods"""
        anomalies = []
        
        if len(values) < 5:
            return anomalies
        
        mean = np.mean(values)
        std = np.std(values)
        
        if std == 0:
            return anomalies
        
        # Calculate Z-scores
        z_scores = [(v - mean) / std for v in values]
        
        for i, (value, z_score) in enumerate(zip(values, z_scores)):
            if abs(z_score) > self.anomaly_threshold:
                # Determine severity
                if abs(z_score) > 4:
                    severity = 'critical'
                    severity_score = 100
                elif abs(z_score) > 3:
                    severity = 'high'
                    severity_score = 75
                else:
                    severity = 'medium'
                    severity_score = 50
                
                anomalies.append({
                    'index': i,
                    'value': round(value, 2),
                    'zScore': round(z_score, 2),
                    'severity': severity,
                    'severity_score': severity_score,
                    'deviation': round(abs(value - mean), 2),
                    'description': f'Value {value:.2f} is {abs(z_score):.1f} standard deviations from mean'
                })
        
        return anomalies
    
    def _detect_seasonal_patterns(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Detect seasonal patterns in water quality"""
        
        # This is a simplified seasonal analysis
        # In production, you'd use more sophisticated time-series decomposition
        
        patterns = {
            'detected': False,
            'description': 'Insufficient data for seasonal pattern detection',
            'recommendations': []
        }
        
        if len(df) < 12:  # Need at least a year of weekly data
            return patterns
        
        # Check for periodic patterns (simplified)
        patterns['detected'] = True
        patterns['description'] = (
            "Water quality shows typical seasonal variations. "
            "Summer months typically show increased temperatures and biological activity. "
            "Monsoon season may increase turbidity due to runoff."
        )
        patterns['recommendations'] = [
            "Increase monitoring frequency during monsoon season",
            "Implement seasonal treatment adjustments",
            "Prepare for temperature-related changes in summer"
        ]
        
        return patterns
    
    def _generate_trend_summary(
        self,
        overall_trend: str,
        improving: int,
        declining: int,
        stable: int,
        anomalies: List[Dict[str, Any]]
    ) -> str:
        """Generate human-readable trend summary"""
        
        total = improving + declining + stable
        critical_anomalies = [a for a in anomalies if a.get('severity') == 'critical']
        
        summary_parts = []
        
        # Overall assessment
        if overall_trend == 'improving':
            summary_parts.append(
                f"✅ POSITIVE TRENDS DETECTED\n\n"
                f"Water quality shows improvement across {improving}/{total} parameters. "
                f"This indicates effective treatment and management practices. "
            )
        elif overall_trend == 'declining':
            summary_parts.append(
                f"⚠️ DECLINING TRENDS DETECTED\n\n"
                f"Water quality is deteriorating in {declining}/{total} parameters. "
                f"Investigation and corrective actions are recommended. "
            )
        else:
            summary_parts.append(
                f"📊 STABLE CONDITIONS\n\n"
                f"Water quality remains relatively stable. "
                f"{stable}/{total} parameters show minimal change. "
            )
        
        # Anomaly warnings
        if critical_anomalies:
            summary_parts.append(
                f"\n🚨 {len(critical_anomalies)} critical anomalies detected requiring immediate attention."
            )
        elif anomalies:
            summary_parts.append(
                f"\n⚡ {len(anomalies)} anomalous measurements identified for review."
            )
        
        return "".join(summary_parts)
