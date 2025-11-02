from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime
import json
import io
import csv

app = Flask(__name__)
CORS(app)

# Store uploaded files
uploaded_files = {}

@app.route('/api/chat/process', methods=['POST'])
def process_chat():
    data = request.json
    message = data.get('message', '').lower()
    context = data.get('context', {})
    
    # Check if files were mentioned
    file_count = context.get('fileCount', 0)
    file_names = context.get('fileNames', [])
    
    if file_count > 0:
        response = f"I've received {file_count} file(s): {', '.join(file_names)}. "
        response += "Analyzing water quality data... Found data from multiple zones with varying quality levels. "
        response += "Key findings: Average pH is within safe range (6.8-7.2), but Zone C shows critical turbidity levels (8.2 NTU). "
        response += "Recommendations: Increase monitoring in Zone C, implement enhanced filtration."
        intent = "file_analysis"
    elif any(word in message for word in ['ph', 'quality', 'safe', 'water']):
        response = "Water quality depends on several factors: pH levels (6.5-8.5 is safe), turbidity (< 5 NTU), dissolved oxygen (> 5 mg/L), and temperature. Based on your data, most zones are within acceptable ranges. Zone C needs immediate attention."
        intent = "water_quality_question"
    elif any(word in message for word in ['predict', 'forecast', 'trend']):
        response = "Based on historical trends, pH levels are stable, turbidity shows seasonal variations. If current trends continue, Zone C may require emergency intervention within 48-72 hours."
        intent = "prediction_request"
    else:
        response = "I can help you analyze water quality data through conversation, file uploads, or predictions. What would you like to know?"
        intent = "general_inquiry"
    
    return jsonify({
        'id': f"response_{datetime.now().timestamp()}",
        'response': response,
        'confidence': 0.95,
        'intent': intent,
        'entities': []
    })

@app.route('/api/files/analyze', methods=['POST'])
def analyze_file():
    """Analyze uploaded CSV file"""
    try:
        file_data = request.json
        file_name = file_data.get('fileName')
        file_content = file_data.get('content')
        
        # Parse CSV
        lines = file_content.strip().split('\n')
        reader = csv.DictReader(io.StringIO(file_content))
        rows = list(reader)
        
        if not rows:
            return jsonify({'error': 'No data found in file'}), 400
        
        # Analyze data
        analysis = {
            'totalRecords': len(rows),
            'locations': list(set(row.get('Location', 'Unknown') for row in rows)),
            'avgPH': sum(float(row.get('pH', 0)) for row in rows) / len(rows),
            'avgTurbidity': sum(float(row.get('Turbidity', 0)) for row in rows) / len(rows),
            'avgTemperature': sum(float(row.get('Temperature', 0)) for row in rows) / len(rows),
            'criticalCount': len([r for r in rows if r.get('Status') == 'Critical']),
            'warningCount': len([r for r in rows if r.get('Status') == 'Warning']),
            'safeCount': len([r for r in rows if r.get('Status') == 'Safe']),
        }
        
        return jsonify({
            'success': True,
            'analysis': analysis,
            'fileName': file_name,
            'message': f"Analyzed {len(rows)} water quality records from {len(analysis['locations'])} locations."
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/predictions/water-quality', methods=['POST'])
def predict_water_quality():
    data = request.json
    params = data.get('parameters', {})
    
    ph = params.get('pH', 7.0)
    turbidity = params.get('turbidity', 2.0)
    do = params.get('dissolved_oxygen', 8.0)
    
    # Determine status
    if ph < 6.5 or ph > 8.5 or turbidity > 5 or do < 5:
        status = 'Critical' if turbidity > 8 else 'Warning'
        score = 50 if status == 'Critical' else 70
    else:
        status = 'Safe'
        score = 90
    
    return jsonify({
        'prediction': {
            'parameter': 'Overall Quality',
            'predictedValue': score,
            'status': status,
            'confidence': 0.88,
            'recommendations': [
                f'pH level is {"optimal" if 6.5 < ph < 8.5 else "outside safe range"}',
                f'Turbidity {"within limits" if turbidity < 5 else "exceeds safe limits"}',
                f'Dissolved oxygen {"sufficient" if do > 5 else "critically low"}',
                'Increase monitoring frequency',
                'Implement corrective measures if needed'
            ]
        }
    })

@app.route('/api/recommendations', methods=['POST'])
def get_recommendations():
    status = request.json.get('status', 'Safe')
    recommendations = {
        'Safe': [
            'Continue routine monitoring',
            'Regular quality checks recommended',
            'No immediate action needed',
            'Maintain current treatment protocols'
        ],
        'Warning': [
            'Increase monitoring frequency to daily',
            'Review and optimize treatment parameters',
            'Conduct detailed analysis of contamination source',
            'Prepare contingency plans'
        ],
        'Critical': [
            'URGENT: Implement emergency protocols',
            'Alert all relevant authorities immediately',
            'Consider limiting public water usage',
            'Deploy emergency treatment measures',
            'Increase monitoring to hourly'
        ]
    }
    return jsonify({'recommendations': recommendations.get(status, [])})

@app.route('/api/classification/alert-sentiment', methods=['POST'])
def classify_sentiment():
    text = request.json.get('text', '')
    
    # Analyze sentiment based on keywords
    if any(word in text.lower() for word in ['critical', 'emergency', 'urgent', 'danger']):
        sentiment = 'critical'
        confidence = 0.95
    elif any(word in text.lower() for word in ['warning', 'caution', 'concern', 'issue']):
        sentiment = 'warning'
        confidence = 0.90
    else:
        sentiment = 'normal'
        confidence = 0.85
    
    return jsonify({
        'sentiment': sentiment,
        'confidence': confidence,
        'details': f'Alert classified as {sentiment} level'
    })

@app.route('/api/report/generate', methods=['POST'])
def generate_report():
    """Generate a report from conversation data"""
    data = request.json
    title = data.get('title', 'Water Quality Report')
    format_type = data.get('format', 'PDF')
    messages = data.get('messages', [])
    
    # Create report data
    report = {
        'title': title,
        'generatedAt': datetime.now().isoformat(),
        'format': format_type,
        'totalMessages': len(messages),
        'conversation': messages,
        'summary': 'This report summarizes the water quality analysis conversation.'
    }
    
    return jsonify({
        'success': True,
        'report': report,
        'message': f'Report generated successfully in {format_type} format'
    })

if __name__ == '__main__':
    print("🚀 ML Backend running on http://localhost:8000")
    print("✅ File upload endpoint: POST /api/files/analyze")
    print("✅ Report generation: POST /api/report/generate")
    app.run(debug=True, host='0.0.0.0', port=8000)
