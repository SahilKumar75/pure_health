from flask import Flask, request, jsonify
from datetime import datetime
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/api/chat/process', methods=['POST'])
def process_chat():
    data = request.json
    message = data.get('message', '').lower()
    
    if any(word in message for word in ['ph', 'quality', 'safe']):
        response = "Water quality depends on pH, turbidity, and dissolved oxygen levels."
        intent = "water_quality_question"
    elif any(word in message for word in ['predict', 'forecast']):
        response = "I can predict water quality trends based on historical data."
        intent = "prediction_request"
    else:
        response = "I can help you with water quality analysis and recommendations."
        intent = "general_inquiry"
    
    return jsonify({
        'id': f"response_{datetime.now().timestamp()}",
        'response': response,
        'confidence': 0.95,
        'intent': intent,
        'entities': []
    })

@app.route('/api/predictions/water-quality', methods=['POST'])
def predict_water_quality():
    data = request.json
    params = data.get('parameters', {})
    
    ph = params.get('pH', 7.0)
    turbidity = params.get('turbidity', 2.0)
    
    if ph < 6.5 or ph > 8.5:
        status = 'Warning'
    elif turbidity > 5:
        status = 'Warning'
    else:
        status = 'Safe'
    
    return jsonify({
        'prediction': {
            'parameter': 'Overall Quality',
            'predictedValue': 85,
            'status': status,
            'confidence': 0.88,
            'recommendations': [
                'Monitor pH levels weekly',
                'Check turbidity levels',
                'Test for contaminants'
            ]
        }
    })

@app.route('/api/recommendations', methods=['POST'])
def get_recommendations():
    status = request.json.get('status', 'Safe')
    recommendations = {
        'Safe': ['Continue monitoring', 'Regular checks recommended'],
        'Warning': ['Increase monitoring', 'Review treatment'],
        'Critical': ['Emergency protocols', 'Alert authorities']
    }
    return jsonify({'recommendations': recommendations.get(status, [])})

@app.route('/api/classification/alert-sentiment', methods=['POST'])
def classify_sentiment():
    text = request.json.get('text', '')
    
    return jsonify({
        'sentiment': 'critical' if len(text) > 20 else 'normal',
        'confidence': 0.85
    })

if __name__ == '__main__':
    print("🚀 ML Backend running on http://localhost:8000")
    app.run(debug=True, host='0.0.0.0', port=8000)
