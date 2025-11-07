"""
ENHANCED LIVE WATER QUALITY MONITORING SYSTEM
Based on MPCB & GSDA Real Systems

This is the foundation for ML models and frontend integration.
Implements realistic water quality monitoring with:
- Surface Water Monitoring (MPCB Network)
- Groundwater Monitoring (GSDA Network)  
- Seasonal Variations (Pre-Monsoon, Post-Monsoon, Monsoon)
- Time-based Fluctuations
- Pollution Events
- Complete Parameter Suite (20+ parameters)
- Laboratory Network
- Water Quality Classification
"""

import threading
import time
import datetime
import random
import json
import math
from typing import Dict, List, Optional
from dataclasses import dataclass, asdict
from enum import Enum

# Import station definitions
# OLD: Using small test dataset (17 stations)
# from comprehensive_station_data import SURFACE_WATER_STATIONS
# from groundwater_station_data import GROUNDWATER_BASELINE_STATIONS

# NEW: Using complete Maharashtra network from station_loader
from station_loader import get_stations_by_district, ALL_STATIONS


class Season(Enum):
    """Maharashtra seasons for water quality variations"""
    PRE_MONSOON = "Pre-Monsoon"  # March-May
    MONSOON = "Monsoon"  # June-September
    POST_MONSOON = "Post-Monsoon"  # October-November
    WINTER = "Winter"  # December-February


class WaterQualityClass(Enum):
    """CPCB Water Quality Classification"""
    CLASS_A = "Class A - Drinking without treatment"
    CLASS_B = "Class B - Outdoor bathing (organized)"
    CLASS_C = "Class C - Drinking with conventional treatment"
    CLASS_D = "Class D - Wildlife & Fisheries"
    CLASS_E = "Class E - Irrigation, Industrial cooling, Controlled waste disposal"
    UNFIT = "Unfit for any use"


@dataclass
class WaterQualityReading:
    """Complete water quality reading with all parameters"""
    station_id: str
    timestamp: str
    season: str
    
    # Physical Parameters (required)
    ph: float
    temperature: float
    turbidity: float
    
    # Chemical Parameters - Major Ions (required)
    tds: float
    conductivity: float
    totalHardness: float
    totalAlkalinity: float
    calcium: float
    magnesium: float
    sodium: float
    potassium: float
    chlorides: float
    sulfates: float
    nitrates: float
    phosphates: float
    fluoride: float
    iron: float
    
    # Heavy Metals (required)
    arsenic: float
    lead: float
    chromium: float
    cadmium: float
    
    # Microbiological (required)
    totalColiform: int
    fecalColiform: int
    
    # Derived Metrics (required)
    wqi: float
    waterQualityClass: str
    status: str
    alerts: List[str]
    
    # Optional parameters (default None)
    color: Optional[int] = None
    odor: Optional[str] = None
    taste: Optional[str] = None
    dissolvedOxygen: Optional[float] = None
    bod: Optional[float] = None
    cod: Optional[float] = None
    bicarbonates: Optional[float] = None
    ammonia: Optional[float] = None
    mercury: Optional[float] = None


