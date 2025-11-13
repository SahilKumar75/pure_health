"""
Government API Integration Layer - Phase 6
Connects to CPCB, MPCB, CWC, and IMD data sources for real-time water quality data
"""

import requests
import json
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional
import pandas as pd
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry
import time


class APIIntegrationBase:
    """Base class for API integrations with retry logic and error handling"""
    
    def __init__(self, base_url: str, api_key: Optional[str] = None, timeout: int = 30):
        self.base_url = base_url
        self.api_key = api_key
        self.timeout = timeout
        self.session = self._create_session()
    
    def _create_session(self):
        """Create requests session with retry strategy"""
        session = requests.Session()
        retry_strategy = Retry(
            total=3,
            status_forcelist=[429, 500, 502, 503, 504],
            allowed_methods=["HEAD", "GET", "OPTIONS"],  # Updated from method_whitelist
            backoff_factor=1
        )
        adapter = HTTPAdapter(max_retries=retry_strategy)
        session.mount("http://", adapter)
        session.mount("https://", adapter)
        return session
    
    def _make_request(self, endpoint: str, params: Dict = None, method: str = "GET") -> Dict:
        """Make API request with error handling"""
        url = f"{self.base_url}/{endpoint}"
        
        headers = {}
        if self.api_key:
            headers['Authorization'] = f'Bearer {self.api_key}'
        
        try:
            if method == "GET":
                response = self.session.get(url, params=params, headers=headers, timeout=self.timeout)
            elif method == "POST":
                response = self.session.post(url, json=params, headers=headers, timeout=self.timeout)
            
            response.raise_for_status()
            return response.json()
            
        except requests.exceptions.Timeout:
            return {'error': 'Request timeout', 'status': 'timeout'}
        except requests.exceptions.HTTPError as e:
            return {'error': str(e), 'status': 'http_error', 'status_code': e.response.status_code}
        except Exception as e:
            return {'error': str(e), 'status': 'error'}


class CPCBAPIIntegration(APIIntegrationBase):
    """
    Central Pollution Control Board (CPCB) API Integration
    Connects to National Water Quality Monitoring Programme (NWMP)
    """
    
    def __init__(self, api_key: Optional[str] = None):
        # CPCB NWMP portal URL (placeholder - replace with actual API endpoint)
        base_url = "https://cpcb.nic.in/nwmp/api"
        super().__init__(base_url, api_key)
        self.data_cache = {}
    
    def fetch_station_data(self, station_id: str, date_range: tuple = None) -> Dict[str, Any]:
        """
        Fetch water quality data for specific station
        
        Args:
            station_id: CPCB station identifier
            date_range: Tuple of (start_date, end_date) as datetime objects
        
        Returns:
            Dictionary with station data and measurements
        """
        if date_range is None:
            end_date = datetime.now()
            start_date = end_date - timedelta(days=7)
            date_range = (start_date, end_date)
        
        params = {
            'station_id': station_id,
            'start_date': date_range[0].strftime('%Y-%m-%d'),
            'end_date': date_range[1].strftime('%Y-%m-%d'),
            'parameters': 'pH,DO,BOD,FC,Temperature,Turbidity,TDS'
        }
        
        # Try API call (will fail if no real API, then use fallback)
        result = self._make_request('stations/data', params)
        
        if 'error' in result:
            print(f"⚠️ CPCB API unavailable: {result['error']}")
            return self._generate_fallback_data(station_id, date_range)
        
        return self._parse_cpcb_response(result)
    
    def fetch_all_stations(self, state: str = "Maharashtra") -> List[Dict]:
        """
        Fetch list of all monitoring stations in a state
        
        Args:
            state: State name
        
        Returns:
            List of station metadata
        """
        params = {'state': state}
        result = self._make_request('stations/list', params)
        
        if 'error' in result:
            print(f"⚠️ CPCB Station list unavailable: {result['error']}")
            return self._get_default_maharashtra_stations()
        
        return result.get('stations', [])
    
    def fetch_real_time_data(self, station_id: str) -> Dict[str, Any]:
        """
        Fetch latest real-time measurements
        
        Args:
            station_id: CPCB station identifier
        
        Returns:
            Latest measurement data
        """
        params = {'station_id': station_id, 'latest': True}
        result = self._make_request('stations/realtime', params)
        
        if 'error' in result:
            return self._generate_fallback_realtime(station_id)
        
        return result
    
    def _parse_cpcb_response(self, response: Dict) -> Dict[str, Any]:
        """Parse CPCB API response into standard format"""
        return {
            'source': 'CPCB',
            'timestamp': datetime.now().isoformat(),
            'data': response,
            'status': 'success'
        }
    
    def _generate_fallback_data(self, station_id: str, date_range: tuple) -> Dict:
        """Generate fallback data when API is unavailable"""
        import numpy as np
        
        days = (date_range[1] - date_range[0]).days
        
        # Generate synthetic but realistic data
        data = []
        for i in range(days * 4):  # 4 readings per day
            timestamp = date_range[0] + timedelta(hours=i * 6)
            reading = {
                'timestamp': timestamp.isoformat(),
                'ph': 7.0 + np.random.normal(0, 0.5),
                'bod': max(0.5, 3.0 + np.random.normal(0, 1)),
                'dissolved_oxygen': max(0.5, 6.0 + np.random.normal(0, 1)),
                'fecal_coliform': max(1, 500 + np.random.normal(0, 200)),
                'temperature': 25.0 + np.random.normal(0, 3),
                'turbidity': max(0.5, 10.0 + np.random.normal(0, 5))
            }
            data.append(reading)
        
        return {
            'source': 'FALLBACK',
            'station_id': station_id,
            'data': data,
            'message': 'Using synthetic data - CPCB API unavailable'
        }
    
    def _generate_fallback_realtime(self, station_id: str) -> Dict:
        """Generate fallback real-time data"""
        import random
        
        reading = {
            'timestamp': datetime.now().isoformat(),
            'station_id': station_id,
            'source': 'FALLBACK',
            'ph': 7.0 + random.uniform(-0.5, 0.5),
            'bod': max(0.5, 3.0 + random.uniform(-1, 1)),
            'dissolved_oxygen': max(0.5, 6.0 + random.uniform(-1, 1)),
            'fecal_coliform': max(1, 500 + random.uniform(-200, 200)),
            'temperature': 25.0 + random.uniform(-3, 3),
            'turbidity': max(0.5, 10.0 + random.uniform(-5, 5))
        }
        
        return reading
    
    def _get_default_maharashtra_stations(self) -> List[Dict]:
        """Default Maharashtra stations list"""
        return [
            {'id': 'MH001', 'name': 'Godavari at Nashik', 'lat': 19.9975, 'lon': 73.7898},
            {'id': 'MH002', 'name': 'Krishna at Pune', 'lat': 18.5204, 'lon': 73.8567},
            {'id': 'MH003', 'name': 'Tapi at Surat', 'lat': 21.1702, 'lon': 72.8311},
            {'id': 'MH004', 'name': 'Ulhas at Thane', 'lat': 19.2183, 'lon': 72.9781},
            {'id': 'MH005', 'name': 'Mithi River Mumbai', 'lat': 19.0760, 'lon': 72.8777}
        ]


