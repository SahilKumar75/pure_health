"""
ENHANCED HISTORICAL DATA GENERATOR WITH DISEASE PREDICTION
Generates 1 year of water quality data for all 4495 stations
Includes disease risk parameters for outbreak prediction

Disease Categories:
1. Waterborne Diseases: Cholera, Typhoid, Dysentery, Hepatitis A
2. Vector-borne Diseases: Malaria, Dengue, Chikungunya (water stagnation related)
3. Water-washed Diseases: Skin infections, Eye infections
"""

import json
import random
import math
from datetime import datetime, timedelta
from typing import Dict, List
import os

# Disease risk thresholds based on water quality parameters
DISEASE_RISK_THRESHOLDS = {
    'cholera': {
        'fecalColiform': 100,  # MPN/100ml
        'turbidity': 5,  # NTU
        'ph_min': 6.5,
        'ph_max': 8.5
    },
    'typhoid': {
        'fecalColiform': 50,
        'nitrates': 45,  # mg/L
        'totalColiform': 500
    },
    'dysentery': {
        'fecalColiform': 200,
        'turbidity': 10,
        'totalColiform': 1000
    },
    'hepatitis_a': {
        'fecalColiform': 10,
        'totalColiform': 50,
        'turbidity': 5
    },
    'malaria': {
        'stagnation_index': 0.6,  # 0-1 scale
        'temperature': 25,  # min °C
        'turbidity': 20  # high turbidity = stagnant water
    },
    'dengue': {
        'stagnation_index': 0.7,
        'temperature': 26,
        'rainfall_index': 0.5  # 0-1 scale
    },
    'skin_infections': {
        'turbidity': 15,
        'fecalColiform': 500,
        'temperature': 30
    }
}

