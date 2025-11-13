"""
TimescaleDB Integration for Pure Health
High-performance time-series database for water quality data

Features:
- Hypertables for efficient time-series storage
- Continuous aggregates for fast queries
- Data retention policies
- Compression for old data
- Real-time inserts with high throughput
- Automated rollups (hourly, daily, weekly)

TimescaleDB extends PostgreSQL with time-series capabilities:
- 10-100x faster than regular PostgreSQL for time-series
- Automatic partitioning by time
- Native SQL interface
"""

import asyncio
import logging
from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
from dataclasses import dataclass
import json

# PostgreSQL async driver
try:
    import asyncpg
    ASYNCPG_AVAILABLE = True
except ImportError:
    ASYNCPG_AVAILABLE = False
    print("Warning: asyncpg not installed. TimescaleDB features disabled.")
    print("Install with: pip install asyncpg")

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@dataclass
class DatabaseConfig:
    """TimescaleDB connection configuration"""
    host: str = "localhost"
    port: int = 5432
    database: str = "pure_health"
    user: str = "postgres"
    password: str = "postgres"
    
    def get_dsn(self) -> str:
        """Get database connection string"""
        return f"postgresql://{self.user}:{self.password}@{self.host}:{self.port}/{self.database}"


class TimescaleDBManager:
    """
    TimescaleDB manager for water quality data
    Handles hypertables, continuous aggregates, and retention policies
    """
    
    def __init__(self, config: DatabaseConfig):
        self.config = config
        self.pool: Optional[asyncpg.Pool] = None
        logger.info(f"TimescaleDB manager initialized for {config.database}@{config.host}")
    
    async def connect(self):
        """Create connection pool"""
        if not ASYNCPG_AVAILABLE:
            raise RuntimeError("asyncpg not installed. Cannot connect to TimescaleDB.")
        
        try:
            self.pool = await asyncpg.create_pool(
                host=self.config.host,
                port=self.config.port,
                database=self.config.database,
                user=self.config.user,
                password=self.config.password,
                min_size=5,
                max_size=20,
                command_timeout=60
            )
            logger.info("✓ Connected to TimescaleDB")
            
            # Verify TimescaleDB extension
            await self._verify_timescale()
            
        except Exception as e:
            logger.error(f"Failed to connect to TimescaleDB: {e}")
            raise
    
    async def disconnect(self):
        """Close connection pool"""
        if self.pool:
            await self.pool.close()
            logger.info("✓ Disconnected from TimescaleDB")
    
    async def _verify_timescale(self):
        """Verify TimescaleDB extension is installed"""
        async with self.pool.acquire() as conn:
            result = await conn.fetchval(
                "SELECT default_version FROM pg_available_extensions WHERE name = 'timescaledb'"
            )
            if result:
                logger.info(f"✓ TimescaleDB extension available (version {result})")
            else:
                logger.warning("⚠ TimescaleDB extension not installed. Install with: CREATE EXTENSION timescaledb;")
    
    async def initialize_schema(self):
        """Create database schema with hypertables"""
        logger.info("Initializing TimescaleDB schema...")
        
        async with self.pool.acquire() as conn:
            # Enable TimescaleDB extension
            await conn.execute("CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;")
            logger.info("  ✓ TimescaleDB extension enabled")
            
            # Create stations table
            await conn.execute("""
                CREATE TABLE IF NOT EXISTS stations (
                    station_id TEXT PRIMARY KEY,
                    name TEXT NOT NULL,
                    location TEXT,
                    latitude DOUBLE PRECISION,
                    longitude DOUBLE PRECISION,
                    basin TEXT,
                    created_at TIMESTAMPTZ DEFAULT NOW(),
                    metadata JSONB
                );
            """)
            logger.info("  ✓ Stations table created")
            
            # Create measurements hypertable
            await conn.execute("""
                CREATE TABLE IF NOT EXISTS measurements (
                    time TIMESTAMPTZ NOT NULL,
                    station_id TEXT NOT NULL,
                    parameter TEXT NOT NULL,
                    value DOUBLE PRECISION NOT NULL,
                    unit TEXT,
                    quality TEXT DEFAULT 'good',
                    source TEXT DEFAULT 'manual',
                    metadata JSONB,
                    FOREIGN KEY (station_id) REFERENCES stations(station_id)
                );
            """)
            logger.info("  ✓ Measurements table created")
            
            # Convert to hypertable (if not already)
            try:
                await conn.execute("""
                    SELECT create_hypertable('measurements', 'time', 
                        if_not_exists => TRUE,
                        chunk_time_interval => INTERVAL '1 day'
                    );
                """)
                logger.info("  ✓ Measurements converted to hypertable (1-day chunks)")
            except Exception as e:
                if "already a hypertable" not in str(e):
                    logger.error(f"Error creating hypertable: {e}")
            
            # Create indexes
            await conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_measurements_station_time 
                ON measurements (station_id, time DESC);
            """)
            await conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_measurements_parameter_time 
                ON measurements (parameter, time DESC);
            """)
            logger.info("  ✓ Indexes created")
            
            # Create WQI table (calculated values)
            await conn.execute("""
                CREATE TABLE IF NOT EXISTS wqi_readings (
                    time TIMESTAMPTZ NOT NULL,
                    station_id TEXT NOT NULL,
                    wqi DOUBLE PRECISION NOT NULL,
                    status TEXT,
                    water_class TEXT,
                    parameters JSONB,
                    FOREIGN KEY (station_id) REFERENCES stations(station_id)
                );
            """)
            
            try:
                await conn.execute("""
                    SELECT create_hypertable('wqi_readings', 'time',
                        if_not_exists => TRUE,
                        chunk_time_interval => INTERVAL '1 day'
                    );
                """)
                logger.info("  ✓ WQI hypertable created")
            except Exception:
                pass
            
            # Create alerts table
            await conn.execute("""
                CREATE TABLE IF NOT EXISTS alerts (
                    time TIMESTAMPTZ NOT NULL,
                    station_id TEXT NOT NULL,
                    alert_type TEXT NOT NULL,
                    severity TEXT NOT NULL,
                    parameter TEXT,
                    value DOUBLE PRECISION,
                    threshold DOUBLE PRECISION,
                    message TEXT,
                    acknowledged BOOLEAN DEFAULT FALSE,
                    FOREIGN KEY (station_id) REFERENCES stations(station_id)
                );
            """)
            
            try:
                await conn.execute("""
                    SELECT create_hypertable('alerts', 'time',
                        if_not_exists => TRUE,
                        chunk_time_interval => INTERVAL '7 days'
                    );
                """)
                logger.info("  ✓ Alerts hypertable created")
            except Exception:
                pass
        
        logger.info("✓ Schema initialization complete")
    
    async def create_continuous_aggregates(self):
        """Create continuous aggregates for fast queries"""
        logger.info("Creating continuous aggregates...")
        
        async with self.pool.acquire() as conn:
            # Hourly aggregates
            await conn.execute("""
                CREATE MATERIALIZED VIEW IF NOT EXISTS measurements_hourly
                WITH (timescaledb.continuous) AS
                SELECT
                    time_bucket('1 hour', time) AS bucket,
                    station_id,
                    parameter,
                    AVG(value) as avg_value,
                    MIN(value) as min_value,
                    MAX(value) as max_value,
                    COUNT(*) as sample_count
                FROM measurements
                GROUP BY bucket, station_id, parameter
                WITH NO DATA;
            """)
            logger.info("  ✓ Hourly aggregate created")
            
            # Daily aggregates
            await conn.execute("""
                CREATE MATERIALIZED VIEW IF NOT EXISTS measurements_daily
                WITH (timescaledb.continuous) AS
                SELECT
                    time_bucket('1 day', time) AS bucket,
                    station_id,
                    parameter,
                    AVG(value) as avg_value,
                    MIN(value) as min_value,
                    MAX(value) as max_value,
                    STDDEV(value) as stddev_value,
                    COUNT(*) as sample_count
                FROM measurements
                GROUP BY bucket, station_id, parameter
                WITH NO DATA;
            """)
            logger.info("  ✓ Daily aggregate created")
            
            # Weekly WQI aggregates
            await conn.execute("""
                CREATE MATERIALIZED VIEW IF NOT EXISTS wqi_weekly
                WITH (timescaledb.continuous) AS
                SELECT
                    time_bucket('1 week', time) AS bucket,
                    station_id,
                    AVG(wqi) as avg_wqi,
                    MIN(wqi) as min_wqi,
                    MAX(wqi) as max_wqi,
                    COUNT(*) as sample_count
                FROM wqi_readings
                GROUP BY bucket, station_id
                WITH NO DATA;
            """)
            logger.info("  ✓ Weekly WQI aggregate created")
            
            # Refresh policies (auto-update aggregates)
            try:
                await conn.execute("""
                    SELECT add_continuous_aggregate_policy('measurements_hourly',
                        start_offset => INTERVAL '3 hours',
                        end_offset => INTERVAL '1 hour',
                        schedule_interval => INTERVAL '1 hour',
                        if_not_exists => TRUE
                    );
                """)
                logger.info("  ✓ Hourly refresh policy added")
            except Exception:
                pass
            
            try:
                await conn.execute("""
                    SELECT add_continuous_aggregate_policy('measurements_daily',
                        start_offset => INTERVAL '3 days',
                        end_offset => INTERVAL '1 day',
                        schedule_interval => INTERVAL '1 day',
                        if_not_exists => TRUE
                    );
                """)
                logger.info("  ✓ Daily refresh policy added")
            except Exception:
                pass
        
        logger.info("✓ Continuous aggregates configured")
    
    async def create_retention_policies(self):
        """Create data retention policies"""
        logger.info("Creating retention policies...")
        
        async with self.pool.acquire() as conn:
            # Keep raw measurements for 90 days
            try:
                await conn.execute("""
                    SELECT add_retention_policy('measurements',
                        INTERVAL '90 days',
                        if_not_exists => TRUE
                    );
                """)
                logger.info("  ✓ Measurements: 90-day retention")
            except Exception as e:
                logger.warning(f"  Retention policy exists or error: {e}")
            
            # Keep WQI readings for 2 years
            try:
                await conn.execute("""
                    SELECT add_retention_policy('wqi_readings',
                        INTERVAL '2 years',
                        if_not_exists => TRUE
                    );
                """)
                logger.info("  ✓ WQI readings: 2-year retention")
            except Exception:
                pass
            
            # Keep alerts for 1 year
            try:
                await conn.execute("""
                    SELECT add_retention_policy('alerts',
                        INTERVAL '1 year',
                        if_not_exists => TRUE
                    );
                """)
                logger.info("  ✓ Alerts: 1-year retention")
            except Exception:
                pass
        
        logger.info("✓ Retention policies configured")
    
    async def enable_compression(self):
        """Enable compression for old data"""
        logger.info("Enabling compression...")
        
        async with self.pool.acquire() as conn:
            # Compress measurements older than 7 days
            try:
                await conn.execute("""
                    ALTER TABLE measurements SET (
                        timescaledb.compress,
                        timescaledb.compress_segmentby = 'station_id,parameter'
                    );
                """)
                await conn.execute("""
                    SELECT add_compression_policy('measurements',
                        INTERVAL '7 days',
                        if_not_exists => TRUE
                    );
                """)
                logger.info("  ✓ Measurements: compress after 7 days")
            except Exception as e:
                logger.warning(f"  Compression already enabled or error: {e}")
            
            # Compress WQI readings older than 30 days
            try:
                await conn.execute("""
                    ALTER TABLE wqi_readings SET (
                        timescaledb.compress,
                        timescaledb.compress_segmentby = 'station_id'
                    );
                """)
                await conn.execute("""
                    SELECT add_compression_policy('wqi_readings',
                        INTERVAL '30 days',
                        if_not_exists => TRUE
                    );
                """)
                logger.info("  ✓ WQI readings: compress after 30 days")
            except Exception:
                pass
        
        logger.info("✓ Compression enabled")
    
    async def insert_station(self, station_id: str, name: str, 
                           latitude: float, longitude: float,
                           location: str = None, basin: str = None,
                           metadata: Dict = None):
        """Insert or update station information"""
        async with self.pool.acquire() as conn:
            await conn.execute("""
                INSERT INTO stations (station_id, name, location, latitude, longitude, basin, metadata)
                VALUES ($1, $2, $3, $4, $5, $6, $7)
                ON CONFLICT (station_id) DO UPDATE SET
                    name = EXCLUDED.name,
                    location = EXCLUDED.location,
                    latitude = EXCLUDED.latitude,
                    longitude = EXCLUDED.longitude,
                    basin = EXCLUDED.basin,
                    metadata = EXCLUDED.metadata;
            """, station_id, name, location, latitude, longitude, basin, json.dumps(metadata) if metadata else None)
        
        logger.info(f"Station {station_id} inserted/updated")
    
    async def insert_measurement(self, station_id: str, parameter: str,
                                value: float, unit: str = None,
                                timestamp: datetime = None, quality: str = "good",
                                source: str = "sensor", metadata: Dict = None):
        """Insert a single measurement"""
        if timestamp is None:
            timestamp = datetime.now()
        
        async with self.pool.acquire() as conn:
            await conn.execute("""
                INSERT INTO measurements (time, station_id, parameter, value, unit, quality, source, metadata)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8);
            """, timestamp, station_id, parameter, value, unit, quality, source, 
               json.dumps(metadata) if metadata else None)
    
    async def insert_measurements_batch(self, measurements: List[Dict]):
        """Insert multiple measurements efficiently"""
        if not measurements:
            return
        
        async with self.pool.acquire() as conn:
            await conn.executemany("""
                INSERT INTO measurements (time, station_id, parameter, value, unit, quality, source, metadata)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8);
            """, [(
                m.get('timestamp', datetime.now()),
                m['station_id'],
                m['parameter'],
                m['value'],
                m.get('unit'),
                m.get('quality', 'good'),
                m.get('source', 'sensor'),
                json.dumps(m.get('metadata')) if m.get('metadata') else None
            ) for m in measurements])
        
        logger.info(f"Inserted {len(measurements)} measurements")
    
    async def insert_wqi(self, station_id: str, wqi: float, status: str,
                        water_class: str, parameters: Dict,
                        timestamp: datetime = None):
        """Insert WQI reading"""
        if timestamp is None:
            timestamp = datetime.now()
        
        async with self.pool.acquire() as conn:
            await conn.execute("""
                INSERT INTO wqi_readings (time, station_id, wqi, status, water_class, parameters)
                VALUES ($1, $2, $3, $4, $5, $6);
            """, timestamp, station_id, wqi, status, water_class, json.dumps(parameters))
    
    async def insert_alert(self, station_id: str, alert_type: str, severity: str,
                          parameter: str = None, value: float = None,
                          threshold: float = None, message: str = None,
                          timestamp: datetime = None):
        """Insert alert"""
        if timestamp is None:
            timestamp = datetime.now()
        
        async with self.pool.acquire() as conn:
            await conn.execute("""
                INSERT INTO alerts (time, station_id, alert_type, severity, parameter, value, threshold, message)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8);
            """, timestamp, station_id, alert_type, severity, parameter, value, threshold, message)
    
    async def get_latest_measurements(self, station_id: str, hours: int = 24) -> List[Dict]:
        """Get latest measurements for a station"""
        async with self.pool.acquire() as conn:
            rows = await conn.fetch("""
                SELECT time, parameter, value, unit, quality, source
                FROM measurements
                WHERE station_id = $1 AND time > NOW() - INTERVAL '1 hour' * $2
                ORDER BY time DESC;
            """, station_id, hours)
            
            return [dict(row) for row in rows]
    
    async def get_hourly_aggregates(self, station_id: str, parameter: str, days: int = 7) -> List[Dict]:
        """Get hourly aggregates"""
        async with self.pool.acquire() as conn:
            rows = await conn.fetch("""
                SELECT bucket, avg_value, min_value, max_value, sample_count
                FROM measurements_hourly
                WHERE station_id = $1 AND parameter = $2 AND bucket > NOW() - INTERVAL '1 day' * $3
                ORDER BY bucket DESC;
            """, station_id, parameter, days)
            
            return [dict(row) for row in rows]
    
    async def get_database_stats(self) -> Dict:
        """Get database statistics"""
        async with self.pool.acquire() as conn:
            # Table sizes
            tables = await conn.fetch("""
                SELECT
                    schemaname,
                    tablename,
                    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
                FROM pg_tables
                WHERE schemaname = 'public'
                ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
            """)
            
            # Hypertable info
            hypertables = await conn.fetch("""
                SELECT hypertable_name, num_chunks
                FROM timescaledb_information.hypertables;
            """)
            
            # Compression stats
            compression = await conn.fetch("""
                SELECT
                    hypertable_name,
                    compression_status,
                    uncompressed_total_bytes,
                    compressed_total_bytes
                FROM timescaledb_information.compression_settings;
            """)
            
            return {
                'tables': [dict(row) for row in tables],
                'hypertables': [dict(row) for row in hypertables],
                'compression': [dict(row) for row in compression]
            }