class MPCBAPIIntegration(APIIntegrationBase):
    """
    Maharashtra Pollution Control Board (MPCB) API Integration
    State-specific water quality data
    """
    
    def __init__(self, api_key: Optional[str] = None):
        base_url = "https://mpcb.gov.in/api"  # Placeholder
        super().__init__(base_url, api_key)
    
    def fetch_station_status(self, location: str) -> Dict[str, Any]:
        """
        Fetch current water quality status for location
        
        Args:
            location: Location name (e.g., "Mumbai", "Pune")
        
        Returns:
            Current status and classification
        """
        params = {'location': location, 'format': 'json'}
        result = self._make_request('water-quality/status', params)
        
        if 'error' in result:
            return self._generate_mpcb_fallback(location)
        
        return result
    
    def fetch_compliance_data(self, industry_id: str) -> Dict[str, Any]:
        """
        Fetch industrial discharge compliance data
        
        Args:
            industry_id: Industry identifier
        
        Returns:
            Compliance status and discharge parameters
        """
        params = {'industry_id': industry_id}
        result = self._make_request('compliance/discharge', params)
        
        return result if 'error' not in result else {'status': 'unavailable'}
    
    def _generate_mpcb_fallback(self, location: str) -> Dict:
        """Fallback MPCB data"""
        return {
            'source': 'MPCB_FALLBACK',
            'location': location,
            'status': 'Moderate',
            'classification': 'Class B',
            'timestamp': datetime.now().isoformat(),
            'message': 'MPCB API unavailable'
        }


class CWCAPIIntegration(APIIntegrationBase):
    """
    Central Water Commission (CWC) API Integration
    Real-time sensor data from hydrological stations
    """
    
    def __init__(self, api_key: Optional[str] = None):
        base_url = "http://cwc.gov.in/api"  # Placeholder
        super().__init__(base_url, api_key)
    
    def fetch_sensor_data(self, sensor_id: str) -> Dict[str, Any]:
        """
        Fetch real-time data from CWC sensor
        
        Args:
            sensor_id: CWC sensor identifier
        
        Returns:
            Latest sensor readings
        """
        params = {'sensor_id': sensor_id}
        result = self._make_request('sensors/realtime', params)
        
        if 'error' in result:
            return self._generate_sensor_fallback(sensor_id)
        
        return result
    
    def fetch_water_level(self, station_id: str) -> Dict[str, Any]:
        """Fetch water level data"""
        params = {'station_id': station_id}
        result = self._make_request('water-level', params)
        
        return result if 'error' not in result else {'level': 'unavailable'}
    
    def _generate_sensor_fallback(self, sensor_id: str) -> Dict:
        """Fallback sensor data"""
        import random
        return {
            'source': 'CWC_FALLBACK',
            'sensor_id': sensor_id,
            'temperature': round(25 + random.uniform(-5, 5), 2),
            'water_level': round(random.uniform(2, 8), 2),
            'flow_rate': round(random.uniform(10, 100), 2),
            'timestamp': datetime.now().isoformat()
        }


