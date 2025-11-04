from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
from ai_analysis_service import AIAnalysisService
from report_generator import ReportGenerator
import json
import os
from werkzeug.utils import secure_filename
from datetime import datetime

app = Flask(__name__)

# Enable CORS for all routes with file upload support
CORS(app, resources={
    r"/api/*": {
        "origins": "*",
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization", "Accept"],
        "expose_headers": ["Content-Type"],
        "supports_credentials": False
    }
})

# Initialize services
ai_analysis = AIAnalysisService()
report_generator = ReportGenerator()

# Configure upload folder
UPLOAD_FOLDER = 'uploads'
REPORTS_FOLDER = 'reports'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(REPORTS_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['REPORTS_FOLDER'] = REPORTS_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size

@app.route('/api/status', methods=['GET'])
def status():
    """Check system status"""
    return jsonify({
        'status': 'ok',
        'ai_service': 'active',
        'version': '2.0.0'
    })

# AI Analysis Endpoints

@app.route('/api/ai/upload', methods=['POST', 'OPTIONS'])
def ai_upload():
    """Upload file for AI analysis"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        if 'file' not in request.files:
            return jsonify({'error': 'No file provided'}), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        filename = secure_filename(file.filename)
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(file_path)
        
        # Parse file data
        file_data = _parse_uploaded_file(file_path)
        file_data['file_name'] = filename
        
        # Get record count
        record_count = len(file_data.get('data', {}).get(list(file_data.get('data', {}).keys())[0], [])) if file_data.get('data') else 0
        
        return jsonify({
            'file_data': file_data,
            'file_name': filename,
            'record_count': record_count,
            'message': 'File uploaded successfully'
        })
        
    except Exception as e:
        print(f"❌ Upload Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/ai/analyze', methods=['POST', 'OPTIONS'])
def ai_analyze():
    """Generate comprehensive AI analysis"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        data = request.json
        file_data = data.get('file_data')
        location = data.get('location')
        
        if not file_data:
            return jsonify({'error': 'No file data provided'}), 400
        
        print(f"📊 Generating comprehensive analysis...")
        
        # Generate full analysis report
        report = ai_analysis.analyze_file(file_data, location)
        
        print(f"✅ Analysis complete: {report['id']}")
        
        return jsonify(report)
        
    except Exception as e:
        print(f"❌ Analysis Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/ai/predictions', methods=['POST', 'OPTIONS'])
def ai_predictions():
    """Get predictions for next 2 months"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        data = request.json
        file_data = data.get('file_data')
        
        if not file_data:
            return jsonify({'error': 'No file data provided'}), 400
        
        df = ai_analysis._parse_file_data(file_data)
        predictions = ai_analysis._generate_predictions(df)
        
        return jsonify({'predictions': predictions})
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/ai/risk-assessment', methods=['POST', 'OPTIONS'])
def ai_risk_assessment():
    """Get risk assessment"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        data = request.json
        file_data = data.get('file_data')
        
        if not file_data:
            return jsonify({'error': 'No file data provided'}), 400
        
        df = ai_analysis._parse_file_data(file_data)
        risk_assessment = ai_analysis._generate_risk_assessment(df)
        
        return jsonify(risk_assessment)
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/ai/trend-analysis', methods=['POST', 'OPTIONS'])
def ai_trend_analysis():
    """Get trend analysis"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        data = request.json
        file_data = data.get('file_data')
        
        if not file_data:
            return jsonify({'error': 'No file data provided'}), 400
        
        df = ai_analysis._parse_file_data(file_data)
        trend_analysis = ai_analysis._generate_trend_analysis(df)
        
        return jsonify(trend_analysis)
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/ai/recommendations', methods=['POST', 'OPTIONS'])
def ai_recommendations():
    """Get recommendations"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        data = request.json
        file_data = data.get('file_data')
        
        if not file_data:
            return jsonify({'error': 'No file data provided'}), 400
        
        df = ai_analysis._parse_file_data(file_data)
        risk_assessment = ai_analysis._generate_risk_assessment(df)
        recommendations = ai_analysis._generate_recommendations(df, risk_assessment)
        
        return jsonify({'recommendations': recommendations})
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/ai/save-report', methods=['POST', 'OPTIONS'])
def save_report():
    """Save analysis report"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        report = request.json
        
        if not report:
            return jsonify({'error': 'No report data provided'}), 400
        
        report_id = ai_analysis.save_report(report)
        
        return jsonify({
            'message': 'Report saved successfully',
            'report_id': report_id
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/ai/reports', methods=['GET', 'OPTIONS'])
def get_reports():
    """Get all saved reports"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        reports = ai_analysis.get_saved_reports()
        return jsonify({'reports': reports})
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/ai/reports/<report_id>', methods=['GET', 'DELETE', 'OPTIONS'])
def manage_report(report_id):
    """Get or delete a specific report"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        if request.method == 'GET':
            report = ai_analysis.get_report_by_id(report_id)
            if not report:
                return jsonify({'error': 'Report not found'}), 404
            return jsonify(report)
        
        elif request.method == 'DELETE':
            success = ai_analysis.delete_report(report_id)
            if not success:
                return jsonify({'error': 'Report not found'}), 404
            return jsonify({'message': 'Report deleted successfully'})
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def _parse_uploaded_file(file_path):
    """Parse uploaded file into structured data"""
    try:
        import csv
        
        data = {}
        with open(file_path, 'r') as f:
            # Try CSV first
            if file_path.endswith('.csv'):
                reader = csv.DictReader(f)
                rows = list(reader)
                
                if rows:
                    # Convert to column-based format
                    for key in rows[0].keys():
                        data[key] = []
                    
                    for row in rows:
                        for key, value in row.items():
                            try:
                                data[key].append(float(value))
                            except:
                                data[key].append(value)
        
        return {'data': data}
        
    except Exception as e:
        print(f"Error parsing file: {e}")
        # Return sample data for demo
        return {
            'data': {
                'pH': [7.2, 7.5, 7.1, 7.3, 7.4],
                'DO': [6.5, 6.8, 6.2, 6.7, 6.6],
                'BOD': [2.1, 2.3, 2.5, 2.2, 2.4],
                'Temperature': [25.3, 26.1, 25.8, 25.5, 25.9]
            }
        }

@app.route('/api/reports/generate', methods=['POST', 'OPTIONS'])
def generate_report():
    """Generate comprehensive PDF report"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        data = request.json
        analysis_data = data.get('analysis_data')
        report_type = data.get('type', 'comprehensive')  # comprehensive, summary, compliance
        
        if not analysis_data:
            return jsonify({'error': 'No analysis data provided'}), 400
        
        print(f"📄 Generating {report_type} report...")
        
        # Generate filename
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f"water_quality_report_{timestamp}.pdf"
        output_path = os.path.join(app.config['REPORTS_FOLDER'], filename)
        
        # Generate report
        report_generator.generate_comprehensive_report(analysis_data, output_path)
        
        file_size = os.path.getsize(output_path)
        
        print(f"✅ Report generated: {filename} ({file_size} bytes)")
        
        return jsonify({
            'success': True,
            'filename': filename,
            'download_url': f'/api/reports/download/{filename}',
            'file_size': file_size,
            'generated_at': datetime.now().isoformat()
        })
        
    except Exception as e:
        print(f"❌ Report Generation Error: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500

@app.route('/api/reports/download/<filename>', methods=['GET'])
def download_report(filename):
    """Download generated report"""
    try:
        file_path = os.path.join(app.config['REPORTS_FOLDER'], filename)
        
        if not os.path.exists(file_path):
            return jsonify({'error': 'Report not found'}), 404
        
        return send_file(
            file_path,
            as_attachment=True,
            download_name=filename,
            mimetype='application/pdf'
        )
        
    except Exception as e:
        print(f"❌ Download Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("\n" + "="*60)
    print("🚀 PureHealth AI Backend - Lightweight Edition")
    print("="*60)
    print("✅ API Running: http://localhost:8000")
    print("✅ Status: http://localhost:8000/api/status")
    print("✅ AI Analysis: POST http://localhost:8000/api/ai/analyze")
    print("✅ Reports: POST http://localhost:8000/api/reports/generate")
    print("="*60 + "\n")
    
    app.run(host='0.0.0.0', port=8000, debug=True)
