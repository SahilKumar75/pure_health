"""
Satellite Data Processor for Pure Health
Processes satellite imagery for water quality parameters:
- Sentinel-2 (ESA) - Turbidity, Chlorophyll-a, CDOM
- Landsat 8/9 (NASA) - Water temperature, turbidity
- MODIS (NASA) - Chlorophyll-a, TSM

Features:
- Automated data fetching from satellite APIs
- Cloud masking and quality filtering
- Water body segmentation
- Parameter extraction (turbidity, chlorophyll, temperature)
- Temporal aggregation (weekly/monthly)
- GeoTIFF processing
"""

import asyncio
import logging
from typing import Dict, List, Optional, Tuple
from datetime import datetime, timedelta
from dataclasses import dataclass, asdict
import json
import aiohttp
from pathlib import Path

# Geospatial libraries (optional - install as needed)
try:
    import numpy as np
    NUMPY_AVAILABLE = True
except ImportError:
    NUMPY_AVAILABLE = False
    print("Warning: numpy not installed. Some features will be limited.")

try:
    from PIL import Image
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False
    print("Warning: Pillow not installed. Image processing disabled.")

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@dataclass
class SatelliteReading:
    """Represents a satellite-derived water quality reading"""
    station_id: str
    latitude: float
    longitude: float
    parameter: str  # turbidity, chlorophyll_a, temperature, cdom
    value: float
    unit: str
    timestamp: str
    satellite: str  # sentinel2, landsat8, landsat9, modis
    cloud_cover: float
    quality: str = "good"  # good, suspect, bad
    
    def to_dict(self) -> Dict:
        return asdict(self)


@dataclass
class StationLocation:
    """Water quality station location"""
    station_id: str
    name: str
    latitude: float
    longitude: float
    buffer_km: float = 1.0  # Search radius in km


class Sentinel2Processor:
    """
    Sentinel-2 satellite data processor
    Provides 10m resolution for turbidity and chlorophyll-a
    """
    
    # Sentinel-2 band information
    BANDS = {
        'B2': {'name': 'Blue', 'resolution': 10, 'wavelength': 490},
        'B3': {'name': 'Green', 'resolution': 10, 'wavelength': 560},
        'B4': {'name': 'Red', 'resolution': 10, 'wavelength': 665},
        'B5': {'name': 'Red Edge 1', 'resolution': 20, 'wavelength': 705},
        'B8': {'name': 'NIR', 'resolution': 10, 'wavelength': 842},
        'B11': {'name': 'SWIR 1', 'resolution': 20, 'wavelength': 1610},
    }
    
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key
        self.base_url = "https://services.sentinel-hub.com/api/v1"
        self.session: Optional[aiohttp.ClientSession] = None
        logger.info("Sentinel-2 processor initialized")
    
    async def start(self):
        """Start HTTP session"""
        self.session = aiohttp.ClientSession()
        logger.info("Sentinel-2 session started")
    
    async def stop(self):
        """Stop HTTP session"""
        if self.session:
            await self.session.close()
        logger.info("Sentinel-2 session stopped")
    
    async def fetch_data(self, location: StationLocation, 
                        start_date: datetime, end_date: datetime,
                        max_cloud_cover: float = 20.0) -> List[SatelliteReading]:
        """
        Fetch Sentinel-2 data for a location
        
        Args:
            location: Station location
            start_date: Start date for data
            end_date: End date for data
            max_cloud_cover: Maximum acceptable cloud cover (%)
            
        Returns:
            List of satellite readings
        """
        logger.info(f"Fetching Sentinel-2 data for {location.name} ({start_date.date()} to {end_date.date()})")
        
        # Mock implementation (replace with real API calls)
        readings = await self._mock_fetch_data(location, start_date, end_date, max_cloud_cover)
        
        logger.info(f"Retrieved {len(readings)} Sentinel-2 readings")
        return readings
    
    async def _mock_fetch_data(self, location: StationLocation,
                               start_date: datetime, end_date: datetime,
                               max_cloud_cover: float) -> List[SatelliteReading]:
        """Mock data for testing (replace with real API)"""
        if not NUMPY_AVAILABLE:
            return []
        
        readings = []
        current_date = start_date
        
        while current_date <= end_date:
            # Simulate weekly observations
            if np.random.random() > 0.3:  # 70% chance of valid observation
                cloud_cover = np.random.uniform(0, max_cloud_cover)
                
                # Turbidity (NTU) - derived from Red/Blue ratio
                turbidity = np.random.uniform(2, 15)
                readings.append(SatelliteReading(
                    station_id=location.station_id,
                    latitude=location.latitude,
                    longitude=location.longitude,
                    parameter="turbidity",
                    value=round(turbidity, 2),
                    unit="NTU",
                    timestamp=current_date.isoformat(),
                    satellite="sentinel2",
                    cloud_cover=round(cloud_cover, 1),
                    quality="good" if cloud_cover < 10 else "suspect"
                ))
                
                # Chlorophyll-a (μg/L) - derived from NDCI
                chlorophyll = np.random.uniform(1, 20)
                readings.append(SatelliteReading(
                    station_id=location.station_id,
                    latitude=location.latitude,
                    longitude=location.longitude,
                    parameter="chlorophyll_a",
                    value=round(chlorophyll, 2),
                    unit="μg/L",
                    timestamp=current_date.isoformat(),
                    satellite="sentinel2",
                    cloud_cover=round(cloud_cover, 1),
                    quality="good" if cloud_cover < 10 else "suspect"
                ))
            
            current_date += timedelta(days=7)  # Weekly observations
        
        return readings
    
    def calculate_turbidity(self, red_band: np.ndarray, blue_band: np.ndarray) -> float:
        """
        Calculate turbidity using Red/Blue ratio
        Higher ratio = higher turbidity
        """
        if not NUMPY_AVAILABLE:
            return 0.0
        
        # Mask water pixels (simplified)
        water_mask = (red_band > 0) & (blue_band > 0)
        
        if not water_mask.any():
            return 0.0
        
        # Calculate ratio
        ratio = red_band[water_mask] / blue_band[water_mask]
        
        # Convert to NTU (empirical relationship)
        turbidity_ntu = np.median(ratio) * 10.0
        
        return float(turbidity_ntu)
    
    def calculate_chlorophyll_a(self, red_edge: np.ndarray, red_band: np.ndarray) -> float:
        """
        Calculate Chlorophyll-a using Normalized Difference Chlorophyll Index (NDCI)
        NDCI = (Red Edge - Red) / (Red Edge + Red)
        """
        if not NUMPY_AVAILABLE:
            return 0.0
        
        # Calculate NDCI
        ndci = (red_edge - red_band) / (red_edge + red_band + 1e-10)
        
        # Convert NDCI to Chlorophyll-a (μg/L) using empirical relationship
        # Chl-a = 14.039 + 86.115 * NDCI + 194.325 * NDCI^2
        chlorophyll_a = 14.039 + 86.115 * np.median(ndci) + 194.325 * (np.median(ndci) ** 2)
        
        return max(0.0, float(chlorophyll_a))


