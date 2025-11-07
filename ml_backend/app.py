from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
from ai_analysis_service import AIAnalysisService
from report_generator import ReportGenerator
# Updated import for enhanced station service
from enhanced_live_station_service import get_station_service
import json
import os
from werkzeug.utils import secure_filename
from datetime import datetime
import hashlib

app = Flask(__name__)

# Enable CORS for all routes with file upload support
CORS(app, resources={
    r"/api/*": {
        "origins": "*",
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization", "Accept", "If-None-Match"],
        "expose_headers": ["Content-Type", "ETag", "Cache-Control"],
        "supports_credentials": False
    }
})

# Response cache for frequently accessed data
response_cache = {}
cache_ttl = 60  # Cache for 60 seconds

# Initialize services
ai_analysis = AIAnalysisService()
report_generator = ReportGenerator()
# Initialize enhanced station service with full Maharashtra network (PRODUCTION MODE)
station_service = get_station_service(test_mode=False)

# Configure upload folder
UPLOAD_FOLDER = 'uploads'
REPORTS_FOLDER = 'reports'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(REPORTS_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['REPORTS_FOLDER'] = REPORTS_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size

# ============================================
# CACHING & OPTIMIZATION HELPERS
# ============================================

def generate_etag(data):
    """Generate ETag from data for cache validation"""
    json_str = json.dumps(data, sort_keys=True)
    return hashlib.md5(json_str.encode()).hexdigest()

def get_cached_response(cache_key):
    """Get cached response if available and not expired"""
    if cache_key in response_cache:
        cached_data, cached_time = response_cache[cache_key]
        if (datetime.now() - cached_time).total_seconds() < cache_ttl:
            return cached_data
    return None

def set_cached_response(cache_key, data):
    """Cache response with timestamp"""
    response_cache[cache_key] = (data, datetime.now())

def check_etag_match(data):
    """Check if client has cached version (ETag match)"""
    client_etag = request.headers.get('If-None-Match')
    if client_etag:
        current_etag = generate_etag(data)
        if client_etag == current_etag:
            return True, current_etag
    return False, generate_etag(data)

# ============================================
# API ENDPOINTS
# ============================================

@app.route('/api/status', methods=['GET'])
def status():
    """Check system status"""
    return jsonify({
        'status': 'ok',
        'ai_service': 'active',
        'version': '2.1.0',  # Updated version with caching
        'cache_enabled': True,
        'total_stations': len(station_service.get_all_stations())
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

# ============================================
# LIVE WATER STATION MONITORING ENDPOINTS
# ============================================

@app.route('/api/stations', methods=['GET', 'OPTIONS'])
def get_all_stations():
    """
    Get list of all monitoring stations with pagination and filtering
    
    Query Parameters:
        page (int): Page number (default: 1)
        per_page (int): Items per page (default: 50, max: 200)
        district (str): Filter by district name
        type (str): Filter by station type (surface_water/groundwater)
        region (str): Filter by region
        search (str): Search in station names
    """
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        # Get pagination parameters
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('per_page', 50, type=int), 200)  # Max 200 per page
        
        # Get filter parameters
        district_filter = request.args.get('district', None)
        type_filter = request.args.get('type', None)
        region_filter = request.args.get('region', None)
        search_query = request.args.get('search', None)
        
        # Get all stations
        all_stations = station_service.get_all_stations()
        
        # Apply filters
        filtered_stations = all_stations
        
        if district_filter:
            filtered_stations = [s for s in filtered_stations 
                               if s.get('district', '').lower() == district_filter.lower()]
        
        if type_filter:
            filtered_stations = [s for s in filtered_stations 
                               if type_filter.lower() in s.get('type', '').lower()]
        
        if region_filter:
            filtered_stations = [s for s in filtered_stations 
                               if s.get('region', '').lower() == region_filter.lower()]
        
        if search_query:
            search_lower = search_query.lower()
            filtered_stations = [s for s in filtered_stations 
                               if search_lower in s.get('name', '').lower() or 
                                  search_lower in s.get('id', '').lower()]
        
        # Calculate pagination
        total_count = len(filtered_stations)
        total_pages = (total_count + per_page - 1) // per_page  # Ceiling division
        start_idx = (page - 1) * per_page
        end_idx = start_idx + per_page
        
        # Get paginated results
        paginated_stations = filtered_stations[start_idx:end_idx]
        
        return jsonify({
            'success': True,
            'pagination': {
                'page': page,
                'per_page': per_page,
                'total_items': total_count,
                'total_pages': total_pages,
                'has_next': page < total_pages,
                'has_prev': page > 1
            },
            'filters': {
                'district': district_filter,
                'type': type_filter,
                'region': region_filter,
                'search': search_query
            },
            'count': len(paginated_stations),
            'stations': paginated_stations
        })
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/stations/<station_id>', methods=['GET', 'OPTIONS'])
def get_station_by_id(station_id):
    """Get specific station information and current data"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        # Get station info
        station = next((s for s in station_service.get_all_stations() if s['id'] == station_id), None)
        if not station:
            return jsonify({'error': 'Station not found'}), 404
        
        # Get current data
        data = station_service.get_station_data(station_id)
        
        return jsonify({
            'success': True,
            'station': station,
            'current_data': data
        })
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/stations/data/all', methods=['GET', 'OPTIONS'])
def get_all_station_data():
    """
    Get current data for all stations with pagination
    
    Query Parameters:
        page (int): Page number (default: 1)
        per_page (int): Items per page (default: 50, max: 200)
        district (str): Filter by district
        type (str): Filter by type
    """
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        # Get pagination parameters
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('per_page', 50, type=int), 200)
        district_filter = request.args.get('district', None)
        type_filter = request.args.get('type', None)
        
        # Get all data
        all_data = station_service.get_all_station_data()
        
        # Apply filters if needed
        if district_filter or type_filter:
            all_stations = station_service.get_all_stations()
            filtered_data = []
            for data_item in all_data:
                station_id = data_item.get('station_id') or data_item.get('stationId')
                station = next((s for s in all_stations if s.get('id') == station_id), None)
                if station:
                    if district_filter and station.get('district', '').lower() != district_filter.lower():
                        continue
                    if type_filter and type_filter.lower() not in station.get('type', '').lower():
                        continue
                    filtered_data.append(data_item)
            all_data = filtered_data
        
        # Calculate pagination
        total_count = len(all_data)
        total_pages = (total_count + per_page - 1) // per_page
        start_idx = (page - 1) * per_page
        end_idx = start_idx + per_page
        
        paginated_data = all_data[start_idx:end_idx]
        
        return jsonify({
            'success': True,
            'pagination': {
                'page': page,
                'per_page': per_page,
                'total_items': total_count,
                'total_pages': total_pages,
                'has_next': page < total_pages,
                'has_prev': page > 1
            },
            'count': len(paginated_data),
            'data': paginated_data,
            'timestamp': datetime.now().isoformat()
        })
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/stations/data/<station_id>', methods=['GET', 'OPTIONS'])
def get_station_data(station_id):
    """Get current data for a specific station"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        data = station_service.get_station_data(station_id)
        if not data:
            return jsonify({'error': 'Station data not found'}), 404
        
        return jsonify({
            'success': True,
            'data': data
        })
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/stations/district/<district>', methods=['GET', 'OPTIONS'])
def get_stations_by_district(district):
    """Get all stations in a specific district with pagination"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        # Get pagination parameters
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('per_page', 50, type=int), 200)  # Max 200 items per page
        include_data = request.args.get('include_data', 'false').lower() == 'true'
        station_type = request.args.get('type', None, type=str)
        
        # Get all stations for this district
        all_stations = station_service.get_stations_by_district(district)
        
        # Apply type filter if provided
        if station_type:
            all_stations = [s for s in all_stations if s.get('type') == station_type]
        
        # Calculate pagination
        total_count = len(all_stations)
        total_pages = (total_count + per_page - 1) // per_page
        start_idx = (page - 1) * per_page
        end_idx = start_idx + per_page
        
        # Get paginated stations
        paginated_stations = all_stations[start_idx:end_idx]
        
        # Optionally include current data
        stations_response = []
        if include_data:
            for station in paginated_stations:
                data = station_service.get_station_data(station.get('station_id') or station.get('id'))
                stations_response.append({
                    'station': station,
                    'current_data': data
                })
        else:
            stations_response = paginated_stations
        
        return jsonify({
            'success': True,
            'district': district,
            'pagination': {
                'page': page,
                'per_page': per_page,
                'total_items': total_count,
                'total_pages': total_pages,
                'has_next': page < total_pages,
                'has_prev': page > 1
            },
            'filters': {
                'type': station_type,
                'include_data': include_data
            },
            'count': len(stations_response),
            'stations': stations_response
        })
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/stations/status/<status>', methods=['GET', 'OPTIONS'])
def get_stations_by_status(status):
    """Get all stations with a specific water quality status with pagination"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        # Get pagination parameters
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('per_page', 50, type=int), 200)
        district = request.args.get('district', None, type=str)
        
        # Get all stations with this status
        all_station_data = station_service.get_stations_by_status(status)
        
        # Apply district filter
        if district:
            all_station_data = [s for s in all_station_data if s.get('district') == district]
        
        # Calculate pagination
        total_count = len(all_station_data)
        total_pages = (total_count + per_page - 1) // per_page if total_count > 0 else 1
        start_idx = (page - 1) * per_page
        end_idx = start_idx + per_page
        
        # Get paginated data
        paginated_data = all_station_data[start_idx:end_idx]
        
        return jsonify({
            'success': True,
            'status': status,
            'pagination': {
                'page': page,
                'per_page': per_page,
                'total_items': total_count,
                'total_pages': total_pages,
                'has_next': page < total_pages,
                'has_prev': page > 1
            },
            'filters': {
                'district': district
            },
            'count': len(paginated_data),
            'stations': paginated_data
        })
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/stations/summary', methods=['GET', 'OPTIONS'])
def get_summary_statistics():
    """Get summary statistics across all stations"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        summary = station_service.get_summary_statistics()
        return jsonify({
            'success': True,
            'summary': summary
        })
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/stations/simulation/start', methods=['POST', 'OPTIONS'])
def start_simulation():
    """Start the live simulation with optional interval"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        data = request.json or {}
        interval = data.get('interval_seconds', 900)  # Default 15 minutes
        
        station_service.start_simulation(interval_seconds=interval)
        
        return jsonify({
            'success': True,
            'message': f'Live simulation started with {interval}s interval',
            'interval_seconds': interval
        })
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/stations/simulation/stop', methods=['POST', 'OPTIONS'])
def stop_simulation():
    """Stop the live simulation"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        station_service.stop_simulation()
        return jsonify({
            'success': True,
            'message': 'Live simulation stopped'
        })
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/stations/simulation/refresh', methods=['POST', 'OPTIONS'])
def refresh_station_data():
    """Manually trigger a data refresh for all stations"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        result = station_service.refresh_data()
        
        return jsonify({
            'success': True,
            'message': result['message'],
            'timestamp': result['timestamp'],
            'stationsUpdated': result['stations_updated']
        })
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

# ============================================
# ENHANCED MONITORING ENDPOINTS
# ============================================

@app.route('/api/stations/type/<station_type>', methods=['GET', 'OPTIONS'])
def get_stations_by_type(station_type):
    """Get stations by type (surface_water or groundwater) with pagination"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        # Get pagination parameters
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('per_page', 50, type=int), 200)
        district = request.args.get('district', None, type=str)
        region = request.args.get('region', None, type=str)
        
        # Get all stations of this type
        all_stations = station_service.get_stations_by_type(station_type)
        
        # Apply additional filters
        if district:
            all_stations = [s for s in all_stations if s.get('district') == district]
        if region:
            all_stations = [s for s in all_stations if s.get('region') == region]
        
        # Calculate pagination
        total_count = len(all_stations)
        total_pages = (total_count + per_page - 1) // per_page
        start_idx = (page - 1) * per_page
        end_idx = start_idx + per_page
        
        # Get paginated stations
        paginated_stations = all_stations[start_idx:end_idx]
        
        return jsonify({
            'success': True,
            'type': station_type,
            'pagination': {
                'page': page,
                'per_page': per_page,
                'total_items': total_count,
                'total_pages': total_pages,
                'has_next': page < total_pages,
                'has_prev': page > 1
            },
            'filters': {
                'district': district,
                'region': region
            },
            'count': len(paginated_stations),
            'stations': paginated_stations
        })
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/stations/water-class/<water_class>', methods=['GET', 'OPTIONS'])
def get_stations_by_water_class(water_class):
    """Get stations by CPCB water quality class (A, B, C, D, E) with pagination"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        # Get pagination parameters
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('per_page', 50, type=int), 200)
        district = request.args.get('district', None, type=str)
        station_type = request.args.get('type', None, type=str)
        
        # Get all stations of this water class
        all_stations = station_service.get_stations_by_water_class(water_class)
        
        # Apply additional filters
        if district:
            all_stations = [s for s in all_stations if s.get('district') == district]
        if station_type:
            all_stations = [s for s in all_stations if s.get('type') == station_type]
        
        # Calculate pagination
        total_count = len(all_stations)
        total_pages = (total_count + per_page - 1) // per_page
        start_idx = (page - 1) * per_page
        end_idx = start_idx + per_page
        
        # Get paginated stations
        paginated_stations = all_stations[start_idx:end_idx]
        
        return jsonify({
            'success': True,
            'waterClass': water_class,
            'pagination': {
                'page': page,
                'per_page': per_page,
                'total_items': total_count,
                'total_pages': total_pages,
                'has_next': page < total_pages,
                'has_prev': page > 1
            },
            'filters': {
                'district': district,
                'type': station_type
            },
            'count': len(paginated_stations),
            'stations': paginated_stations
        })
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/stations/alerts', methods=['GET', 'OPTIONS'])
def get_stations_with_alerts():
    """Get all stations with active water quality alerts with pagination"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        # Get pagination parameters
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('per_page', 50, type=int), 200)
        district = request.args.get('district', None, type=str)
        severity = request.args.get('severity', None, type=str)  # critical, warning
        
        # Get all stations with alerts
        all_stations = station_service.get_stations_with_alerts()
        
        # Apply additional filters
        if district:
            all_stations = [s for s in all_stations if s.get('district') == district]
        if severity:
            all_stations = [s for s in all_stations if any(
                alert.get('severity') == severity for alert in s.get('alerts', [])
            )]
        
        # Calculate pagination
        total_count = len(all_stations)
        total_pages = (total_count + per_page - 1) // per_page
        start_idx = (page - 1) * per_page
        end_idx = start_idx + per_page
        
        # Get paginated stations
        paginated_stations = all_stations[start_idx:end_idx]
        
        # Calculate total alerts
        total_alerts = sum(s.get('alertCount', len(s.get('alerts', []))) for s in all_stations)
        
        return jsonify({
            'success': True,
            'pagination': {
                'page': page,
                'per_page': per_page,
                'total_items': total_count,
                'total_pages': total_pages,
                'has_next': page < total_pages,
                'has_prev': page > 1
            },
            'filters': {
                'district': district,
                'severity': severity
            },
            'count': len(paginated_stations),
            'totalAlerts': total_alerts,
            'stations': paginated_stations
        })
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/stations/<station_id>/history', methods=['GET', 'OPTIONS'])
def get_station_history(station_id):
    """Get historical readings for a station with pagination"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        # Get pagination parameters
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('per_page', 50, type=int), 200)
        limit = request.args.get('limit', None, type=int)  # Optional total limit
        
        # Get historical data
        max_records = limit if limit else 1000  # Default max 1000 records
        all_history = station_service.get_historical_data(station_id, max_records)
        
        # Calculate pagination
        total_count = len(all_history)
        total_pages = (total_count + per_page - 1) // per_page if total_count > 0 else 1
        start_idx = (page - 1) * per_page
        end_idx = start_idx + per_page
        
        # Get paginated history
        paginated_history = all_history[start_idx:end_idx]
        
        return jsonify({
            'success': True,
            'stationId': station_id,
            'pagination': {
                'page': page,
                'per_page': per_page,
                'total_items': total_count,
                'total_pages': total_pages,
                'has_next': page < total_pages,
                'has_prev': page > 1
            },
            'count': len(paginated_history),
            'readings': paginated_history
        })
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/parameters/<parameter>/statistics', methods=['GET', 'OPTIONS'])
def get_parameter_statistics(parameter):
    """Get statistics for a specific parameter across all stations"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        stats = station_service.get_parameter_statistics(parameter)
        return jsonify({
            'success': True,
            'parameter': parameter,
            'statistics': stats
        })
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/stations/region/<region>', methods=['GET', 'OPTIONS'])
def get_stations_by_region(region):
    """Get all stations in a specific region (Konkan, Pune, Vidarbha, etc.) with pagination"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        # Get pagination parameters
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('per_page', 50, type=int), 200)
        station_type = request.args.get('type', None, type=str)
        include_data = request.args.get('include_data', 'false').lower() == 'true'
        
        # Get all stations in region
        all_stations = station_service.get_all_stations()
        matching_stations = [s for s in all_stations if s.get('region', '').lower() == region.lower()]
        
        # Apply type filter
        if station_type:
            matching_stations = [s for s in matching_stations if s.get('type') == station_type]
        
        # Calculate pagination
        total_count = len(matching_stations)
        total_pages = (total_count + per_page - 1) // per_page if total_count > 0 else 1
        start_idx = (page - 1) * per_page
        end_idx = start_idx + per_page
        
        # Get paginated stations
        paginated_stations = matching_stations[start_idx:end_idx]
        
        # Optionally include current data
        stations_response = []
        if include_data:
            for station in paginated_stations:
                station_details = station_service.get_station_by_id(
                    station.get('station_id') or station.get('id')
                )
                if station_details:
                    stations_response.append(station_details)
        else:
            stations_response = paginated_stations
        
        return jsonify({
            'success': True,
            'region': region,
            'pagination': {
                'page': page,
                'per_page': per_page,
                'total_items': total_count,
                'total_pages': total_pages,
                'has_next': page < total_pages,
                'has_prev': page > 1
            },
            'filters': {
                'type': station_type,
                'include_data': include_data
            },
            'count': len(stations_response),
            'stations': stations_response
        })
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/stations/laboratories', methods=['GET', 'OPTIONS'])
def get_laboratory_network():
    """Get list of all laboratories and stations they monitor"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        all_stations = station_service.get_all_stations()
        
        # Group by laboratory
        labs = {}
        for station in all_stations:
            lab_name = station.get('laboratory', 'Unknown')
            if lab_name not in labs:
                labs[lab_name] = []
            labs[lab_name].append({
                'id': station['id'],
                'name': station['name'],
                'type': station['type'],
                'district': station['district']
            })
        
        lab_list = [{
            'name': lab,
            'stationCount': len(stations),
            'stations': stations
        } for lab, stations in labs.items()]
        
        return jsonify({
            'success': True,
            'totalLaboratories': len(lab_list),
            'laboratories': lab_list
        })
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/stations/map-data', methods=['GET', 'OPTIONS'])
def get_map_data():
    """Get all station locations for map visualization (optimized with pagination)"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        # Get pagination parameters
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('per_page', 500, type=int), 5000)  # Support all 4,495 stations
        district = request.args.get('district', None, type=str)
        station_type = request.args.get('type', None, type=str)
        minimal = request.args.get('minimal', 'false').lower() == 'true'
        
        all_stations = station_service.get_all_stations()
        
        # Apply filters
        if district:
            all_stations = [s for s in all_stations if s.get('district') == district]
        if station_type:
            all_stations = [s for s in all_stations if s.get('type') == station_type]
        
        # Calculate pagination
        total_count = len(all_stations)
        total_pages = (total_count + per_page - 1) // per_page if total_count > 0 else 1
        start_idx = (page - 1) * per_page
        end_idx = start_idx + per_page
        
        # Get paginated stations
        paginated_stations = all_stations[start_idx:end_idx]
        
        map_data = []
        if minimal:
            # Ultra-fast: GPS coordinates only
            for station in paginated_stations:
                map_data.append({
                    'id': station.get('station_id') or station.get('id'),
                    'lat': station.get('latitude'),
                    'lon': station.get('longitude'),
                    'type': station.get('type')
                })
        else:
            # Include basic status info
            for station in paginated_stations:
                station_details = station_service.get_station_by_id(
                    station.get('station_id') or station.get('id')
                )
                if station_details and station_details.get('currentReading'):
                    reading = station_details['currentReading']
                    map_data.append({
                        'id': station.get('station_id') or station.get('id'),
                        'name': station.get('name'),
                        'type': station.get('type'),
                        'latitude': station.get('latitude'),
                        'longitude': station.get('longitude'),
                        'wqi': reading.get('wqi'),
                        'status': reading.get('status'),
                        'waterClass': reading.get('waterQualityClass'),
                        'hasAlerts': len(reading.get('alerts', [])) > 0,
                        'alertCount': len(reading.get('alerts', []))
                    })
        
        return jsonify({
            'success': True,
            'pagination': {
                'page': page,
                'per_page': per_page,
                'total_items': total_count,
                'total_pages': total_pages,
                'has_next': page < total_pages,
                'has_prev': page > 1
            },
            'filters': {
                'district': district,
                'type': station_type,
                'minimal': minimal
            },
            'count': len(map_data),
            'stations': map_data
        })
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/stations/nearby', methods=['GET', 'OPTIONS'])
def get_nearby_stations():
    """Get stations within a radius of user location (optimized for mobile/performance)"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        import math
        
        # Get user location and radius
        user_lat = request.args.get('lat', type=float)
        user_lon = request.args.get('lon', type=float)
        radius_km = request.args.get('radius', 30, type=float)  # Default 30km
        limit = request.args.get('limit', 200, type=int)  # Max stations to return
        district = request.args.get('district', None, type=str)
        station_type = request.args.get('type', None, type=str)
        
        if not user_lat or not user_lon:
            return jsonify({'error': 'lat and lon parameters required'}), 400
        
        # Haversine formula to calculate distance
        def calculate_distance(lat1, lon1, lat2, lon2):
            R = 6371  # Earth's radius in km
            dlat = math.radians(lat2 - lat1)
            dlon = math.radians(lon2 - lon1)
            a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon/2)**2
            c = 2 * math.asin(math.sqrt(a))
            return R * c
        
        all_stations = station_service.get_all_stations()
        
        # Apply filters
        if district:
            all_stations = [s for s in all_stations if s.get('district') == district]
        if station_type:
            all_stations = [s for s in all_stations if s.get('type') == station_type]
        
        # Calculate distances and filter by radius
        nearby_stations = []
        for station in all_stations:
            distance = calculate_distance(
                user_lat, user_lon,
                station.get('latitude'), station.get('longitude')
            )
            if distance <= radius_km:
                nearby_stations.append({
                    'station': station,
                    'distance': round(distance, 2)
                })
        
        # Sort by distance (closest first)
        nearby_stations.sort(key=lambda x: x['distance'])
        
        # Limit results
        nearby_stations = nearby_stations[:limit]
        
        # Build response with station details
        stations_data = []
        for item in nearby_stations:
            station = item['station']
            station_details = station_service.get_station_by_id(
                station.get('station_id') or station.get('id')
            )
            if station_details and station_details.get('currentReading'):
                reading = station_details['currentReading']
                stations_data.append({
                    'id': station.get('station_id') or station.get('id'),
                    'name': station.get('name'),
                    'type': station.get('type'),
                    'latitude': station.get('latitude'),
                    'longitude': station.get('longitude'),
                    'distance': item['distance'],
                    'wqi': reading.get('wqi'),
                    'status': reading.get('status'),
                    'waterClass': reading.get('waterQualityClass'),
                    'hasAlerts': len(reading.get('alerts', [])) > 0,
                    'alertCount': len(reading.get('alerts', []))
                })
        
        return jsonify({
            'success': True,
            'userLocation': {
                'latitude': user_lat,
                'longitude': user_lon
            },
            'radius': radius_km,
            'totalFound': len(stations_data),
            'stations': stations_data
        })
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/stations/viewport', methods=['POST', 'OPTIONS'])
def get_viewport_stations():
    """Get stations within map viewport bounds (optimized for pan/zoom)"""
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        data = request.get_json()
        
        # Get viewport bounds
        north = data.get('north')
        south = data.get('south')
        east = data.get('east')
        west = data.get('west')
        zoom_level = data.get('zoom', 10)
        
        if not all([north, south, east, west]):
            return jsonify({'error': 'Viewport bounds required (north, south, east, west)'}), 400
        
        all_stations = station_service.get_all_stations()
        
        # Filter stations within viewport
        viewport_stations = []
        for station in all_stations:
            lat = station.get('latitude')
            lon = station.get('longitude')
            
            if south <= lat <= north and west <= lon <= east:
                viewport_stations.append(station)
        
        # Adaptive loading based on zoom level
        # High zoom (zoomed out) = show fewer stations, cluster the rest
        # Low zoom (zoomed in) = show all stations in viewport
        if zoom_level < 8:
            # Zoomed out: sample stations (show ~100 max)
            max_stations = 100
            if len(viewport_stations) > max_stations:
                # Sample evenly distributed stations
                step = len(viewport_stations) // max_stations
                viewport_stations = viewport_stations[::step][:max_stations]
        elif zoom_level < 10:
            # Medium zoom: show ~300 stations
            max_stations = 300
            if len(viewport_stations) > max_stations:
                step = len(viewport_stations) // max_stations
                viewport_stations = viewport_stations[::step][:max_stations]
        # else: show all stations in viewport (zoomed in enough)
        
        # Build response
        stations_data = []
        for station in viewport_stations:
            station_details = station_service.get_station_by_id(
                station.get('station_id') or station.get('id')
            )
            if station_details and station_details.get('currentReading'):
                reading = station_details['currentReading']
                stations_data.append({
                    'id': station.get('station_id') or station.get('id'),
                    'name': station.get('name'),
                    'type': station.get('type'),
                    'latitude': station.get('latitude'),
                    'longitude': station.get('longitude'),
                    'wqi': reading.get('wqi'),
                    'status': reading.get('status'),
                    'waterClass': reading.get('waterQualityClass'),
                    'hasAlerts': len(reading.get('alerts', [])) > 0,
                    'alertCount': len(reading.get('alerts', []))
                })
        
        return jsonify({
            'success': True,
            'viewport': {
                'north': north,
                'south': south,
                'east': east,
                'west': west,
                'zoom': zoom_level
            },
            'totalInViewport': len(viewport_stations),
            'returned': len(stations_data),
            'stations': stations_data
        })
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("\n" + "="*80)
    print("🚀 PureHealth Enhanced Water Quality Monitoring System")
    print("="*80)
    print("✅ API Running: http://localhost:8000")
    print("✅ Status: http://localhost:8000/api/status")
    print("\n📊 AI Analysis Endpoints:")
    print("   POST http://localhost:8000/api/ai/analyze")
    print("   POST http://localhost:8000/api/reports/generate")
    print("\n🌊 Enhanced Live Station Monitoring Endpoints:")
    print("   GET  http://localhost:8000/api/stations")
    print("   GET  http://localhost:8000/api/stations/<id>")
    print("   GET  http://localhost:8000/api/stations/data/all")
    print("   GET  http://localhost:8000/api/stations/district/<district>")
    print("   GET  http://localhost:8000/api/stations/type/<type>")
    print("   GET  http://localhost:8000/api/stations/water-class/<class>")
    print("   GET  http://localhost:8000/api/stations/alerts")
    print("   GET  http://localhost:8000/api/stations/region/<region>")
    print("   GET  http://localhost:8000/api/stations/laboratories")
    print("   GET  http://localhost:8000/api/stations/map-data")
    print("   GET  http://localhost:8000/api/stations/summary")
    print("   GET  http://localhost:8000/api/stations/<id>/history")
    print("   GET  http://localhost:8000/api/parameters/<param>/statistics")
    print("   POST http://localhost:8000/api/stations/simulation/start")
    print("   POST http://localhost:8000/api/stations/simulation/stop")
    print("   POST http://localhost:8000/api/stations/simulation/refresh")
    print("\n📍 Based on MPCB & GSDA Real Monitoring Networks")
    print("   - Surface Water Monitoring (MPCB)")
    print("   - Groundwater Monitoring (GSDA)")
    print("   - 20+ Water Quality Parameters")
    print("   - Seasonal Variations & Real-time Alerts")
    print("="*80 + "\n")
    
    # Start live simulation automatically with 15-minute intervals
    print("🔄 Initializing Maharashtra Water Quality Monitoring Network...")
    station_service.start_simulation(update_interval=900)
    
    app.run(host='0.0.0.0', port=8000, debug=False)