class HistoricalDataGenerator:
    """Generate 1 year of historical data for disease prediction"""
    
    def __init__(self):
        self.start_date = datetime(2024, 11, 12)  # 1 year ago
        self.end_date = datetime(2025, 11, 12)  # today
        self.days = 365
        
    def generate_station_history(self, station: Dict) -> List[Dict]:
        """Generate 365 days of readings for a station"""
        readings = []
        station_id = station.get('station_id') or station.get('id')
        station_type = station.get('type', 'surface')
        district = station.get('district', 'Unknown')
        
        # Baseline parameters based on station type
        baseline = self._get_baseline_params(station_type, district)
        
        # Generate daily readings
        for day in range(self.days):
            date = self.start_date + timedelta(days=day)
            season = self._get_season(date.month)
            
            # Generate water quality reading
            reading = self._generate_daily_reading(
                station_id, date, season, baseline, station_type
            )
            
            # Calculate disease risks
            reading['disease_risks'] = self._calculate_disease_risks(reading)
            
            # Calculate outbreak probability
            reading['outbreak_probability'] = self._calculate_outbreak_probability(
                reading['disease_risks']
            )
            
            readings.append(reading)
        
        return readings
    
    def _get_baseline_params(self, station_type: str, district: str) -> Dict:
        """Get baseline parameters based on station type and location"""
        
        # Pollution-prone districts (industrial/urban)
        polluted_districts = [
            'Mumbai City', 'Mumbai Suburban', 'Thane', 'Pune', 
            'Nagpur', 'Nashik', 'Solapur', 'Aurangabad'
        ]
        
        is_polluted = district in polluted_districts
        
        if station_type == 'groundwater':
            return {
                'ph': 7.2 if not is_polluted else 6.8,
                'temperature': 26.0,
                'turbidity': 2.0 if not is_polluted else 8.0,
                'tds': 400 if not is_polluted else 800,
                'conductivity': 600 if not is_polluted else 1200,
                'totalHardness': 200 if not is_polluted else 350,
                'totalAlkalinity': 180 if not is_polluted else 280,
                'calcium': 50 if not is_polluted else 90,
                'magnesium': 25 if not is_polluted else 45,
                'sodium': 40 if not is_polluted else 80,
                'chlorides': 100 if not is_polluted else 300,
                'sulfates': 50 if not is_polluted else 150,
                'nitrates': 10 if not is_polluted else 40,
                'phosphates': 0.1 if not is_polluted else 0.5,
                'fluoride': 0.6 if not is_polluted else 1.5,
                'iron': 0.1 if not is_polluted else 0.8,
                'arsenic': 0.001 if not is_polluted else 0.008,
                'lead': 0.001 if not is_polluted else 0.008,
                'chromium': 0.001 if not is_polluted else 0.04,
                'cadmium': 0.0005 if not is_polluted else 0.002,
                'totalColiform': 10 if not is_polluted else 500,
                'fecalColiform': 0 if not is_polluted else 50,
                'dissolvedOxygen': 6.5,
                'bod': 1.5 if not is_polluted else 8.0,
                'cod': 10 if not is_polluted else 40,
            }
        else:  # surface water
            return {
                'ph': 7.5 if not is_polluted else 7.0,
                'temperature': 25.0,
                'turbidity': 5.0 if not is_polluted else 25.0,
                'tds': 300 if not is_polluted else 600,
                'conductivity': 450 if not is_polluted else 900,
                'totalHardness': 150 if not is_polluted else 280,
                'totalAlkalinity': 120 if not is_polluted else 220,
                'calcium': 40 if not is_polluted else 70,
                'magnesium': 20 if not is_polluted else 38,
                'sodium': 35 if not is_polluted else 70,
                'chlorides': 80 if not is_polluted else 250,
                'sulfates': 40 if not is_polluted else 120,
                'nitrates': 5 if not is_polluted else 30,
                'phosphates': 0.2 if not is_polluted else 1.5,
                'fluoride': 0.5 if not is_polluted else 1.2,
                'iron': 0.2 if not is_polluted else 1.5,
                'arsenic': 0.002 if not is_polluted else 0.01,
                'lead': 0.002 if not is_polluted else 0.01,
                'chromium': 0.002 if not is_polluted else 0.05,
                'cadmium': 0.001 if not is_polluted else 0.003,
                'totalColiform': 50 if not is_polluted else 2000,
                'fecalColiform': 5 if not is_polluted else 500,
                'dissolvedOxygen': 7.0 if not is_polluted else 4.0,
                'bod': 2.0 if not is_polluted else 15.0,
                'cod': 15 if not is_polluted else 80,
            }
    
    def _get_season(self, month: int) -> str:
        """Get season based on month"""
        if month in [3, 4, 5]:
            return 'Pre-Monsoon'
        elif month in [6, 7, 8, 9]:
            return 'Monsoon'
        elif month in [10, 11]:
            return 'Post-Monsoon'
        else:
            return 'Winter'
    
    def _generate_daily_reading(
        self, 
        station_id: str, 
        date: datetime, 
        season: str, 
        baseline: Dict,
        station_type: str
    ) -> Dict:
        """Generate a single day's reading"""
        
        # Seasonal variations
        season_factors = {
            'Pre-Monsoon': {'temp': 1.15, 'turbidity': 0.8, 'coliform': 1.3},
            'Monsoon': {'temp': 0.95, 'turbidity': 2.5, 'coliform': 3.0},
            'Post-Monsoon': {'temp': 1.0, 'turbidity': 1.5, 'coliform': 2.0},
            'Winter': {'temp': 0.85, 'turbidity': 0.7, 'coliform': 0.8}
        }
        
        factors = season_factors.get(season, {'temp': 1.0, 'turbidity': 1.0, 'coliform': 1.0})
        
        # Add random daily variation (±10%)
        def vary(value, factor=1.0):
            variation = random.uniform(0.9, 1.1)
            return round(value * factor * variation, 2)
        
        # Generate reading
        reading = {
            'stationId': station_id,
            'timestamp': date.isoformat(),
            'season': season,
            
            # Physical parameters
            'ph': vary(baseline['ph'], 1.0),
            'temperature': vary(baseline['temperature'], factors['temp']),
            'turbidity': vary(baseline['turbidity'], factors['turbidity']),
            
            # Chemical parameters
            'tds': vary(baseline['tds']),
            'conductivity': vary(baseline['conductivity']),
            'totalHardness': vary(baseline['totalHardness']),
            'totalAlkalinity': vary(baseline['totalAlkalinity']),
            'calcium': vary(baseline['calcium']),
            'magnesium': vary(baseline['magnesium']),
            'sodium': vary(baseline['sodium']),
            'chlorides': vary(baseline['chlorides']),
            'sulfates': vary(baseline['sulfates']),
            'nitrates': vary(baseline['nitrates']),
            'phosphates': vary(baseline['phosphates'], 1.0),
            'fluoride': vary(baseline['fluoride'], 1.0),
            'iron': vary(baseline['iron'], 1.0),
            
            # Heavy metals
            'arsenic': vary(baseline['arsenic'], 1.0),
            'lead': vary(baseline['lead'], 1.0),
            'chromium': vary(baseline['chromium'], 1.0),
            'cadmium': vary(baseline['cadmium'], 1.0),
            
            # Microbiological
            'totalColiform': int(vary(baseline['totalColiform'], factors['coliform'])),
            'fecalColiform': int(vary(baseline['fecalColiform'], factors['coliform'])),
            
            # Oxygen parameters
            'dissolvedOxygen': vary(baseline['dissolvedOxygen']),
            'bod': vary(baseline['bod']),
            'cod': vary(baseline['cod']),
            
            # Disease-specific parameters
            'stagnationIndex': self._calculate_stagnation_index(
                baseline['turbidity'] * factors['turbidity'],
                baseline['dissolvedOxygen'],
                season
            ),
            'rainfallIndex': self._get_rainfall_index(season, date),
        }
        
        # Calculate WQI
        reading['wqi'] = self._calculate_wqi(reading)
        reading['status'] = self._get_status(reading['wqi'])
        reading['waterQualityClass'] = self._get_water_class(reading['wqi'])
        
        return reading
    
    def _calculate_stagnation_index(self, turbidity: float, do: float, season: str) -> float:
        """Calculate water stagnation index (0-1)"""
        # High turbidity + low DO = high stagnation
        turb_score = min(turbidity / 50.0, 1.0)  # Normalize to 0-1
        do_score = max(0, (8 - do) / 8.0)  # Lower DO = higher stagnation
        
        # Monsoon has less stagnation due to flow
        season_factor = 0.5 if season == 'Monsoon' else 1.0
        
        index = ((turb_score + do_score) / 2) * season_factor
        return round(min(max(index, 0), 1), 3)
    
    def _get_rainfall_index(self, season: str, date: datetime) -> float:
        """Get rainfall index for the day (0-1)"""
        if season == 'Monsoon':
            # Vary throughout monsoon
            base = 0.7
            variation = math.sin(date.day * math.pi / 30) * 0.3
            return round(min(max(base + variation, 0), 1), 3)
        elif season == 'Post-Monsoon':
            return round(random.uniform(0.2, 0.4), 3)
        else:
            return round(random.uniform(0.0, 0.1), 3)
    
    def _calculate_disease_risks(self, reading: Dict) -> Dict:
        """Calculate risk scores for each disease (0-100)"""
        risks = {}
        
        # Cholera risk
        cholera_factors = []
        if reading['fecalColiform'] > DISEASE_RISK_THRESHOLDS['cholera']['fecalColiform']:
            cholera_factors.append(min(reading['fecalColiform'] / 500, 1.0))
        if reading['turbidity'] > DISEASE_RISK_THRESHOLDS['cholera']['turbidity']:
            cholera_factors.append(min(reading['turbidity'] / 20, 1.0))
        if not (6.5 <= reading['ph'] <= 8.5):
            cholera_factors.append(0.5)
        risks['cholera'] = int(sum(cholera_factors) / max(len(cholera_factors), 1) * 100)
        
        # Typhoid risk
        typhoid_factors = []
        if reading['fecalColiform'] > DISEASE_RISK_THRESHOLDS['typhoid']['fecalColiform']:
            typhoid_factors.append(min(reading['fecalColiform'] / 300, 1.0))
        if reading['nitrates'] > DISEASE_RISK_THRESHOLDS['typhoid']['nitrates']:
            typhoid_factors.append(min(reading['nitrates'] / 50, 1.0))
        if reading['totalColiform'] > DISEASE_RISK_THRESHOLDS['typhoid']['totalColiform']:
            typhoid_factors.append(min(reading['totalColiform'] / 2000, 1.0))
        risks['typhoid'] = int(sum(typhoid_factors) / max(len(typhoid_factors), 1) * 100)
        
        # Dysentery risk
        dysentery_factors = []
        if reading['fecalColiform'] > DISEASE_RISK_THRESHOLDS['dysentery']['fecalColiform']:
            dysentery_factors.append(min(reading['fecalColiform'] / 1000, 1.0))
        if reading['turbidity'] > DISEASE_RISK_THRESHOLDS['dysentery']['turbidity']:
            dysentery_factors.append(min(reading['turbidity'] / 30, 1.0))
        risks['dysentery'] = int(sum(dysentery_factors) / max(len(dysentery_factors), 1) * 100)
        
        # Hepatitis A risk
        hep_factors = []
        if reading['fecalColiform'] > DISEASE_RISK_THRESHOLDS['hepatitis_a']['fecalColiform']:
            hep_factors.append(min(reading['fecalColiform'] / 100, 1.0))
        if reading['totalColiform'] > DISEASE_RISK_THRESHOLDS['hepatitis_a']['totalColiform']:
            hep_factors.append(min(reading['totalColiform'] / 500, 1.0))
        risks['hepatitis_a'] = int(sum(hep_factors) / max(len(hep_factors), 1) * 100)
        
        # Malaria risk (vector-borne, related to water stagnation)
        malaria_factors = []
        if reading['stagnationIndex'] > DISEASE_RISK_THRESHOLDS['malaria']['stagnation_index']:
            malaria_factors.append(reading['stagnationIndex'])
        if reading['temperature'] > DISEASE_RISK_THRESHOLDS['malaria']['temperature']:
            malaria_factors.append(min((reading['temperature'] - 20) / 15, 1.0))
        risks['malaria'] = int(sum(malaria_factors) / max(len(malaria_factors), 1) * 100)
        
        # Dengue risk
        dengue_factors = []
        if reading['stagnationIndex'] > DISEASE_RISK_THRESHOLDS['dengue']['stagnation_index']:
            dengue_factors.append(reading['stagnationIndex'])
        if reading['temperature'] > DISEASE_RISK_THRESHOLDS['dengue']['temperature']:
            dengue_factors.append(min((reading['temperature'] - 20) / 15, 1.0))
        if reading['rainfallIndex'] > DISEASE_RISK_THRESHOLDS['dengue']['rainfall_index']:
            dengue_factors.append(reading['rainfallIndex'])
        risks['dengue'] = int(sum(dengue_factors) / max(len(dengue_factors), 1) * 100)
        
        # Skin infections
        skin_factors = []
        if reading['turbidity'] > DISEASE_RISK_THRESHOLDS['skin_infections']['turbidity']:
            skin_factors.append(min(reading['turbidity'] / 50, 1.0))
        if reading['fecalColiform'] > DISEASE_RISK_THRESHOLDS['skin_infections']['fecalColiform']:
            skin_factors.append(min(reading['fecalColiform'] / 2000, 1.0))
        risks['skin_infections'] = int(sum(skin_factors) / max(len(skin_factors), 1) * 100)
        
        return risks
    
    def _calculate_outbreak_probability(self, disease_risks: Dict) -> Dict:
        """Calculate probability of disease outbreak (0-100)"""
        # High risk threshold
        high_risk_threshold = 60
        
        # Count high-risk diseases
        high_risk_diseases = [d for d, risk in disease_risks.items() if risk >= high_risk_threshold]
        
        # Overall outbreak probability
        if len(high_risk_diseases) >= 3:
            probability = 'high'
            score = 85
        elif len(high_risk_diseases) >= 2:
            probability = 'medium'
            score = 60
        elif len(high_risk_diseases) >= 1:
            probability = 'low'
            score = 35
        else:
            probability = 'very_low'
            score = 10
        
        return {
            'level': probability,
            'score': score,
            'high_risk_diseases': high_risk_diseases,
            'disease_count': len(high_risk_diseases)
        }
    
    def _calculate_wqi(self, reading: Dict) -> float:
        """Calculate Water Quality Index"""
        # Simplified WQI calculation
        do_score = min(reading['dissolvedOxygen'] / 8.0, 1.0) * 100
        ph_score = (1 - abs(reading['ph'] - 7.0) / 7.0) * 100
        turb_score = max(0, (1 - reading['turbidity'] / 50.0)) * 100
        coliform_score = max(0, (1 - reading['fecalColiform'] / 1000.0)) * 100
        
        wqi = (do_score + ph_score + turb_score + coliform_score) / 4
        return round(wqi, 1)
    
    def _get_status(self, wqi: float) -> str:
        """Get water quality status from WQI"""
        if wqi >= 80:
            return 'good'
        elif wqi >= 60:
            return 'moderate'
        elif wqi >= 40:
            return 'poor'
        elif wqi >= 20:
            return 'very_poor'
        else:
            return 'critical'
    
    def _get_water_class(self, wqi: float) -> str:
        """Get water quality class"""
        if wqi >= 90:
            return 'Class A'
        elif wqi >= 75:
            return 'Class B'
        elif wqi >= 60:
            return 'Class C'
        elif wqi >= 45:
            return 'Class D'
        elif wqi >= 30:
            return 'Class E'
        else:
            return 'Unfit'