class Landsat8Processor:
    """
    Landsat 8/9 satellite data processor
    Provides 30m resolution for temperature and turbidity
    """
    
    # Landsat 8 band information
    BANDS = {
        'B2': {'name': 'Blue', 'resolution': 30, 'wavelength': 482},
        'B3': {'name': 'Green', 'resolution': 30, 'wavelength': 562},
        'B4': {'name': 'Red', 'resolution': 30, 'wavelength': 655},
        'B5': {'name': 'NIR', 'resolution': 30, 'wavelength': 865},
        'B10': {'name': 'TIR 1', 'resolution': 100, 'wavelength': 10895},  # Thermal
        'B11': {'name': 'TIR 2', 'resolution': 100, 'wavelength': 12005},  # Thermal
    }
    
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key
        self.base_url = "https://earthengine.googleapis.com"
        self.session: Optional[aiohttp.ClientSession] = None
        logger.info("Landsat 8 processor initialized")
    
    async def start(self):
        """Start HTTP session"""
        self.session = aiohttp.ClientSession()
        logger.info("Landsat 8 session started")
    
    async def stop(self):
        """Stop HTTP session"""
        if self.session:
            await self.session.close()
        logger.info("Landsat 8 session stopped")
    
    async def fetch_data(self, location: StationLocation,
                        start_date: datetime, end_date: datetime,
                        max_cloud_cover: float = 20.0) -> List[SatelliteReading]:
        """Fetch Landsat 8 data for a location"""
        logger.info(f"Fetching Landsat 8 data for {location.name} ({start_date.date()} to {end_date.date()})")
        
        # Mock implementation
        readings = await self._mock_fetch_data(location, start_date, end_date, max_cloud_cover)
        
        logger.info(f"Retrieved {len(readings)} Landsat 8 readings")
        return readings
    
    async def _mock_fetch_data(self, location: StationLocation,
                               start_date: datetime, end_date: datetime,
                               max_cloud_cover: float) -> List[SatelliteReading]:
        """Mock data for testing"""
        if not NUMPY_AVAILABLE:
            return []
        
        readings = []
        current_date = start_date
        
        # Landsat has 16-day revisit time
        while current_date <= end_date:
            if np.random.random() > 0.4:  # 60% chance of valid observation
                cloud_cover = np.random.uniform(0, max_cloud_cover)
                
                # Water temperature (°C) - from thermal bands
                # Seasonal variation
                month = current_date.month
                base_temp = 15 + 10 * np.sin((month - 3) * np.pi / 6)  # Seasonal cycle
                temperature = base_temp + np.random.uniform(-2, 2)
                
                readings.append(SatelliteReading(
                    station_id=location.station_id,
                    latitude=location.latitude,
                    longitude=location.longitude,
                    parameter="temperature",
                    value=round(temperature, 2),
                    unit="°C",
                    timestamp=current_date.isoformat(),
                    satellite="landsat8",
                    cloud_cover=round(cloud_cover, 1),
                    quality="good" if cloud_cover < 10 else "suspect"
                ))
            
            current_date += timedelta(days=16)  # 16-day revisit
        
        return readings
    
    def calculate_temperature(self, thermal_band: np.ndarray) -> float:
        """
        Calculate water surface temperature from thermal band
        
        Args:
            thermal_band: Landsat thermal infrared band (B10 or B11)
            
        Returns:
            Temperature in Celsius
        """
        if not NUMPY_AVAILABLE:
            return 0.0
        
        # Convert DN to radiance (simplified)
        # Real implementation needs metadata for calibration
        K1 = 774.89  # Calibration constant
        K2 = 1321.08  # Calibration constant
        
        # Convert to brightness temperature (Kelvin)
        temp_kelvin = K2 / (np.log(K1 / thermal_band + 1))
        
        # Convert to Celsius
        temp_celsius = temp_kelvin - 273.15
        
        # Mask water pixels and return median
        water_temp = np.median(temp_celsius[temp_celsius > 0])
        
        return float(water_temp)


