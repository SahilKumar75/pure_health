"""
MAHARASHTRA WATER QUALITY MONITORING STATION GENERATOR
Generates comprehensive monitoring network matching GSDA and MPCB scale:
- 3,370 Baseline Groundwater Stations
- 975 Trend Groundwater Stations  
- ~150 Surface Water Stations
TOTAL: ~4,500 stations across 36 districts

This script programmatically generates ALL stations with realistic GPS coordinates.
"""

import json
import random
from station_generator_config import MAHARASHTRA_DISTRICTS

# =============================================================================
# CONFIGURATION
# =============================================================================

TARGET_BASELINE_STATIONS = 3370
TARGET_TREND_STATIONS = 975
TARGET_SURFACE_WATER_STATIONS = 150

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def generate_gps_offset(center_lat, center_lon, max_offset_km=50):
    """
    Generate GPS coordinates near a center point.
    max_offset_km: maximum distance from center in kilometers
    """
    # 1 degree latitude ≈ 111 km
    # 1 degree longitude ≈ 111 km * cos(latitude)
    lat_offset_deg = (random.uniform(-max_offset_km, max_offset_km) / 111.0)
    lon_offset_deg = (random.uniform(-max_offset_km, max_offset_km) / (111.0 * abs(0.9)))  # Approximate for Maharashtra latitude
    
    new_lat = round(center_lat + lat_offset_deg, 4)
    new_lon = round(center_lon + lon_offset_deg, 4)
    
    return new_lat, new_lon

def generate_station_id(district_code, station_type, monitoring_type, station_number):
    """
    Generate unique station ID
    Format: MH-<DISTRICT>-<TYPE>-<MONITORING>-<NUMBER>
    Example: MH-PUN-SW-001, MH-PUN-GW-BS-001, MH-PUN-GW-TR-001
    """
    type_code = "SW" if station_type == "surface_water" else "GW"
    monitoring_code = ""
    if station_type == "groundwater":
        monitoring_code = "-BS" if monitoring_type == "baseline" else "-TR"
    
    return f"MH-{district_code}-{type_code}{monitoring_code}-{station_number:03d}"

# =============================================================================
# DISTRICT CODE MAPPING
# =============================================================================

DISTRICT_CODES = {
    'Pune': 'PUN', 'Satara': 'SAT', 'Sangli': 'SAN', 'Solapur': 'SOL', 'Kolhapur': 'KOL',
    'Mumbai': 'MUM', 'Mumbai Suburban': 'MSUB', 'Thane': 'THA', 'Palghar': 'PAL', 
    'Raigad': 'RAI', 'Ratnagiri': 'RTN', 'Sindhudurg': 'SIN',
    'Nashik': 'NAS', 'Dhule': 'DHU', 'Nandurbar': 'NAN', 'Jalgaon': 'JAL', 'Ahmednagar': 'AHM',
    'Chhatrapati Sambhajinagar': 'CSBN', 'Beed': 'BED', 'Latur': 'LAT', 'Jalna': 'JLN', 
    'Osmanabad': 'OSM', 'Parbhani': 'PAR', 'Hingoli': 'HIN', 'Nanded': 'NAN',
    'Amravati': 'AMR', 'Akola': 'AKL', 'Buldhana': 'BUL', 'Washim': 'WAS', 'Yavatmal': 'YAV',
    'Nagpur': 'NAG', 'Wardha': 'WAR', 'Bhandara': 'BHA', 'Chandrapur': 'CHA', 
    'Gadchiroli': 'GAD', 'Gondia': 'GON'
}

# =============================================================================
# STATION GENERATION
# =============================================================================

def calculate_district_allocation(total_districts, target_stations):
    """
    Allocate stations to districts proportionally based on number of labs.
    Districts with more labs get more stations.
    """
    lab_counts = {district: len(data['labs']) for district, data in MAHARASHTRA_DISTRICTS.items()}
    total_labs = sum(lab_counts.values())
    
    allocation = {}
    remaining = target_stations
    
    for district in sorted(lab_counts.keys()):
        proportion = lab_counts[district] / total_labs
        allocated = int(target_stations * proportion)
        allocation[district] = max(allocated, 1)  # At least 1 station per district
        remaining -= allocation[district]
    
    # Distribute remaining stations to largest districts
    while remaining > 0:
        sorted_districts = sorted(lab_counts.keys(), key=lambda d: lab_counts[d], reverse=True)
        for district in sorted_districts:
            if remaining > 0:
                allocation[district] += 1
                remaining -= 1
            else:
                break
    
    return allocation

