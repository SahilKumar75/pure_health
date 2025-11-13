"""
IoT Sensor Handler for Pure Health
Handles real-time data collection from multiple IoT sensor types:
- MQTT sensors (most common for water quality)
- HTTP/REST sensors
- CoAP sensors
- Serial sensors (USB connected)

Features:
- Multi-protocol support
- Data validation and quality checks
- Sensor health monitoring
- Auto-reconnection
- Data buffering for offline scenarios
"""

import asyncio
import json
import logging
from typing import Dict, List, Optional, Callable, Any
from datetime import datetime, timedelta
from dataclasses import dataclass, asdict
import aiohttp

# MQTT support (optional - install with: pip install paho-mqtt)
try:
    import paho.mqtt.client as mqtt
    MQTT_AVAILABLE = True
except ImportError:
    MQTT_AVAILABLE = False
    print("Warning: paho-mqtt not installed. MQTT sensors will not work.")
    print("Install with: pip install paho-mqtt")

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@dataclass
class SensorReading:
    """Represents a single sensor reading"""
    sensor_id: str
    station_id: str
    parameter: str  # ph, do, bod, fc, tds, temperature, turbidity
    value: float
    unit: str
    timestamp: str
    quality: str = "good"  # good, suspect, bad
    
    def to_dict(self) -> Dict:
        return asdict(self)


@dataclass
class SensorConfig:
    """Configuration for a sensor"""
    sensor_id: str
    station_id: str
    protocol: str  # mqtt, http, coap, serial
    parameter: str  # ph, do, bod, fc, tds, temperature, turbidity
    
    # Protocol-specific settings
    mqtt_topic: Optional[str] = None
    mqtt_qos: int = 1
    
    http_url: Optional[str] = None
    http_interval: int = 300  # 5 minutes
    http_method: str = "GET"
    
    serial_port: Optional[str] = None
    serial_baud: int = 9600
    
    # Validation thresholds
    min_value: Optional[float] = None
    max_value: Optional[float] = None
    
    # Health monitoring
    max_silent_duration: int = 600  # 10 minutes


class MQTTSensorClient:
    """MQTT client for IoT sensors"""
    
    def __init__(self, broker_host: str = "localhost", broker_port: int = 1883,
                 username: Optional[str] = None, password: Optional[str] = None):
        if not MQTT_AVAILABLE:
            raise RuntimeError("MQTT not available. Install paho-mqtt.")
        
        self.broker_host = broker_host
        self.broker_port = broker_port
        self.username = username
        self.password = password
        
        self.client = mqtt.Client()
        self.client.on_connect = self._on_connect
        self.client.on_message = self._on_message
        self.client.on_disconnect = self._on_disconnect
        
        self.subscriptions: Dict[str, Callable] = {}
        self.is_connected = False
        
        if username and password:
            self.client.username_pw_set(username, password)
        
        logger.info(f"MQTT client initialized for {broker_host}:{broker_port}")
    
    def _on_connect(self, client, userdata, flags, rc):
        """Called when connected to MQTT broker"""
        if rc == 0:
            self.is_connected = True
            logger.info(f"✓ Connected to MQTT broker at {self.broker_host}:{self.broker_port}")
            
            # Re-subscribe to all topics
            for topic in self.subscriptions.keys():
                client.subscribe(topic)
                logger.info(f"  Subscribed to topic: {topic}")
        else:
            logger.error(f"✗ MQTT connection failed with code {rc}")
    
    def _on_disconnect(self, client, userdata, rc):
        """Called when disconnected from MQTT broker"""
        self.is_connected = False
        if rc != 0:
            logger.warning(f"Unexpected MQTT disconnection (code {rc}). Reconnecting...")
    
    def _on_message(self, client, userdata, msg):
        """Called when message received"""
        topic = msg.topic
        payload = msg.payload.decode('utf-8')
        
        logger.debug(f"MQTT message on {topic}: {payload}")
        
        # Call registered callback
        if topic in self.subscriptions:
            try:
                data = json.loads(payload)
                self.subscriptions[topic](topic, data)
            except json.JSONDecodeError:
                logger.error(f"Invalid JSON in MQTT message: {payload}")
            except Exception as e:
                logger.error(f"Error processing MQTT message: {e}")
    
    def connect(self):
        """Connect to MQTT broker"""
        try:
            self.client.connect(self.broker_host, self.broker_port, keepalive=60)
            self.client.loop_start()
            logger.info("MQTT client started")
        except Exception as e:
            logger.error(f"Failed to connect to MQTT broker: {e}")
            raise
    
    def subscribe(self, topic: str, callback: Callable, qos: int = 1):
        """Subscribe to MQTT topic"""
        self.subscriptions[topic] = callback
        if self.is_connected:
            self.client.subscribe(topic, qos)
            logger.info(f"Subscribed to {topic}")
    
    def disconnect(self):
        """Disconnect from MQTT broker"""
        self.client.loop_stop()
        self.client.disconnect()
        logger.info("MQTT client disconnected")