class EnhancedLiveStationService:
    """
    Enhanced Live Water Quality Monitoring Service
    Matches real MPCB + GSDA systems with complete parameter coverage
    """
    
    def __init__(self, test_mode=True, test_district='Pune'):
        """
        Initialize monitoring service
        
        Args:
            test_mode: If True, load single district for testing (default: True)
            test_district: District to load in test mode (default: 'Pune')
        """
        self.stations = []
        self.current_readings = {}
        self.historical_data = {}
        self.is_running = False
        self.update_thread = None
        self.update_interval = 900  # 15 minutes
        self.last_update = None
        self.test_mode = test_mode
        self.test_district = test_district
        
        # Initialize complete station network
        self._initialize_comprehensive_stations()
        
        # Start automatic updates
        self.start_simulation()
    
    def _initialize_comprehensive_stations(self):
        """Initialize all stations from Maharashtra network"""
        print("🌊 Initializing Maharashtra Water Quality Monitoring Network...")
        
        if self.test_mode:
            # Load single district for testing
            print(f"📊 TEST MODE: Loading {self.test_district} district only...")
            stations_to_load = get_stations_by_district(self.test_district)
            print(f"   Found {len(stations_to_load)} stations in {self.test_district}")
        else:
            # Load complete network (all 4,495 stations)
            print("📊 PRODUCTION MODE: Loading all 4,495 stations across Maharashtra...")
            stations_to_load = ALL_STATIONS
        
        # Process and add stations
        surface_count = 0
        groundwater_baseline_count = 0
        groundwater_trend_count = 0
        
        for station_data in stations_to_load:
            self.stations.append(station_data)
            
            # Count by type
            if station_data['type'] == 'surface_water':
                surface_count += 1
                station_type_label = "Surface Water"
            elif station_data.get('monitoring_type') == 'baseline':
                groundwater_baseline_count += 1
                station_type_label = "GW Baseline"
            else:
                groundwater_trend_count += 1
                station_type_label = "GW Trend"
            
            # Print progress (every 50 stations in production mode)
            if not self.test_mode and len(self.stations) % 50 == 0:
                print(f"  Loading... {len(self.stations)}/{len(stations_to_load)} stations")
            elif self.test_mode:
                print(f"  ✓ {station_type_label}: {station_data['name']} ({station_data['station_id']})")
        
        print(f"\n✅ Total Stations Loaded: {len(self.stations)}")
        print(f"   - Surface Water: {surface_count}")
        print(f"   - Groundwater Baseline: {groundwater_baseline_count}")
        print(f"   - Groundwater Trend: {groundwater_trend_count}")
        
        if self.test_mode:
            print(f"\n💡 Running in TEST MODE with {self.test_district} district")
            print(f"   To load all stations, initialize with: EnhancedLiveStationService(test_mode=False)")
        
        # Generate base parameters for all stations
        print(f"\n⚙️  Generating base water quality parameters for {len(self.stations)} stations...")
        self._generate_base_parameters_for_stations()
        print("✅ Base parameters generated successfully!")
    
    def _generate_base_parameters_for_stations(self):
        """Generate realistic base parameters for each station based on its characteristics"""
        for station in self.stations:
            # Skip if already has baseParameters (for backwards compatibility)
            if 'baseParameters' in station or 'base_parameters' in station:
                continue
            
            station_type = station['type']
            land_use = station.get('land_use', 'rural')
            
            # Generate based on station type and land use
            if station_type == 'surface_water':
                if land_use == 'urban':
                    base_params = {
                        'ph': random.uniform(7.0, 8.0),
                        'temperature': random.uniform(24, 28),
                        'turbidity': random.uniform(15, 40),
                        'tds': random.uniform(300, 600),
                        'conductivity': random.uniform(450, 900),
                        'dissolvedOxygen': random.uniform(4.5, 7.0),
                        'bod': random.uniform(3, 8),
                        'cod': random.uniform(15, 40),
                        'totalHardness': random.uniform(120, 280),
                        'totalAlkalinity': random.uniform(100, 250),
                        'calcium': random.uniform(35, 80),
                        'magnesium': random.uniform(15, 45),
                        'sodium': random.uniform(40, 100),
                        'potassium': random.uniform(3, 10),
                        'chlorides': random.uniform(50, 200),
                        'sulfates': random.uniform(30, 100),
                        'bicarbonates': random.uniform(120, 300),
                        'nitrates': random.uniform(5, 20),
                        'phosphates': random.uniform(0.5, 2.0),
                        'fluoride': random.uniform(0.3, 1.0),
                        'iron': random.uniform(0.1, 0.5),
                        'ammonia': random.uniform(0.3, 1.8),
                        'arsenic': random.uniform(0, 10),
                        'lead': random.uniform(0, 5),
                        'chromium': random.uniform(0, 15),
                        'cadmium': random.uniform(0, 2),
                        'mercury': random.uniform(0, 1),
                        'totalColiform': random.randint(200, 2000),
                        'fecalColiform': random.randint(50, 500),
                        'color': random.randint(5, 20),
                        'odor': 'slight',
                        'taste': 'acceptable',
                    }
                elif land_use == 'industrial':
                    base_params = {
                        'ph': random.uniform(6.5, 8.5),
                        'temperature': random.uniform(26, 32),
                        'turbidity': random.uniform(20, 60),
                        'tds': random.uniform(400, 800),
                        'conductivity': random.uniform(600, 1200),
                        'dissolvedOxygen': random.uniform(3.5, 6.0),
                        'bod': random.uniform(5, 15),
                        'cod': random.uniform(30, 80),
                        'totalHardness': random.uniform(150, 350),
                        'totalAlkalinity': random.uniform(120, 300),
                        'calcium': random.uniform(45, 100),
                        'magnesium': random.uniform(20, 60),
                        'sodium': random.uniform(60, 150),
                        'potassium': random.uniform(4, 12),
                        'chlorides': random.uniform(100, 350),
                        'sulfates': random.uniform(50, 150),
                        'bicarbonates': random.uniform(150, 350),
                        'nitrates': random.uniform(8, 30),
                        'phosphates': random.uniform(1.0, 3.5),
                        'fluoride': random.uniform(0.4, 1.2),
                        'iron': random.uniform(0.2, 1.0),
                        'ammonia': random.uniform(0.5, 2.5),
                        'arsenic': random.uniform(0, 15),
                        'lead': random.uniform(0, 8),
                        'chromium': random.uniform(0, 25),
                        'cadmium': random.uniform(0, 3),
                        'mercury': random.uniform(0, 2),
                        'totalColiform': random.randint(500, 3000),
                        'fecalColiform': random.randint(100, 800),
                        'color': random.randint(10, 30),
                        'odor': 'moderate',
                        'taste': 'slightly objectionable',
                    }
                else:  # agricultural or forest
                    base_params = {
                        'ph': random.uniform(7.2, 7.8),
                        'temperature': random.uniform(22, 26),
                        'turbidity': random.uniform(5, 20),
                        'tds': random.uniform(200, 400),
                        'conductivity': random.uniform(300, 600),
                        'dissolvedOxygen': random.uniform(6.0, 8.5),
                        'bod': random.uniform(1, 4),
                        'cod': random.uniform(8, 20),
                        'totalHardness': random.uniform(80, 200),
                        'totalAlkalinity': random.uniform(80, 200),
                        'calcium': random.uniform(25, 60),
                        'magnesium': random.uniform(10, 35),
                        'sodium': random.uniform(20, 60),
                        'potassium': random.uniform(2, 8),
                        'chlorides': random.uniform(20, 100),
                        'sulfates': random.uniform(15, 60),
                        'bicarbonates': random.uniform(100, 250),
                        'nitrates': random.uniform(2, 10),
                        'phosphates': random.uniform(0.2, 1.0),
                        'fluoride': random.uniform(0.2, 0.8),
                        'iron': random.uniform(0.05, 0.3),
                        'ammonia': random.uniform(0.1, 0.8),
                        'arsenic': random.uniform(0, 5),
                        'lead': random.uniform(0, 3),
                        'chromium': random.uniform(0, 10),
                        'cadmium': random.uniform(0, 1),
                        'mercury': random.uniform(0, 0.5),
                        'totalColiform': random.randint(50, 500),
                        'fecalColiform': random.randint(10, 150),
                        'color': random.randint(0, 10),
                        'odor': 'none',
                        'taste': 'acceptable',
                    }
            else:  # groundwater
                aquifer_type = station.get('aquifer_type', 'alluvial')
                
                if aquifer_type == 'basaltic':
                    base_params = {
                        'ph': random.uniform(7.5, 8.2),
                        'temperature': random.uniform(24, 27),
                        'turbidity': random.uniform(1, 5),
                        'tds': random.uniform(300, 600),
                        'conductivity': random.uniform(450, 900),
                        'totalHardness': random.uniform(150, 350),
                        'totalAlkalinity': random.uniform(120, 280),
                        'calcium': random.uniform(40, 90),
                        'magnesium': random.uniform(20, 60),
                        'sodium': random.uniform(30, 100),
                        'potassium': random.uniform(2, 10),
                        'chlorides': random.uniform(50, 150),
                        'sulfates': random.uniform(20, 80),
                        'bicarbonates': random.uniform(150, 350),
                        'nitrates': random.uniform(10, 40),
                        'phosphates': random.uniform(0.1, 0.8),
                        'fluoride': random.uniform(0.5, 2.0),
                        'iron': random.uniform(0.1, 0.5),
                        'ammonia': random.uniform(0.05, 0.5),
                        'arsenic': random.uniform(0, 8),
                        'lead': random.uniform(0, 4),
                        'chromium': random.uniform(0, 12),
                        'cadmium': random.uniform(0, 1.5),
                        'mercury': random.uniform(0, 0.8),
                        'totalColiform': random.randint(0, 50),
                        'fecalColiform': random.randint(0, 10),
                        'color': random.randint(0, 5),
                        'odor': 'none',
                        'taste': 'acceptable',
                    }
                elif aquifer_type == 'hard_rock':
                    base_params = {
                        'ph': random.uniform(6.8, 7.6),
                        'temperature': random.uniform(23, 26),
                        'turbidity': random.uniform(1, 8),
                        'tds': random.uniform(200, 500),
                        'conductivity': random.uniform(300, 750),
                        'totalHardness': random.uniform(100, 280),
                        'totalAlkalinity': random.uniform(90, 220),
                        'calcium': random.uniform(30, 70),
                        'magnesium': random.uniform(15, 50),
                        'sodium': random.uniform(20, 80),
                        'potassium': random.uniform(1, 8),
                        'chlorides': random.uniform(30, 120),
                        'sulfates': random.uniform(15, 60),
                        'bicarbonates': random.uniform(110, 270),
                        'nitrates': random.uniform(15, 50),
                        'phosphates': random.uniform(0.1, 0.6),
                        'fluoride': random.uniform(0.3, 1.5),
                        'iron': random.uniform(0.2, 1.0),
                        'ammonia': random.uniform(0.05, 0.4),
                        'arsenic': random.uniform(0, 6),
                        'lead': random.uniform(0, 3),
                        'chromium': random.uniform(0, 10),
                        'cadmium': random.uniform(0, 1),
                        'mercury': random.uniform(0, 0.6),
                        'totalColiform': random.randint(0, 30),
                        'fecalColiform': random.randint(0, 5),
                        'color': random.randint(0, 5),
                        'odor': 'none',
                        'taste': 'acceptable',
                    }
                else:  # alluvial or semi-confined
                    base_params = {
                        'ph': random.uniform(7.0, 7.8),
                        'temperature': random.uniform(24, 28),
                        'turbidity': random.uniform(2, 10),
                        'tds': random.uniform(250, 550),
                        'conductivity': random.uniform(375, 825),
                        'totalHardness': random.uniform(120, 300),
                        'totalAlkalinity': random.uniform(100, 250),
                        'calcium': random.uniform(35, 80),
                        'magnesium': random.uniform(18, 55),
                        'sodium': random.uniform(25, 90),
                        'potassium': random.uniform(2, 9),
                        'chlorides': random.uniform(40, 130),
                        'sulfates': random.uniform(18, 70),
                        'bicarbonates': random.uniform(120, 300),
                        'nitrates': random.uniform(20, 60),
                        'phosphates': random.uniform(0.1, 0.7),
                        'fluoride': random.uniform(0.4, 1.8),
                        'iron': random.uniform(0.15, 0.8),
                        'ammonia': random.uniform(0.05, 0.5),
                        'arsenic': random.uniform(0, 7),
                        'lead': random.uniform(0, 3.5),
                        'chromium': random.uniform(0, 11),
                        'cadmium': random.uniform(0, 1.2),
                        'mercury': random.uniform(0, 0.7),
                        'totalColiform': random.randint(0, 40),
                        'fecalColiform': random.randint(0, 8),
                        'color': random.randint(0, 5),
                        'odor': 'none',
                        'taste': 'acceptable',
                    }
            
            # Add to station (using snake_case to match new structure)
            station['baseParameters'] = base_params
    
    def _get_current_season(self) -> Season:
        """Determine current season based on date"""
        month = datetime.datetime.now().month
        
        if month in [3, 4, 5]:
            return Season.PRE_MONSOON
        elif month in [6, 7, 8, 9]:
            return Season.MONSOON
        elif month in [10, 11]:
            return Season.POST_MONSOON
        else:  # 12, 1, 2
            return Season.WINTER
    
    def _get_seasonal_factor(self, season: Season, param: str) -> float:
        """
        Get seasonal variation factor for parameter
        Based on real Maharashtra seasonal patterns
        """
        factors = {
            Season.PRE_MONSOON: {
                'turbidity': 0.8,
                'tds': 1.3,
                'dissolvedOxygen': 0.9,
                'temperature': 1.2,
                'bod': 1.4,
                'cod': 1.5,
                'nitrates': 1.3,
                'phosphates': 1.2,
                'chlorides': 1.3,
                'totalColiform': 1.5,
                'fecalColiform': 1.6,
                'default': 1.0
            },
            Season.MONSOON: {
                'turbidity': 2.5,  # High sediment load
                'tds': 0.7,  # Dilution effect
                'dissolvedOxygen': 1.1,
                'temperature': 0.9,
                'bod': 0.8,
                'cod': 0.8,
                'nitrates': 1.8,  # Agricultural runoff
                'phosphates': 2.0,  # Runoff
                'chlorides': 0.7,
                'totalColiform': 3.0,  # High contamination
                'fecalColiform': 4.0,
                'default': 1.0
            },
            Season.POST_MONSOON: {
                'turbidity': 1.3,
                'tds': 0.9,
                'dissolvedOxygen': 1.0,
                'temperature': 1.0,
                'bod': 1.0,
                'cod': 1.0,
                'nitrates': 1.2,
                'phosphates': 1.1,
                'chlorides': 0.9,
                'totalColiform': 1.2,
                'fecalColiform': 1.3,
                'default': 1.0
            },
            Season.WINTER: {
                'turbidity': 0.7,
                'tds': 1.1,
                'dissolvedOxygen': 1.2,  # Higher DO in cold water
                'temperature': 0.8,
                'bod': 0.9,
                'cod': 0.9,
                'nitrates': 1.0,
                'phosphates': 0.9,
                'chlorides': 1.1,
                'totalColiform': 0.8,
                'fecalColiform': 0.7,
                'default': 1.0
            }
        }
        
        season_factors = factors.get(season, {})
        return season_factors.get(param, season_factors.get('default', 1.0))
    
    def _get_time_variation_factor(self) -> float:
        """Get time-based variation (diurnal cycle)"""
        hour = datetime.datetime.now().hour
        
        # Peak pollution: Morning (6-9 AM) and Evening (6-9 PM)
        # Minimum: Late night (2-5 AM)
        if 6 <= hour <= 9 or 18 <= hour <= 21:
            return random.uniform(1.1, 1.3)
        elif 2 <= hour <= 5:
            return random.uniform(0.7, 0.9)
        else:
            return random.uniform(0.9, 1.1)
    
    def _apply_pollution_event(self, station: dict, base_value: float, param: str) -> float:
        """
        Simulate pollution events (industrial discharge, sewage overflow, etc.)
        5% chance of pollution event
        """
        if random.random() < 0.05:  # 5% chance
            if param in ['bod', 'cod', 'ammonia', 'phosphates']:
                return base_value * random.uniform(1.5, 2.5)
            elif param in ['totalColiform', 'fecalColiform']:
                return base_value * random.uniform(2.0, 4.0)
            elif param == 'turbidity':
                return base_value * random.uniform(1.5, 2.0)
        
        return base_value
    
    def _generate_realistic_reading(self, station: dict) -> WaterQualityReading:
        """
        Generate realistic water quality reading with all parameters
        Incorporates seasonal, time-based, and random variations
        """
        season = self._get_current_season()
        time_factor = self._get_time_variation_factor()
        base_params = station['baseParameters']
        
        # Helper function to generate varied value
        def vary(base: float, param: str, is_microbiological: bool = False) -> float:
            if base is None:
                return None
            
            seasonal_factor = self._get_seasonal_factor(season, param)
            random_factor = random.uniform(0.85, 1.15)
            
            value = base * seasonal_factor * time_factor * random_factor
            
            # Apply pollution events
            value = self._apply_pollution_event(station, value, param)
            
            # Round based on parameter type
            if is_microbiological:
                return max(0, int(value))
            elif param in ['ph', 'temperature']:
                return round(value, 1)
            elif param in ['turbidity', 'dissolvedOxygen', 'bod', 'cod']:
                return round(value, 1)
            else:
                return round(value, 2)
        
        # Generate all parameters (calculate defaults for missing params)
        # First, calculate derived values
        calcium_value = vary(base_params.get('calcium', base_params['totalHardness'] * 0.25), 'calcium')
        magnesium_value = vary(base_params.get('magnesium', base_params['totalHardness'] * 0.12), 'magnesium')
        sodium_value = vary(base_params.get('sodium', base_params['chlorides'] * 0.2), 'sodium')
        potassium_value = vary(base_params.get('potassium', sodium_value * 0.1 if 'sodium' not in base_params else base_params['sodium'] * 0.1), 'potassium')
        sulfates_value = vary(base_params.get('sulfates', base_params['chlorides'] * 0.15), 'sulfates')
        
        reading = WaterQualityReading(
            station_id=station.get('station_id', station.get('id')),  # Support both old and new format
            timestamp=datetime.datetime.now().isoformat(),
            season=season.value,
            
            # Physical
            ph=vary(base_params['ph'], 'ph'),
            temperature=vary(base_params['temperature'], 'temperature'),
            turbidity=vary(base_params['turbidity'], 'turbidity'),
            color=base_params.get('color'),
            odor=base_params.get('odor'),
            taste=base_params.get('taste'),
            
            # Chemical - Major
            tds=vary(base_params['tds'], 'tds'),
            conductivity=vary(base_params['conductivity'], 'conductivity'),
            dissolvedOxygen=vary(base_params.get('dissolvedOxygen'), 'dissolvedOxygen') if 'dissolvedOxygen' in base_params else None,
            bod=vary(base_params.get('bod'), 'bod') if 'bod' in base_params else None,
            cod=vary(base_params.get('cod'), 'cod') if 'cod' in base_params else None,
            totalHardness=vary(base_params['totalHardness'], 'totalHardness'),
            totalAlkalinity=vary(base_params['totalAlkalinity'], 'totalAlkalinity'),
            calcium=calcium_value,
            magnesium=magnesium_value,
            sodium=sodium_value,
            potassium=potassium_value,
            chlorides=vary(base_params['chlorides'], 'chlorides'),
            sulfates=sulfates_value,
            bicarbonates=vary(base_params.get('bicarbonates'), 'bicarbonates') if 'bicarbonates' in base_params else None,
            nitrates=vary(base_params['nitrates'], 'nitrates'),
            phosphates=vary(base_params['phosphates'], 'phosphates'),
            fluoride=vary(base_params['fluoride'], 'fluoride'),
            iron=vary(base_params['iron'], 'iron'),
            ammonia=vary(base_params.get('ammonia'), 'ammonia') if 'ammonia' in base_params else None,
            
            # Heavy Metals
            arsenic=vary(base_params['arsenic'], 'arsenic'),
            lead=vary(base_params['lead'], 'lead'),
            chromium=vary(base_params['chromium'], 'chromium'),
            cadmium=vary(base_params['cadmium'], 'cadmium'),
            mercury=vary(base_params.get('mercury'), 'mercury') if 'mercury' in base_params else None,
            
            # Microbiological
            totalColiform=vary(base_params['totalColiform'], 'totalColiform', True),
            fecalColiform=vary(base_params['fecalColiform'], 'fecalColiform', True),
            
            # Derived (calculated below)
            wqi=0.0,
            waterQualityClass="",
            status="",
            alerts=[]
        )
        
        # Calculate WQI and status
        reading.wqi = self._calculate_comprehensive_wqi(reading)
        reading.waterQualityClass = self._determine_water_class(reading, station).value
        reading.status = self._determine_status(reading.wqi)
        reading.alerts = self._check_comprehensive_alerts(reading, station)
        
        return reading
    
    def _calculate_comprehensive_wqi(self, reading: WaterQualityReading) -> float:
        """
        Calculate Water Quality Index using CPCB methodology
        Weighted average of key parameters
        """
        weights = {
            'ph': 0.10,
            'dissolvedOxygen': 0.15,
            'bod': 0.12,
            'turbidity': 0.10,
            'tds': 0.10,
            'nitrates': 0.08,
            'fecalColiform': 0.15,
            'totalColiform': 0.10,
            'fluoride': 0.05,
            'iron': 0.05,
        }
        
        # Calculate sub-indices (0-100 scale)
        sub_indices = {}
        
        # pH (optimal: 7.0-8.5)
        if 6.5 <= reading.ph <= 8.5:
            sub_indices['ph'] = 100
        elif 6.0 <= reading.ph <= 9.0:
            sub_indices['ph'] = 80
        else:
            sub_indices['ph'] = 50
        
        # Dissolved Oxygen (higher is better)
        if reading.dissolvedOxygen:
            if reading.dissolvedOxygen >= 6.0:
                sub_indices['dissolvedOxygen'] = 100
            elif reading.dissolvedOxygen >= 4.0:
                sub_indices['dissolvedOxygen'] = 70
            else:
                sub_indices['dissolvedOxygen'] = 40
        else:
            sub_indices['dissolvedOxygen'] = 80  # Default for groundwater
        
        # BOD (lower is better)
        if reading.bod:
            if reading.bod <= 3.0:
                sub_indices['bod'] = 100
            elif reading.bod <= 6.0:
                sub_indices['bod'] = 70
            else:
                sub_indices['bod'] = 40
        else:
            sub_indices['bod'] = 80
        
        # Turbidity (lower is better)
        if reading.turbidity <= 5:
            sub_indices['turbidity'] = 100
        elif reading.turbidity <= 10:
            sub_indices['turbidity'] = 80
        else:
            sub_indices['turbidity'] = 50
        
        # TDS (lower is better)
        if reading.tds <= 500:
            sub_indices['tds'] = 100
        elif reading.tds <= 1000:
            sub_indices['tds'] = 75
        else:
            sub_indices['tds'] = 50
        
        # Nitrates (lower is better)
        if reading.nitrates <= 10:
            sub_indices['nitrates'] = 100
        elif reading.nitrates <= 45:
            sub_indices['nitrates'] = 70
        else:
            sub_indices['nitrates'] = 40
        
        # Fecal Coliform (lower is better)
        if reading.fecalColiform <= 10:
            sub_indices['fecalColiform'] = 100
        elif reading.fecalColiform <= 100:
            sub_indices['fecalColiform'] = 70
        else:
            sub_indices['fecalColiform'] = 30
        
        # Total Coliform
        if reading.totalColiform <= 50:
            sub_indices['totalColiform'] = 100
        elif reading.totalColiform <= 500:
            sub_indices['totalColiform'] = 70
        else:
            sub_indices['totalColiform'] = 40
        
        # Fluoride (1.0-1.5 optimal)
        if 0.6 <= reading.fluoride <= 1.5:
            sub_indices['fluoride'] = 100
        elif reading.fluoride <= 2.0:
            sub_indices['fluoride'] = 70
        else:
            sub_indices['fluoride'] = 40
        
        # Iron (lower is better)
        if reading.iron <= 0.3:
            sub_indices['iron'] = 100
        elif reading.iron <= 1.0:
            sub_indices['iron'] = 75
        else:
            sub_indices['iron'] = 50
        
        # Calculate weighted WQI
        wqi = sum(sub_indices[param] * weights[param] for param in weights.keys())
        
        return round(wqi, 2)
    
    def _determine_water_class(self, reading: WaterQualityReading, station: dict) -> WaterQualityClass:
        """Determine CPCB water quality class"""
        wqi = reading.wqi
        
        if wqi >= 90:
            return WaterQualityClass.CLASS_A
        elif wqi >= 75:
            return WaterQualityClass.CLASS_B
        elif wqi >= 60:
            return WaterQualityClass.CLASS_C
        elif wqi >= 45:
            return WaterQualityClass.CLASS_D
        elif wqi >= 30:
            return WaterQualityClass.CLASS_E
        else:
            return WaterQualityClass.UNFIT
    
    def _determine_status(self, wqi: float) -> str:
        """Determine water quality status"""
        if wqi >= 80:
            return "Excellent"
        elif wqi >= 65:
            return "Good"
        elif wqi >= 50:
            return "Moderate"
        elif wqi >= 35:
            return "Poor"
        else:
            return "Very Poor"
    
    def _check_comprehensive_alerts(self, reading: WaterQualityReading, station: dict) -> List[str]:
        """Check for parameter threshold violations"""
        alerts = []
        
        # pH
        if reading.ph < 6.5 or reading.ph > 8.5:
            alerts.append(f"pH out of range: {reading.ph} (safe: 6.5-8.5)")
        
        # Dissolved Oxygen
        if reading.dissolvedOxygen and reading.dissolvedOxygen < 4.0:
            alerts.append(f"Low Dissolved Oxygen: {reading.dissolvedOxygen} mg/L (min: 4.0)")
        
        # Turbidity
        if reading.turbidity > 10:
            alerts.append(f"High Turbidity: {reading.turbidity} NTU (max: 10)")
        
        # TDS
        if reading.tds > 500:
            alerts.append(f"High TDS: {reading.tds} mg/L (max: 500)")
        
        # Nitrates
        if reading.nitrates > 45:
            alerts.append(f"High Nitrates: {reading.nitrates} mg/L (max: 45)")
        
        # Fluoride
        if reading.fluoride > 1.5:
            alerts.append(f"High Fluoride: {reading.fluoride} mg/L (max: 1.5)")
        elif reading.fluoride < 0.6:
            alerts.append(f"Low Fluoride: {reading.fluoride} mg/L (min: 0.6)")
        
        # Iron
        if reading.iron > 1.0:
            alerts.append(f"High Iron: {reading.iron} mg/L (max: 1.0)")
        
        # Heavy Metals
        if reading.arsenic > 0.01:
            alerts.append(f"⚠️ CRITICAL: Arsenic: {reading.arsenic} mg/L (max: 0.01)")
        if reading.lead > 0.01:
            alerts.append(f"⚠️ CRITICAL: Lead: {reading.lead} mg/L (max: 0.01)")
        if reading.chromium > 0.05:
            alerts.append(f"High Chromium: {reading.chromium} mg/L (max: 0.05)")
        if reading.cadmium > 0.003:
            alerts.append(f"⚠️ CRITICAL: Cadmium: {reading.cadmium} mg/L (max: 0.003)")
        
        # Microbiological
        if reading.fecalColiform > 100:
            alerts.append(f"⚠️ High Fecal Coliform: {reading.fecalColiform} MPN/100ml (max: 100)")
        if reading.totalColiform > 500:
            alerts.append(f"High Total Coliform: {reading.totalColiform} MPN/100ml (max: 500)")
        
        # BOD/COD
        if reading.bod and reading.bod > 6.0:
            alerts.append(f"High BOD: {reading.bod} mg/L (max: 6.0)")
        if reading.cod and reading.cod > 30:
            alerts.append(f"High COD: {reading.cod} mg/L (max: 30)")
        
        return alerts
    
    def _get_station_id(self, station: dict) -> str:
        """Get station ID supporting both old ('id') and new ('station_id') format"""
        return station.get('station_id', station.get('id'))
    
    def _update_all_stations(self):
        """Update readings for all stations"""
        for station in self.stations:
            reading = self._generate_realistic_reading(station)
            station_id = self._get_station_id(station)
            self.current_readings[station_id] = asdict(reading)
            
            # Store historical data
            if station_id not in self.historical_data:
                self.historical_data[station_id] = []
            
            self.historical_data[station_id].append(asdict(reading))
            
            # Keep last 100 readings
            if len(self.historical_data[station_id]) > 100:
                self.historical_data[station_id] = self.historical_data[station_id][-100:]
        
        self.last_update = datetime.datetime.now().isoformat()
    
    def _background_update_loop(self):
        """Background thread for automatic updates"""
        print(f"🔄 Starting automatic monitoring updates (interval: {self.update_interval}s)")
        
        while self.is_running:
            try:
                self._update_all_stations()
                print(f"✅ Updated {len(self.stations)} stations at {self.last_update}")
            except Exception as e:
                print(f"❌ Error updating stations: {str(e)}")
            
            time.sleep(self.update_interval)
    
    def start_simulation(self, update_interval: int = 900):
        """Start the monitoring simulation"""
        if not self.is_running:
            self.update_interval = update_interval
            self.is_running = True
            
            # Initial update
            self._update_all_stations()
            
            # Start background thread
            self.update_thread = threading.Thread(target=self._background_update_loop, daemon=True)
            self.update_thread.start()
            
            print(f"✅ Maharashtra Water Quality Monitoring System Started")
            print(f"   Total Stations: {len(self.stations)}")
            print(f"   Update Interval: {update_interval} seconds ({update_interval/60:.1f} minutes)")
            surface_count = len([s for s in self.stations if s['type'] == 'surface_water'])
            groundwater_count = len(self.stations) - surface_count
            print(f"   Monitoring: {surface_count} Surface Water + {groundwater_count} Groundwater Stations")
    
    def stop_simulation(self):
        """Stop the monitoring simulation"""
        self.is_running = False
        if self.update_thread:
            self.update_thread.join(timeout=5)
        print("⏸️  Monitoring simulation stopped")
    
    def refresh_data(self):
        """Force immediate data refresh"""
        self._update_all_stations()
        return {
            'message': 'Data refreshed successfully',
            'timestamp': self.last_update,
            'stations_updated': len(self.stations)
        }
    
    # ==================== API METHODS ====================
    
    def get_all_stations(self) -> List[dict]:
        """Get list of all monitoring stations with metadata"""
        return [{
            'id': self._get_station_id(s),
            'name': s['name'],
            'type': s.get('stationType', s.get('type')),  # Support both formats
            'monitoringType': s.get('monitoringType', s.get('monitoring_type', 'baseline')),  # Support both formats
            'district': s['district'],
            'taluka': s.get('taluka'),
            'region': s['region'],
            'latitude': s['latitude'],
            'longitude': s['longitude'],
            'altitude': s.get('altitude'),
            'waterBody': s.get('waterBody', s.get('water_body')),  # Support both formats
            'wellType': s.get('wellType', s.get('well_type')),
            'laboratory': s['laboratory'],
            'samplingFrequency': s.get('samplingFrequency', s.get('sampling_frequency', 'Monthly')),
            'designatedBestUse': s.get('designatedBestUse', s.get('designated_best_use')),
            'landUse': s.get('landUse', s.get('land_use')),
            'populationNearby': s.get('populationNearby', s.get('population_nearby')),
        } for s in self.stations]
    
    def get_station_by_id(self, station_id: str) -> Optional[dict]:
        """Get complete station details"""
        station = next((s for s in self.stations if self._get_station_id(s) == station_id), None)
        if station:
            current_reading = self.current_readings.get(station_id)
            return {
                'station': station,
                'currentReading': current_reading,
                'lastUpdate': self.last_update
            }
        return None
    
    def get_all_current_data(self) -> dict:
        """Get current readings for all stations"""
        return {
            'timestamp': self.last_update,
            'totalStations': len(self.stations),
            'readings': self.current_readings
        }
    
    def get_stations_by_district(self, district: str) -> List[dict]:
        """Get all stations in a district"""
        matching_stations = [s for s in self.stations if s['district'].lower() == district.lower()]
        return [{
            'station': s,
            'currentReading': self.current_readings.get(self._get_station_id(s))
        } for s in matching_stations]
    
    def get_stations_by_type(self, station_type: str) -> List[dict]:
        """Get stations by type (Surface Water / Groundwater)"""
        matching_stations = [s for s in self.stations if station_type.lower() in s.get('stationType', s.get('type', '')).lower()]
        return [{
            'station': s,
            'currentReading': self.current_readings.get(self._get_station_id(s))
        } for s in matching_stations]
    
    def get_stations_by_water_class(self, water_class: str) -> List[dict]:
        """Get stations by water quality class"""
        result = []
        for station in self.stations:
            station_id = self._get_station_id(station)
            reading = self.current_readings.get(station_id)
            if reading and water_class.lower() in reading['waterQualityClass'].lower():
                result.append({
                    'station': station,
                    'currentReading': reading
                })
        return result
    
    def get_stations_with_alerts(self) -> List[dict]:
        """Get all stations with active alerts"""
        result = []
        for station in self.stations:
            station_id = self._get_station_id(station)
            reading = self.current_readings.get(station_id)
            if reading and reading.get('alerts'):
                result.append({
                    'station': station,
                    'currentReading': reading,
                    'alertCount': len(reading['alerts'])
                })
        return sorted(result, key=lambda x: x['alertCount'], reverse=True)
    
    def get_summary_statistics(self) -> dict:
        """Get comprehensive summary statistics"""
        if not self.current_readings:
            return {'error': 'No data available'}
        
        readings = list(self.current_readings.values())
        
        # Count by status
        status_counts = {}
        for reading in readings:
            status = reading['status']
            status_counts[status] = status_counts.get(status, 0) + 1
        
        # Count by water class
        class_counts = {}
        for reading in readings:
            wclass = reading['waterQualityClass']
            class_counts[wclass] = class_counts.get(wclass, 0) + 1
        
        # Count alerts
        total_alerts = sum(len(r.get('alerts', [])) for r in readings)
        stations_with_alerts = len([r for r in readings if r.get('alerts')])
        
        # Average WQI
        wqi_values = [r['wqi'] for r in readings]
        avg_wqi = sum(wqi_values) / len(wqi_values) if wqi_values else 0
        
        # By region
        region_stats = {}
        for station in self.stations:
            region = station['region']
            station_id = self._get_station_id(station)
            reading = self.current_readings.get(station_id)
            if reading:
                if region not in region_stats:
                    region_stats[region] = {'count': 0, 'avgWqi': 0, 'wqiSum': 0}
                region_stats[region]['count'] += 1
                region_stats[region]['wqiSum'] += reading['wqi']
        
        for region in region_stats:
            region_stats[region]['avgWqi'] = round(
                region_stats[region]['wqiSum'] / region_stats[region]['count'], 2
            )
            del region_stats[region]['wqiSum']
        
        return {
            'lastUpdate': self.last_update,
            'totalStations': len(self.stations),
            'surfaceWaterStations': len([s for s in self.stations if s['type'] == 'surface_water']),
            'groundwaterStations': len([s for s in self.stations if s['type'] == 'groundwater']),
            'averageWQI': round(avg_wqi, 2),
            'statusDistribution': status_counts,
            'waterClassDistribution': class_counts,
            'totalAlerts': total_alerts,
            'stationsWithAlerts': stations_with_alerts,
            'regionStatistics': region_stats,
            'currentSeason': self._get_current_season().value
        }
    
    def get_historical_data(self, station_id: str, limit: int = 50) -> List[dict]:
        """Get historical readings for a station"""
        if station_id in self.historical_data:
            return self.historical_data[station_id][-limit:]
        return []
    
    def get_parameter_statistics(self, parameter: str) -> dict:
        """Get statistics for a specific parameter across all stations"""
        if not self.current_readings:
            return {'error': 'No data available'}
        
        values = []
        for reading in self.current_readings.values():
            if parameter in reading and reading[parameter] is not None:
                values.append(reading[parameter])
        
        if not values:
            return {'error': f'Parameter {parameter} not found'}
        
        return {
            'parameter': parameter,
            'count': len(values),
            'min': min(values),
            'max': max(values),
            'average': round(sum(values) / len(values), 2),
            'median': sorted(values)[len(values) // 2]
        }


# ==================== SINGLETON INSTANCE ====================

_service_instance = None

def get_station_service(test_mode=None, test_district='Pune') -> EnhancedLiveStationService:
    """
    Get singleton instance of monitoring service
    
    Args:
        test_mode: Override test mode (None = auto-detect from env, True = test, False = production)
        test_district: District to use in test mode (default: Pune)
    
    Environment Variables:
        STATION_TEST_MODE: Set to 'false' or '0' to load all 4,495 stations
        STATION_TEST_DISTRICT: District name for test mode (default: Pune)
    """
    global _service_instance
    if _service_instance is None:
        # Auto-detect mode from environment if not specified
        if test_mode is None:
            import os
            env_test_mode = os.getenv('STATION_TEST_MODE', 'true').lower()
            test_mode = env_test_mode not in ['false', '0', 'no', 'production']
            
        # Get test district from environment
        import os
        test_district = os.getenv('STATION_TEST_DISTRICT', test_district)
        
        _service_instance = EnhancedLiveStationService(
            test_mode=test_mode,
            test_district=test_district
        )
    return _service_instance


if __name__ == "__main__":
    # Test the service
    print("=" * 80)
    print("MAHARASHTRA WATER QUALITY MONITORING SYSTEM - TEST")
    print("=" * 80)
    
    service = get_station_service()
    
    print("\n📊 SYSTEM SUMMARY:")
    summary = service.get_summary_statistics()
    print(json.dumps(summary, indent=2))
    
    print("\n🚨 STATIONS WITH ALERTS:")
    alerts = service.get_stations_with_alerts()
    for item in alerts[:5]:
        print(f"\n  {item['station']['name']} ({item['station']['id']})")
        print(f"  Alerts: {item['alertCount']}")
        for alert in item['currentReading']['alerts']:
            print(f"    - {alert}")
    
    print("\n✅ System is operational and generating realistic data!")
    print("=" * 80)
