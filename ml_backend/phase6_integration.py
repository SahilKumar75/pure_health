"""
Phase 6 Integration Script
Starts WebSocket server + Real-time service + Flask backend
"""

import asyncio
import logging
from threading import Thread
import sys

# Import Phase 6 components
from websocket_server import RealtimeWebSocketServer
from realtime_service import RealtimeDataOrchestrator
from api_integrations import GovernmentAPIIntegration
from sensor_handler import IoTSensorHandler, SensorConfig
from satellite_processor import SatelliteDataProcessor, StationLocation

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class Phase6Integration:
    """
    Main integration class for Phase 6
    Coordinates all real-time components
    """
    
    def __init__(self):
        self.websocket_server = None
        self.orchestrator = None
        self.api_integration = None
        self.sensor_handler = None
        self.satellite_processor = None
        
    async def start(self):
        """Start all Phase 6 services"""
        logger.info("=== Phase 6: Real-time Data Integration - Starting ===\n")
        
        # 1. Initialize API integrations
        logger.info("1. Initializing Government API Integration...")
        self.api_integration = GovernmentAPIIntegration()
        logger.info("   ✓ API Integration ready\n")
        
        # 2. Initialize WebSocket server
        logger.info("2. Initializing WebSocket Server...")
        self.websocket_server = RealtimeWebSocketServer()
        logger.info("   ✓ WebSocket Server initialized")
        logger.info("   Endpoints:")
        logger.info("     - ws://localhost:8080/ws (general)")
        logger.info("     - ws://localhost:8080/ws/station/{id} (station-specific)")
        logger.info("     - http://localhost:8080/health (health check)")
        logger.info("     - http://localhost:8080/stats (statistics)\n")
        
        # 3. Initialize Real-time Orchestrator
        logger.info("3. Initializing Real-time Data Orchestrator...")
        self.orchestrator = RealtimeDataOrchestrator(
            websocket_server=self.websocket_server
        )
        logger.info("   ✓ Data Orchestrator ready\n")
        
        # 3b. Initialize IoT Sensor Handler
        logger.info("3b. Initializing IoT Sensor Handler...")
        self.sensor_handler = IoTSensorHandler(
            mqtt_broker="localhost",
            mqtt_port=1883
        )
        await self.sensor_handler.start()
        
        # Register sensor data callback to forward to orchestrator
        def on_sensor_data(reading):
            # Forward sensor reading to orchestrator
            asyncio.create_task(
                self.websocket_server.broadcast_update(
                    reading.station_id,
                    {
                        'timestamp': reading.timestamp,
                        'parameter': reading.parameter,
                        'value': reading.value,
                        'unit': reading.unit,
                        'quality': reading.quality,
                        'source': 'iot_sensor'
                    }
                )
            )
        
        self.sensor_handler.register_callback(on_sensor_data)
        logger.info("   ✓ IoT Sensor Handler ready\n")
        
        # 3c. Initialize Satellite Data Processor
        logger.info("3c. Initializing Satellite Data Processor...")
        self.satellite_processor = SatelliteDataProcessor()
        await self.satellite_processor.start()
        logger.info("   ✓ Satellite Processor ready\n")
        
        # 4. Register test stations
        logger.info("4. Registering stations for real-time monitoring...")
        test_stations = [
            {'id': 1, 'name': 'Mithi River - Powai', 'location': 'Mumbai', 'lat': 19.1197, 'lon': 72.9133},
            {'id': 2, 'name': 'Godavari River - Nashik', 'location': 'Nashik', 'lat': 19.9975, 'lon': 73.7898},
            {'id': 3, 'name': 'Mula-Mutha River', 'location': 'Pune', 'lat': 18.5204, 'lon': 73.8567},
        ]
        
        for station in test_stations:
            # Register with orchestrator
            self.orchestrator.register_station(station['id'], station)
            logger.info(f"   ✓ Station {station['id']}: {station['name']}")
            
            # Register with satellite processor
            sat_location = StationLocation(
                station_id=str(station['id']),
                name=station['name'],
                latitude=station['lat'],
                longitude=station['lon'],
                buffer_km=1.0
            )
            self.satellite_processor.register_station(sat_location)
        
        # 5. Register test IoT sensors
        logger.info("\n5. Registering IoT sensors...")
        test_sensors = [
            SensorConfig(
                sensor_id="sensor_ph_001",
                station_id="1",
                protocol="mqtt",
                parameter="ph",
                mqtt_topic="purehealth/station1/ph",
                min_value=0.0,
                max_value=14.0
            ),
            SensorConfig(
                sensor_id="sensor_do_001",
                station_id="1",
                protocol="mqtt",
                parameter="do",
                mqtt_topic="purehealth/station1/do",
                min_value=0.0,
                max_value=20.0
            ),
        ]
        
        for sensor in test_sensors:
            self.sensor_handler.register_sensor(sensor)
            logger.info(f"   ✓ {sensor.protocol.upper()} sensor: {sensor.sensor_id} ({sensor.parameter})")
        
        logger.info("\n=== Phase 6 Services Started Successfully ===")
        logger.info("Real-time monitoring active for 3 stations")
        logger.info("IoT sensors configured: 2")
        logger.info("Satellite data sources: Sentinel-2, Landsat 8")
        logger.info("Press Ctrl+C to stop\n")
        
        # Start background tasks
        try:
            # Run WebSocket server and orchestrator concurrently
            await asyncio.gather(
                self.run_websocket_server(),
                self.orchestrator.start()
            )
        except KeyboardInterrupt:
            logger.info("\nShutting down...")
            await self.stop()
    
    async def run_websocket_server(self):
        """Run WebSocket server in async context"""
        from aiohttp import web
        runner = web.AppRunner(self.websocket_server.app)
        await runner.setup()
        site = web.TCPSite(runner, '0.0.0.0', 8080)
        await site.start()
        
        # Keep running
        while True:
            await asyncio.sleep(3600)
    
    async def stop(self):
        """Stop all services"""
        logger.info("Stopping Phase 6 services...")
        
        if self.sensor_handler:
            await self.sensor_handler.stop()
        
        if self.satellite_processor:
            await self.satellite_processor.stop()
        
        logger.info("✓ All services stopped")


async def main():
    """Main entry point"""
    integration = Phase6Integration()
    try:
        await integration.start()
    except KeyboardInterrupt:
        print("\n\nShutdown requested")
    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)
        sys.exit(1)


if __name__ == '__main__':
    print("""
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║   Pure Health - Phase 6: Real-time Data Integration           ║
║                                                                ║
║   Components:                                                  ║
║   • WebSocket Server (Real-time communication)                 ║
║   • Data Orchestrator (Multi-source integration)               ║
║   • API Integration Layer (CPCB/MPCB/CWC/IMD)                  ║
║   • IoT Sensor Handler (MQTT/HTTP sensors)                     ║
║   • Satellite Data Processor (Sentinel-2, Landsat 8)           ║
║   • ML Prediction Updates (Phase 5 models)                     ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
    """)
    
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n\n✓ Phase 6 services stopped")
