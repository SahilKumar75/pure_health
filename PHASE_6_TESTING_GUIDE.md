# Phase 6 - Quick Start Testing Guide

## 🚀 Quick Test (5 minutes)

### 1. Start Backend Services
```bash
cd /Users/sahilkumarsingh/Desktop/pure_health/ml_backend
python3 phase6_integration.py
```

**Expected Output**:
```
╔════════════════════════════════════════════════════╗
║   Pure Health - Phase 6: Real-time Integration    ║
║   Components:                                      ║
║   • WebSocket Server                               ║
║   • Data Orchestrator                              ║
║   • API Integration Layer                          ║
║   • IoT Sensor Handler                             ║
║   • Satellite Data Processor                       ║
║   • ML Prediction Updates                          ║
╚════════════════════════════════════════════════════╝

✓ WebSocket Server initialized
✓ Data Orchestrator ready
✓ IoT Sensor Handler ready
✓ Satellite Processor ready
=== Phase 6 Services Started Successfully ===
Real-time monitoring active for 3 stations
WebSocket: ws://localhost:8080/ws
Health Check: http://localhost:8080/health
```

### 2. Test WebSocket Health
```bash
# In a new terminal
curl http://localhost:8080/health
```

**Expected Response**:
```json
{
  "status": "healthy",
  "websocket_clients": 0,
  "uptime": "10 seconds",
  "timestamp": "2025-11-13T12:00:00"
}
```

### 3. Run Flutter App
```bash
cd /Users/sahilkumarsingh/Desktop/pure_health
flutter run
```

### 4. Verify Dashboard
- Look for **green "LIVE"** indicator in top-right corner
- Should see real-time updates every 5 minutes
- Alerts should appear in snackbar and dialog

---

## 🔧 Full Testing Checklist

### Backend Services ✅
- [ ] WebSocket server starts on port 8080
- [ ] 3 stations registered (Station 1, 2, 3)
- [ ] IoT sensors initialized (2 MQTT sensors)
- [ ] Satellite processor ready (3 locations)
- [ ] Real-time orchestrator loops running
- [ ] API integration initialized
- [ ] No errors in console

### WebSocket Connection ✅
- [ ] Flutter app connects to ws://localhost:8080/ws
- [ ] Connection status shows "LIVE" (green)
- [ ] Auto-reconnection works when backend restarts
- [ ] Multiple clients can connect simultaneously

### Data Flow ✅
- [ ] Real-time data updates every 5 minutes
- [ ] WQI calculations appear correctly
- [ ] Parameter values within expected ranges
- [ ] Timestamps are current
- [ ] Data source attribution (IoT/API/Satellite/ML)

### Alerts System ✅
- [ ] Critical thresholds trigger alerts
- [ ] Alerts appear in dashboard snackbar
- [ ] Alerts dialog shows history
- [ ] Alert count badge updates
- [ ] Severity levels displayed (Critical/Warning/Info)

### ML Predictions ✅
- [ ] Predictions update every 15 minutes
- [ ] Next hour forecast shown
- [ ] Trend indicators displayed
- [ ] Confidence scores visible

### IoT Sensor Handler (Optional) ✅
- [ ] MQTT broker running (mosquitto)
- [ ] Sensors publish data successfully
- [ ] Handler receives and validates data
- [ ] Quality scoring applied (good/suspect/bad)
- [ ] Health monitoring active

### TimescaleDB (Optional) ✅
- [ ] Docker container running
- [ ] Database schema initialized
- [ ] Measurements inserted successfully
- [ ] Continuous aggregates created
- [ ] Compression enabled

---

## 🐛 Troubleshooting

### Issue: WebSocket Server Won't Start
**Symptom**: Port 8080 already in use  
**Solution**:
```bash
# Kill existing process
lsof -ti:8080 | xargs kill -9

# Or use different port
# Edit phase6_integration.py: port=8081
```