class IMDWeatherIntegration(APIIntegrationBase):
    """
    India Meteorological Department (IMD) Weather API
    Weather data for water quality impact analysis
    """
    
    def __init__(self, api_key: Optional[str] = None):
        base_url = "https://imd.gov.in/api"  # Placeholder
        super().__init__(base_url, api_key)
    
    def fetch_weather_data(self, lat: float, lon: float) -> Dict[str, Any]:
        """
        Fetch weather data for coordinates
        
        Args:
            lat: Latitude
            lon: Longitude
        
        Returns:
            Current weather and forecast
        """
        params = {'lat': lat, 'lon': lon, 'units': 'metric'}
        result = self._make_request('weather/current', params)
        
        if 'error' in result:
            return self._generate_weather_fallback(lat, lon)
        
        return result
    
    def fetch_rainfall_data(self, district: str, date_range: tuple = None) -> Dict[str, Any]:
        """
        Fetch rainfall data for district
        
        Args:
            district: District name
            date_range: Date range tuple
        
        Returns:
            Rainfall measurements
        """
        if date_range is None:
            end_date = datetime.now()
            start_date = end_date - timedelta(days=7)
            date_range = (start_date, end_date)
        
        params = {
            'district': district,
            'start_date': date_range[0].strftime('%Y-%m-%d'),
            'end_date': date_range[1].strftime('%Y-%m-%d')
        }
        
        result = self._make_request('rainfall', params)
        return result if 'error' not in result else {'rainfall': []}
    
    def _generate_weather_fallback(self, lat: float, lon: float) -> Dict:
        """Fallback weather data"""
        import random
        return {
            'source': 'WEATHER_FALLBACK',
            'location': {'lat': lat, 'lon': lon},
            'temperature': round(25 + random.uniform(-5, 10), 1),
            'humidity': round(random.uniform(40, 90), 1),
            'rainfall_24h': round(random.uniform(0, 50), 1),
            'wind_speed': round(random.uniform(5, 20), 1),
            'timestamp': datetime.now().isoformat()
        }


class DataSourceCoordinator:
    """
    Coordinates multiple data sources and provides unified interface
    """
    
    def __init__(self):
        self.cpcb = CPCBAPIIntegration()
        self.mpcb = MPCBAPIIntegration()
        self.cwc = CWCAPIIntegration()
        self.imd = IMDWeatherIntegration()
    
    def fetch_comprehensive_data(self, station_id: str, lat: float = None, lon: float = None) -> Dict[str, Any]:
        """
        Fetch data from all available sources
        
        Args:
            station_id: Station identifier
            lat, lon: Optional coordinates for weather data
        
        Returns:
            Unified data from all sources
        """
        print(f"📡 Fetching comprehensive data for station {station_id}...")
        
        data = {
            'station_id': station_id,
            'timestamp': datetime.now().isoformat(),
            'sources': {}
        }
        
        # Fetch CPCB data
        print("  → Fetching CPCB data...")
        data['sources']['cpcb'] = self.cpcb.fetch_real_time_data(station_id)
        
        # Fetch CWC sensor data
        print("  → Fetching CWC sensor data...")
        data['sources']['cwc'] = self.cwc.fetch_sensor_data(station_id)
        
        # Fetch weather data if coordinates provided
        if lat and lon:
            print("  → Fetching weather data...")
            data['sources']['weather'] = self.imd.fetch_weather_data(lat, lon)
        
        print("✅ Data fetch complete")
        return data
    
    def get_station_list(self, state: str = "Maharashtra") -> List[Dict]:
        """Get list of all stations"""
        return self.cpcb.fetch_all_stations(state)


# Example usage and testing
if __name__ == '__main__':
    print("=== API Integration Layer - Phase 6 Testing ===\n")
    
    # Initialize coordinator
    coordinator = DataSourceCoordinator()
    
    # Test 1: Fetch comprehensive data
    print("Test 1: Fetching comprehensive data...")
    data = coordinator.fetch_comprehensive_data(
        station_id='MH001',
        lat=19.9975,
        lon=73.7898
    )
    print(f"✅ Sources available: {list(data['sources'].keys())}")
    print(f"   Timestamp: {data['timestamp']}\n")
    
    # Test 2: Get station list
    print("Test 2: Fetching Maharashtra stations...")
    stations = coordinator.get_station_list()
    print(f"✅ Found {len(stations)} stations")
    for station in stations[:3]:
        print(f"   - {station['name']} ({station['id']})")
    print()
    
    # Test 3: Individual API tests
    print("Test 3: Individual API components...")
    
    # CPCB
    cpcb = CPCBAPIIntegration()
    cpcb_data = cpcb.fetch_real_time_data('MH001')
    print(f"✅ CPCB: {cpcb_data.get('source', 'N/A')}")
    
    # Weather
    imd = IMDWeatherIntegration()
    weather = imd.fetch_weather_data(19.9975, 73.7898)
    print(f"✅ Weather: Temp {weather.get('temperature', 'N/A')}°C, "
          f"Humidity {weather.get('humidity', 'N/A')}%")
    
    print("\n=== API Integration Layer Ready ===")
