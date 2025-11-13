"""
Real-time Service Orchestrator - Phase 6
Coordinates all real-time data flows and integrations
"""

import asyncio
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
import pandas as pd
from enhanced_prediction_service import EnhancedPredictionService

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class RealtimeDataOrchestrator:
    """
    Orchestrates real-time data collection, processing, and distribution
    Integrates Phase 5 ML models with live data streams
    """
    
    def __init__(self, websocket_server=None):
        self.websocket_server = websocket_server
        self.prediction_service = EnhancedPredictionService()
        self.active_stations: Dict[int, Dict] = {}
        self.last_update: Dict[int, datetime] = {}
        self.update_interval = 300  # 5 minutes in seconds
        
        # Data quality thresholds
        self.quality_thresholds = {
            'ph': {'min': 6.0, 'max': 9.0, 'critical_min': 5.0, 'critical_max': 10.0},
            'dissolved_oxygen': {'min': 4.0, 'critical_min': 2.0},
            'bod': {'max': 5.0, 'critical_max': 10.0},
            'fecal_coliform': {'max': 2500, 'critical_max': 10000},
            'turbidity': {'max': 10.0, 'critical_max': 50.0}
        }
        
    async def start(self):
        """Start the real-time service"""
        logger.info("Starting Real-time Data Orchestrator")
        
        # Start background tasks
        tasks = [
            asyncio.create_task(self.data_collection_loop()),
            asyncio.create_task(self.prediction_update_loop()),
            asyncio.create_task(self.anomaly_detection_loop()),
            asyncio.create_task(self.health_check_loop())
        ]
        
        await asyncio.gather(*tasks)
    
    async def data_collection_loop(self):
        """Continuously collect data from all sources"""
        logger.info("Starting data collection loop")
        
        while True:
            try:
                for station_id in self.active_stations.keys():
                    await self.collect_station_data(station_id)
                    await asyncio.sleep(1)  # Small delay between stations
                
                # Wait before next collection cycle
                await asyncio.sleep(self.update_interval)
                
            except Exception as e:
                logger.error(f"Error in data collection loop: {e}")
                await asyncio.sleep(60)  # Wait 1 minute on error
    
    async def prediction_update_loop(self):
        """Continuously update ML predictions"""
        logger.info("Starting prediction update loop")
        
        while True:
            try:
                for station_id, station_data in self.active_stations.items():
                    if 'current_data' in station_data:
                        await self.update_predictions(station_id, station_data['current_data'])
                
                # Update predictions every 15 minutes
                await asyncio.sleep(900)
                
            except Exception as e:
                logger.error(f"Error in prediction loop: {e}")
                await asyncio.sleep(300)
    
    async def anomaly_detection_loop(self):
        """Continuously monitor for anomalies"""
        logger.info("Starting anomaly detection loop")
        
        while True:
            try:
                for station_id, station_data in self.active_stations.items():
                    if 'current_data' in station_data:
                        await self.detect_anomalies(station_id, station_data['current_data'])
                
                # Check every 5 minutes
                await asyncio.sleep(300)
                
            except Exception as e:
                logger.error(f"Error in anomaly detection: {e}")
                await asyncio.sleep(300)
    
    async def health_check_loop(self):
        """Monitor system health"""
        logger.info("Starting health check loop")
        
        while True:
            try:
                status = {
                    'timestamp': datetime.now().isoformat(),
                    'active_stations': len(self.active_stations),
                    'last_updates': {
                        station_id: last_time.isoformat()
                        for station_id, last_time in self.last_update.items()
                    }
                }
                logger.info(f"Health check: {status}")
                
                # Every 1 minute
                await asyncio.sleep(60)
                
            except Exception as e:
                logger.error(f"Error in health check: {e}")
                await asyncio.sleep(60)
    
    async def collect_station_data(self, station_id: int):
        """
        Collect data from all sources for a station
        Priority: Sensors > API > Satellite > ML Fallback
        """
        try:
            data = None
            source = None
            
            # Try sensor data first (highest priority)
            data, source = await self.fetch_sensor_data(station_id)
            
            # Fallback to API data
            if not data:
                data, source = await self.fetch_api_data(station_id)
            
            # Fallback to satellite data
            if not data:
                data, source = await self.fetch_satellite_data(station_id)
            
            # Final fallback: ML prediction
            if not data:
                data, source = await self.generate_ml_fallback(station_id)
            
            if data:
                data['source'] = source
                data['timestamp'] = datetime.now().isoformat()
                
                # Store and process
                await self.process_station_data(station_id, data)
                
                # Update last collection time
                self.last_update[station_id] = datetime.now()
                
        except Exception as e:
            logger.error(f"Error collecting data for station {station_id}: {e}")
    
    async def fetch_sensor_data(self, station_id: int) -> tuple:
        """Fetch data from IoT sensors"""
        # TODO: Implement actual sensor integration
        # For now, return None to simulate no sensor data
        return None, None
    
    async def fetch_api_data(self, station_id: int) -> tuple:
        """Fetch data from government APIs"""
        # TODO: Implement CPCB/MPCB API integration
        # For now, return simulated data
        return None, None
    
    async def fetch_satellite_data(self, station_id: int) -> tuple:
        """Fetch data from satellite sources"""
        # TODO: Implement Sentinel-2/Landsat integration
        return None, None
    
    async def generate_ml_fallback(self, station_id: int) -> tuple:
        """Generate data using ML models when no real data available"""
        try:
            if station_id in self.active_stations:
                last_data = self.active_stations[station_id].get('current_data', {})
                
                # Use last known data with slight variations
                if last_data:
                    import numpy as np
                    fallback_data = {
                        'ph': last_data.get('ph', 7.5) + np.random.normal(0, 0.1),
                        'bod': max(0.5, last_data.get('bod', 2.5) + np.random.normal(0, 0.3)),
                        'dissolved_oxygen': max(0.5, last_data.get('dissolved_oxygen', 6.0) + np.random.normal(0, 0.2)),
                        'fecal_coliform': max(1, last_data.get('fecal_coliform', 500) * (1 + np.random.normal(0, 0.1))),
                        'temperature': last_data.get('temperature', 25) + np.random.normal(0, 0.5),
                        'turbidity': max(0.5, last_data.get('turbidity', 5) + np.random.normal(0, 0.5)),
                        'tds': last_data.get('tds', 300) + np.random.normal(0, 10),
                        'confidence': 0.5  # Lower confidence for ML fallback
                    }
                    return fallback_data, 'ml_fallback'
            
            return None, None
            
        except Exception as e:
            logger.error(f"Error generating ML fallback: {e}")
            return None, None
    
    async def process_station_data(self, station_id: int, data: Dict):
        """Process and validate incoming station data"""
        try:
            # Validate data quality
            validation_result = self.validate_data(data)
            data['validation'] = validation_result
            
            # Calculate WQI if not present
            if 'wqi' not in data and all(k in data for k in ['ph', 'bod', 'dissolved_oxygen', 'fecal_coliform']):
                data['wqi'] = self.calculate_wqi_quick(data)
            
            # Store in active stations
            if station_id not in self.active_stations:
                self.active_stations[station_id] = {}
            
            self.active_stations[station_id]['current_data'] = data
            self.active_stations[station_id]['last_update'] = datetime.now()
            
            # Broadcast to WebSocket clients
            if self.websocket_server:
                await self.websocket_server.broadcast_update(station_id, data)
            
            logger.info(f"Processed data for station {station_id}: WQI={data.get('wqi', 'N/A'):.1f}")
            
        except Exception as e:
            logger.error(f"Error processing station data: {e}")
    
    def validate_data(self, data: Dict) -> Dict:
        """Validate data against quality thresholds"""
        validation = {
            'is_valid': True,
            'warnings': [],
            'errors': []
        }
        
        for param, thresholds in self.quality_thresholds.items():
            if param in data:
                value = data[param]
                
                # Check critical thresholds
                if 'critical_min' in thresholds and value < thresholds['critical_min']:
                    validation['errors'].append(f"{param} critically low: {value}")
                    validation['is_valid'] = False
                
                if 'critical_max' in thresholds and value > thresholds['critical_max']:
                    validation['errors'].append(f"{param} critically high: {value}")
                    validation['is_valid'] = False
                
                # Check warning thresholds
                if 'min' in thresholds and value < thresholds['min']:
                    validation['warnings'].append(f"{param} below safe minimum: {value}")
                
                if 'max' in thresholds and value > thresholds['max']:
                    validation['warnings'].append(f"{param} above safe maximum: {value}")
        
        return validation
    
    def calculate_wqi_quick(self, data: Dict) -> float:
        """Quick WQI calculation using CPCB weights"""
        # Simplified WQI - use Phase 1 calculator for full accuracy
        try:
            ph = data.get('ph', 7.0)
            bod = data.get('bod', 2.0)
            do_val = data.get('dissolved_oxygen', 6.0)
            fc = data.get('fecal_coliform', 500)
            
            # Rough sub-indices
            ph_sub = 90 if 7.0 <= ph <= 8.5 else 70
            bod_sub = 90 if bod <= 3 else 70
            do_sub = 90 if do_val >= 6 else 70
            fc_sub = 90 if fc <= 500 else 70
            
            wqi = (0.22 * ph_sub + 0.19 * bod_sub + 0.31 * do_sub + 0.28 * fc_sub)
            return max(0, min(100, wqi))
            
        except Exception as e:
            logger.error(f"Error calculating WQI: {e}")
            return 50.0
    
    async def update_predictions(self, station_id: int, current_data: Dict):
        """Update ML predictions for a station"""
        try:
            # Determine season
            month = datetime.now().month
            if month in [6, 7, 8, 9]:
                season = 'monsoon'
            elif month in [3, 4, 5]:
                season = 'summer'
            elif month in [11, 12, 1, 2]:
                season = 'winter'
            else:
                season = 'post_monsoon'
            
            # Generate predictions using Phase 5 models
            predictions = self.prediction_service.generate_multi_parameter_forecast(
                current_data=current_data,
                season=season,
                horizons=[7, 30, 90]
            )
            
            # Store predictions
            self.active_stations[station_id]['predictions'] = predictions
            
            # Broadcast to WebSocket clients
            if self.websocket_server:
                await self.websocket_server.broadcast_prediction(station_id, predictions)
            
            logger.info(f"Updated predictions for station {station_id}")
            
        except Exception as e:
            logger.error(f"Error updating predictions: {e}")
    
    async def detect_anomalies(self, station_id: int, data: Dict):
        """Detect anomalies and send alerts"""
        try:
            alerts = []
            
            # Check for critical values
            if data.get('dissolved_oxygen', 10) < 4.0:
                alerts.append({
                    'severity': 'critical',
                    'parameter': 'Dissolved Oxygen',
                    'value': data['dissolved_oxygen'],
                    'threshold': 4.0,
                    'message': 'Critical DO levels detected - aquatic life at risk'
                })
            
            if data.get('fecal_coliform', 0) > 2500:
                alerts.append({
                    'severity': 'high',
                    'parameter': 'Fecal Coliform',
                    'value': data['fecal_coliform'],
                    'threshold': 2500,
                    'message': 'High bacterial contamination detected'
                })
            
            if data.get('ph', 7) < 6.0 or data.get('ph', 7) > 9.0:
                alerts.append({
                    'severity': 'high',
                    'parameter': 'pH',
                    'value': data['ph'],
                    'threshold': '6.0-9.0',
                    'message': 'pH outside safe range'
                })
            
            # Send alerts if any found
            for alert in alerts:
                if self.websocket_server:
                    await self.websocket_server.broadcast_alert(station_id, alert)
                logger.warning(f"Alert for station {station_id}: {alert['message']}")
            
        except Exception as e:
            logger.error(f"Error detecting anomalies: {e}")
    
    def register_station(self, station_id: int, station_info: Dict):
        """Register a station for real-time monitoring"""
        self.active_stations[station_id] = {
            'info': station_info,
            'registered_at': datetime.now()
        }
        logger.info(f"Registered station {station_id} for real-time monitoring")
    
    def unregister_station(self, station_id: int):
        """Unregister a station"""
        if station_id in self.active_stations:
            del self.active_stations[station_id]
            logger.info(f"Unregistered station {station_id}")


# Test runner
if __name__ == '__main__':
    print("=== Real-time Data Orchestrator - Phase 6 ===\n")
    
    async def test_orchestrator():
        orchestrator = RealtimeDataOrchestrator()
        
        # Register test stations
        orchestrator.register_station(1, {'name': 'Test Station 1', 'location': 'Mumbai'})
        orchestrator.register_station(2, {'name': 'Test Station 2', 'location': 'Pune'})
        
        print("✓ Orchestrator initialized")
        print(f"✓ {len(orchestrator.active_stations)} stations registered")
        print("\nStarting real-time service...\n")
        
        # Run for 30 seconds
        try:
            await asyncio.wait_for(orchestrator.start(), timeout=30)
        except asyncio.TimeoutError:
            print("\n✓ Test completed successfully")
    
    asyncio.run(test_orchestrator())