### Issue: Flutter App Shows "OFFLINE"
**Symptom**: Grey "OFFLINE" indicator  
**Possible Causes**:
1. Backend not running → Start `python3 phase6_integration.py`
2. Wrong WebSocket URL → Check `realtime_websocket_service.dart` (should be ws://localhost:8080/ws)
3. Firewall blocking connection → Check macOS firewall settings

### Issue: No Real-time Updates
**Symptom**: Dashboard not refreshing  
**Check**:
1. WebSocket connection established
2. Backend data collection loop running
3. Station data available in orchestrator
4. No errors in Flutter console

### Issue: MQTT Sensors Not Working
**Symptom**: Warning "paho-mqtt not installed"  
**Solution**:
```bash
pip3 install paho-mqtt
# Or use mock sensors (default behavior)
```

### Issue: TimescaleDB Errors
**Symptom**: Warning "asyncpg not installed"  
**Solution**:
```bash
# For development (optional)
pip3 install asyncpg

# For production (required)
docker run -d --name timescaledb -p 5432:5432 \
  -e POSTGRES_PASSWORD=postgres \
  timescale/timescaledb:latest-pg14
```

---

## 📊 Expected Data

### Sample Station Update (WebSocket Message)
```json
{
  "type": "station_update",
  "data": {
    "station_id": "1",
    "name": "Station 1",
    "timestamp": "2025-11-13T12:00:00",
    "wqi": 78.5,
    "status": "Good",
    "parameters": {
      "pH": 7.2,
      "DO": 6.8,
      "BOD": 2.1,
      "FC": 120.5,
      "TDS": 380.0,
      "temperature": 24.5,
      "turbidity": 8.2
    },
    "source": "api",
    "data_quality": "good"
  }
}
```

### Sample Alert (WebSocket Message)
```json
{
  "type": "alert",
  "data": {
    "station_id": "1",
    "station_name": "Station 1",
    "timestamp": "2025-11-13T12:05:00",
    "severity": "critical",
    "parameter": "DO",
    "value": 3.2,
    "threshold": 4.0,
    "message": "Dissolved Oxygen critically low: 3.2 mg/L (threshold: 4.0 mg/L)"
  }
}
```

### Sample Prediction (WebSocket Message)
```json
{
  "type": "prediction",
  "data": {
    "station_id": "1",
    "timestamp": "2025-11-13T12:00:00",
    "predictions": [
      {
        "parameter": "pH",
        "forecast_time": "2025-11-13T13:00:00",
        "predicted_value": 7.3,
        "confidence": 0.92,
        "trend": "stable"
      },
      {
        "parameter": "DO",
        "forecast_time": "2025-11-13T13:00:00",
        "predicted_value": 6.5,
        "confidence": 0.88,
        "trend": "decreasing"
      }
    ]
  }
}
```

---

## 🎯 Success Indicators

### ✅ Phase 6 Working Correctly When:
1. **Backend starts without errors** - All components initialize
2. **WebSocket accepts connections** - Health check returns 200 OK
3. **Flutter shows "LIVE"** - Green indicator in dashboard
4. **Data updates every 5 min** - Timestamps advancing
5. **Alerts trigger properly** - Critical thresholds detected
6. **Predictions update** - Every 15 minutes
7. **Performance good** - No lag, smooth UI updates
8. **No memory leaks** - Stable memory usage over time

---

## 📝 Testing Notes

### Performance Benchmarks
- WebSocket latency: < 100ms
- Data collection cycle: 5 minutes
- Prediction cycle: 15 minutes
- Health check cycle: 1 minute
- Dashboard refresh: Instant (WebSocket push)
- Flutter rebuild time: < 16ms (60fps)

### Data Sources Priority
1. **IoT Sensors** (highest) - Real-time, high quality
2. **Government APIs** - Daily updates, official
3. **Satellite Data** - Weekly, spatial coverage
4. **ML Predictions** - Fallback, forecasting

### Current Limitations
- TimescaleDB optional (uses mock data if not available)
- MQTT broker optional (uses mock sensors)
- Satellite APIs use mock data (real APIs need credentials)
- Only 3 stations registered (can add more easily)

---

## 🔄 Next Steps After Testing

### If Everything Works:
1. ✅ Mark Phase 6 as production-ready
2. 📄 Document any configuration changes
3. 🚀 Deploy to staging environment
4. 📊 Start Phase 7 (Advanced Visualizations)

### If Issues Found:
1. 🐛 Document bugs with reproduction steps
2. 🔍 Check logs for error messages
3. 💬 Ask for help if needed
4. 🔧 Apply fixes and retest

---

## 💻 Quick Commands Reference

```bash
# Start backend
cd ml_backend && python3 phase6_integration.py

# Test health
curl http://localhost:8080/health

# Check WebSocket stats
curl http://localhost:8080/stats

# Run Flutter
flutter run

# Install dependencies
pip3 install -r requirements.txt
flutter pub get

# MQTT test publish (if broker running)
mosquitto_pub -h localhost -t "purehealth/station1/ph" \
  -m '{"value": 7.2, "unit": "pH", "timestamp": "2025-11-13T12:00:00"}'

# Start TimescaleDB
docker run -d --name timescaledb -p 5432:5432 \
  -e POSTGRES_PASSWORD=postgres timescale/timescaledb:latest-pg14

# View backend logs
tail -f ml_backend/logs/phase6.log  # if logging enabled
```

---

**Ready to test?** Start with the Quick Test section above! 🚀

**Questions?** Check the troubleshooting section or PHASE_6_COMPLETE.md for details.

**Status**: Phase 6 - Ready for Testing ✅
