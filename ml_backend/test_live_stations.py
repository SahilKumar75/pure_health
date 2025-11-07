"""
Test script for Live Water Station API
Tests all endpoints to ensure they work correctly
"""

import requests
import json
from datetime import datetime

BASE_URL = "http://localhost:8000/api"

def print_section(title):
    print("\n" + "="*60)
    print(f"   {title}")
    print("="*60)

def test_get_all_stations():
    print_section("TEST 1: Get All Stations")
    try:
        response = requests.get(f"{BASE_URL}/stations")
        data = response.json()
        print(f"✅ Status Code: {response.status_code}")
        print(f"✅ Station Count: {data['count']}")
        print(f"✅ First Station: {data['stations'][0]['name']}")
        return True
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_get_station_by_id():
    print_section("TEST 2: Get Station by ID")
    try:
        station_id = "MH-MUM-001"
        response = requests.get(f"{BASE_URL}/stations/{station_id}")
        data = response.json()
        print(f"✅ Status Code: {response.status_code}")
        print(f"✅ Station: {data['station']['name']}")
        print(f"✅ Current WQI: {data['current_data']['wqi']}")
        print(f"✅ Status: {data['current_data']['status']}")
        return True
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_get_all_station_data():
    print_section("TEST 3: Get All Station Data")
    try:
        response = requests.get(f"{BASE_URL}/stations/data/all")
        data = response.json()
        print(f"✅ Status Code: {response.status_code}")
        print(f"✅ Data Count: {data['count']}")
        print(f"✅ Timestamp: {data['timestamp']}")
        
        # Show sample data
        sample_id = list(data['data'].keys())[0]
        sample = data['data'][sample_id]
        print(f"\n📊 Sample Station ({sample_id}):")
        print(f"   Name: {sample['stationName']}")
        print(f"   WQI: {sample['wqi']}")
        print(f"   pH: {sample['parameters']['pH']}")
        print(f"   DO: {sample['parameters']['dissolvedOxygen']} mg/L")
        print(f"   Turbidity: {sample['parameters']['turbidity']} NTU")
        return True
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_get_stations_by_district():
    print_section("TEST 4: Get Stations by District")
    try:
        district = "Mumbai"
        response = requests.get(f"{BASE_URL}/stations/district/{district}")
        data = response.json()
        print(f"✅ Status Code: {response.status_code}")
        print(f"✅ District: {data['district']}")
        print(f"✅ Station Count: {data['count']}")
        
        for item in data['stations']:
            station = item['station']
            current_data = item['current_data']
            print(f"   - {station['name']}: WQI {current_data['wqi']} ({current_data['status']})")
        
        return True
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_get_stations_by_status():
    print_section("TEST 5: Get Stations by Status")
    try:
        status = "Good"
        response = requests.get(f"{BASE_URL}/stations/status/{status}")
        data = response.json()
        print(f"✅ Status Code: {response.status_code}")
        print(f"✅ Status Filter: {data['status']}")
        print(f"✅ Station Count: {data['count']}")
        return True
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_get_summary():
    print_section("TEST 6: Get Summary Statistics")
    try:
        response = requests.get(f"{BASE_URL}/stations/summary")
        data = response.json()
        summary = data['summary']
        print(f"✅ Status Code: {response.status_code}")
        print(f"✅ Total Stations: {summary['total_stations']}")
        print(f"✅ Average WQI: {summary['average_wqi']}")
        print(f"✅ Total Alerts: {summary['total_alerts']}")
        print(f"\n📊 Status Distribution:")
        for status, count in summary['status_distribution'].items():
            print(f"   - {status}: {count} stations")
        return True
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_refresh_data():
    print_section("TEST 7: Refresh Station Data")
    try:
        response = requests.post(f"{BASE_URL}/stations/simulation/refresh")
        data = response.json()
        print(f"✅ Status Code: {response.status_code}")
        print(f"✅ Message: {data['message']}")
        print(f"✅ Data Count: {data['count']}")
        print(f"✅ Timestamp: {data['timestamp']}")
        return True
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_start_simulation():
    print_section("TEST 8: Start Simulation")
    try:
        payload = {"interval_seconds": 300}  # 5 minutes for testing
        response = requests.post(
            f"{BASE_URL}/stations/simulation/start",
            json=payload,
            headers={"Content-Type": "application/json"}
        )
        data = response.json()
        print(f"✅ Status Code: {response.status_code}")
        print(f"✅ Message: {data['message']}")
        print(f"✅ Interval: {data['interval_seconds']} seconds")
        return True
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def run_all_tests():
    print("\n" + "🧪 "*30)
    print("LIVE WATER STATION API TEST SUITE")
    print("🧪 "*30)
    
    tests = [
        test_get_all_stations,
        test_get_station_by_id,
        test_get_all_station_data,
        test_get_stations_by_district,
        test_get_stations_by_status,
        test_get_summary,
        test_refresh_data,
        test_start_simulation,
    ]
    
    results = []
    for test in tests:
        try:
            result = test()
            results.append(result)
        except Exception as e:
            print(f"❌ Test failed with exception: {e}")
            results.append(False)
    
    # Summary
    print_section("TEST RESULTS SUMMARY")
    passed = sum(results)
    total = len(results)
    print(f"\n✅ Passed: {passed}/{total}")
    print(f"❌ Failed: {total - passed}/{total}")
    
    if passed == total:
        print("\n🎉 ALL TESTS PASSED!")
    else:
        print("\n⚠️  Some tests failed. Check the output above.")
    
    print("\n" + "="*60 + "\n")

if __name__ == "__main__":
    print("\n⏳ Waiting for backend to be ready...")
    print("   Make sure the backend is running: python ml_backend/app.py")
    print("   Press Enter when ready...")
    input()
    
    run_all_tests()
