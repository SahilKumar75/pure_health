"""
IoT Sensor Handler - Phase 6
Manages MQTT-based IoT sensors for real-time water quality monitoring
"""

import json
import time
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional, Callable
from collections import deque
import threading


try:
    import paho.mqtt.client as mqtt
    MQTT_AVAILABLE = True
except ImportError:
    MQTT_AVAILABLE = False
    print("⚠️ paho-mqtt not installed. Install with: pip install paho-mqtt")


class SensorReading:
    """Represents a single sensor reading"""
    
    def __init__(self, sensor_id: str, parameter: str, value: float, 
                 timestamp: datetime = None, quality: float = 1.0):
        self.sensor_id = sensor_id
        self.parameter = parameter
        self.value = value
        self.timestamp = timestamp or datetime.now()
        self.quality = quality  # Data quality score 0-1
        
    def to_dict(self) -> Dict:
        return {
            'sensor_id': self.sensor_id,
            'parameter': self.parameter,
            'value': self.value,
            'timestamp': self.timestamp.isoformat(),
            'quality': self.quality
        }
    
    def is_valid(self) -> bool:
        """Check if reading is within reasonable bounds"""
        bounds = {
            'ph': (0, 14),
            'temperature': (-10, 50),
            'dissolved_oxygen': (0, 20),
            'turbidity': (0, 1000),
            'bod': (0, 100),
            'conductivity': (0, 10000),
            'tds': (0, 5000)
        }
        
        if self.parameter.lower() in bounds:
            min_val, max_val = bounds[self.parameter.lower()]
            return min_val <= self.value <= max_val
        
        return True  # Unknown parameters pass


class SensorHealthMonitor:
    """Monitors sensor health and detects failures"""
    
    def __init__(self, check_interval: int = 300):
        self.check_interval = check_interval  # seconds
        self.sensor_states = {}
        self.last_readings = {}
        
    def update_sensor(self, sensor_id: str, reading: SensorReading):
        """Update sensor health status"""
        now = datetime.now()
        
        if sensor_id not in self.sensor_states:
            self.sensor_states[sensor_id] = {
                'status': 'active',
                'last_seen': now,
                'reading_count': 0,
                'error_count': 0,
                'first_seen': now
            }
        
        state = self.sensor_states[sensor_id]
        state['last_seen'] = now
        state['reading_count'] += 1
        
        if not reading.is_valid():
            state['error_count'] += 1
        
        self.last_readings[sensor_id] = reading
        
        # Update status
        if state['error_count'] > 10:
            state['status'] = 'degraded'
        else:
            state['status'] = 'active'
    
    def check_health(self, sensor_id: str) -> Dict[str, Any]:
        """Get sensor health status"""
        if sensor_id not in self.sensor_states:
            return {'status': 'unknown', 'message': 'Sensor not found'}
        
        state = self.sensor_states[sensor_id]
        now = datetime.now()
        time_since_last = (now - state['last_seen']).total_seconds()
        
        if time_since_last > self.check_interval:
            state['status'] = 'offline'
            return {
                'status': 'offline',
                'last_seen': state['last_seen'].isoformat(),
                'time_since_last': f"{int(time_since_last)}s"
            }
        
        error_rate = state['error_count'] / max(state['reading_count'], 1)
        
        return {
            'status': state['status'],
            'last_seen': state['last_seen'].isoformat(),
            'reading_count': state['reading_count'],
            'error_count': state['error_count'],
            'error_rate': round(error_rate, 3),
            'uptime': str(now - state['first_seen'])
        }
    
    def get_all_sensors_health(self) -> Dict[str, Dict]:
        """Get health status of all sensors"""
        return {
            sensor_id: self.check_health(sensor_id)
            for sensor_id in self.sensor_states.keys()
        }