class SatelliteDataProcessor:
    """
    Main satellite data processor
    Coordinates multiple satellite sources
    """
    
    def __init__(self, 
                 sentinel2_api_key: Optional[str] = None,
                 landsat_api_key: Optional[str] = None):
        
        self.sentinel2 = Sentinel2Processor(sentinel2_api_key)
        self.landsat8 = Landsat8Processor(landsat_api_key)
        
        self.stations: Dict[str, StationLocation] = {}
        self.cache_dir = Path("satellite_cache")
        self.cache_dir.mkdir(exist_ok=True)
        
        logger.info("Satellite Data Processor initialized")
    
    async def start(self):
        """Start all satellite processors"""
        logger.info("Starting satellite processors...")
        await self.sentinel2.start()
        await self.landsat8.start()
        logger.info("✓ All satellite processors started")
    
    async def stop(self):
        """Stop all satellite processors"""
        logger.info("Stopping satellite processors...")
        await self.sentinel2.stop()
        await self.landsat8.stop()
        logger.info("✓ All satellite processors stopped")
    
    def register_station(self, location: StationLocation):
        """Register a water quality station for satellite monitoring"""
        self.stations[location.station_id] = location
        logger.info(f"Registered station {location.station_id}: {location.name} ({location.latitude}, {location.longitude})")
    
    async def fetch_all_data(self, days: int = 30, max_cloud_cover: float = 20.0) -> Dict[str, List[SatelliteReading]]:
        """
        Fetch satellite data for all registered stations
        
        Args:
            days: Number of days to look back
            max_cloud_cover: Maximum cloud cover percentage
            
        Returns:
            Dictionary mapping station_id to list of readings
        """
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days)
        
        logger.info(f"Fetching satellite data for {len(self.stations)} stations ({days} days)")
        
        all_readings = {}
        
        for station_id, location in self.stations.items():
            readings = []
            
            # Fetch from Sentinel-2 (turbidity, chlorophyll)
            try:
                sentinel_data = await self.sentinel2.fetch_data(
                    location, start_date, end_date, max_cloud_cover
                )
                readings.extend(sentinel_data)
            except Exception as e:
                logger.error(f"Error fetching Sentinel-2 data for {station_id}: {e}")
            
            # Fetch from Landsat 8 (temperature)
            try:
                landsat_data = await self.landsat8.fetch_data(
                    location, start_date, end_date, max_cloud_cover
                )
                readings.extend(landsat_data)
            except Exception as e:
                logger.error(f"Error fetching Landsat data for {station_id}: {e}")
            
            all_readings[station_id] = readings
            logger.info(f"  Station {station_id}: {len(readings)} satellite observations")
        
        return all_readings
    
    def aggregate_readings(self, readings: List[SatelliteReading], 
                          parameter: str, days: int = 7) -> Optional[float]:
        """
        Aggregate satellite readings for a parameter
        
        Args:
            readings: List of satellite readings
            parameter: Parameter to aggregate
            days: Number of days to average over
            
        Returns:
            Aggregated value or None
        """
        if not NUMPY_AVAILABLE:
            return None
        
        # Filter by parameter
        param_readings = [r for r in readings if r.parameter == parameter]
        
        if not param_readings:
            return None
        
        # Get recent readings
        cutoff = datetime.now() - timedelta(days=days)
        recent = [r for r in param_readings 
                 if datetime.fromisoformat(r.timestamp) > cutoff]
        
        if not recent:
            return None
        
        # Filter by quality
        good_readings = [r for r in recent if r.quality == "good"]
        
        if not good_readings:
            good_readings = recent  # Use all if no good readings
        
        # Calculate weighted average (weight by cloud cover)
        values = np.array([r.value for r in good_readings])
        weights = np.array([1.0 / (r.cloud_cover + 1) for r in good_readings])
        
        weighted_avg = np.average(values, weights=weights)
        
        return float(weighted_avg)
    
    async def process_station(self, station_id: str, days: int = 30) -> Dict[str, float]:
        """
        Process satellite data for a single station
        
        Returns:
            Dictionary of parameter values
        """
        if station_id not in self.stations:
            logger.warning(f"Station {station_id} not registered")
            return {}
        
        # Fetch data
        all_data = await self.fetch_all_data(days=days)
        readings = all_data.get(station_id, [])
        
        if not readings:
            return {}
        
        # Aggregate parameters
        result = {}
        
        for param in ['turbidity', 'chlorophyll_a', 'temperature']:
            value = self.aggregate_readings(readings, param, days=7)
            if value is not None:
                result[param] = round(value, 2)
        
        logger.info(f"Processed satellite data for {station_id}: {result}")
        return result
    
    def save_cache(self, station_id: str, readings: List[SatelliteReading]):
        """Save readings to cache"""
        cache_file = self.cache_dir / f"{station_id}_satellite.json"
        
        data = {
            'station_id': station_id,
            'timestamp': datetime.now().isoformat(),
            'readings': [r.to_dict() for r in readings]
        }
        
        with open(cache_file, 'w') as f:
            json.dump(data, f, indent=2)
        
        logger.info(f"Cached {len(readings)} readings for {station_id}")
    
    def load_cache(self, station_id: str) -> List[SatelliteReading]:
        """Load readings from cache"""
        cache_file = self.cache_dir / f"{station_id}_satellite.json"
        
        if not cache_file.exists():
            return []
        
        try:
            with open(cache_file, 'r') as f:
                data = json.load(f)
            
            readings = [SatelliteReading(**r) for r in data['readings']]
            logger.info(f"Loaded {len(readings)} cached readings for {station_id}")
            return readings
        except Exception as e:
            logger.error(f"Error loading cache: {e}")
            return []


