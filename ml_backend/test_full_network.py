#!/usr/bin/env python3
"""
Production Network Test - Full 4,495 Stations
Tests performance, memory usage, and API functionality with complete station network
"""

import os
import sys
import time
import requests
from datetime import datetime

# Try to import psutil for memory tracking (optional)
try:
    import psutil
    HAS_PSUTIL = True
except ImportError:
    HAS_PSUTIL = False
    print("⚠️  psutil not installed - memory tracking disabled")
    print("   Install with: pip install psutil\n")

# Set environment to production mode
os.environ['STATION_TEST_MODE'] = 'false'

print("\n" + "="*80)
print("🚀 PRODUCTION NETWORK TEST - 4,495 Stations")
print("="*80)

# ============================================
# STEP 1: Initialize Service
# ============================================
print("\n📦 STEP 1: Initializing service with full network...")
print("-" * 80)

start_time = time.time()
if HAS_PSUTIL:
    process = psutil.Process()
    initial_memory = process.memory_info().rss / (1024 * 1024)  # MB
else:
    initial_memory = 0

from enhanced_live_station_service import get_station_service

service = get_station_service()
init_time = time.time() - start_time

if HAS_PSUTIL:
    init_memory = process.memory_info().rss / (1024 * 1024)  # MB
    memory_used = init_memory - initial_memory
    print(f"✅ Service initialized in {init_time:.2f} seconds")
    print(f"💾 Memory usage: {memory_used:.2f} MB (Total: {init_memory:.2f} MB)")
else:
    print(f"✅ Service initialized in {init_time:.2f} seconds")
    print(f"💾 Memory tracking: Not available (install psutil)")

# Verify station count
all_stations = service.get_all_stations()
print(f"📊 Loaded stations: {len(all_stations)}")

if len(all_stations) < 4000:
    print(f"⚠️  WARNING: Expected ~4,495 stations, got {len(all_stations)}")
    print("   Make sure STATION_TEST_MODE=false is set correctly")
else:
    print(f"✅ Full network loaded successfully!")

# ============================================
# STEP 2: Verify Station Details
# ============================================
print("\n📍 STEP 2: Verifying station details...")
print("-" * 80)

# Count by type
surface_water = [s for s in all_stations if s.get('type') == 'surface_water']
groundwater = [s for s in all_stations if s.get('type') == 'groundwater']

print(f"   Surface Water: {len(surface_water)} stations")
print(f"   Groundwater:   {len(groundwater)} stations")
print(f"   Total:         {len(all_stations)} stations")

# Count by district
districts = {}
for station in all_stations:
    district = station.get('district', 'Unknown')
    districts[district] = districts.get(district, 0) + 1

print(f"\n   Districts covered: {len(districts)}")
print(f"   Top 5 districts by station count:")
sorted_districts = sorted(districts.items(), key=lambda x: x[1], reverse=True)
for district, count in sorted_districts[:5]:
    print(f"     • {district}: {count} stations")

# Verify GPS coordinates
stations_with_gps = [s for s in all_stations if s.get('latitude') and s.get('longitude')]
print(f"\n   Stations with GPS: {len(stations_with_gps)}/{len(all_stations)} ({len(stations_with_gps)/len(all_stations)*100:.1f}%)")

if len(stations_with_gps) == len(all_stations):
    print("   ✅ 100% GPS coverage!")

# ============================================
# STEP 3: Test Data Generation
# ============================================
print("\n⚙️  STEP 3: Testing data generation...")
print("-" * 80)

# Get summary statistics
summary = service.get_summary_statistics()
print(f"   Total Stations: {summary.get('totalStations', 0)}")
print(f"   Average WQI: {summary.get('averageWQI', 0):.2f}")
print(f"   Stations with Alerts: {summary.get('stationsWithAlerts', 0)}")

# Test individual station data
test_station_ids = [all_stations[0].get('station_id') or all_stations[0].get('id')]
if len(all_stations) > 100:
    test_station_ids.append(all_stations[100].get('station_id') or all_stations[100].get('id'))

print(f"\n   Testing data generation for {len(test_station_ids)} sample stations...")
for station_id in test_station_ids:
    station_data = service.get_station_by_id(station_id)
    if station_data and station_data.get('currentReading'):
        data = station_data['currentReading']
        wqi = data.get('wqi', 0)
        param_count = len(data.get('parameters', {}))
        print(f"     ✅ {station_id}: WQI {wqi:.2f}, {param_count} parameters")
    else:
        print(f"     ❌ {station_id}: No data generated")

# ============================================
# STEP 4: Memory Usage Check
# ============================================
print("\n💾 STEP 4: Memory usage analysis...")
print("-" * 80)

if HAS_PSUTIL:
    current_memory = process.memory_info().rss / (1024 * 1024)  # MB
    print(f"   Current memory: {current_memory:.2f} MB")
    print(f"   Memory per station: {(current_memory - initial_memory) / len(all_stations):.3f} MB")

    memory_limit = 4096  # 4GB target
    if current_memory < memory_limit:
        print(f"   ✅ Memory usage within limit ({memory_limit} MB)")
    else:
        print(f"   ⚠️  Memory usage exceeds limit! ({current_memory:.2f} MB > {memory_limit} MB)")
        print("      Consider optimization: reduce historical data storage, add caching")