class MQTTSensorHandler:
    """
    Handles MQTT-based IoT sensor communication
    Supports multiple sensors, topics, and real-time data streaming
    """
    
    def __init__(self, broker_url: str = "localhost", broker_port: int = 1883,
                 username: Optional[str] = None, password: Optional[str] = None):
        
        if not MQTT_AVAILABLE:
            raise ImportError("paho-mqtt library not available. Install with: pip install paho-mqtt")
        
        self.broker_url = broker_url
        self.broker_port = broker_port
        self.username = username
        self.password = password
        
        self.client = mqtt.Client(client_id=f"pure_health_{int(time.time())}")
        self.client.on_connect = self._on_connect
        self.client.on_message = self._on_message
        self.client.on_disconnect = self._on_disconnect
        
        if username and password:
            self.client.username_pw_set(username, password)
        
        self.connected = False
        self.subscribed_topics = set()
        self.message_handlers = []
        self.sensor_buffer = deque(maxlen=1000)  # Store last 1000 readings
        self.health_monitor = SensorHealthMonitor()
        
    def connect(self) -> bool:
        """Connect to MQTT broker"""
        try:
            print(f"🔌 Connecting to MQTT broker at {self.broker_url}:{self.broker_port}...")
            self.client.connect(self.broker_url, self.broker_port, keepalive=60)
            self.client.loop_start()
            
            # Wait for connection
            timeout = 10
            start_time = time.time()
            while not self.connected and (time.time() - start_time) < timeout:
                time.sleep(0.1)
            
            if self.connected:
                print("✅ Connected to MQTT broker")
                return True
            else:
                print("❌ Connection timeout")
                return False
                
        except Exception as e:
            print(f"❌ Connection failed: {e}")
            return False
    
    def disconnect(self):
        """Disconnect from MQTT broker"""
        self.client.loop_stop()
        self.client.disconnect()
        self.connected = False
        print("🔌 Disconnected from MQTT broker")
    
    def subscribe_to_sensor(self, sensor_id: str, parameter: str = "#"):
        """
        Subscribe to sensor topic
        
        Args:
            sensor_id: Sensor identifier
            parameter: Specific parameter or "#" for all
        """
        topic = f"sensors/{sensor_id}/{parameter}"
        self.client.subscribe(topic)
        self.subscribed_topics.add(topic)
        print(f"📡 Subscribed to: {topic}")
    
    def subscribe_to_station(self, station_id: str):
        """Subscribe to all sensors at a station"""
        topic = f"stations/{station_id}/#"
        self.client.subscribe(topic)
        self.subscribed_topics.add(topic)
        print(f"📡 Subscribed to station: {station_id}")
    
    def add_message_handler(self, handler: Callable[[SensorReading], None]):
        """Add callback function to handle incoming messages"""
        self.message_handlers.append(handler)
    
    def publish_reading(self, sensor_id: str, parameter: str, value: float):
        """
        Publish a sensor reading (for testing)
        
        Args:
            sensor_id: Sensor identifier
            parameter: Parameter name (pH, temperature, etc.)
            value: Measurement value
        """
        topic = f"sensors/{sensor_id}/{parameter}"
        payload = {
            'value': value,
            'timestamp': datetime.now().isoformat(),
            'sensor_id': sensor_id,
            'parameter': parameter
        }
        
        self.client.publish(topic, json.dumps(payload), qos=1)
    
    def get_recent_readings(self, sensor_id: Optional[str] = None, 
                           parameter: Optional[str] = None, 
                           limit: int = 100) -> List[SensorReading]:
        """
        Get recent sensor readings from buffer
        
        Args:
            sensor_id: Filter by sensor ID
            parameter: Filter by parameter
            limit: Maximum number of readings
        
        Returns:
            List of sensor readings
        """
        readings = list(self.sensor_buffer)
        
        if sensor_id:
            readings = [r for r in readings if r.sensor_id == sensor_id]
        
        if parameter:
            readings = [r for r in readings if r.parameter.lower() == parameter.lower()]
        
        return readings[-limit:]
    
    def get_sensor_health(self, sensor_id: Optional[str] = None) -> Dict:
        """Get health status of sensor(s)"""
        if sensor_id:
            return self.health_monitor.check_health(sensor_id)
        else:
            return self.health_monitor.get_all_sensors_health()
    
    def _on_connect(self, client, userdata, flags, rc):
        """Callback when connected to broker"""
        if rc == 0:
            self.connected = True
            print("✅ MQTT connection established")
        else:
            print(f"❌ MQTT connection failed with code: {rc}")
    
    def _on_disconnect(self, client, userdata, rc):
        """Callback when disconnected from broker"""
        self.connected = False
        if rc != 0:
            print(f"⚠️ Unexpected MQTT disconnect. Attempting reconnect...")
            self._attempt_reconnect()
    
    def _on_message(self, client, userdata, message):
        """Callback when message received"""
        try:
            # Parse message
            payload = json.loads(message.payload.decode())
            
            # Extract sensor info from topic (e.g., "sensors/MH001/ph")
            topic_parts = message.topic.split('/')
            
            if len(topic_parts) >= 3:
                sensor_id = topic_parts[1]
                parameter = topic_parts[2]
            else:
                sensor_id = payload.get('sensor_id', 'unknown')
                parameter = payload.get('parameter', 'unknown')
            
            # Create reading
            reading = SensorReading(
                sensor_id=sensor_id,
                parameter=parameter,
                value=float(payload.get('value', 0)),
                timestamp=datetime.fromisoformat(payload.get('timestamp', datetime.now().isoformat())),
                quality=float(payload.get('quality', 1.0))
            )
            
            # Validate and store
            if reading.is_valid():
                self.sensor_buffer.append(reading)
                self.health_monitor.update_sensor(sensor_id, reading)
                
                # Call registered handlers
                for handler in self.message_handlers:
                    try:
                        handler(reading)
                    except Exception as e:
                        print(f"⚠️ Handler error: {e}")
            else:
                print(f"⚠️ Invalid reading: {reading.to_dict()}")
                
        except Exception as e:
            print(f"⚠️ Error processing message: {e}")
    
    def _attempt_reconnect(self, max_attempts: int = 5):
        """Attempt to reconnect to broker"""
        for attempt in range(max_attempts):
            print(f"🔄 Reconnection attempt {attempt + 1}/{max_attempts}")
            if self.connect():
                # Re-subscribe to topics
                for topic in self.subscribed_topics:
                    self.client.subscribe(topic)
                print("✅ Reconnected and re-subscribed")
                return True
            time.sleep(2 ** attempt)  # Exponential backoff
        
        print("❌ Reconnection failed")
        return False