def generate_all_stations_historical_data():
    """Generate 1 year of historical data for all 4495 stations"""
    print("="*80)
    print("GENERATING 1 YEAR HISTORICAL DATA FOR ALL 4495 STATIONS")
    print("WITH DISEASE OUTBREAK PREDICTION PARAMETERS")
    print("="*80)
    
    # Load all stations
    from station_loader import ALL_STATIONS
    
    generator = HistoricalDataGenerator()
    
    # Create output directory
    output_dir = 'historical_data'
    os.makedirs(output_dir, exist_ok=True)
    
    print(f"\n📊 Total Stations: {len(ALL_STATIONS)}")
    print(f"📅 Date Range: {generator.start_date.date()} to {generator.end_date.date()}")
    print(f"📈 Readings per station: 365 days")
    print(f"💾 Output directory: {output_dir}/")
    
    # Process stations in batches (to avoid memory issues)
    batch_size = 100
    total_stations = len(ALL_STATIONS)
    
    for batch_start in range(0, total_stations, batch_size):
        batch_end = min(batch_start + batch_size, total_stations)
        batch_stations = ALL_STATIONS[batch_start:batch_end]
        
        print(f"\n🔄 Processing stations {batch_start+1} to {batch_end}...")
        
        batch_data = {}
        
        for station in batch_stations:
            station_id = station.get('station_id') or station.get('id')
            
            # Generate 365 days of readings
            readings = generator.generate_station_history(station)
            
            batch_data[station_id] = {
                'station': station,
                'readings': readings,
                'summary': {
                    'total_readings': len(readings),
                    'date_range': {
                        'start': readings[0]['timestamp'],
                        'end': readings[-1]['timestamp']
                    },
                    'avg_wqi': round(sum(r['wqi'] for r in readings) / len(readings), 1),
                    'high_risk_days': sum(1 for r in readings if r['outbreak_probability']['level'] in ['high', 'medium'])
                }
            }
        
        # Save batch to file
        batch_file = f'{output_dir}/historical_data_batch_{batch_start//batch_size + 1}.json'
        with open(batch_file, 'w') as f:
            json.dump(batch_data, f, indent=2)
        
        print(f"✅ Saved batch to {batch_file}")
    
    # Create index file
    index = {
        'generated_at': datetime.now().isoformat(),
        'total_stations': total_stations,
        'days_per_station': 365,
        'total_readings': total_stations * 365,
        'batches': (total_stations + batch_size - 1) // batch_size,
        'disease_categories': {
            'waterborne': ['cholera', 'typhoid', 'dysentery', 'hepatitis_a'],
            'vector_borne': ['malaria', 'dengue'],
            'water_washed': ['skin_infections']
        },
        'parameters': list(batch_data[list(batch_data.keys())[0]]['readings'][0].keys())
    }
    
    with open(f'{output_dir}/index.json', 'w') as f:
        json.dump(index, f, indent=2)
    
    print(f"\n{'='*80}")
    print("✅ HISTORICAL DATA GENERATION COMPLETE!")
    print(f"{'='*80}")
    print(f"\n📊 Summary:")
    print(f"   Total Stations: {total_stations}")
    print(f"   Total Readings: {total_stations * 365:,}")
    print(f"   Batches Created: {index['batches']}")
    print(f"   Output Directory: {output_dir}/")
    print(f"\n🦠 Disease Prediction Enabled:")
    print(f"   - Waterborne: Cholera, Typhoid, Dysentery, Hepatitis A")
    print(f"   - Vector-borne: Malaria, Dengue")
    print(f"   - Water-washed: Skin Infections")
    print(f"\n📁 Files Generated:")
    print(f"   - historical_data_batch_*.json (data files)")
    print(f"   - index.json (metadata)")
    

if __name__ == '__main__':
    generate_all_stations_historical_data()
