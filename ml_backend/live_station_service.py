"""
Live Water Station Simulation Service
Acts as a backend data source for real-time water quality monitoring
Mimics Maharashtra Pollution Control Board (MPCB) monitoring stations
"""

import random
import time
from datetime import datetime, timedelta
from typing import Dict, List, Optional
import threading
import json


class LiveStationService:
    """
    Simulates real-time water quality monitoring stations across Maharashtra.
    Generates realistic data with time-based variations.
    """
    
    def __init__(self):
        self.stations = self._initialize_stations()
        self.station_data: Dict[str, Dict] = {}
        self.update_thread: Optional[threading.Thread] = None
        self.running = False
        self.update_interval = 900  # 15 minutes in seconds (like real MPCB stations)
        
        # Initialize with first readings
        self._update_all_stations()
    
    def _initialize_stations(self) -> List[Dict]:
        """Initialize all 20 monitoring stations across Maharashtra"""
        return [
            # Mumbai Metropolitan Region
            {
                'id': 'MH-MUM-001',
                'name': 'Bandra Reclamation',
                'district': 'Mumbai',
                'region': 'Konkan',
                'location': 'Bandra West',
                'latitude': 19.0596,
                'longitude': 72.8295,
                'waterSource': 'Arabian Sea - Coastal',
                'type': 'Coastal Monitoring',
                'baseParameters': {
                    'ph': 7.8,
                    'turbidity': 12.0,
                    'dissolvedOxygen': 6.5,
                    'temperature': 27.0,
                    'conductivity': 850.0,
                    'tds': 450.0,
                    'bod': 4.5,
                    'cod': 25.0,
                    'chlorides': 380.0,
                    'nitrates': 8.5,
                }
            },
            {
                'id': 'MH-MUM-002',
                'name': 'Mithi River - Mahim',
                'district': 'Mumbai',
                'region': 'Konkan',
                'location': 'Mahim',
                'latitude': 19.0369,
                'longitude': 72.8406,
                'waterSource': 'Mithi River',
                'type': 'River Monitoring',
                'baseParameters': {
                    'ph': 7.2,
                    'turbidity': 18.0,
                    'dissolvedOxygen': 5.2,
                    'temperature': 28.0,
                    'conductivity': 920.0,
                    'tds': 580.0,
                    'bod': 6.8,
                    'cod': 35.0,
                    'chlorides': 420.0,
                    'nitrates': 12.0,
                }
            },
            {
                'id': 'MH-MUM-003',
                'name': 'Powai Lake',
                'district': 'Mumbai',
                'region': 'Konkan',
                'location': 'Powai',
                'latitude': 19.1197,
                'longitude': 72.9059,
                'waterSource': 'Powai Lake',
                'type': 'Lake Monitoring',
                'baseParameters': {
                    'ph': 7.4,
                    'turbidity': 8.5,
                    'dissolvedOxygen': 7.2,
                    'temperature': 26.5,
                    'conductivity': 680.0,
                    'tds': 380.0,
                    'bod': 3.2,
                    'cod': 18.0,
                    'chlorides': 280.0,
                    'nitrates': 6.5,
                }
            },
            # Pune Region
            {
                'id': 'MH-PUN-001',
                'name': 'Mula River - Sangam Bridge',
                'district': 'Pune',
                'region': 'Pune',
                'location': 'Sangamwadi',
                'latitude': 18.5277,
                'longitude': 73.8642,
                'waterSource': 'Mula River',
                'type': 'River Monitoring',
                'baseParameters': {
                    'ph': 7.3,
                    'turbidity': 10.0,
                    'dissolvedOxygen': 6.8,
                    'temperature': 25.0,
                    'conductivity': 720.0,
                    'tds': 420.0,
                    'bod': 4.0,
                    'cod': 22.0,
                    'chlorides': 320.0,
                    'nitrates': 9.0,
                }
            },
            {
                'id': 'MH-PUN-002',
                'name': 'Mutha River - Deccan',
                'district': 'Pune',
                'region': 'Pune',
                'location': 'Deccan Gymkhana',
                'latitude': 18.5074,
                'longitude': 73.8372,
                'waterSource': 'Mutha River',
                'type': 'River Monitoring',
                'baseParameters': {
                    'ph': 7.4,
                    'turbidity': 9.0,
                    'dissolvedOxygen': 7.0,
                    'temperature': 24.5,
                    'conductivity': 700.0,
                    'tds': 400.0,
                    'bod': 3.8,
                    'cod': 20.0,
                    'chlorides': 300.0,
                    'nitrates': 8.0,
                }
            },
            {
                'id': 'MH-PUN-003',
                'name': 'Khadakwasla Reservoir',
                'district': 'Pune',
                'region': 'Pune',
                'location': 'Khadakwasla',
                'latitude': 18.4367,
                'longitude': 73.7584,
                'waterSource': 'Khadakwasla Dam',
                'type': 'Reservoir Monitoring',
                'baseParameters': {
                    'ph': 7.6,
                    'turbidity': 6.5,
                    'dissolvedOxygen': 7.8,
                    'temperature': 23.5,
                    'conductivity': 580.0,
                    'tds': 320.0,
                    'bod': 2.5,
                    'cod': 15.0,
                    'chlorides': 220.0,
                    'nitrates': 5.5,
                }
            },
            # Nagpur Region
            {
                'id': 'MH-NAG-001',
                'name': 'Nag River - Seminary Hills',
                'district': 'Nagpur',
                'region': 'Vidarbha',
                'location': 'Seminary Hills',
                'latitude': 21.1346,
                'longitude': 79.0820,
                'waterSource': 'Nag River',
                'type': 'River Monitoring',
                'baseParameters': {
                    'ph': 7.1,
                    'turbidity': 14.0,
                    'dissolvedOxygen': 5.8,
                    'temperature': 27.5,
                    'conductivity': 780.0,
                    'tds': 480.0,
                    'bod': 5.2,
                    'cod': 28.0,
                    'chlorides': 350.0,
                    'nitrates': 10.5,
                }
            },
            {
                'id': 'MH-NAG-002',
                'name': 'Ambazari Lake',
                'district': 'Nagpur',
                'region': 'Vidarbha',
                'location': 'Ambazari',
                'latitude': 21.1206,
                'longitude': 79.0473,
                'waterSource': 'Ambazari Lake',
                'type': 'Lake Monitoring',
                'baseParameters': {
                    'ph': 7.5,
                    'turbidity': 7.5,
                    'dissolvedOxygen': 7.4,
                    'temperature': 26.0,
                    'conductivity': 650.0,
                    'tds': 360.0,
                    'bod': 3.0,
                    'cod': 17.0,
                    'chlorides': 260.0,
                    'nitrates': 6.8,
                }
            },
            # Nashik Region
            {
                'id': 'MH-NAS-001',
                'name': 'Godavari River - Panchavati',
                'district': 'Nashik',
                'region': 'Nashik',
                'location': 'Panchavati',
                'latitude': 19.9975,
                'longitude': 73.7898,
                'waterSource': 'Godavari River',
                'type': 'River Monitoring',
                'baseParameters': {
                    'ph': 7.7,
                    'turbidity': 8.0,
                    'dissolvedOxygen': 7.5,
                    'temperature': 24.0,
                    'conductivity': 620.0,
                    'tds': 350.0,
                    'bod': 2.8,
                    'cod': 16.0,
                    'chlorides': 240.0,
                    'nitrates': 6.0,
                }
            },
            {
                'id': 'MH-NAS-002',
                'name': 'Gangapur Dam',
                'district': 'Nashik',
                'region': 'Nashik',
                'location': 'Gangapur',
                'latitude': 20.0281,
                'longitude': 73.9372,
                'waterSource': 'Gangapur Reservoir',
                'type': 'Reservoir Monitoring',
                'baseParameters': {
                    'ph': 7.8,
                    'turbidity': 5.5,
                    'dissolvedOxygen': 8.0,
                    'temperature': 23.0,
                    'conductivity': 540.0,
                    'tds': 290.0,
                    'bod': 2.2,
                    'cod': 13.0,
                    'chlorides': 200.0,
                    'nitrates': 4.5,
                }
            },
            # Aurangabad Region
            {
                'id': 'MH-AUR-001',
                'name': 'Kham River',
                'district': 'Aurangabad',
                'region': 'Marathwada',
                'location': 'Aurangabad City',
                'latitude': 19.8762,
                'longitude': 75.3433,
                'waterSource': 'Kham River',
                'type': 'River Monitoring',
                'baseParameters': {
                    'ph': 7.2,
                    'turbidity': 11.0,
                    'dissolvedOxygen': 6.2,
                    'temperature': 26.5,
                    'conductivity': 740.0,
                    'tds': 440.0,
                    'bod': 4.2,
                    'cod': 24.0,
                    'chlorides': 330.0,
                    'nitrates': 9.5,
                }
            },
            {
                'id': 'MH-AUR-002',
                'name': 'Jayakwadi Dam',
                'district': 'Aurangabad',
                'region': 'Marathwada',
                'location': 'Paithan',
                'latitude': 19.4858,
                'longitude': 75.3803,
                'waterSource': 'Jayakwadi Reservoir',
                'type': 'Reservoir Monitoring',
                'baseParameters': {
                    'ph': 7.6,
                    'turbidity': 6.0,
                    'dissolvedOxygen': 7.6,
                    'temperature': 25.0,
                    'conductivity': 600.0,
                    'tds': 340.0,
                    'bod': 2.6,
                    'cod': 15.5,
                    'chlorides': 230.0,
                    'nitrates': 5.8,
                }
            },
            # Kolhapur Region
            {
                'id': 'MH-KOL-001',
                'name': 'Panchganga River',
                'district': 'Kolhapur',
                'region': 'Western Maharashtra',
                'location': 'Kolhapur City',
                'latitude': 16.7050,
                'longitude': 74.2433,
                'waterSource': 'Panchganga River',
                'type': 'River Monitoring',
                'baseParameters': {
                    'ph': 7.3,
                    'turbidity': 9.5,
                    'dissolvedOxygen': 7.0,
                    'temperature': 24.5,
                    'conductivity': 680.0,
                    'tds': 390.0,
                    'bod': 3.5,
                    'cod': 19.0,
                    'chlorides': 290.0,
                    'nitrates': 7.5,
                }
            },
            # Solapur Region
            {
                'id': 'MH-SOL-001',
                'name': 'Sina River',
                'district': 'Solapur',
                'region': 'Western Maharashtra',
                'location': 'Solapur City',
                'latitude': 17.6599,
                'longitude': 75.9064,
                'waterSource': 'Sina River',
                'type': 'River Monitoring',
                'baseParameters': {
                    'ph': 7.1,
                    'turbidity': 12.5,
                    'dissolvedOxygen': 6.0,
                    'temperature': 27.0,
                    'conductivity': 760.0,
                    'tds': 460.0,
                    'bod': 4.8,
                    'cod': 26.0,
                    'chlorides': 360.0,
                    'nitrates': 10.0,
                }
            },
            # Thane Region
            {
                'id': 'MH-THA-001',
                'name': 'Ulhas River - Thane',
                'district': 'Thane',
                'region': 'Konkan',
                'location': 'Thane City',
                'latitude': 19.2183,
                'longitude': 72.9781,
                'waterSource': 'Ulhas River',
                'type': 'River Monitoring',
                'baseParameters': {
                    'ph': 7.2,
                    'turbidity': 13.0,
                    'dissolvedOxygen': 6.3,
                    'temperature': 27.5,
                    'conductivity': 790.0,
                    'tds': 470.0,
                    'bod': 5.0,
                    'cod': 27.0,
                    'chlorides': 370.0,
                    'nitrates': 9.8,
                }
            },
            {
                'id': 'MH-THA-002',
                'name': 'Tansa Lake',
                'district': 'Thane',
                'region': 'Konkan',
                'location': 'Tansa',
                'latitude': 19.7333,
                'longitude': 73.2333,
                'waterSource': 'Tansa Reservoir',
                'type': 'Reservoir Monitoring',
                'baseParameters': {
                    'ph': 7.6,
                    'turbidity': 5.8,
                    'dissolvedOxygen': 7.9,
                    'temperature': 24.0,
                    'conductivity': 560.0,
                    'tds': 310.0,
                    'bod': 2.3,
                    'cod': 14.0,
                    'chlorides': 210.0,
                    'nitrates': 5.2,
                }
            },
            # Raigad Region
            {
                'id': 'MH-RAI-001',
                'name': 'Patalganga River',
                'district': 'Raigad',
                'region': 'Konkan',
                'location': 'Panvel',
                'latitude': 18.9894,
                'longitude': 73.1175,
                'waterSource': 'Patalganga River',
                'type': 'River Monitoring',
                'baseParameters': {
                    'ph': 7.3,
                    'turbidity': 10.5,
                    'dissolvedOxygen': 6.6,
                    'temperature': 26.0,
                    'conductivity': 710.0,
                    'tds': 410.0,
                    'bod': 3.9,
                    'cod': 21.0,
                    'chlorides': 310.0,
                    'nitrates': 8.2,
                }
            },
            # Satara Region
            {
                'id': 'MH-SAT-001',
                'name': 'Krishna River - Karad',
                'district': 'Satara',
                'region': 'Western Maharashtra',
                'location': 'Karad',
                'latitude': 17.2892,
                'longitude': 74.1817,
                'waterSource': 'Krishna River',
                'type': 'River Monitoring',
                'baseParameters': {
                    'ph': 7.5,
                    'turbidity': 7.8,
                    'dissolvedOxygen': 7.3,
                    'temperature': 24.0,
                    'conductivity': 640.0,
                    'tds': 370.0,
                    'bod': 3.1,
                    'cod': 17.5,
                    'chlorides': 270.0,
                    'nitrates': 6.7,
                }
            },
            # Ahmednagar Region
            {
                'id': 'MH-AHM-001',
                'name': 'Pravara River',
                'district': 'Ahmednagar',
                'region': 'Western Maharashtra',
                'location': 'Sangamner',
                'latitude': 19.5664,
                'longitude': 74.2159,
                'waterSource': 'Pravara River',
                'type': 'River Monitoring',
                'baseParameters': {
                    'ph': 7.4,
                    'turbidity': 8.8,
                    'dissolvedOxygen': 7.1,
                    'temperature': 25.0,
                    'conductivity': 670.0,
                    'tds': 385.0,
                    'bod': 3.3,
                    'cod': 18.5,
                    'chlorides': 285.0,
                    'nitrates': 7.2,
                }
            },
            # Amravati Region
            {
                'id': 'MH-AMR-001',
                'name': 'Pedhi River',
                'district': 'Amravati',
                'region': 'Vidarbha',
                'location': 'Amravati City',
                'latitude': 20.9320,
                'longitude': 77.7523,
                'waterSource': 'Pedhi River',
                'type': 'River Monitoring',
                'baseParameters': {
                    'ph': 7.2,
                    'turbidity': 11.5,
                    'dissolvedOxygen': 6.4,
                    'temperature': 27.0,
                    'conductivity': 750.0,
                    'tds': 450.0,
                    'bod': 4.5,
                    'cod': 25.0,
                    'chlorides': 340.0,
                    'nitrates': 9.3,
                }
            },
        ]
    
    def _get_hour_factor(self, hour: int) -> float:
        """Get variation factor based on time of day"""
        if 6 <= hour < 10:
            return 0.8  # Early morning - cleaner
        elif 10 <= hour < 16:
            return 1.2  # Midday - more activity
        elif 16 <= hour < 20:
            return 1.4  # Evening - peak activity
        else:
            return 0.9  # Night - minimal activity
    
    def _get_season_factor(self, month: int) -> float:
        """Get variation factor based on season"""
        if 6 <= month <= 9:
            return 1.5  # Monsoon - higher turbidity
        elif 3 <= month <= 5:
            return 1.2  # Summer
        else:
            return 1.0  # Winter
    
    def _random_variation(self, range_val: float) -> float:
        """Generate random variation within range"""
        return (random.random() - 0.5) * 2 * range_val
    
    def _calculate_wqi(self, params: Dict) -> float:
        """Calculate Water Quality Index based on parameters"""
        ph = params['pH']
        turbidity = params['turbidity']
        do_ = params['dissolvedOxygen']
        tds = params['tds']
        bod = params['bod']
        chlorides = params['chlorides']
        nitrates = params['nitrates']
        
        # Ideal pH is 7.0
        ph_index = 100 - (abs(ph - 7.0) / 1.5 * 100)
        ph_index = max(0, min(100, ph_index))
        
        # Calculate sub-indices
        turbidity_index = max(0, 100 - (turbidity / 50.0 * 100))
        do_index = min(100, (do_ / 12.0) * 100)
        tds_index = max(0, 100 - (tds / 1500.0 * 100))
        bod_index = max(0, 100 - (bod / 20.0 * 100))
        chlorides_index = max(0, 100 - (chlorides / 600.0 * 100))
        nitrates_index = max(0, 100 - (nitrates / 50.0 * 100))
        
        # Weighted average
        wqi = (ph_index * 0.20 + 
               turbidity_index * 0.15 + 
               do_index * 0.20 + 
               tds_index * 0.15 + 
               bod_index * 0.10 + 
               chlorides_index * 0.10 + 
               nitrates_index * 0.10)
        
        return max(0, min(100, wqi))
    
    def _get_water_quality_status(self, wqi: float) -> str:
        """Get water quality status based on WQI"""
        if wqi >= 90:
            return 'Excellent'
        elif wqi >= 70:
            return 'Good'
        elif wqi >= 50:
            return 'Fair'
        elif wqi >= 25:
            return 'Poor'
        else:
            return 'Very Poor'
    
    def _check_alerts(self, params: Dict) -> List[str]:
        """Check for parameter alerts"""
        alerts = []
        
        if params['pH'] < 6.5 or params['pH'] > 8.5:
            alerts.append('pH outside safe range (6.5-8.5)')
        if params['turbidity'] > 10:
            alerts.append('High turbidity (>10 NTU)')
        if params['dissolvedOxygen'] < 5:
            alerts.append('Low dissolved oxygen (<5 mg/L)')
        if params['tds'] > 500:
            alerts.append('High TDS (>500 mg/L)')
        if params['bod'] > 3:
            alerts.append('High BOD (>3 mg/L)')
        if params['chlorides'] > 250:
            alerts.append('High chlorides (>250 mg/L)')
        if params['nitrates'] > 45:
            alerts.append('High nitrates (>45 mg/L)')
        
        return alerts
    
    def _generate_station_reading(self, station: Dict) -> Dict:
        """Generate realistic reading for a station"""
        now = datetime.now()
        base_params = station['baseParameters']
        
        # Time-based factors
        hour_factor = self._get_hour_factor(now.hour)
        season_factor = self._get_season_factor(now.month)
        
        # Generate parameters with realistic variations
        ph = max(6.0, min(9.0, base_params['ph'] + self._random_variation(0.3) * hour_factor))
        turbidity = max(0.1, min(50.0, base_params['turbidity'] + self._random_variation(5.0) * hour_factor * season_factor))
        dissolved_oxygen = max(2.0, min(12.0, base_params['dissolvedOxygen'] + self._random_variation(1.5) * hour_factor))
        temperature = max(15.0, min(35.0, base_params['temperature'] + self._random_variation(3.0) * season_factor))
        conductivity = max(50.0, min(2000.0, base_params['conductivity'] + self._random_variation(100.0)))
        tds = max(50.0, min(1500.0, base_params['tds'] + self._random_variation(50.0)))
        bod = max(0.5, min(20.0, base_params['bod'] + self._random_variation(1.0) * season_factor))
        cod = max(5.0, min(100.0, base_params['cod'] + self._random_variation(5.0) * season_factor))
        chlorides = max(10.0, min(600.0, base_params['chlorides'] + self._random_variation(20.0)))
        nitrates = max(0.1, min(50.0, base_params['nitrates'] + self._random_variation(5.0)))
        
        parameters = {
            'pH': round(ph, 2),
            'turbidity': round(turbidity, 2),
            'dissolvedOxygen': round(dissolved_oxygen, 2),
            'temperature': round(temperature, 1),
            'conductivity': round(conductivity, 1),
            'tds': round(tds, 1),
            'bod': round(bod, 2),
            'cod': round(cod, 2),
            'chlorides': round(chlorides, 1),
            'nitrates': round(nitrates, 2),
        }
        
        wqi = self._calculate_wqi(parameters)
        status = self._get_water_quality_status(wqi)
        alerts = self._check_alerts(parameters)
        
        return {
            'stationId': station['id'],
            'stationName': station['name'],
            'location': station['location'],
            'latitude': station['latitude'],
            'longitude': station['longitude'],
            'timestamp': now.isoformat(),
            'parameters': parameters,
            'wqi': round(wqi, 1),
            'status': status,
            'alerts': alerts,
            'district': station['district'],
            'region': station['region'],
            'waterSource': station['waterSource'],
            'stationType': station['type'],
        }
    
    def _update_all_stations(self):
        """Update readings for all stations"""
        for station in self.stations:
            reading = self._generate_station_reading(station)
            self.station_data[station['id']] = reading
    
    def _background_update_loop(self):
        """Background thread that updates station data periodically"""
        while self.running:
            time.sleep(self.update_interval)
            if self.running:
                self._update_all_stations()
                print(f"🔄 Updated all stations at {datetime.now().strftime('%H:%M:%S')}")
    
    def start_simulation(self, interval_seconds: int = 900):
        """Start the live simulation with specified interval"""
        if self.running:
            return
        
        self.update_interval = interval_seconds
        self.running = True
        self.update_thread = threading.Thread(target=self._background_update_loop, daemon=True)
        self.update_thread.start()
        print(f"✅ Live simulation started (updates every {interval_seconds}s)")
    
    def stop_simulation(self):
        """Stop the live simulation"""
        self.running = False
        if self.update_thread:
            self.update_thread.join(timeout=2)
        print("🛑 Live simulation stopped")
    
    def get_all_stations(self) -> List[Dict]:
        """Get list of all stations"""
        return self.stations
    
    def get_station_data(self, station_id: str) -> Optional[Dict]:
        """Get current data for a specific station"""
        return self.station_data.get(station_id)
    
    def get_all_station_data(self) -> Dict[str, Dict]:
        """Get current data for all stations"""
        return self.station_data
    
    def get_stations_by_district(self, district: str) -> List[Dict]:
        """Get all stations in a district"""
        return [s for s in self.stations if s['district'] == district]
    
    def get_stations_by_status(self, status: str) -> List[Dict]:
        """Get all stations with a specific water quality status"""
        return [
            data for data in self.station_data.values() 
            if data['status'] == status
        ]
    
    def get_summary_statistics(self) -> Dict:
        """Get summary statistics across all stations"""
        total = len(self.station_data)
        if total == 0:
            return {}
        
        statuses = {}
        avg_wqi = 0
        alerts_count = 0
        
        for data in self.station_data.values():
            status = data['status']
            statuses[status] = statuses.get(status, 0) + 1
            avg_wqi += data['wqi']
            alerts_count += len(data['alerts'])
        
        return {
            'total_stations': total,
            'average_wqi': round(avg_wqi / total, 1),
            'status_distribution': statuses,
            'total_alerts': alerts_count,
            'last_update': datetime.now().isoformat()
        }


# Global instance
_station_service = None


def get_station_service() -> LiveStationService:
    """Get or create the global station service instance"""
    global _station_service
    if _station_service is None:
        _station_service = LiveStationService()
    return _station_service