def generate_surface_water_stations():
    """Generate all surface water monitoring stations"""
    stations = []
    allocation = calculate_district_allocation(36, TARGET_SURFACE_WATER_STATIONS)
    
    for district, data in MAHARASHTRA_DISTRICTS.items():
        district_code = DISTRICT_CODES[district]
        num_stations = allocation[district]
        
        # Distribute across rivers and water bodies
        water_bodies = data['major_rivers'] + data['major_water_bodies']
        
        for i in range(num_stations):
            water_body = water_bodies[i % len(water_bodies)] if water_bodies else f"Water Body {i+1}"
            
            lat, lon = generate_gps_offset(data['center_lat'], data['center_lon'], max_offset_km=40)
            
            station = {
                'station_id': generate_station_id(district_code, 'surface_water', None, i+1),
                'name': f"{water_body} - {district}",
                'type': 'surface_water',
                'monitoring_type': 'routine',
                'district': district,
                'region': data['region'],
                'latitude': lat,
                'longitude': lon,
                'altitude': random.randint(200, 800),
                'water_body': water_body,
                'water_body_type': 'river' if water_body in data['major_rivers'] else 'reservoir',
                'sampling_frequency': 'monthly',
                'laboratory': data['labs'][0],  # Assign to district/regional lab
                'designated_use': random.choice(['drinking', 'irrigation', 'industrial', 'bathing']),
                'land_use': random.choice(['agricultural', 'urban', 'industrial', 'forest']),
                'population_nearby': random.randint(1000, 500000),
                'pollution_sources': random.sample(['domestic_sewage', 'industrial_effluent', 'agricultural_runoff', 'urban_runoff'], k=random.randint(1, 3))
            }
            stations.append(station)
    
    return stations

def generate_groundwater_baseline_stations():
    """Generate all groundwater baseline monitoring stations"""
    stations = []
    allocation = calculate_district_allocation(36, TARGET_BASELINE_STATIONS)
    
    for district, data in MAHARASHTRA_DISTRICTS.items():
        district_code = DISTRICT_CODES[district]
        num_stations = allocation[district]
        
        # Distribute across labs in district
        labs = data['labs']
        
        for i in range(num_stations):
            lab = labs[i % len(labs)]
            
            # Extract taluka/location from SDL name if available
            location = lab.split('SDL ')[-1] if 'SDL' in lab else district
            
            lat, lon = generate_gps_offset(data['center_lat'], data['center_lon'], max_offset_km=50)
            
            well_type = random.choice(['dug_well', 'bore_well', 'tube_well'])
            depth = random.randint(10, 80) if well_type == 'dug_well' else random.randint(30, 200)
            
            station = {
                'station_id': generate_station_id(district_code, 'groundwater', 'baseline', i+1),
                'name': f"{location} Baseline {i+1}",
                'type': 'groundwater',
                'monitoring_type': 'baseline',
                'district': district,
                'taluka': location,
                'region': data['region'],
                'latitude': lat,
                'longitude': lon,
                'altitude': random.randint(300, 900),
                'sampling_frequency': 'quarterly',
                'laboratory': lab,
                'designated_use': random.choice(['drinking', 'irrigation', 'domestic']),
                'land_use': random.choice(['agricultural', 'rural', 'urban', 'semi-urban']),
                'population_nearby': random.randint(500, 50000),
                'pollution_sources': random.sample(['agricultural_runoff', 'domestic_waste', 'industrial_seepage', 'natural'], k=random.randint(1, 2)),
                'well_type': well_type,
                'well_depth_m': depth,
                'water_level_mbgl': round(random.uniform(2, depth * 0.7), 2),
                'aquifer_type': random.choice(['alluvial', 'basaltic', 'hard_rock', 'semi-confined'])
            }
            stations.append(station)
    
    return stations

def generate_groundwater_trend_stations():
    """Generate all groundwater trend monitoring stations"""
    stations = []
    allocation = calculate_district_allocation(36, TARGET_TREND_STATIONS)
    
    for district, data in MAHARASHTRA_DISTRICTS.items():
        district_code = DISTRICT_CODES[district]
        num_stations = allocation[district]
        
        labs = data['labs']
        
        for i in range(num_stations):
            lab = labs[i % len(labs)]
            location = lab.split('SDL ')[-1] if 'SDL' in lab else district
            
            lat, lon = generate_gps_offset(data['center_lat'], data['center_lon'], max_offset_km=50)
            
            well_type = random.choice(['bore_well', 'tube_well', 'piezometer'])
            depth = random.randint(50, 250)
            
            station = {
                'station_id': generate_station_id(district_code, 'groundwater', 'trend', i+1),
                'name': f"{location} Trend {i+1}",
                'type': 'groundwater',
                'monitoring_type': 'trend',
                'district': district,
                'taluka': location,
                'region': data['region'],
                'latitude': lat,
                'longitude': lon,
                'altitude': random.randint(300, 900),
                'sampling_frequency': 'bi-annual',
                'laboratory': lab,
                'designated_use': 'monitoring',
                'land_use': random.choice(['agricultural', 'rural', 'urban']),
                'population_nearby': random.randint(500, 30000),
                'pollution_sources': ['natural', 'background_monitoring'],
                'well_type': well_type,
                'well_depth_m': depth,
                'water_level_mbgl': round(random.uniform(5, depth * 0.6), 2),
                'aquifer_type': random.choice(['alluvial', 'basaltic', 'hard_rock', 'confined'])
            }
            stations.append(station)
    
    return stations