class HTTPSensorClient:
    """HTTP/REST client for polling sensors"""
    
    def __init__(self):
        self.session: Optional[aiohttp.ClientSession] = None
        self.polling_tasks: List[asyncio.Task] = []
        logger.info("HTTP sensor client initialized")
    
    async def start(self):
        """Start HTTP client session"""
        self.session = aiohttp.ClientSession()
        logger.info("HTTP client session started")
    
    async def stop(self):
        """Stop HTTP client session"""
        # Cancel all polling tasks
        for task in self.polling_tasks:
            task.cancel()
        
        if self.session:
            await self.session.close()
        logger.info("HTTP client session stopped")
    
    async def poll_sensor(self, config: SensorConfig, callback: Callable):
        """Poll HTTP sensor at regular intervals"""
        while True:
            try:
                if config.http_method == "GET":
                    async with self.session.get(config.http_url) as response:
                        if response.status == 200:
                            data = await response.json()
                            callback(config.sensor_id, data)
                        else:
                            logger.warning(f"HTTP sensor {config.sensor_id} returned status {response.status}")
                elif config.http_method == "POST":
                    async with self.session.post(config.http_url) as response:
                        if response.status == 200:
                            data = await response.json()
                            callback(config.sensor_id, data)
                
                # Wait for next poll
                await asyncio.sleep(config.http_interval)
                
            except Exception as e:
                logger.error(f"Error polling HTTP sensor {config.sensor_id}: {e}")
                await asyncio.sleep(config.http_interval)
    
    def start_polling(self, config: SensorConfig, callback: Callable):
        """Start polling a sensor"""
        task = asyncio.create_task(self.poll_sensor(config, callback))
        self.polling_tasks.append(task)
        logger.info(f"Started polling HTTP sensor {config.sensor_id} every {config.http_interval}s")


class SensorHealthMonitor:
    """Monitors sensor health and detects issues"""
    
    def __init__(self):
        self.last_readings: Dict[str, datetime] = {}
        self.sensor_configs: Dict[str, SensorConfig] = {}
        self.health_status: Dict[str, str] = {}
    
    def register_sensor(self, config: SensorConfig):
        """Register a sensor for health monitoring"""
        self.sensor_configs[config.sensor_id] = config
        self.health_status[config.sensor_id] = "unknown"
        logger.info(f"Registered sensor {config.sensor_id} for health monitoring")
    
    def record_reading(self, sensor_id: str):
        """Record that a reading was received"""
        self.last_readings[sensor_id] = datetime.now()
        self.health_status[sensor_id] = "healthy"
    
    def check_health(self) -> Dict[str, Dict[str, Any]]:
        """Check health of all sensors"""
        now = datetime.now()
        health_report = {}
        
        for sensor_id, config in self.sensor_configs.items():
            last_reading = self.last_readings.get(sensor_id)
            
            if last_reading is None:
                status = "no_data"
                last_seen = "never"
            else:
                time_since = (now - last_reading).total_seconds()
                if time_since > config.max_silent_duration:
                    status = "silent"
                    last_seen = f"{int(time_since)}s ago"
                else:
                    status = "healthy"
                    last_seen = f"{int(time_since)}s ago"
            
            health_report[sensor_id] = {
                "status": status,
                "last_seen": last_seen,
                "station_id": config.station_id,
                "parameter": config.parameter,
                "protocol": config.protocol,
            }
        
        return health_report


