from flask import Flask, request, jsonify
from flask_cors import CORS
from ollama_service import OllamaAIService
import json

app = Flask(__name__)

# Enable CORS for all routes
CORS(app, resources={
    r"/api/*": {
        "origins": "*",
        "methods": ["GET", "POST", "OPTIONS"],
        "allow_headers": ["Content-Type"]
    }
})

# Initialize Ollama
ollama = OllamaAIService()

@app.route('/api/status', methods=['GET'])
def status():
    """Check system status"""
    return jsonify({
        'status': 'ok',
        'ollama_running': ollama.check_connection(),
        'model': ollama.model
    })

@app.route('/api/models', methods=['GET'])
def get_models():
    """Get available models"""
    return jsonify({'models': ollama.list_models()})

@app.route('/api/chat/process', methods=['POST', 'OPTIONS'])
def chat():
    """Process chat with Ollama"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        data = request.json
        message = data.get('message', '')
        file_data = data.get('file_data')
        
        if not message:
            return jsonify({'error': 'No message provided'}), 400
        
        print(f"📩 Message: {message}")
        print(f"📄 File data: {file_data is not None}")
        
        # Get AI response
        response_text = ollama.chat(message, file_data)
        
        print(f"🤖 Response: {response_text[:100]}...")
        
        return jsonify({
            'response': response_text,
            'intent': 'ollama_analysis',
            'confidence': 0.95,
            'metadata': {
                'model': ollama.model,
                'has_file': file_data is not None,
                'prediction': {
                    'status': 'Analysis Complete',
                    'score': 85.0
                }
            }
        })
        
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/files/analyze', methods=['POST'])
def analyze_file():
    """Analyze uploaded file"""
    try:
        if 'file' not in request.files:
            return jsonify({'error': 'No file provided'}), 400
        
        file = request.files['file']
        
        # Read file content
        if file.filename.endswith('.csv'):
            content = file.read().decode('utf-8')
            # Parse CSV and analyze
            analysis = ollama.chat(f"Analyze this water quality CSV:\n{content[:1000]}")
            
            return jsonify({
                'fileName': file.filename,
                'recordsCount': 9,
                'analysis': analysis
            })
        else:
            return jsonify({'error': 'Only CSV files supported'}), 400
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("\n" + "="*50)
    print("🚀 PureHealth Backend with Ollama AI")
    print("="*50)
    print("✅ API Running: http://172.20.10.4:8000")
    print("✅ Status: http://172.20.10.4:8000/api/status")
    print("✅ Chat: POST http://172.20.10.4:8000/api/chat/process")
    print("🤖 Ollama: http://localhost:11434")
    print("="*50 + "\n")
    
    app.run(host='0.0.0.0', port=8000, debug=True)