# =============================================================================
# MAIN GENERATION
# =============================================================================

def generate_all_stations():
    """Generate complete monitoring network"""
    print("=" * 80)
    print("MAHARASHTRA WATER QUALITY MONITORING STATION GENERATOR")
    print("=" * 80)
    print()
    
    print("🌊 Generating Surface Water Stations...")
    surface_water_stations = generate_surface_water_stations()
    print(f"   ✅ Generated {len(surface_water_stations)} surface water stations")
    print()
    
    print("💧 Generating Groundwater Baseline Stations...")
    baseline_stations = generate_groundwater_baseline_stations()
    print(f"   ✅ Generated {len(baseline_stations)} groundwater baseline stations")
    print()
    
    print("📊 Generating Groundwater Trend Stations...")
    trend_stations = generate_groundwater_trend_stations()
    print(f"   ✅ Generated {len(trend_stations)} groundwater trend stations")
    print()
    
    all_stations = surface_water_stations + baseline_stations + trend_stations
    
    print("=" * 80)
    print(f"🎉 TOTAL STATIONS GENERATED: {len(all_stations)}")
    print("=" * 80)
    print()
    
    # Statistics
    print("📈 STATISTICS BY DISTRICT:")
    print("-" * 80)
    district_stats = {}
    for station in all_stations:
        district = station['district']
        if district not in district_stats:
            district_stats[district] = {'surface_water': 0, 'baseline': 0, 'trend': 0}
        
        if station['type'] == 'surface_water':
            district_stats[district]['surface_water'] += 1
        elif station['monitoring_type'] == 'baseline':
            district_stats[district]['baseline'] += 1
        else:
            district_stats[district]['trend'] += 1
    
    for district in sorted(district_stats.keys()):
        stats = district_stats[district]
        total = stats['surface_water'] + stats['baseline'] + stats['trend']
        print(f"{district:30s} | SW: {stats['surface_water']:3d} | BS: {stats['baseline']:3d} | TR: {stats['trend']:3d} | Total: {total:4d}")
    
    print("-" * 80)
    print()
    
    return all_stations

# =============================================================================
# SAVE TO FILES
# =============================================================================

def save_stations(stations):
    """Save stations to JSON files"""
    
    # Save complete dataset
    print("💾 Saving complete station database...")
    with open('complete_maharashtra_stations.json', 'w', encoding='utf-8') as f:
        json.dump(stations, f, indent=2, ensure_ascii=False)
    print(f"   ✅ Saved to: complete_maharashtra_stations.json")
    print()
    
    # Save by type for easier loading
    surface_water = [s for s in stations if s['type'] == 'surface_water']
    baseline = [s for s in stations if s.get('monitoring_type') == 'baseline']
    trend = [s for s in stations if s.get('monitoring_type') == 'trend']
    
    with open('surface_water_stations.json', 'w', encoding='utf-8') as f:
        json.dump(surface_water, f, indent=2, ensure_ascii=False)
    print(f"   ✅ Saved {len(surface_water)} surface water stations")
    
    with open('groundwater_baseline_stations.json', 'w', encoding='utf-8') as f:
        json.dump(baseline, f, indent=2, ensure_ascii=False)
    print(f"   ✅ Saved {len(baseline)} groundwater baseline stations")
    
    with open('groundwater_trend_stations.json', 'w', encoding='utf-8') as f:
        json.dump(trend, f, indent=2, ensure_ascii=False)
    print(f"   ✅ Saved {len(trend)} groundwater trend stations")
    print()

# =============================================================================
# RUN GENERATOR
# =============================================================================

if __name__ == "__main__":
    print()
    print("⚡ Starting station generation...")
    print(f"   Target: {TARGET_SURFACE_WATER_STATIONS} surface water stations")
    print(f"   Target: {TARGET_BASELINE_STATIONS} groundwater baseline stations")
    print(f"   Target: {TARGET_TREND_STATIONS} groundwater trend stations")
    print(f"   Total Target: {TARGET_SURFACE_WATER_STATIONS + TARGET_BASELINE_STATIONS + TARGET_TREND_STATIONS} stations")
    print()
    
    # Generate all stations
    all_stations = generate_all_stations()
    
    # Save to files
    save_stations(all_stations)
    
    print("=" * 80)
    print("✨ GENERATION COMPLETE!")
    print("=" * 80)
    print()
    print("📁 Generated Files:")
    print("   - complete_maharashtra_stations.json (all stations)")
    print("   - surface_water_stations.json")
    print("   - groundwater_baseline_stations.json")
    print("   - groundwater_trend_stations.json")
    print()
    print("🚀 Next Steps:")
    print("   1. Review generated stations")
    print("   2. Integrate with enhanced_live_station_service.py")
    print("   3. Test API with full station load")
    print()
