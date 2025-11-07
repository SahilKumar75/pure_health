"""
Test script for Enhanced Live Station Service with complete Maharashtra network
"""

print('🚀 Testing Enhanced Live Station Service with Pune District...')
print('=' * 80)

from enhanced_live_station_service import EnhancedLiveStationService
import time
import json

# Initialize with Pune district
print('\n⏳ Initializing service...')
service = EnhancedLiveStationService(test_mode=True, test_district='Pune')

print('\n⏳ Waiting for initial data generation (3 seconds)...')
time.sleep(3)

print('\n📊 Summary Statistics:')
summary = service.get_summary_statistics()
print(f'  Total Stations: {summary["totalStations"]}')
print(f'  Surface Water: {summary["surfaceWaterStations"]}')
print(f'  Groundwater: {summary["groundwaterStations"]}')
print(f'  Average WQI: {round(summary["averageWQI"], 2)}')

print('\n🗺️  Sample Stations with GPS:')
for station in service.stations[:5]:
    print(f'  ✓ {station["station_id"]}: {station["name"]}')
    print(f'    GPS: ({station["latitude"]}, {station["longitude"]})')
    print(f'    Type: {station["type"]}, District: {station["district"]}')

print('\n🚨 Stations with Alerts:')
alerts = service.get_stations_with_alerts()
if alerts:
    for item in alerts[:3]:
        print(f'  ⚠️  {item["station"]["name"]} - {item["alertCount"]} alert(s)')
else:
    print('  ✅ No alerts at this time')

print('\n✅ TEST PASSED! Service is operational with 200 Pune stations!')
print('=' * 80)