# Example usage
async def main():
    """Test the satellite processor"""
    print("\n" + "="*60)
    print("Satellite Data Processor - Test Mode")
    print("="*60 + "\n")
    
    # Initialize processor
    processor = SatelliteDataProcessor()
    await processor.start()
    
    # Register test stations
    print("Registering test stations...")
    
    stations = [
        StationLocation(
            station_id="1",
            name="Mithi River - Powai",
            latitude=19.1197,
            longitude=72.9133,
            buffer_km=1.0
        ),
        StationLocation(
            station_id="2",
            name="Godavari River - Nashik",
            latitude=19.9975,
            longitude=73.7898,
            buffer_km=2.0
        ),
        StationLocation(
            station_id="3",
            name="Mula-Mutha River",
            latitude=18.5204,
            longitude=73.8567,
            buffer_km=1.5
        ),
    ]
    
    for station in stations:
        processor.register_station(station)
    
    print(f"\n✓ Registered {len(stations)} stations\n")
    
    # Fetch satellite data
    print("Fetching satellite data (last 30 days)...")
    all_data = await processor.fetch_all_data(days=30, max_cloud_cover=20.0)
    
    print("\n" + "="*60)
    print("Satellite Data Summary")
    print("="*60)
    
    for station_id, readings in all_data.items():
        station = processor.stations[station_id]
        print(f"\n{station.name} (Station {station_id}):")
        print(f"  Total observations: {len(readings)}")
        
        # Group by parameter
        by_param = {}
        for reading in readings:
            if reading.parameter not in by_param:
                by_param[reading.parameter] = []
            by_param[reading.parameter].append(reading)
        
        for param, param_readings in by_param.items():
            good = len([r for r in param_readings if r.quality == "good"])
            avg_cloud = np.mean([r.cloud_cover for r in param_readings]) if NUMPY_AVAILABLE else 0
            print(f"  {param}: {len(param_readings)} obs ({good} good quality, avg cloud: {avg_cloud:.1f}%)")
        
        # Get aggregated values
        result = await processor.process_station(station_id, days=30)
        if result:
            print(f"  Aggregated values:")
            for param, value in result.items():
                print(f"    {param}: {value}")
        
        # Save to cache
        processor.save_cache(station_id, readings)
    
    # Stop processor
    await processor.stop()
    print("\n✓ Satellite processor stopped\n")


if __name__ == "__main__":
    asyncio.run(main())