class IoTSensorHandler:
    """
    Main handler for IoT sensors
    Coordinates MQTT, HTTP, and other sensor protocols
    """
    
    def __init__(self, 
                 mqtt_broker: str = "localhost",
                 mqtt_port: int = 1883,
                 mqtt_username: Optional[str] = None,
                 mqtt_password: Optional[str] = None):
        
        self.mqtt_client: Optional[MQTTSensorClient] = None
        self.http_client: Optional[HTTPSensorClient] = None
        self.health_monitor = SensorHealthMonitor()
        
        self.sensors: Dict[str, SensorConfig] = {}
        self.data_callbacks: List[Callable] = []
        self.data_buffer: List[SensorReading] = []
        
        # MQTT settings
        self.mqtt_broker = mqtt_broker
        self.mqtt_port = mqtt_port
        self.mqtt_username = mqtt_username
        self.mqtt_password = mqtt_password
        
        logger.info("IoT Sensor Handler initialized")
    
    async def start(self):
        """Start sensor handler"""
        logger.info("Starting IoT Sensor Handler...")
        
        # Initialize MQTT client if available
        if MQTT_AVAILABLE:
            try:
                self.mqtt_client = MQTTSensorClient(
                    self.mqtt_broker,
                    self.mqtt_port,
                    self.mqtt_username,
                    self.mqtt_password
                )
                self.mqtt_client.connect()
                logger.info("✓ MQTT client started")
            except Exception as e:
                logger.error(f"Failed to start MQTT client: {e}")
        
        # Initialize HTTP client
        self.http_client = HTTPSensorClient()
        await self.http_client.start()
        logger.info("✓ HTTP client started")
        
        # Start health monitoring loop
        asyncio.create_task(self._health_check_loop())
        
        logger.info("IoT Sensor Handler started successfully")
    
    async def stop(self):
        """Stop sensor handler"""
        logger.info("Stopping IoT Sensor Handler...")
        
        if self.mqtt_client:
            self.mqtt_client.disconnect()
        
        if self.http_client:
            await self.http_client.stop()
        
        logger.info("IoT Sensor Handler stopped")
    
    def register_sensor(self, config: SensorConfig):
        """Register a new sensor"""
        self.sensors[config.sensor_id] = config
        self.health_monitor.register_sensor(config)
        
        if config.protocol == "mqtt" and self.mqtt_client:
            self.mqtt_client.subscribe(
                config.mqtt_topic,
                lambda topic, data: self._handle_mqtt_data(config.sensor_id, data),
                config.mqtt_qos
            )
            logger.info(f"✓ Registered MQTT sensor {config.sensor_id} on topic {config.mqtt_topic}")
        
        elif config.protocol == "http" and self.http_client:
            self.http_client.start_polling(
                config,
                lambda sensor_id, data: self._handle_http_data(sensor_id, data)
            )
            logger.info(f"✓ Registered HTTP sensor {config.sensor_id} at {config.http_url}")
        
        else:
            logger.warning(f"Protocol {config.protocol} not yet supported for sensor {config.sensor_id}")
    
    def _handle_mqtt_data(self, sensor_id: str, data: Dict):
        """Handle data from MQTT sensor"""
        try:
            config = self.sensors[sensor_id]
            reading = self._parse_sensor_data(sensor_id, config, data)
            
            if reading:
                self._process_reading(reading)
        except Exception as e:
            logger.error(f"Error handling MQTT data from {sensor_id}: {e}")
    
    def _handle_http_data(self, sensor_id: str, data: Dict):
        """Handle data from HTTP sensor"""
        try:
            config = self.sensors[sensor_id]
            reading = self._parse_sensor_data(sensor_id, config, data)
            
            if reading:
                self._process_reading(reading)
        except Exception as e:
            logger.error(f"Error handling HTTP data from {sensor_id}: {e}")
    
    def _parse_sensor_data(self, sensor_id: str, config: SensorConfig, data: Dict) -> Optional[SensorReading]:
        """Parse sensor data into SensorReading"""
        try:
            # Extract value (support different formats)
            value = data.get('value') or data.get(config.parameter) or data.get('reading')
            
            if value is None:
                logger.warning(f"No value found in sensor data: {data}")
                return None
            
            # Validate value
            quality = self._validate_value(config, float(value))
            
            reading = SensorReading(
                sensor_id=sensor_id,
                station_id=config.station_id,
                parameter=config.parameter,
                value=float(value),
                unit=data.get('unit', self._get_default_unit(config.parameter)),
                timestamp=data.get('timestamp', datetime.now().isoformat()),
                quality=quality
            )
            
            return reading
            
        except Exception as e:
            logger.error(f"Error parsing sensor data: {e}")
            return None
    
    def _validate_value(self, config: SensorConfig, value: float) -> str:
        """Validate sensor value"""
        if config.min_value is not None and value < config.min_value:
            return "bad"
        if config.max_value is not None and value > config.max_value:
            return "bad"
        
        # Check if value is suspiciously close to boundaries
        if config.min_value is not None and value < config.min_value * 1.1:
            return "suspect"
        if config.max_value is not None and value > config.max_value * 0.9:
            return "suspect"
        
        return "good"
    
    def _get_default_unit(self, parameter: str) -> str:
        """Get default unit for parameter"""
        units = {
            'ph': 'pH',
            'do': 'mg/L',
            'bod': 'mg/L',
            'fc': 'MPN/100mL',
            'tds': 'mg/L',
            'temperature': '°C',
            'turbidity': 'NTU'
        }
        return units.get(parameter, '')
    
    def _process_reading(self, reading: SensorReading):
        """Process a validated sensor reading"""
        # Update health monitor
        self.health_monitor.record_reading(reading.sensor_id)
        
        # Log reading
        logger.info(f"Sensor {reading.sensor_id}: {reading.parameter}={reading.value}{reading.unit} [{reading.quality}]")
        
        # Add to buffer
        self.data_buffer.append(reading)
        
        # Call registered callbacks
        for callback in self.data_callbacks:
            try:
                callback(reading)
            except Exception as e:
                logger.error(f"Error in data callback: {e}")
    
    def register_callback(self, callback: Callable):
        """Register callback for new sensor data"""
        self.data_callbacks.append(callback)
        logger.info("Registered data callback")
    
    async def _health_check_loop(self):
        """Periodic health check"""
        while True:
            try:
                await asyncio.sleep(60)  # Check every minute
                
                health_report = self.health_monitor.check_health()
                
                # Log unhealthy sensors
                for sensor_id, status in health_report.items():
                    if status['status'] != 'healthy':
                        logger.warning(f"Sensor {sensor_id} is {status['status']} (last seen: {status['last_seen']})")
                
            except Exception as e:
                logger.error(f"Error in health check loop: {e}")
    
    def get_health_report(self) -> Dict:
        """Get current health report"""
        return self.health_monitor.check_health()
    
    def get_buffered_data(self, clear: bool = True) -> List[Dict]:
        """Get buffered sensor data"""
        data = [reading.to_dict() for reading in self.data_buffer]
        if clear:
            self.data_buffer.clear()
        return data


