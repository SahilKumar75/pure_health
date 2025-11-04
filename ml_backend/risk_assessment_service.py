"""
Risk Assessment Service
Evaluates contamination risks and provides detailed risk analysis
"""

import pandas as pd
import numpy as np
from typing import Dict, List, Any, Tuple
from utils import convert_to_serializable


class RiskAssessmentService:
    """Evaluate water quality risks and contamination levels"""
    
    def __init__(self):
        # WHO/BIS/MPCB Standards for drinking water
        self.standards = {
            'pH': {
                'min': 6.5,
                'max': 8.5,
                'optimal': 7.0,
                'critical_min': 5.5,
                'critical_max': 9.5,
                'weight': 0.20
            },
            'turbidity': {
                'max': 5.0,
                'optimal': 1.0,
                'critical_max': 10.0,
                'weight': 0.25
            },
            'dissolved_oxygen': {
                'min': 5.0,
                'optimal': 7.0,
                'critical_min': 3.0,
                'weight': 0.20
            },
            'DO': {
                'min': 5.0,
                'optimal': 7.0,
                'critical_min': 3.0,
                'weight': 0.20
            },
            'temperature': {
                'min': 20.0,
                'max': 30.0,
                'optimal': 25.0,
                'critical_min': 15.0,
                'critical_max': 35.0,
                'weight': 0.10
            },
            'conductivity': {
                'min': 300,
                'max': 600,
                'optimal': 450,
                'critical_max': 1000,
                'weight': 0.10
            },
            'BOD': {
                'max': 3.0,
                'optimal': 2.0,
                'critical_max': 6.0,
                'weight': 0.15
            },
            'TDS': {
                'max': 500,
                'optimal': 300,
                'critical_max': 1000,
                'weight': 0.10
            },
            'coliform': {
                'max': 0,
                'optimal': 0,
                'critical_max': 10,
                'weight': 0.30
            }
        }
    
    def assess_risk(self, df: pd.DataFrame) -> Dict[str, Any]:
        """
        Comprehensive risk assessment of water quality data
        
        Args:
            df: DataFrame with water quality measurements
            
        Returns:
            Risk assessment dictionary with scores, factors, and recommendations
        """
        risk_factors = []
        total_weighted_score = 0
        total_weight = 0
        
        # Analyze each parameter
        for column in df.columns:
            param_lower = column.lower()
            
            # Skip non-water quality columns
            if param_lower in ['date', 'timestamp', 'location', 'station', 'id']:
                continue
            
            # Check if parameter has standards defined
            standard = self._get_standard(param_lower)
            if not standard:
                continue
            
            try:
                # Get parameter values
                values = pd.to_numeric(df[column], errors='coerce').dropna()
                if len(values) == 0:
                    continue
                
                # Calculate risk for this parameter
                risk_factor = self._assess_parameter_risk(
                    column,
                    values.tolist(),
                    standard
                )
                
                if risk_factor:
                    risk_factors.append(risk_factor)
                    total_weighted_score += risk_factor['riskScore'] * standard['weight']
                    total_weight += standard['weight']
                    
            except Exception as e:
                print(f"Error assessing risk for {column}: {e}")
                continue
        
        # Calculate overall risk
        overall_score = (total_weighted_score / total_weight) if total_weight > 0 else 50.0
        overall_level = self._determine_risk_level(overall_score)
        
        # Generate summary
        summary = self._generate_risk_summary(overall_level, overall_score, risk_factors)
        
        # Health impact assessment
        health_impact = self._assess_health_impact(risk_factors)
        
        result = {
            'overallRiskLevel': overall_level,
            'riskScore': round(overall_score, 1),
            'riskFactors': sorted(risk_factors, key=lambda x: x['riskScore'], reverse=True),
            'summary': summary,
            'healthImpact': health_impact,
            'timestamp': pd.Timestamp.now().isoformat()
        }
        
        return convert_to_serializable(result)
    
    def _get_standard(self, param_name: str) -> Dict[str, Any]:
        """Get standard for parameter (handle name variations)"""
        # Normalize parameter name
        if param_name in self.standards:
            return self.standards[param_name]
        
        # Check variations
        if 'do' in param_name or 'oxygen' in param_name:
            return self.standards.get('dissolved_oxygen')
        if 'turb' in param_name:
            return self.standards.get('turbidity')
        if 'temp' in param_name:
            return self.standards.get('temperature')
        if 'cond' in param_name:
            return self.standards.get('conductivity')
        
        return None
    
    def _assess_parameter_risk(
        self,
        parameter: str,
        values: List[float],
        standard: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Assess risk for a single parameter"""
        
        current_value = float(np.mean(values))
        min_value = float(np.min(values))
        max_value = float(np.max(values))
        std_dev = float(np.std(values))
        
        # Calculate risk score (0-100, higher = more risk)
        risk_score = 0
        risk_level = 'low'
        description = f'{parameter} is within acceptable limits'
        
        # Check against thresholds
        if 'min' in standard:
            if current_value < standard.get('critical_min', standard['min'] * 0.7):
                risk_score = 90
                risk_level = 'critical'
                description = f'{parameter} is critically below minimum safe level'
            elif current_value < standard['min']:
                risk_score = 70
                risk_level = 'high'
                description = f'{parameter} is below minimum safe level'
        
        if 'max' in standard:
            if current_value > standard.get('critical_max', standard['max'] * 1.5):
                risk_score = max(risk_score, 95)
                risk_level = 'critical'
                description = f'{parameter} critically exceeds maximum safe level'
            elif current_value > standard['max']:
                risk_score = max(risk_score, 75)
                risk_level = 'high'
                description = f'{parameter} exceeds maximum safe level'
        
        # Check deviation from optimal
        if risk_score < 60 and 'optimal' in standard:
            deviation_pct = abs((current_value - standard['optimal']) / standard['optimal']) * 100
            if deviation_pct > 20:
                risk_score = max(risk_score, 50)
                risk_level = 'medium' if risk_level == 'low' else risk_level
                description = f'{parameter} deviates from optimal range'
        
        # Check variability (high std dev indicates instability)
        if std_dev > current_value * 0.15:  # More than 15% variation
            risk_score = max(risk_score, 40)
            if risk_level == 'low':
                risk_level = 'medium'
                description = f'{parameter} shows high variability'
        
        # If still low risk
        if risk_score < 30:
            risk_score = 20
            risk_level = 'low'
        
        return {
            'parameter': parameter,
            'level': risk_level,
            'riskScore': round(risk_score, 1),
            'currentValue': round(current_value, 2),
            'minObserved': round(min_value, 2),
            'maxObserved': round(max_value, 2),
            'standardMin': standard.get('min'),
            'standardMax': standard.get('max'),
            'standardOptimal': standard.get('optimal'),
            'deviation': round(std_dev, 2),
            'description': description
        }
    
    def _determine_risk_level(self, score: float) -> str:
        """Determine overall risk level from score"""
        if score >= 80:
            return 'critical'
        elif score >= 60:
            return 'high'
        elif score >= 40:
            return 'medium'
        else:
            return 'low'
    
    def _generate_risk_summary(
        self,
        level: str,
        score: float,
        factors: List[Dict[str, Any]]
    ) -> str:
        """Generate human-readable risk summary"""
        
        critical_factors = [f for f in factors if f['level'] == 'critical']
        high_factors = [f for f in factors if f['level'] == 'high']
        
        if level == 'critical':
            params = ', '.join([f['parameter'] for f in critical_factors][:3])
            return (
                f"🚨 CRITICAL RISK DETECTED (Score: {score:.1f}/100)\n\n"
                f"Severe water quality issues identified. Critical parameters: {params}. "
                f"IMMEDIATE ACTION REQUIRED. Water may be unsafe for consumption and poses "
                f"significant health risks. Emergency treatment protocols must be activated."
            )
        
        elif level == 'high':
            params = ', '.join([f['parameter'] for f in high_factors][:3])
            return (
                f"⚠️ HIGH RISK (Score: {score:.1f}/100)\n\n"
                f"Significant water quality concerns. Parameters requiring urgent attention: {params}. "
                f"Water quality is degraded and requires prompt corrective measures. "
                f"Enhanced monitoring and treatment recommended."
            )
        
        elif level == 'medium':
            return (
                f"⚡ MODERATE RISK (Score: {score:.1f}/100)\n\n"
                f"Some parameters are outside optimal ranges. While not immediately dangerous, "
                f"conditions should be monitored closely. Preventive measures recommended "
                f"to avoid escalation to higher risk levels."
            )
        
        else:
            return (
                f"✅ LOW RISK (Score: {score:.1f}/100)\n\n"
                f"Water quality is within acceptable standards. Continue regular monitoring "
                f"to maintain current conditions. Minor adjustments may optimize quality further."
            )
    
    def _assess_health_impact(self, risk_factors: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Assess potential health and environmental impacts"""
        
        impacts = {
            'immediate': [],
            'short_term': [],
            'long_term': [],
            'severity': 'low'
        }
        
        for factor in risk_factors:
            param = factor['parameter'].lower()
            level = factor['level']
            
            if level in ['critical', 'high']:
                if 'ph' in param:
                    impacts['immediate'].append('Skin and eye irritation')
                    impacts['short_term'].append('Digestive issues, corrosion of fixtures')
                    impacts['long_term'].append('Chronic digestive problems')
                
                elif 'do' in param or 'oxygen' in param:
                    impacts['immediate'].append('Fish kills, foul odor')
                    impacts['short_term'].append('Ecosystem degradation')
                    impacts['long_term'].append('Loss of aquatic biodiversity')
                
                elif 'bod' in param:
                    impacts['immediate'].append('Oxygen depletion')
                    impacts['short_term'].append('Algal blooms, fish mortality')
                    impacts['long_term'].append('Eutrophication, ecosystem collapse')
                
                elif 'turb' in param:
                    impacts['immediate'].append('Cloudiness, aesthetic issues')
                    impacts['short_term'].append('Reduced disinfection effectiveness')
                    impacts['long_term'].append('Pathogen harbor, chronic infections')
                
                elif 'coliform' in param:
                    impacts['immediate'].append('⚠️ Waterborne disease risk')
                    impacts['short_term'].append('Gastroenteritis, diarrhea')
                    impacts['long_term'].append('Chronic intestinal infections')
        
        # Determine severity
        if any(f['level'] == 'critical' for f in risk_factors):
            impacts['severity'] = 'critical'
        elif any(f['level'] == 'high' for f in risk_factors):
            impacts['severity'] = 'high'
        elif any(f['level'] == 'medium' for f in risk_factors):
            impacts['severity'] = 'medium'
        
        # Remove duplicates
        impacts['immediate'] = list(set(impacts['immediate']))
        impacts['short_term'] = list(set(impacts['short_term']))
        impacts['long_term'] = list(set(impacts['long_term']))
        
        return impacts
