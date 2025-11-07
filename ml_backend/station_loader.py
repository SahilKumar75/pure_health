"""
LIGHTWEIGHT STATION LOADER
Loads station data from JSON files on demand
"""

import json
import os

_STATION_CACHE = None

def load_all_stations():
    """Load all stations from JSON file (cached)"""
    global _STATION_CACHE
    
    if _STATION_CACHE is None:
        json_path = os.path.join(os.path.dirname(__file__), 'complete_maharashtra_stations.json')
        with open(json_path, 'r', encoding='utf-8') as f:
            _STATION_CACHE = json.load(f)
    
    return _STATION_CACHE

def get_station_by_id(station_id):
    """Get specific station by ID"""
    stations = load_all_stations()
    for station in stations:
        if station['station_id'] == station_id:
            return station
    return None

def get_stations_by_district(district):
    """Get all stations in a district"""
    stations = load_all_stations()
    return [s for s in stations if s['district'] == district]

def get_stations_by_type(station_type):
    """Get all stations of a specific type"""
    stations = load_all_stations()
    return [s for s in stations if s['type'] == station_type]

def get_surface_water_stations():
    """Get all surface water stations"""
    return get_stations_by_type('surface_water')

def get_groundwater_baseline_stations():
    """Get all groundwater baseline stations"""
    stations = load_all_stations()
    return [s for s in stations if s.get('monitoring_type') == 'baseline']

def get_groundwater_trend_stations():
    """Get all groundwater trend stations"""
    stations = load_all_stations()
    return [s for s in stations if s.get('monitoring_type') == 'trend']

# Quick access
ALL_STATIONS = load_all_stations()

print(f"✅ Loaded {len(ALL_STATIONS)} Maharashtra water quality monitoring stations")
