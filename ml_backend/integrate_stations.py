"""
INTEGRATION SCRIPT: Load Complete Maharashtra Station Network
Updates enhanced_live_station_service.py to use all 4,495 stations
"""

import json
import random

# =============================================================================
# LOAD STATION DATA
# =============================================================================

def load_all_stations():
    """Load all 4,495 stations from JSON file"""
    with open('complete_maharashtra_stations.json', 'r', encoding='utf-8') as f:
        stations = json.load(f)
    return stations

# =============================================================================
# GENERATE BASE PARAMETERS FOR EACH STATION
# =============================================================================

def generate_base_parameters(station):
    """
    Generate realistic base parameter values based on station characteristics
    """
    station_type = station['type']
    land_use = station.get('land_use', 'rural')
    designated_use = station.get('designated_use', 'drinking')
    
    # Base parameters vary by land use and station type
    if station_type == 'surface_water':
        # Surface water base values
        if land_use == 'urban':
            base_params = {
                'ph': random.uniform(7.0, 8.0),
                'temperature_c': random.uniform(24, 28),
                'turbidity_ntu': random.uniform(15, 40),
                'tds_mg_l': random.uniform(300, 600),
                'do_mg_l': random.uniform(4.5, 7.0),
                'bod_mg_l': random.uniform(3, 8),
                'cod_mg_l': random.uniform(15, 40),
                'total_coliform_mpn_100ml': random.randint(200, 2000),
                'fecal_coliform_mpn_100ml': random.randint(50, 500),
                'nitrate_mg_l': random.uniform(5, 20),
                'phosphate_mg_l': random.uniform(0.5, 2.0),
                'chloride_mg_l': random.uniform(50, 200),
                'fluoride_mg_l': random.uniform(0.3, 1.0),
                'iron_mg_l': random.uniform(0.1, 0.5),
            }
        elif land_use == 'industrial':
            base_params = {
                'ph': random.uniform(6.5, 8.5),
                'temperature_c': random.uniform(26, 32),
                'turbidity_ntu': random.uniform(20, 60),
                'tds_mg_l': random.uniform(400, 800),
                'do_mg_l': random.uniform(3.5, 6.0),
                'bod_mg_l': random.uniform(5, 15),
                'cod_mg_l': random.uniform(30, 80),
                'total_coliform_mpn_100ml': random.randint(500, 3000),
                'fecal_coliform_mpn_100ml': random.randint(100, 800),
                'nitrate_mg_l': random.uniform(8, 30),
                'phosphate_mg_l': random.uniform(1.0, 3.5),
                'chloride_mg_l': random.uniform(100, 350),
                'fluoride_mg_l': random.uniform(0.4, 1.2),
                'iron_mg_l': random.uniform(0.2, 1.0),
            }
        else:  # agricultural or forest
            base_params = {
                'ph': random.uniform(7.2, 7.8),
                'temperature_c': random.uniform(22, 26),
                'turbidity_ntu': random.uniform(5, 20),
                'tds_mg_l': random.uniform(200, 400),
                'do_mg_l': random.uniform(6.0, 8.5),
                'bod_mg_l': random.uniform(1, 4),
                'cod_mg_l': random.uniform(8, 20),
                'total_coliform_mpn_100ml': random.randint(50, 500),
                'fecal_coliform_mpn_100ml': random.randint(10, 150),
                'nitrate_mg_l': random.uniform(2, 10),
                'phosphate_mg_l': random.uniform(0.2, 1.0),
                'chloride_mg_l': random.uniform(20, 100),
                'fluoride_mg_l': random.uniform(0.2, 0.8),
                'iron_mg_l': random.uniform(0.05, 0.3),
            }
    else:  # groundwater
        aquifer_type = station.get('aquifer_type', 'alluvial')
        
        if aquifer_type == 'basaltic':
            base_params = {
                'ph': random.uniform(7.5, 8.2),
                'temperature_c': random.uniform(24, 27),
                'turbidity_ntu': random.uniform(1, 5),
                'tds_mg_l': random.uniform(300, 600),
                'total_hardness_mg_l': random.uniform(150, 350),
                'calcium_mg_l': random.uniform(40, 90),
                'magnesium_mg_l': random.uniform(20, 60),
                'sodium_mg_l': random.uniform(30, 100),
                'potassium_mg_l': random.uniform(2, 10),
                'chloride_mg_l': random.uniform(50, 150),
                'sulfate_mg_l': random.uniform(20, 80),
                'nitrate_mg_l': random.uniform(10, 40),
                'fluoride_mg_l': random.uniform(0.5, 2.0),
                'iron_mg_l': random.uniform(0.1, 0.5),
                'total_coliform_mpn_100ml': random.randint(0, 50),
                'fecal_coliform_mpn_100ml': random.randint(0, 10),
            }
        elif aquifer_type == 'hard_rock':
            base_params = {
                'ph': random.uniform(6.8, 7.6),
                'temperature_c': random.uniform(23, 26),
                'turbidity_ntu': random.uniform(1, 8),
                'tds_mg_l': random.uniform(200, 500),
                'total_hardness_mg_l': random.uniform(100, 280),
                'calcium_mg_l': random.uniform(30, 70),
                'magnesium_mg_l': random.uniform(15, 50),
                'sodium_mg_l': random.uniform(20, 80),
                'potassium_mg_l': random.uniform(1, 8),
                'chloride_mg_l': random.uniform(30, 120),
                'sulfate_mg_l': random.uniform(15, 60),
                'nitrate_mg_l': random.uniform(15, 50),
                'fluoride_mg_l': random.uniform(0.3, 1.5),
                'iron_mg_l': random.uniform(0.2, 1.0),
                'total_coliform_mpn_100ml': random.randint(0, 30),
                'fecal_coliform_mpn_100ml': random.randint(0, 5),
            }
        else:  # alluvial or semi-confined
            base_params = {
                'ph': random.uniform(7.0, 7.8),
                'temperature_c': random.uniform(24, 28),
                'turbidity_ntu': random.uniform(2, 10),
                'tds_mg_l': random.uniform(250, 550),
                'total_hardness_mg_l': random.uniform(120, 300),
                'calcium_mg_l': random.uniform(35, 80),
                'magnesium_mg_l': random.uniform(18, 55),
                'sodium_mg_l': random.uniform(25, 90),
                'potassium_mg_l': random.uniform(2, 9),
                'chloride_mg_l': random.uniform(40, 130),
                'sulfate_mg_l': random.uniform(18, 70),
                'nitrate_mg_l': random.uniform(20, 60),
                'fluoride_mg_l': random.uniform(0.4, 1.8),
                'iron_mg_l': random.uniform(0.15, 0.8),
                'total_coliform_mpn_100ml': random.randint(0, 40),
                'fecal_coliform_mpn_100ml': random.randint(0, 8),
            }
    
    # Add common parameters
    base_params.update({
        'conductivity_us_cm': base_params['tds_mg_l'] * 1.5,
        'total_alkalinity_mg_l': random.uniform(80, 250),
        'bicarbonate_mg_l': random.uniform(100, 300),
        'ammonia_mg_l': random.uniform(0.1, 1.5),
        'arsenic_ug_l': random.uniform(0, 10),
        'lead_ug_l': random.uniform(0, 5),
        'chromium_ug_l': random.uniform(0, 15),
        'cadmium_ug_l': random.uniform(0, 2),
        'mercury_ug_l': random.uniform(0, 1),
    })
    
    return base_params

