#!/usr/bin/env python3
"""
ML Model Status Verification Script
===================================
This script checks whether the app is using real trained ML models or mock predictions.

Run this script to verify:
- Model file existence
- Training data availability  
- Model metadata and accuracy
- Backend API configuration
"""

import os
import sys
import json
from pathlib import Path
from datetime import datetime

# Color codes for terminal output
RED = '\033[91m'
GREEN = '\033[92m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
BOLD = '\033[1m'
END = '\033[0m'

def print_header(text):
    """Print a formatted header"""
    print(f"\n{BLUE}{BOLD}{'=' * 60}{END}")
    print(f"{BLUE}{BOLD}{text.center(60)}{END}")
    print(f"{BLUE}{BOLD}{'=' * 60}{END}\n")

def print_success(text):
    """Print success message"""
    print(f"{GREEN}✓ {text}{END}")

def print_error(text):
    """Print error message"""
    print(f"{RED}✗ {text}{END}")

def print_warning(text):
    """Print warning message"""
    print(f"{YELLOW}⚠ {text}{END}")

def print_info(text):
    """Print info message"""
    print(f"{BLUE}ℹ {text}{END}")

def check_model_files():
    """Check if ML model files exist"""
    print_header("ML Model Files")
    
    model_dir = Path("models")
    if not model_dir.exists():
        print_error(f"Models directory not found: {model_dir}")
        return False
    
    expected_models = [
        "water_quality_predictor.pkl",
        "random_forest_model.pkl",
        "neural_network_model.h5",
    ]
    
    found_models = []
    for model_file in expected_models:
        model_path = model_dir / model_file
        if model_path.exists():
            size = model_path.stat().st_size / (1024 * 1024)  # Size in MB
            print_success(f"Found: {model_file} ({size:.2f} MB)")
            found_models.append(model_file)
        else:
            print_warning(f"Not found: {model_file}")
    
    if not found_models:
        print_error("No ML model files found!")
        print_info("All predictions will use MOCK data")
        return False
    
    print_success(f"Found {len(found_models)} model file(s)")
    return True

def check_training_data():
    """Check if training data files exist"""
    print_header("Training Data")
    
    data_files = [
        "water_quality_data.csv",
        "test_water_quality.csv",
        "groundwater_baseline_stations.json",
    ]
    
    found_data = []
    total_samples = 0
    
    for data_file in data_files:
        data_path = Path(data_file)
        if data_path.exists():
            size = data_path.stat().st_size / 1024  # Size in KB
            
            # Try to count lines for CSV files
            if data_file.endswith('.csv'):
                try:
                    with open(data_path, 'r') as f:
                        lines = sum(1 for _ in f) - 1  # Subtract header
                        total_samples += lines
                        print_success(f"Found: {data_file} ({lines:,} samples, {size:.2f} KB)")
                except:
                    print_success(f"Found: {data_file} ({size:.2f} KB)")
            else:
                print_success(f"Found: {data_file} ({size:.2f} KB)")
            
            found_data.append(data_file)
        else:
            print_warning(f"Not found: {data_file}")
    
    if not found_data:
        print_error("No training data files found!")
        return False
    
    if total_samples > 0:
        print_success(f"Total training samples: {total_samples:,}")
        
        if total_samples < 100:
            print_error("⚠️ Too few samples! Need at least 1,000 for reliable training")
        elif total_samples < 1000:
            print_warning("⚠️ Low sample count. Recommend at least 1,000 samples")
        else:
            print_success("✓ Sufficient training data")
    
    return True

def check_model_metadata():
    """Check if model metadata exists"""
    print_header("Model Metadata")
    
    metadata_files = [
        "models/model_metadata.json",
        "models/training_info.json",
    ]
    
    found_metadata = False
    for metadata_file in metadata_files:
        metadata_path = Path(metadata_file)
        if metadata_path.exists():
            try:
                with open(metadata_path, 'r') as f:
                    metadata = json.load(f)
                    print_success(f"Found: {metadata_file}")
                    print_info(f"  Model Type: {metadata.get('model_type', 'Unknown')}")
                    print_info(f"  Version: {metadata.get('version', 'Unknown')}")
                    print_info(f"  Accuracy: {metadata.get('accuracy', 0):.2%}")
                    print_info(f"  Last Updated: {metadata.get('last_updated', 'Unknown')}")
                    found_metadata = True
            except Exception as e:
                print_warning(f"Found {metadata_file} but couldn't parse: {e}")
        else:
            print_warning(f"Not found: {metadata_file}")
    
    if not found_metadata:
        print_warning("No model metadata found - can't verify model quality")
    
    return found_metadata

