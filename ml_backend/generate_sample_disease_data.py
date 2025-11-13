"""
Generate a smaller sample dataset for Flutter app demonstration.
This creates data for only 50 stations (instead of 4495) with 90 days (instead of 365).
Perfect for testing and demo purposes without bloating the app size.
"""

import json
import os
from datetime import datetime, timedelta
from generate_historical_disease_data import HistoricalDataGenerator

def generate_sample_data():
    """Generate sample disease data for demo purposes"""
    
    print("=" * 70)
    print("GENERATING SAMPLE DISEASE DATA FOR FLUTTER APP")
    print("=" * 70)
    
    # Load stations
    from station_loader import ALL_STATIONS
    
    # Select 50 representative stations (mix of types and locations)
    sample_stations = ALL_STATIONS[:50]  # First 50 stations
    
    print(f"\n✅ Selected {len(sample_stations)} sample stations")
    
    # Create generator (it uses fixed dates internally)
    generator = HistoricalDataGenerator()
    
    # We'll only take the last 90 days of data
    days_per_station = 90
    
    # Create output directory
    output_dir = '../assets/historical_data'
    os.makedirs(output_dir, exist_ok=True)
    
    print(f"📊 Generating {days_per_station} days of data per station...")
    print(f"💾 Output directory: {output_dir}")
    
    # Generate data for all sample stations
    all_station_data = {}
    
    for i, station in enumerate(sample_stations, 1):
        station_history = generator.generate_station_history(station)
        station_id = station.get('station_id') or station.get('id', f'STATION_{i}')
        # Take only the last 90 days
        all_station_data[station_id] = {
            'station_info': station,
            'readings': station_history[-days_per_station:]  # Last 90 days only
        }
        
        if i % 10 == 0:
            print(f"   Processed {i}/{len(sample_stations)} stations...")
    
    # Save all data in a single file (it's small enough now)
    output_file = os.path.join(output_dir, 'sample_disease_data.json')
    with open(output_file, 'w') as f:
        json.dump(all_station_data, f)
    
    file_size_mb = os.path.getsize(output_file) / (1024 * 1024)
    
    print(f"\n✅ Saved sample data to: {output_file}")
    print(f"📦 File size: {file_size_mb:.2f} MB")
    
    # Create index file
    index_data = {
        'generated_at': datetime.now().isoformat(),
        'total_stations': len(sample_stations),
        'days_per_station': days_per_station,
        'total_readings': len(sample_stations) * days_per_station,
        'date_range': {
            'start': (datetime.now() - timedelta(days=days_per_station)).isoformat(),
            'end': datetime.now().isoformat()
        },
        'disease_categories': {
            'waterborne': ['cholera', 'typhoid', 'dysentery', 'hepatitis_a'],
            'vector_borne': ['malaria', 'dengue'],
            'water_washed': ['skin_infections']
        },
        'stations': [
            {
                'id': s.get('station_id') or s.get('id', f'STATION_{i+1}'),
                'name': s.get('name', 'Unknown'),
                'district': s.get('district', 'Unknown'),
                'type': s.get('type', 'surface')
            }
            for i, s in enumerate(sample_stations)
        ]
    }
    
    index_file = os.path.join(output_dir, 'sample_index.json')
    with open(index_file, 'w') as f:
        json.dump(index_data, f, indent=2)
    
    print(f"✅ Saved index to: {index_file}")
    
    # Print summary
    print("\n" + "=" * 70)
    print("SAMPLE DATA GENERATION COMPLETE")
    print("=" * 70)
    print(f"\n📊 Statistics:")
    print(f"   Total Stations: {len(sample_stations)}")
    print(f"   Days per Station: {days_per_station}")
    print(f"   Total Readings: {len(sample_stations) * days_per_station:,}")
    print(f"   File Size: {file_size_mb:.2f} MB")
    print(f"\n💡 This sample dataset is perfect for:")
    print(f"   - Flutter app demonstration")
    print(f"   - UI testing and development")
    print(f"   - Quick loading in web browsers")
    print(f"\n📝 The full dataset (4495 stations × 365 days) remains in:")
    print(f"   ml_backend/historical_data/ (for ML model training)")
    print("=" * 70)

if __name__ == '__main__':
    generate_sample_data()