else:
    current_memory = 0
    print("   ⚠️  Memory tracking not available")
    print("      Install psutil for memory analysis: pip install psutil")

# ============================================
# STEP 5: Test API Endpoints (if server running)
# ============================================
print("\n🌐 STEP 5: Testing API endpoints...")
print("-" * 80)

BASE_URL = "http://localhost:8000"

# Check if server is running
try:
    response = requests.get(f"{BASE_URL}/api/status", timeout=2)
    server_running = response.status_code == 200
except:
    server_running = False

if server_running:
    print("   ✅ API server is running")
    
    # Test critical endpoints with timing
    test_cases = [
        ("Main stations list", f"{BASE_URL}/api/stations?page=1&per_page=100"),
        ("Station data", f"{BASE_URL}/api/stations/data/all?page=1&per_page=50"),
        ("District filter", f"{BASE_URL}/api/stations?district=Mumbai&per_page=50"),
        ("Map data (minimal)", f"{BASE_URL}/api/stations/map-data?minimal=true&per_page=1000"),
        ("Alerts", f"{BASE_URL}/api/stations/alerts?per_page=50"),
        ("Summary stats", f"{BASE_URL}/api/stations/summary"),
    ]
    
    print("\n   Testing response times (target: < 5 seconds):")
    all_passed = True
    
    for name, url in test_cases:
        try:
            start = time.time()
            response = requests.get(url, timeout=10)
            elapsed = time.time() - start
            
            if response.status_code == 200:
                data = response.json()
                count = data.get('count', 0)
                status = "✅" if elapsed < 5.0 else "⚠️ "
                print(f"     {status} {name}: {elapsed:.3f}s ({count} items)")
                
                if elapsed >= 5.0:
                    all_passed = False
                    print(f"        WARNING: Exceeds 5s target!")
            else:
                print(f"     ❌ {name}: HTTP {response.status_code}")
                all_passed = False
        except Exception as e:
            print(f"     ❌ {name}: {str(e)}")
            all_passed = False
    
    if all_passed:
        print("\n   ✅ All API endpoints responded within 5 seconds!")
    else:
        print("\n   ⚠️  Some endpoints need optimization")
        
else:
    print("   ⚠️  API server not running")
    print("      Start server with: python app.py")
    print("      Then run this test again")

# ============================================
# STEP 6: Performance Recommendations
# ============================================
print("\n📈 STEP 6: Performance analysis...")
print("-" * 80)

recommendations = []

# Check memory
if current_memory > 3000:  # Over 3GB
    recommendations.append("• Reduce historical data storage (currently 100 readings/station)")
    recommendations.append("• Consider moving to database (PostgreSQL/MongoDB)")

# Check station count vs target
if len(all_stations) < 4400:
    recommendations.append(f"• Verify station generation - expected ~4,495, got {len(all_stations)}")

# Check GPS coverage
if len(stations_with_gps) < len(all_stations):
    missing = len(all_stations) - len(stations_with_gps)
    recommendations.append(f"• Fix GPS coordinates for {missing} stations")

if recommendations:
    print("   Recommendations:")
    for rec in recommendations:
        print(f"   {rec}")
else:
    print("   ✅ System performance is optimal!")

# ============================================
# FINAL SUMMARY
# ============================================
print("\n" + "="*80)
print("📊 PRODUCTION NETWORK TEST SUMMARY")
print("="*80)

print(f"""
✅ Initialization:
   • Time: {init_time:.2f} seconds
   • Memory: {memory_used if HAS_PSUTIL else 'N/A'}
   • Stations: {len(all_stations)}

📍 Coverage:
   • Districts: {len(districts)}
   • Surface Water: {len(surface_water)}
   • Groundwater: {len(groundwater)}
   • GPS Coverage: {len(stations_with_gps)/len(all_stations)*100:.1f}%

💾 Resources:
   • Current Memory: {f'{current_memory:.2f} MB' if HAS_PSUTIL else 'N/A'}
   • Memory/Station: {f'{(current_memory - initial_memory) / len(all_stations):.3f} MB' if HAS_PSUTIL else 'N/A'}
   • Status: {("✅ Within limits" if current_memory < 4096 else "⚠️  Exceeds 4GB limit") if HAS_PSUTIL else 'N/A'}

🎯 Overall Status:
""")

# Calculate overall health
health_score = 0
if len(all_stations) >= 4400: health_score += 25
if len(stations_with_gps) == len(all_stations): health_score += 25
if not HAS_PSUTIL or current_memory < 4096: health_score += 25
if server_running and all_passed: health_score += 25

if health_score == 100:
    print("   🎉 EXCELLENT - System is production-ready!")
elif health_score >= 75:
    print("   ✅ GOOD - Minor optimizations recommended")
elif health_score >= 50:
    print("   ⚠️  FAIR - Optimization needed before production")
else:
    print("   ❌ POOR - Significant issues need addressing")

print(f"   Health Score: {health_score}/100")

print("\n" + "="*80)
print(f"Test completed: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
print("="*80 + "\n")
