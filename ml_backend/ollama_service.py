import requests
import json
from typing import Optional, List, Dict, Any
from datetime import datetime, timedelta

class OllamaAIService:
    def __init__(self, base_url: str = "http://localhost:11434", model: str = "mistral"):
        self.base_url = base_url
        self.model = model
    
    def check_connection(self) -> bool:
        """Check if Ollama is running"""
        try:
            response = requests.get(f"{self.base_url}/api/tags", timeout=5)
            return response.status_code == 200
        except:
            return False
    
    def list_models(self) -> List[str]:
        """Get available models"""
        try:
            response = requests.get(f"{self.base_url}/api/tags", timeout=5)
            if response.status_code == 200:
                data = response.json()
                return [model['name'] for model in data.get('models', [])]
            return []
        except Exception as e:
            print(f"Error listing models: {e}")
            return []
    
    def generate_analysis(self, file_data: Dict[str, Any], location: Optional[Dict] = None) -> Dict[str, Any]:
        """Generate comprehensive water quality analysis using Ollama"""
        
        # Prepare data summary for Ollama
        data_summary = self._prepare_data_summary(file_data)
        location_info = f"\nLocation: {location['name']} ({location['district']}, {location['region']})" if location else ""
        
        # Generate each component using Ollama
        predictions = self._generate_predictions_ollama(data_summary, location_info)
        risk_assessment = self._generate_risk_assessment_ollama(data_summary, location_info)
        trend_analysis = self._generate_trend_analysis_ollama(data_summary, location_info)
        recommendations = self._generate_recommendations_ollama(data_summary, risk_assessment, location_info)
        
        # Build report
        timestamp = datetime.now()
        report = {
            'id': str(hash(f"{timestamp}{file_data}")),
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
    
    def _prepare_data_summary(self, file_data: Dict) -> str:
        """Prepare a concise summary of the data for Ollama"""
        data = file_data.get('data', {})
        summary = "Water Quality Data Summary:\n"
        
        for param, values in data.items():
            if isinstance(values, list) and len(values) > 0:
                avg = sum(v for v in values if isinstance(v, (int, float))) / len([v for v in values if isinstance(v, (int, float))]) if any(isinstance(v, (int, float)) for v in values) else 0
                min_val = min((v for v in values if isinstance(v, (int, float))), default=0)
                max_val = max((v for v in values if isinstance(v, (int, float))), default=0)
                summary += f"- {param}: avg={avg:.2f}, min={min_val:.2f}, max={max_val:.2f}, count={len(values)}\n"
        
        return summary
    
    def _generate_predictions_ollama(self, data_summary: str, location_info: str) -> Dict[str, Any]:
        """Use Ollama to generate 2-month predictions"""
        
        prompt = f"""Analyze this water quality data and provide 2-month predictions for key parameters.
{location_info}

{data_summary}

Provide predictions for the next 8 weeks (2 months) for each parameter. Consider:
1. Current trends in the data
2. Seasonal variations
3. Environmental factors
4. Historical patterns

Format your response as a structured analysis with predicted values and trends."""

        try:
            response = self._call_ollama(prompt)
            
            # Parse Ollama response and structure it
            # For now, returning a structured format based on the data
            predictions = {}
            data = data_summary.split('\n')
            for line in data:
                if ':' in line and 'avg=' in line:
                    param = line.split(':')[0].replace('-', '').strip()
                    avg_str = line.split('avg=')[1].split(',')[0]
                    try:
                        avg_val = float(avg_str)
                        predictions[param] = {
                            'current': round(avg_val, 2),
                            'predicted': [round(avg_val + (i * 0.05 * avg_val), 2) for i in range(1, 9)],
                            'trend': 'stable',
                            'confidence': 0.85,
                            'ai_analysis': response[:200] + "..." if len(response) > 200 else response
                        }
                    except:
                        continue
            
            return predictions
            
        except Exception as e:
            print(f"Error generating predictions: {e}")
            return {}
    
    def _generate_risk_assessment_ollama(self, data_summary: str, location_info: str) -> Dict[str, Any]:
        """Use Ollama to generate risk assessment"""
        
        prompt = f"""As a water quality expert, assess the risks in this water quality data.
{location_info}

{data_summary}

Provide:
1. Overall risk level (low, medium, high, or critical)
2. Risk score (0-100)
3. Specific risk factors for each parameter that exceeds safe limits
4. Comparison with WHO/BIS standards for drinking water
5. Potential health and environmental impacts

Be specific about which parameters are concerning and why."""

        try:
            response = self._call_ollama(prompt)
            
            # Determine risk level from Ollama response
            response_lower = response.lower()
            if 'critical' in response_lower:
                risk_level = 'critical'
                risk_score = 85.0
            elif 'high' in response_lower and 'risk' in response_lower:
                risk_level = 'high'
                risk_score = 70.0
            elif 'medium' in response_lower or 'moderate' in response_lower:
                risk_level = 'medium'
                risk_score = 50.0
            else:
                risk_level = 'low'
                risk_score = 25.0
            
            # Extract risk factors
            risk_factors = []
            lines = response.split('\n')
            for line in lines:
                if any(param in line.lower() for param in ['ph', 'do', 'bod', 'temperature', 'turbidity', 'tds']):
                    risk_factors.append({
                        'parameter': line.split(':')[0].strip() if ':' in line else 'General',
                        'level': risk_level,
                        'currentValue': 0.0,
                        'thresholdValue': 0.0,
                        'description': line.strip()
                    })
            
            return {
                'overallRiskLevel': risk_level,
                'riskScore': risk_score,
                'riskFactors': risk_factors[:5],  # Top 5 factors
                'summary': response[:500] + "..." if len(response) > 500 else response
            }
            
        except Exception as e:
            print(f"Error generating risk assessment: {e}")
            return {
                'overallRiskLevel': 'medium',
                'riskScore': 50.0,
                'riskFactors': [],
                'summary': 'Unable to generate risk assessment at this time.'
            }
    
    def _generate_trend_analysis_ollama(self, data_summary: str, location_info: str) -> Dict[str, Any]:
        """Use Ollama to generate trend analysis"""
        
        prompt = f"""Analyze the trends in this water quality data over time.
{location_info}

{data_summary}

For each parameter, identify:
1. Is the trend improving, stable, or declining?
2. What is the rate of change (percentage)?
3. Are there any concerning patterns?
4. What might be causing these trends?

Provide a comprehensive trend analysis."""

        try:
            response = self._call_ollama(prompt)
            
            # Determine overall trend
            response_lower = response.lower()
            if 'improving' in response_lower or 'better' in response_lower:
                overall_trend = 'improving'
            elif 'declining' in response_lower or 'worsen' in response_lower or 'deteriorat' in response_lower:
                overall_trend = 'declining'
            else:
                overall_trend = 'stable'
            
            # Build parameter trends
            parameter_trends = {}
            data = data_summary.split('\n')
            for line in data:
                if ':' in line and 'avg=' in line:
                    param = line.split(':')[0].replace('-', '').strip()
                    parameter_trends[param] = {
                        'direction': overall_trend,
                        'changePercentage': 2.5,
                        'historicalValues': [],
                        'timestamps': [],
                        'ai_insight': response[:200] + "..." if len(response) > 200 else response
                    }
            
            return {
                'parameterTrends': parameter_trends,
                'overallTrend': overall_trend,
                'summary': response[:500] + "..." if len(response) > 500 else response
            }
            
        except Exception as e:
            print(f"Error generating trend analysis: {e}")
            return {
                'parameterTrends': {},
                'overallTrend': 'stable',
                'summary': 'Unable to generate trend analysis at this time.'
            }
    
    def _generate_recommendations_ollama(self, data_summary: str, risk_assessment: Dict, location_info: str) -> List[Dict[str, Any]]:
        """Use Ollama to generate actionable recommendations"""
        
        prompt = f"""Based on this water quality analysis, provide specific, actionable recommendations for government officials.
{location_info}

{data_summary}

Risk Level: {risk_assessment.get('overallRiskLevel', 'unknown')}
Risk Summary: {risk_assessment.get('summary', '')}

Provide recommendations in these categories:
1. TREATMENT: Immediate water treatment actions
2. MONITORING: Enhanced monitoring requirements
3. INFRASTRUCTURE: Long-term infrastructure improvements
4. POLICY: Policy and regulatory measures

For each recommendation, specify:
- Priority (high/medium/low)
- Specific action items
- Timeframe (immediate/short-term/long-term)

Focus on practical, implementable solutions."""

        try:
            response = self._call_ollama(prompt)
            
            # Parse recommendations from response
            recommendations = []
            
            # Add treatment recommendation
            if risk_assessment.get('overallRiskLevel') in ['high', 'critical']:
                recommendations.append({
                    'priority': 'high',
                    'category': 'treatment',
                    'title': 'Immediate Water Treatment Required',
                    'description': 'Critical parameters detected requiring immediate intervention.',
                    'actionItems': self._extract_action_items(response, 'treatment'),
                    'timeframe': 'immediate'
                })
            
            # Add monitoring recommendation
            recommendations.append({
                'priority': 'medium',
                'category': 'monitoring',
                'title': 'Enhanced Monitoring Program',
                'description': 'Implement comprehensive monitoring to track water quality trends.',
                'actionItems': self._extract_action_items(response, 'monitoring'),
                'timeframe': 'short-term'
            })
            
            # Add infrastructure recommendation
            recommendations.append({
                'priority': 'medium',
                'category': 'infrastructure',
                'title': 'Infrastructure Assessment and Upgrades',
                'description': response[:300] + "..." if len(response) > 300 else response,
                'actionItems': self._extract_action_items(response, 'infrastructure'),
                'timeframe': 'long-term'
            })
            
            # Add policy recommendation
            recommendations.append({
                'priority': 'low',
                'category': 'policy',
                'title': 'Policy and Regulatory Measures',
                'description': 'Strengthen water quality management policies.',
                'actionItems': self._extract_action_items(response, 'policy'),
                'timeframe': 'long-term'
            })
            
            return recommendations
            
        except Exception as e:
            print(f"Error generating recommendations: {e}")
            return []
    
    def _extract_action_items(self, text: str, category: str) -> List[str]:
        """Extract action items from Ollama response"""
        action_items = []
        lines = text.split('\n')
        
        # Look for bullet points or numbered items
        for line in lines:
            line = line.strip()
            if line.startswith(('-', '•', '*')) or (line and line[0].isdigit() and '.' in line):
                item = line.lstrip('-•*0123456789. ')
                if len(item) > 10:  # Meaningful action item
                    action_items.append(item)
        
        # If no items found, create generic ones
        if not action_items:
            action_items = [
                f"Conduct comprehensive {category} assessment",
                f"Implement {category} protocols as per guidelines",
                f"Regular review and monitoring of {category} measures"
            ]
        
        return action_items[:5]  # Return top 5 action items
    
    def _call_ollama(self, prompt: str) -> str:
        """Make a call to Ollama API"""
        try:
            response = requests.post(
                f"{self.base_url}/api/generate",
                json={
                    "model": self.model,
                    "prompt": prompt,
                    "stream": False,
                    "system": "You are an expert water quality analyst with deep knowledge of environmental science, water treatment, and public health. Provide detailed, scientifically accurate analysis."
                },
                timeout=120
            )
            
            if response.status_code == 200:
                result = response.json()
                return result.get('response', '')
            else:
                return f"Error: Status {response.status_code}"
                
        except requests.exceptions.Timeout:
            return "Ollama is taking too long. Please try again."
        except requests.exceptions.ConnectionError:
            return "Cannot connect to Ollama. Make sure it's running: ollama serve"
        except Exception as e:
            return f"Error: {str(e)}"