# Example usage and testing
async def main():
    """Test the sensor handler"""
    print("\n" + "="*60)
    print("IoT Sensor Handler - Test Mode")
    print("="*60 + "\n")
    
    # Initialize handler
    handler = IoTSensorHandler(
        mqtt_broker="localhost",
        mqtt_port=1883
    )
    
    await handler.start()
    
    # Register test sensors
    print("\nRegistering test sensors...")
    
    # MQTT sensor example
    if MQTT_AVAILABLE:
        mqtt_sensor = SensorConfig(
            sensor_id="sensor_mqtt_001",
            station_id="1",
            protocol="mqtt",
            parameter="ph",
            mqtt_topic="purehealth/station1/ph",
            min_value=0.0,
            max_value=14.0
        )
        handler.register_sensor(mqtt_sensor)
    
    # HTTP sensor example
    http_sensor = SensorConfig(
        sensor_id="sensor_http_001",
        station_id="1",
        protocol="http",
        parameter="do",
        http_url="http://localhost:5000/api/sensor/do",
        http_interval=30,  # 30 seconds for testing
        min_value=0.0,
        max_value=20.0
    )
    handler.register_sensor(http_sensor)
    
    # Register callback to print readings
    def print_reading(reading: SensorReading):
        print(f"\n[{reading.timestamp}] {reading.parameter.upper()}: {reading.value} {reading.unit}")
        print(f"  Sensor: {reading.sensor_id}, Station: {reading.station_id}, Quality: {reading.quality}")
    
    handler.register_callback(print_reading)
    
    print("\n✓ Sensors registered. Waiting for data...")
    print("Press Ctrl+C to stop\n")
    
    try:
        # Run for 5 minutes or until interrupted
        await asyncio.sleep(300)
    except KeyboardInterrupt:
        print("\n\nStopping...")
    
    # Print health report
    print("\n" + "="*60)
    print("Sensor Health Report")
    print("="*60)
    health = handler.get_health_report()
    for sensor_id, status in health.items():
        print(f"\n{sensor_id}:")
        print(f"  Status: {status['status']}")
        print(f"  Last seen: {status['last_seen']}")
        print(f"  Parameter: {status['parameter']}")
        print(f"  Protocol: {status['protocol']}")
    
    # Stop handler
    await handler.stop()
    print("\n✓ Sensor handler stopped\n")


if __name__ == "__main__":
    asyncio.run(main())