# =============================================================================
# CREATE ENHANCED STATION DATA
# =============================================================================

def create_enhanced_stations_file():
    """
    Create Python file with all enhanced station data for the monitoring service
    """
    print("Loading stations from JSON...")
    stations = load_all_stations()
    print(f"✅ Loaded {len(stations)} stations")
    
    print("\nGenerating base parameters for each station...")
    
    # Prepare data structure
    output_lines = []
    output_lines.append('"""')
    output_lines.append('COMPLETE MAHARASHTRA STATION DATA')
    output_lines.append(f'Total Stations: {len(stations)}')
    output_lines.append('Generated automatically from complete_maharashtra_stations.json')
    output_lines.append('"""')
    output_lines.append('')
    output_lines.append('ALL_STATIONS = [')
    
    for i, station in enumerate(stations):
        if (i + 1) % 100 == 0:
            print(f"   Processing station {i+1}/{len(stations)}...")
        
        # Generate base parameters
        base_params = generate_base_parameters(station)
        
        # Create station dict with all data
        station_data = {
            **station,
            'base_parameters': base_params
        }
        
        # Format as Python dict (compact to save space)
        output_lines.append('    {')
        for key, value in station_data.items():
            if isinstance(value, str):
                output_lines.append(f'        "{key}": "{value}",')
            elif isinstance(value, dict):
                output_lines.append(f'        "{key}": {value},')
            elif isinstance(value, list):
                output_lines.append(f'        "{key}": {value},')
            else:
                output_lines.append(f'        "{key}": {value},')
        output_lines.append('    },')
    
    output_lines.append(']')
    output_lines.append('')
    output_lines.append(f'# Total: {len(stations)} stations')
    output_lines.append('# Surface Water: ' + str(len([s for s in stations if s['type'] == 'surface_water'])))
    output_lines.append('# Groundwater Baseline: ' + str(len([s for s in stations if s.get('monitoring_type') == 'baseline'])))
    output_lines.append('# Groundwater Trend: ' + str(len([s for s in stations if s.get('monitoring_type') == 'trend'])))
    
    # Write to file
    print("\nWriting to enhanced_all_stations_data.py...")
    with open('enhanced_all_stations_data.py', 'w', encoding='utf-8') as f:
        f.write('\n'.join(output_lines))
    
    print(f"✅ Created enhanced_all_stations_data.py with {len(stations)} stations")
    
    # Also create a lightweight version that just references JSON
    print("\nCreating lightweight loader...")
    lightweight_code = '''"""
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
'''
    
    with open('station_loader.py', 'w', encoding='utf-8') as f:
        f.write(lightweight_code)
    
    print("✅ Created station_loader.py (lightweight JSON loader)")
    
    return len(stations)

# =============================================================================
# MAIN
# =============================================================================

if __name__ == "__main__":
    print("=" * 80)
    print("INTEGRATION SCRIPT: Complete Maharashtra Station Network")
    print("=" * 80)
    print()
    
    total = create_enhanced_stations_file()
    
    print()
    print("=" * 80)
    print("✨ INTEGRATION COMPLETE!")
    print("=" * 80)
    print()
    print("📁 Files Created:")
    print("   1. station_loader.py (lightweight JSON loader)")
    print("   2. enhanced_all_stations_data.py (full Python data - LARGE FILE)")
    print()
    print("🚀 Recommended Usage:")
    print("   Use station_loader.py in enhanced_live_station_service.py")
    print("   This loads stations from JSON on demand (more efficient)")
    print()
    print("📝 Update enhanced_live_station_service.py:")
    print("   Replace import statement with:")
    print("   from station_loader import ALL_STATIONS")
    print()
