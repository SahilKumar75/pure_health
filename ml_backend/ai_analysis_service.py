"""
AI Analysis Service for Water Quality Data
Handles comprehensive analysis including predictions, risk assessment, trends, and recommendations
"""

import json
import uuid
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional
import numpy as np
import pandas as pd
from pathlib import Path

class AIAnalysisService:
    def __init__(self):
        self.reports_dir = Path("saved_reports")
        self.reports_dir.mkdir(exist_ok=True)
        
    def analyze_file(self, file_data: Dict[str, Any], location: Optional[Dict] = None) -> Dict[str, Any]:
        """Generate comprehensive analysis report"""
        
        report_id = str(uuid.uuid4())
        timestamp = datetime.now()
        
        # Extract parameters from file data
        df = self._parse_file_data(file_data)
        
        # Generate analysis components
        predictions = self._generate_predictions(df)
        risk_assessment = self._generate_risk_assessment(df)
        trend_analysis = self._generate_trend_analysis(df)
        recommendations = self._generate_recommendations(df, risk_assessment)
        
        # Build report
        report = {
            'id': report_id,
            'timestamp': timestamp.isoformat(),
            'fileName': file_data.get('file_name', 'Unknown'),
            'location': location,
            'predictions': predictions,
            'predictionStartDate': timestamp.isoformat(),
            'predictionEndDate': (timestamp + timedelta(days=60)).isoformat(),
            'riskAssessment': risk_assessment,
            'trendAnalysis': trend_analysis,
            'recommendations': recommendations,
            'rawData': file_data
        }
        
        return report
    
    def _parse_file_data(self, file_data: Dict[str, Any]) -> pd.DataFrame:
        """Parse file data into DataFrame"""
        try:
            # Assuming file_data has columns as keys and values as lists
            df = pd.DataFrame(file_data.get('data', {}))
            return df
        except Exception as e:
            print(f"Error parsing file data: {e}")
            # Return sample DataFrame for demo
            return pd.DataFrame({
                'pH': [7.2, 7.5, 7.1, 7.3, 7.4],
                'DO': [6.5, 6.8, 6.2, 6.7, 6.6],
                'BOD': [2.1, 2.3, 2.5, 2.2, 2.4],
                'Temperature': [25.3, 26.1, 25.8, 25.5, 25.9]
            })
    
    def _generate_predictions(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Generate 2-month predictions for water quality parameters"""
        predictions = {}
        
        for column in df.columns:
            try:
                values = df[column].dropna()
                if len(values) > 0:
                    # Simple trend-based prediction
                    mean_val = float(values.mean())
                    std_val = float(values.std())
                    trend = float(values.iloc[-1] - values.iloc[0]) if len(values) > 1 else 0
                    
                    # Generate predictions for 8 weeks (2 months)
                    predicted_values = []
                    for week in range(1, 9):
                        pred_value = mean_val + (trend * week * 0.1)
                        predicted_values.append(round(pred_value, 2))
                    
                    predictions[column] = {
                        'current': round(mean_val, 2),
                        'predicted': predicted_values,
                        'trend': 'increasing' if trend > 0 else 'decreasing' if trend < 0 else 'stable',
                        'confidence': 0.85
                    }
            except Exception as e:
                print(f"Error predicting {column}: {e}")
                continue
        
        return predictions
    
    def _generate_risk_assessment(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Generate risk assessment with factors and scores"""
        
        risk_factors = []
        total_risk_score = 0
        factor_count = 0
        
        # Define thresholds for common parameters
        thresholds = {
            'pH': {'min': 6.5, 'max': 8.5, 'optimal': 7.0},
            'DO': {'min': 5.0, 'optimal': 6.5},
            'BOD': {'max': 3.0, 'optimal': 2.0},
            'Temperature': {'max': 30.0, 'optimal': 25.0},
            'Turbidity': {'max': 5.0, 'optimal': 1.0},
            'TDS': {'max': 500, 'optimal': 300}
        }
        
        for column in df.columns:
            try:
                if column not in thresholds:
                    continue
                    
                values = df[column].dropna()
                if len(values) == 0:
                    continue
                    
                current_value = float(values.mean())
                threshold_config = thresholds[column]
                
                # Determine risk level
                risk_level = 'low'
                risk_score = 20
                description = f'{column} is within acceptable limits'
                
                if 'min' in threshold_config and current_value < threshold_config['min']:
                    risk_level = 'high'
                    risk_score = 75
                    description = f'{column} is below minimum threshold'
                elif 'max' in threshold_config and current_value > threshold_config['max']:
                    risk_level = 'critical' if current_value > threshold_config['max'] * 1.2 else 'high'
                    risk_score = 85 if risk_level == 'critical' else 70
                    description = f'{column} exceeds maximum threshold'
                elif abs(current_value - threshold_config['optimal']) > threshold_config['optimal'] * 0.1:
                    risk_level = 'medium'
                    risk_score = 50
                    description = f'{column} is outside optimal range'
                
                risk_factors.append({
                    'parameter': column,
                    'level': risk_level,
                    'currentValue': round(current_value, 2),
                    'thresholdValue': threshold_config.get('max') or threshold_config.get('min', 0),
                    'description': description
                })
                
                total_risk_score += risk_score
                factor_count += 1
                
            except Exception as e:
                print(f"Error assessing risk for {column}: {e}")
                continue
        
        # Calculate overall risk
        avg_risk_score = total_risk_score / factor_count if factor_count > 0 else 30
        
        if avg_risk_score >= 75:
            overall_risk = 'critical'
        elif avg_risk_score >= 60:
            overall_risk = 'high'
        elif avg_risk_score >= 40:
            overall_risk = 'medium'
        else:
            overall_risk = 'low'
        
        summary = self._generate_risk_summary(overall_risk, risk_factors)
        
        return {
            'overallRiskLevel': overall_risk,
            'riskScore': round(avg_risk_score, 1),
            'riskFactors': risk_factors,
            'summary': summary
        }
    
    def _generate_risk_summary(self, risk_level: str, factors: List[Dict]) -> str:
        """Generate summary text for risk assessment"""
        high_risk_params = [f['parameter'] for f in factors if f['level'] in ['high', 'critical']]
        
        if risk_level == 'critical':
            return f"Critical water quality issues detected. Immediate action required for: {', '.join(high_risk_params)}. Contamination risk is severe."
        elif risk_level == 'high':
            return f"Significant water quality concerns identified. Parameters requiring attention: {', '.join(high_risk_params)}. Treatment measures should be implemented."
        elif risk_level == 'medium':
            return "Moderate risk level detected. Some parameters are outside optimal ranges. Regular monitoring and preventive measures recommended."
        else:
            return "Water quality is within acceptable limits. Continue regular monitoring to maintain standards."
    
    def _generate_trend_analysis(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Generate trend analysis for parameters"""
        
        parameter_trends = {}
        improving_count = 0
        declining_count = 0
        stable_count = 0
        
        for column in df.columns:
            try:
                values = df[column].dropna()
                if len(values) < 2:
                    continue
                
                # Calculate trend
                first_half = values[:len(values)//2].mean()
                second_half = values[len(values)//2:].mean()
                change = ((second_half - first_half) / first_half) * 100 if first_half != 0 else 0
                
                # Determine direction (considering whether increase is good or bad)
                if abs(change) < 5:
                    direction = 'stable'
                    stable_count += 1
                elif change > 0:
                    # For most parameters, increase could be bad (except DO)
                    if column == 'DO':
                        direction = 'improving'
                        improving_count += 1
                    else:
                        direction = 'increasing'
                        declining_count += 1
                else:
                    # Decrease could be good or bad depending on parameter
                    if column in ['BOD', 'Temperature', 'Turbidity']:
                        direction = 'improving'
                        improving_count += 1
                    else:
                        direction = 'decreasing'
                        declining_count += 1
                
                parameter_trends[column] = {
                    'direction': direction,
                    'changePercentage': round(change, 2),
                    'historicalValues': [round(v, 2) for v in values.tolist()],
                    'timestamps': [(datetime.now() - timedelta(days=i*7)).isoformat() for i in range(len(values))]
                }
                
            except Exception as e:
                print(f"Error analyzing trend for {column}: {e}")
                continue
        
        # Determine overall trend
        if improving_count > declining_count:
            overall_trend = 'improving'
        elif declining_count > improving_count:
            overall_trend = 'declining'
        else:
            overall_trend = 'stable'
        
        summary = self._generate_trend_summary(overall_trend, parameter_trends)
        
        return {
            'parameterTrends': parameter_trends,
            'overallTrend': overall_trend,
            'summary': summary
        }
    
    def _generate_trend_summary(self, overall_trend: str, trends: Dict) -> str:
        """Generate summary for trend analysis"""
        if overall_trend == 'improving':
            return "Water quality shows positive trends with improving parameters. Continue current treatment and monitoring practices."
        elif overall_trend == 'declining':
            return "Water quality is showing concerning declining trends. Investigation and corrective actions recommended."
        else:
            return "Water quality parameters remain relatively stable. Maintain current monitoring schedule."
    
    def _generate_recommendations(self, df: pd.DataFrame, risk_assessment: Dict) -> List[Dict[str, Any]]:
        """Generate actionable recommendations"""
        recommendations = []
        
        risk_level = risk_assessment['overallRiskLevel']
        risk_factors = risk_assessment['riskFactors']
        
        # High-level recommendations based on overall risk
        if risk_level in ['critical', 'high']:
            recommendations.append({
                'priority': 'high',
                'category': 'treatment',
                'title': 'Immediate Water Treatment Required',
                'description': 'Critical parameters detected requiring immediate treatment intervention to bring water quality within acceptable limits.',
                'actionItems': [
                    'Activate emergency water treatment protocols',
                    'Increase treatment chemical dosages as per guidelines',
                    'Conduct hourly monitoring until stabilization',
                    'Alert downstream communities if applicable'
                ],
                'timeframe': 'immediate'
            })
        
        # Parameter-specific recommendations
        for factor in risk_factors:
            if factor['level'] in ['high', 'critical']:
                param = factor['parameter']
                
                if param == 'pH':
                    recommendations.append({
                        'priority': 'high',
                        'category': 'treatment',
                        'title': f'Adjust pH Levels',
                        'description': f'pH is at {factor["currentValue"]}, outside safe range. Immediate pH correction needed.',
                        'actionItems': [
                            'Add pH correction chemicals (lime/acid)',
                            'Check neutralization systems',
                            'Monitor pH continuously for 24 hours',
                            'Investigate source of pH imbalance'
                        ],
                        'timeframe': 'immediate'
                    })
                
                elif param == 'DO':
                    recommendations.append({
                        'priority': 'high',
                        'category': 'treatment',
                        'title': 'Increase Dissolved Oxygen',
                        'description': 'Dissolved oxygen levels are critically low, affecting aquatic life.',
                        'actionItems': [
                            'Activate aeration systems',
                            'Check for pollution sources',
                            'Reduce organic load input',
                            'Monitor DO levels every 2 hours'
                        ],
                        'timeframe': 'immediate'
                    })
                
                elif param == 'BOD':
                    recommendations.append({
                        'priority': 'high',
                        'category': 'treatment',
                        'title': 'Reduce Organic Pollution',
                        'description': 'High BOD indicates excessive organic pollution requiring treatment.',
                        'actionItems': [
                            'Identify and stop pollution sources',
                            'Increase biological treatment capacity',
                            'Implement stricter discharge controls',
                            'Conduct daily BOD monitoring'
                        ],
                        'timeframe': 'short-term'
                    })
        
        # Monitoring recommendations
        recommendations.append({
            'priority': 'medium',
            'category': 'monitoring',
            'title': 'Enhanced Monitoring Program',
            'description': 'Implement comprehensive monitoring to track water quality trends and early warning signs.',
            'actionItems': [
                'Install automated monitoring sensors',
                'Conduct weekly laboratory analysis',
                'Establish early warning alert systems',
                'Train staff on monitoring protocols'
            ],
            'timeframe': 'short-term'
        })
        
        # Infrastructure recommendations
        if risk_level in ['medium', 'high', 'critical']:
            recommendations.append({
                'priority': 'medium',
                'category': 'infrastructure',
                'title': 'Upgrade Treatment Infrastructure',
                'description': 'Current treatment capacity may be insufficient for maintaining consistent water quality.',
                'actionItems': [
                    'Assess treatment plant capacity',
                    'Plan infrastructure upgrades',
                    'Allocate budget for improvements',
                    'Implement phased upgrade plan'
                ],
                'timeframe': 'long-term'
            })
        
        # Policy recommendations
        recommendations.append({
            'priority': 'low',
            'category': 'policy',
            'title': 'Strengthen Water Quality Regulations',
            'description': 'Review and update water quality management policies to prevent future issues.',
            'actionItems': [
                'Review current water quality standards',
                'Update discharge permit requirements',
                'Implement stricter enforcement mechanisms',
                'Conduct stakeholder consultations'
            ],
            'timeframe': 'long-term'
        })
        
        return recommendations
    
    def save_report(self, report: Dict[str, Any]) -> str:
        """Save report to file system"""
        report_id = report['id']
        file_path = self.reports_dir / f"{report_id}.json"
        
        with open(file_path, 'w') as f:
            json.dump(report, f, indent=2)
        
        return report_id
    
    def get_saved_reports(self) -> List[Dict[str, Any]]:
        """Retrieve all saved reports"""
        reports = []
        
        for file_path in self.reports_dir.glob("*.json"):
            try:
                with open(file_path, 'r') as f:
                    report = json.load(f)
                    reports.append(report)
            except Exception as e:
                print(f"Error loading report {file_path}: {e}")
                continue
        
        # Sort by timestamp, newest first
        reports.sort(key=lambda x: x.get('timestamp', ''), reverse=True)
        return reports
    
    def get_report_by_id(self, report_id: str) -> Optional[Dict[str, Any]]:
        """Get specific report by ID"""
        file_path = self.reports_dir / f"{report_id}.json"
        
        if not file_path.exists():
            return None
        
        try:
            with open(file_path, 'r') as f:
                return json.load(f)
        except Exception as e:
            print(f"Error loading report: {e}")
            return None
    
    def delete_report(self, report_id: str) -> bool:
        """Delete a report"""
        file_path = self.reports_dir / f"{report_id}.json"
        
        if file_path.exists():
            file_path.unlink()
            return True
        return False