class SimulatedSensorNetwork:
    """
    Simulates a network of IoT sensors for testing
    Generates realistic water quality data
    """
    
    def __init__(self, num_sensors: int = 5):
        self.num_sensors = num_sensors
        self.sensors = self._create_sensors()
        self.running = False
        self.thread = None
        
    def _create_sensors(self) -> List[Dict]:
        """Create simulated sensors"""
        return [
            {
                'id': f'SENSOR_{i:03d}',
                'station': f'MH{i:03d}',
                'parameters': ['ph', 'temperature', 'dissolved_oxygen', 'turbidity'],
                'interval': 60  # seconds
            }
            for i in range(self.num_sensors)
        ]
    
    def start(self, mqtt_handler: MQTTSensorHandler):
        """Start generating simulated data"""
        self.running = True
        self.thread = threading.Thread(target=self._generate_data, args=(mqtt_handler,))
        self.thread.daemon = True
        self.thread.start()
        print(f"🤖 Started simulating {self.num_sensors} sensors")
    
    def stop(self):
        """Stop simulation"""
        self.running = False
        if self.thread:
            self.thread.join(timeout=5)
        print("🛑 Stopped sensor simulation")
    
    def _generate_data(self, mqtt_handler: MQTTSensorHandler):
        """Generate and publish simulated readings"""
        import random
        
        while self.running:
            for sensor in self.sensors:
                for param in sensor['parameters']:
                    # Generate realistic value based on parameter
                    if param == 'ph':
                        value = 7.0 + random.gauss(0, 0.5)
                    elif param == 'temperature':
                        value = 25.0 + random.gauss(0, 3)
                    elif param == 'dissolved_oxygen':
                        value = 6.0 + random.gauss(0, 1)
                    elif param == 'turbidity':
                        value = 10.0 + random.gauss(0, 5)
                    else:
                        value = random.gauss(50, 10)
                    
                    # Publish reading
                    mqtt_handler.publish_reading(sensor['id'], param, max(0, value))
            
            time.sleep(60)  # Wait 1 minute before next batch


# Example usage and testing
if __name__ == '__main__':
    print("=== IoT Sensor Handler - Phase 6 Testing ===\n")
    
    if not MQTT_AVAILABLE:
        print("⚠️ MQTT library not available. Install with:")
        print("   pip install paho-mqtt")
        print("\nUsing fallback mode for demonstration...\n")
        
        # Create simulated readings for demonstration
        print("Creating simulated sensor readings...")
        for i in range(5):
            reading = SensorReading(
                sensor_id=f'SENSOR_{i:03d}',
                parameter='ph',
                value=7.0 + (i * 0.2)
            )
            print(f"  {reading.to_dict()}")
        
        print("\n✅ Sensor handler module loaded (MQTT unavailable)")
    else:
        # Full MQTT test
        print("Test 1: Connecting to local MQTT broker...")
        handler = MQTTSensorHandler(broker_url="localhost")
        
        try:
            if handler.connect():
                # Subscribe to test topics
                handler.subscribe_to_sensor("TEST_SENSOR", "ph")
                handler.subscribe_to_station("MH001")
                
                # Add message handler
                def print_reading(reading: SensorReading):
                    print(f"📊 Received: {reading.parameter} = {reading.value} from {reading.sensor_id}")
                
                handler.add_message_handler(print_reading)
                
                # Publish test reading
                print("\nPublishing test readings...")
                handler.publish_reading("TEST_SENSOR", "ph", 7.2)
                handler.publish_reading("TEST_SENSOR", "temperature", 25.5)
                
                time.sleep(2)
                
                # Check health
                health = handler.get_sensor_health()
                print(f"\n✅ Sensors online: {len(health)}")
                
                # Disconnect
                handler.disconnect()
            else:
                print("⚠️ Could not connect to MQTT broker")
                print("   Make sure an MQTT broker is running on localhost:1883")
                print("   Or use: docker run -p 1883:1883 eclipse-mosquitto")
                
        except Exception as e:
            print(f"❌ Error: {e}")
    
    print("\n=== IoT Sensor Handler Ready ===")