# Example usage
async def main():
    """Test TimescaleDB integration"""
    print("\n" + "="*60)
    print("TimescaleDB Integration - Test Mode")
    print("="*60 + "\n")
    
    if not ASYNCPG_AVAILABLE:
        print("❌ asyncpg not installed. Install with: pip install asyncpg")
        print("❌ TimescaleDB features are disabled.\n")
        print("For production, also install TimescaleDB:")
        print("  - Docker: docker run -d --name timescaledb -p 5432:5432 -e POSTGRES_PASSWORD=postgres timescale/timescaledb:latest-pg14")
        print("  - Or follow: https://docs.timescale.com/install/latest/\n")
        return
    
    # Configuration
    config = DatabaseConfig(
        host="localhost",
        port=5432,
        database="pure_health",
        user="postgres",
        password="postgres"
    )
    
    manager = TimescaleDBManager(config)
    
    try:
        # Connect
        print("Connecting to TimescaleDB...")
        await manager.connect()
        
        # Initialize schema
        print("\nInitializing schema...")
        await manager.initialize_schema()
        
        # Create continuous aggregates
        print("\nCreating continuous aggregates...")
        await manager.create_continuous_aggregates()
        
        # Set retention policies
        print("\nSetting retention policies...")
        await manager.create_retention_policies()
        
        # Enable compression
        print("\nEnabling compression...")
        await manager.enable_compression()
        
        # Insert test data
        print("\nInserting test data...")
        
        # Insert stations
        await manager.insert_station(
            station_id="1",
            name="Mithi River - Powai",
            latitude=19.1197,
            longitude=72.9133,
            location="Mumbai",
            basin="Mithi River"
        )
        
        # Insert measurements
        import random
        measurements = []
        for i in range(100):
            timestamp = datetime.now() - timedelta(hours=i)
            measurements.append({
                'timestamp': timestamp,
                'station_id': '1',
                'parameter': 'ph',
                'value': 7.0 + random.uniform(-0.5, 0.5),
                'unit': 'pH',
                'quality': 'good',
                'source': 'sensor'
            })
        
        await manager.insert_measurements_batch(measurements)
        print(f"  ✓ Inserted {len(measurements)} measurements")
        
        # Query data
        print("\nQuerying data...")
        latest = await manager.get_latest_measurements("1", hours=24)
        print(f"  ✓ Found {len(latest)} measurements in last 24 hours")
        
        # Get stats
        print("\nDatabase statistics:")
        stats = await manager.get_database_stats()
        print(f"  Tables: {len(stats['tables'])}")
        print(f"  Hypertables: {len(stats['hypertables'])}")
        
        print("\n✓ TimescaleDB integration test complete!")
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        print("\nMake sure TimescaleDB is running:")
        print("  docker run -d --name timescaledb -p 5432:5432 -e POSTGRES_PASSWORD=postgres timescale/timescaledb:latest-pg14")
    
    finally:
        await manager.disconnect()
        print("\n✓ Disconnected from TimescaleDB\n")


if __name__ == "__main__":
    asyncio.run(main())