def check_flutter_config():
    """Check Flutter app ML configuration"""
    print_header("Flutter App Configuration")
    
    ml_repo_path = Path("../lib/ml/repositories/ml_repository.dart")
    
    if not ml_repo_path.exists():
        print_error(f"ML Repository not found: {ml_repo_path}")
        return None
    
    try:
        with open(ml_repo_path, 'r') as f:
            content = f.read()
            
            # Check for mock flag
            if '_useMockData = true' in content:
                print_error("🚨 MOCK MODE ACTIVE")
                print_info("  The app is configured to use MOCK predictions")
                print_info("  Location: lib/ml/repositories/ml_repository.dart")
                print_info("  Change '_useMockData = true' to 'false' to use real ML")
                return False
            elif '_useMockData = false' in content:
                print_success("✓ REAL ML MODE ACTIVE")
                print_info("  The app is configured to use real ML models")
                return True
            else:
                print_warning("Could not determine mock/real mode")
                return None
    except Exception as e:
        print_error(f"Error reading Flutter config: {e}")
        return None

def check_backend_api():
    """Check if backend API is running"""
    print_header("Backend API Status")
    
    try:
        import requests
        
        api_urls = [
            "http://localhost:8080/health",
            "http://localhost:8080/api/status",
            "http://localhost:5000/health",
        ]
        
        for url in api_urls:
            try:
                response = requests.get(url, timeout=2)
                if response.status_code == 200:
                    print_success(f"Backend API is running: {url}")
                    return True
            except:
                continue
        
        print_warning("Backend API is not running")
        print_info("  Start backend: cd ml_backend && python3 app.py")
        return False
        
    except ImportError:
        print_warning("'requests' library not installed - skipping API check")
        print_info("  Install: pip3 install requests")
        return None

def generate_report():
    """Generate comprehensive verification report"""
    print_header("ML Verification Report")
    print_info(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    # Run all checks
    has_models = check_model_files()
    has_data = check_training_data()
    has_metadata = check_model_metadata()
    flutter_real_mode = check_flutter_config()
    api_running = check_backend_api()
    
    # Final verdict
    print_header("Final Verdict")
    
    if flutter_real_mode is False:
        print_error("🚨 APP IS USING MOCK PREDICTIONS")
        print()
        print_info("Current State:")
        print_info("  • Mock mode is enabled in Flutter app")
        print_info("  • All predictions are hardcoded for demonstration")
        print_info("  • No real ML models are being used")
        print()
        print_info("To use real ML predictions:")
        print_info("  1. Ensure ML models are trained and saved")
        print_info("  2. Edit: lib/ml/repositories/ml_repository.dart")
        print_info("  3. Change: _useMockData = true → false")
        print_info("  4. Restart the Flutter app")
        return
    
    if flutter_real_mode is True:
        if has_models and has_data:
            print_success("✅ APP IS CONFIGURED TO USE REAL ML")
            print()
            print_info("Verification:")
            print_success("  ✓ Real ML mode enabled in Flutter")
            if has_models:
                print_success("  ✓ ML model files found")
            if has_data:
                print_success("  ✓ Training data available")
            if has_metadata:
                print_success("  ✓ Model metadata present")
            if api_running:
                print_success("  ✓ Backend API is running")
            print()
            print_info("Status: All predictions should use trained ML models")
        else:
            print_error("⚠️ REAL MODE ENABLED BUT MODELS/DATA MISSING")
            print()
            print_info("Issue:")
            if not has_models:
                print_error("  ✗ ML model files not found")
            if not has_data:
                print_error("  ✗ Training data not found")
            print()
            print_info("The app may fall back to mock predictions or crash")
            print_info("Please train your ML models before enabling real mode")
    else:
        print_warning("⚠️ COULD NOT DETERMINE APP MODE")
        print_info("Please manually check lib/ml/repositories/ml_repository.dart")

if __name__ == "__main__":
    print()
    print(f"{BOLD}{BLUE}ML Model Status Verification{END}")
    print(f"{BLUE}Pure Health Water Quality App{END}")
    print()
    
    # Change to ml_backend directory if needed
    script_dir = Path(__file__).parent
    os.chdir(script_dir)
    
    generate_report()
    
    print()
    print_info("For more details, see: ML_VERIFICATION_GUIDE.md")
    print()
