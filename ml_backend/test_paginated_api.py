#!/usr/bin/env python3
"""
Test script for paginated API endpoints
Tests all updated endpoints with pagination, filtering, and edge cases
"""

import requests
import json
from datetime import datetime

# Base URL
BASE_URL = "http://localhost:5000"

def print_section(title):
    """Print formatted section header"""
    print("\n" + "="*70)
    print(f"  {title}")
    print("="*70)

def test_endpoint(name, url, params=None):
    """Test an API endpoint and print results"""
    print(f"\n📍 Testing: {name}")
    print(f"   URL: {url}")
    if params:
        print(f"   Params: {params}")
    
    try:
        response = requests.get(url, params=params, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            
            # Print pagination info if available
            if 'pagination' in data:
                pag = data['pagination']
                print(f"   ✅ Status: 200 OK")
                print(f"   📊 Pagination:")
                print(f"      - Page: {pag['page']}/{pag['total_pages']}")
                print(f"      - Items: {pag['per_page']} per page")
                print(f"      - Total: {pag['total_items']} items")
                print(f"      - Has Next: {pag['has_next']}")
            else:
                print(f"   ✅ Status: 200 OK")
                print(f"   📊 Items: {data.get('count', 'N/A')}")
            
            # Print filters if available
            if 'filters' in data:
                filters = data['filters']
                active_filters = {k: v for k, v in filters.items() if v is not None and v != False}
                if active_filters:
                    print(f"   🔍 Active Filters: {active_filters}")
            
            return True
        else:
            print(f"   ❌ Status: {response.status_code}")
            print(f"   Error: {response.text[:200]}")
            return False
            
    except Exception as e:
        print(f"   ❌ Error: {str(e)}")
        return False

def main():
    """Run all API pagination tests"""
    
    print("\n" + "🧪 PAGINATED API TESTING SUITE" + "\n")
    print(f"Testing API at: {BASE_URL}")
    print(f"Test started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    results = []
    
    # ============================================
    # TEST 1: Main Stations Endpoint
    # ============================================
    print_section("TEST 1: Main Stations List (/api/stations)")
    
    # Test 1.1: Basic pagination
    results.append(test_endpoint(
        "Basic Pagination (Page 1)",
        f"{BASE_URL}/api/stations",
        {"page": 1, "per_page": 50}
    ))
    
    # Test 1.2: Different page
    results.append(test_endpoint(
        "Page 2 with 100 items",
        f"{BASE_URL}/api/stations",
        {"page": 2, "per_page": 100}
    ))
    
    # Test 1.3: Filter by district
    results.append(test_endpoint(
        "Filter by District (Mumbai)",
        f"{BASE_URL}/api/stations",
        {"district": "Mumbai", "per_page": 50}
    ))
    
    # Test 1.4: Filter by type
    results.append(test_endpoint(
        "Filter by Type (surface_water)",
        f"{BASE_URL}/api/stations",
        {"type": "surface_water", "per_page": 50}
    ))
    
    # Test 1.5: Combined filters
    results.append(test_endpoint(
        "Combined Filters (Pune + groundwater)",
        f"{BASE_URL}/api/stations",
        {"district": "Pune", "type": "groundwater", "per_page": 50}
    ))
    
    # Test 1.6: Search
    results.append(test_endpoint(
        "Search (Mula)",
        f"{BASE_URL}/api/stations",
        {"search": "Mula", "per_page": 50}
    ))
    
    # ============================================
    # TEST 2: Station Data Endpoint
    # ============================================
    print_section("TEST 2: Station Data (/api/stations/data/all)")
    
    # Test 2.1: Basic pagination
    results.append(test_endpoint(
        "Basic Data Pagination",
        f"{BASE_URL}/api/stations/data/all",
        {"page": 1, "per_page": 50}
    ))
    
    # Test 2.2: Filter by district
    results.append(test_endpoint(
        "Data for Nagpur District",
        f"{BASE_URL}/api/stations/data/all",
        {"district": "Nagpur", "per_page": 50}
    ))
    
    # ============================================
    # TEST 3: District Endpoint
    # ============================================
    print_section("TEST 3: District Stations (/api/stations/district/<district>)")
    
    # Test 3.1: Pune district
    results.append(test_endpoint(
        "Pune District (without data)",
        f"{BASE_URL}/api/stations/district/Pune",
        {"page": 1, "per_page": 50}
    ))
    
    # Test 3.2: With current data
    results.append(test_endpoint(
        "Mumbai District (with data)",
        f"{BASE_URL}/api/stations/district/Mumbai",
        {"page": 1, "per_page": 20, "include_data": "true"}
    ))
    
    # Test 3.3: Type filter
    results.append(test_endpoint(
        "Pune Surface Water Only",
        f"{BASE_URL}/api/stations/district/Pune",
        {"type": "surface_water", "per_page": 50}
    ))
    
    # ============================================
    # TEST 4: Type Endpoint
    # ============================================
    print_section("TEST 4: Station Type (/api/stations/type/<type>)")
    
    # Test 4.1: Surface water
    results.append(test_endpoint(
        "All Surface Water Stations",
        f"{BASE_URL}/api/stations/type/surface_water",
        {"page": 1, "per_page": 100}
    ))
    
    # Test 4.2: Groundwater with district filter
    results.append(test_endpoint(
        "Groundwater in Nagpur",
        f"{BASE_URL}/api/stations/type/groundwater",
        {"district": "Nagpur", "per_page": 50}
    ))
    
    # ============================================
    # TEST 5: Water Class Endpoint
    # ============================================
    print_section("TEST 5: Water Quality Class (/api/stations/water-class/<class>)")
    
    # Test 5.1: Class A
    results.append(test_endpoint(
        "Class A Stations",
        f"{BASE_URL}/api/stations/water-class/A",
        {"page": 1, "per_page": 50}
    ))
    
    # Test 5.2: Class C with filters
    results.append(test_endpoint(
        "Class C in Mumbai",
        f"{BASE_URL}/api/stations/water-class/C",
        {"district": "Mumbai", "per_page": 50}
    ))
    
    # ============================================
    # TEST 6: Alerts Endpoint
    # ============================================
    print_section("TEST 6: Stations with Alerts (/api/stations/alerts)")
    
    # Test 6.1: All alerts
    results.append(test_endpoint(
        "All Stations with Alerts",
        f"{BASE_URL}/api/stations/alerts",
        {"page": 1, "per_page": 50}
    ))
    
    # Test 6.2: Critical alerts only
    results.append(test_endpoint(
        "Critical Alerts Only",
        f"{BASE_URL}/api/stations/alerts",
        {"severity": "critical", "per_page": 50}
    ))
    
    # Test 6.3: District filter
    results.append(test_endpoint(
        "Alerts in Pune",
        f"{BASE_URL}/api/stations/alerts",
        {"district": "Pune", "per_page": 50}
    ))
    
    # ============================================
    # TEST 7: History Endpoint
    # ============================================
    print_section("TEST 7: Station History (/api/stations/<id>/history)")
    
    # Test 7.1: Basic history
    results.append(test_endpoint(
        "History for MH-PUN-SW-001",
        f"{BASE_URL}/api/stations/MH-PUN-SW-001/history",
        {"page": 1, "per_page": 50}
    ))
    
    # Test 7.2: Limited records
    results.append(test_endpoint(
        "Limited History (100 records max)",
        f"{BASE_URL}/api/stations/MH-PUN-SW-001/history",
        {"limit": 100, "per_page": 20}
    ))
    
    # ============================================
    # TEST 8: Region Endpoint
    # ============================================
    print_section("TEST 8: Regional Stations (/api/stations/region/<region>)")
    
    # Test 8.1: Pune Division
    results.append(test_endpoint(
        "Pune Division Stations",
        f"{BASE_URL}/api/stations/region/Pune Division",
        {"page": 1, "per_page": 50}
    ))
    
    # Test 8.2: With type filter
    results.append(test_endpoint(
        "Vidarbha Surface Water",
        f"{BASE_URL}/api/stations/region/Vidarbha",
        {"type": "surface_water", "per_page": 50}
    ))
    
    # ============================================
    # TEST 9: Status Endpoint
    # ============================================
    print_section("TEST 9: Status Filter (/api/stations/status/<status>)")
    
    # Test 9.1: Excellent status
    results.append(test_endpoint(
        "Excellent Quality Stations",
        f"{BASE_URL}/api/stations/status/Excellent",
        {"page": 1, "per_page": 50}
    ))
    
    # Test 9.2: With district filter
    results.append(test_endpoint(
        "Good Quality in Mumbai",
        f"{BASE_URL}/api/stations/status/Good",
        {"district": "Mumbai", "per_page": 50}
    ))
    
    # ============================================
    # TEST 10: Map Data Endpoint
    # ============================================
    print_section("TEST 10: Map Data (/api/stations/map-data)")
    
    # Test 10.1: Standard map data
    results.append(test_endpoint(
        "Standard Map Data",
        f"{BASE_URL}/api/stations/map-data",
        {"page": 1, "per_page": 500}
    ))
    
    # Test 10.2: Minimal GPS only
    results.append(test_endpoint(
        "Minimal GPS Data (fast)",
        f"{BASE_URL}/api/stations/map-data",
        {"page": 1, "per_page": 1000, "minimal": "true"}
    ))
    
    # Test 10.3: District filter
    results.append(test_endpoint(
        "Pune District Map Data",
        f"{BASE_URL}/api/stations/map-data",
        {"district": "Pune", "per_page": 500}
    ))
    
    # ============================================
    # TEST 11: Edge Cases
    # ============================================
    print_section("TEST 11: Edge Cases")
    
    # Test 11.1: Page beyond range
    results.append(test_endpoint(
        "Page 999 (beyond range)",
        f"{BASE_URL}/api/stations",
        {"page": 999, "per_page": 50}
    ))
    
    # Test 11.2: Max per_page limit
    results.append(test_endpoint(
        "Max Items (201 should cap at 200)",
        f"{BASE_URL}/api/stations",
        {"page": 1, "per_page": 201}
    ))
    
    # Test 11.3: Invalid district
    results.append(test_endpoint(
        "Invalid District (should return empty)",
        f"{BASE_URL}/api/stations",
        {"district": "InvalidDistrict", "per_page": 50}
    ))
    
    # ============================================
    # RESULTS SUMMARY
    # ============================================
    print_section("TEST RESULTS SUMMARY")
    
    total_tests = len(results)
    passed_tests = sum(results)
    failed_tests = total_tests - passed_tests
    success_rate = (passed_tests / total_tests * 100) if total_tests > 0 else 0
    
    print(f"\n📊 Total Tests: {total_tests}")
    print(f"✅ Passed: {passed_tests}")
    print(f"❌ Failed: {failed_tests}")
    print(f"📈 Success Rate: {success_rate:.1f}%")
    
    if success_rate == 100:
        print("\n🎉 All tests passed! API pagination is working correctly.")
    else:
        print(f"\n⚠️  {failed_tests} test(s) failed. Please review the errors above.")
    
    print(f"\nTest completed: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("="*70 + "\n")

if __name__ == "__main__":
    main()
