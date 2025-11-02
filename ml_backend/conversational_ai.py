import json
from ml_models import WaterQualityMLModels
import pandas as pd


class ConversationalAI:
    """Handle human-like conversations about water quality"""
    
    def __init__(self):
        self.models = WaterQualityMLModels()
        self.models.load_models()
        self.conversation_history = []
        self.uploaded_data = None
    
    def set_uploaded_data(self, df):
        """Store uploaded data for analysis"""
        self.uploaded_data = df
    
    def process_message(self, user_message, file_data=None):
        """
        Process user message and generate response
        Integrates uploaded files + ML models + conversational AI
        """
        
        message_lower = user_message.lower()
        response = None
        
        # Store message in history
        self.conversation_history.append({
            'role': 'user',
            'message': user_message,
            'timestamp': pd.Timestamp.now()
        })
        
        # Route to appropriate handler
        if file_data is not None and ('analyze' in message_lower or 'upload' in message_lower):
            response = self._handle_file_analysis(user_message, file_data)
        
        elif any(word in message_lower for word in ['predict', 'analyze', 'status', 'quality']):
            response = self._handle_water_quality_question(user_message)
        
        elif any(word in message_lower for word in ['recommendation', 'suggest', 'how']):
            response = self._handle_recommendation_request(user_message)
        
        elif any(word in message_lower for word in ['hello', 'hi', 'help']):
            response = self._handle_greeting(user_message)
        
        else:
            response = self._handle_general_query(user_message)
        
        # Store response in history
        self.conversation_history.append({
            'role': 'assistant',
            'message': response['text'],
            'timestamp': pd.Timestamp.now(),
            'intent': response.get('intent', 'general')
        })
        
        return response
    
    def _handle_file_analysis(self, message, file_data):
        """Analyze uploaded files"""
        try:
            from file_parser import FileParser
            
            # Convert dict to DataFrame if needed
            if isinstance(file_data, dict):
                df = FileParser.convert_to_dataframe(file_data)
            else:
                df = file_data
            
            stats, water_data = FileParser.analyze_file_statistics(df)
            
            # Calculate averages
            avg_pH = None
            avg_turbidity = None
            avg_DO = None
            
            if 'pH' in water_data:
                avg_pH = float(pd.to_numeric(water_data['pH'], errors='coerce').mean())
            
            if 'turbidity' in water_data:
                avg_turbidity = float(pd.to_numeric(water_data['turbidity'], errors='coerce').mean())
            
            if 'dissolved_oxygen' in water_data:
                avg_DO = float(pd.to_numeric(water_data['dissolved_oxygen'], errors='coerce').mean())
            
            # Make ML prediction
            prediction = None
            if avg_pH is not None and avg_turbidity is not None and avg_DO is not None:
                prediction = self.models.predict(
                    float(avg_pH), float(avg_turbidity), float(avg_DO), 25.0, 500.0
                )
            
            # Generate response with proper formatting
            status_text = prediction['status'] if prediction else 'N/A'
            score_text = f"{prediction['score']:.1f}/100" if prediction else 'N/A'
            confidence_text = f"{prediction['confidence']:.1%}" if prediction else 'N/A'
            
            # Format pH, turbidity, DO with proper values
            pH_str = f"{avg_pH:.2f}" if avg_pH is not None else 'N/A'
            turb_str = f"{avg_turbidity:.2f}" if avg_turbidity is not None else 'N/A'
            DO_str = f"{avg_DO:.2f}" if avg_DO is not None else 'N/A'
            
            analysis_text = (
                "\n📊 **File Analysis Complete**\n\n"
                "**Dataset Overview:**\n"
                f"- Total Records: {len(df)}\n"
                f"- Columns Found: {', '.join([str(c) for c in df.columns[:5]])}\n\n"
                "**Water Quality Statistics:**\n"
                f"- Average pH: {pH_str} (Safe: 6.5-8.5)\n"
                f"- Average Turbidity: {turb_str} NTU (Safe: less than 5)\n"
                f"- Average Dissolved Oxygen: {DO_str} mg/L (Safe: greater than 5)\n\n"
                "**ML Model Analysis:**\n"
                f"- Predicted Status: {status_text}\n"
                f"- Quality Score: {score_text}\n"
                f"- Model Confidence: {confidence_text}\n\n"
                "**Key Findings:**\n"
                f"{self._generate_insights(water_data, prediction)}\n\n"
                "Would you like me to:\n"
                "- Deep dive into specific locations?\n"
                "- Generate detailed report?\n"
                "- Compare trends over time?\n"
                "- Create recommendations?"
            )
            
            return {
                'text': analysis_text,
                'intent': 'file_analysis',
                'data': stats,
                'prediction': prediction
            }
        
        except Exception as e:
            import traceback
            traceback.print_exc()
            return {
                'text': f"❌ Error analyzing file: {str(e)}",
                'intent': 'error'
            }
    
    def _handle_water_quality_question(self, message):
        """Handle questions about water quality"""
        response_text = (
            "\n💧 **Water Quality Overview**\n\n"
            "Water quality depends on several parameters:\n\n"
            "1. **pH Level** (6.5-8.5 is safe)\n"
            "   - Too low: Acidic, corrosive\n"
            "   - Too high: Alkaline, scaling\n\n"
            "2. **Turbidity** (less than 5 NTU is safe)\n"
            "   - Caused by suspended particles\n"
            "   - Affects light penetration\n\n"
            "3. **Dissolved Oxygen** (greater than 5 mg/L is safe)\n"
            "   - Essential for aquatic life\n"
            "   - Low levels = stagnant water\n\n"
            "4. **Temperature** (optimal: 20-25 degrees Celsius)\n"
            "   - Affects chemical reactions\n"
            "   - Impacts biological activity\n\n"
            "5. **Conductivity** (300-600 microS/cm is typical)\n"
            "   - Measures dissolved solids\n"
            "   - Indicates mineral content\n\n"
            "**Your uploaded data shows:**\n"
            "- If you've uploaded files, I can analyze them\n"
            "- Would you like me to check your latest data?"
        )
        
        return {
            'text': response_text,
            'intent': 'water_quality_question'
        }
    
    def _handle_recommendation_request(self, message):
        """Generate recommendations"""
        response_text = (
            "\n💡 **Water Quality Recommendations**\n\n"
            "Based on standard water quality guidelines:\n\n"
            "✅ **For Safe Water:**\n"
            "- Maintain pH 6.5-8.5\n"
            "- Keep turbidity below 5 NTU\n"
            "- Ensure DO above 5 mg/L\n"
            "- Regular testing schedule\n"
            "- Proper treatment maintenance\n\n"
            "⚠️ **For Warning Level:**\n"
            "- Increase monitoring frequency\n"
            "- Review treatment parameters\n"
            "- Check for contamination sources\n"
            "- Implement corrective actions\n"
            "- Document all changes\n\n"
            "🚨 **For Critical Level:**\n"
            "- IMMEDIATE action required\n"
            "- Activate emergency protocols\n"
            "- Notify authorities\n"
            "- Implement emergency treatment\n"
            "- Increase monitoring to hourly\n\n"
            "Would you like specific recommendations for your uploaded data?"
        )
        
        return {
            'text': response_text,
            'intent': 'recommendation'
        }
    
    def _handle_greeting(self, message):
        """Handle greeting"""
        response_text = (
            "\n👋 **Welcome to PureHealth AI Assistant**\n\n"
            "I'm your intelligent water quality advisor. I can help you:\n\n"
            "📊 **Analyze Water Data**\n"
            "- Upload CSV, Excel, or PDF files\n"
            "- Extract water quality metrics\n"
            "- Generate statistics\n\n"
            "🤖 **ML-Powered Predictions**\n"
            "- Predict water status (Safe/Warning/Critical)\n"
            "- Quality scoring (0-100)\n"
            "- Confidence measures\n\n"
            "💡 **Smart Recommendations**\n"
            "- Based on analysis results\n"
            "- Treatment suggestions\n"
            "- Preventive measures\n\n"
            "📈 **Insights and Trends**\n"
            "- Historical analysis\n"
            "- Pattern detection\n"
            "- Risk assessment\n\n"
            "**How to start:**\n"
            "1. Upload your water quality data\n"
            "2. Ask me questions about it\n"
            "3. Get AI-powered analysis and recommendations\n\n"
            "What would you like to do?"
        )
        
        return {
            'text': response_text,
            'intent': 'greeting'
        }
    
    def _handle_general_query(self, message):
        """Handle general queries"""
        response_text = (
            f"I understand you're asking: \"{message}\"\n\n"
            "I can help with water quality analysis. Please try:\n"
            "- 'Analyze my water data' (after uploading files)\n"
            "- 'What is water quality?'\n"
            "- 'Give recommendations'\n"
            "- 'Predict water status'\n"
            "- 'Show me trends'\n\n"
            "Upload a file first, then ask me specific questions!"
        )
        
        return {
            'text': response_text,
            'intent': 'general'
        }
    
    def _generate_insights(self, water_data, prediction):
        """Generate insights from data"""
        insights = []
        
        try:
            if 'pH' in water_data:
                ph_series = pd.to_numeric(water_data['pH'], errors='coerce')
                ph = ph_series.mean()
                if ph < 6.5:
                    insights.append("⚠️ pH is too low - consider alkalinity treatment")
                elif ph > 8.5:
                    insights.append("⚠️ pH is too high - consider acidity adjustment")
                else:
                    insights.append("✅ pH levels are optimal")
        except:
            pass
        
        try:
            if 'turbidity' in water_data:
                turb_series = pd.to_numeric(water_data['turbidity'], errors='coerce')
                turb = turb_series.mean()
                if turb > 5:
                    insights.append("⚠️ Turbidity exceeds safe limits - enhance filtration")
                else:
                    insights.append("✅ Turbidity is acceptable")
        except:
            pass
        
        if prediction and prediction.get('status') == 'Critical':
            insights.append("🚨 CRITICAL: Immediate action required!")
        
        return '\n'.join(insights) if insights else "No specific issues detected"
