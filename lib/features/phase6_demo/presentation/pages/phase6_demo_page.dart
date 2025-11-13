import 'package:flutter/material.dart';
import 'package:pure_health/core/services/realtime_websocket_service.dart';
import 'dart:async';

/// Phase 6 Real-time Integration Demo Page
/// Showcases WebSocket live updates, alerts, and predictions
class Phase6DemoPage extends StatefulWidget {
  const Phase6DemoPage({super.key});

  @override
  State<Phase6DemoPage> createState() => _Phase6DemoPageState();
}

class _Phase6DemoPageState extends State<Phase6DemoPage> {
  final RealtimeWebSocketService _wsService = RealtimeWebSocketService();
  
  bool _isConnected = false;
  String _connectionHost = 'localhost:8080';
  
  // Subscriptions
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _stationUpdateSubscription;
  StreamSubscription? _alertSubscription;
  StreamSubscription? _predictionSubscription;
  
  // Data
  final List<Map<String, dynamic>> _recentUpdates = [];
  final List<Map<String, dynamic>> _alerts = [];
  Map<String, dynamic>? _latestPrediction;
  
  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _stationUpdateSubscription?.cancel();
    _alertSubscription?.cancel();
    _predictionSubscription?.cancel();
    _wsService.dispose();
    super.dispose();
  }

  Future<void> _initializeWebSocket() async {
    // Listen to connection status
    _connectionSubscription = _wsService.connectionStatus.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;
      });
    });
    
    // Listen to station updates
    _stationUpdateSubscription = _wsService.stationUpdates.listen((data) {
      setState(() {
        _recentUpdates.insert(0, {
          'type': 'update',
          'time': DateTime.now(),
          'data': data,
        });
        if (_recentUpdates.length > 20) {
          _recentUpdates.removeLast();
        }
      });
    });
    
    // Listen to alerts
    _alertSubscription = _wsService.alerts.listen((alert) {
      setState(() {
        _alerts.insert(0, {
          'time': DateTime.now(),
          'data': alert,
        });
        if (_alerts.length > 10) {
          _alerts.removeLast();
        }
      });
      
      // Show snackbar for critical alerts
      if (alert['severity'] == 'critical') {
        _showAlertSnackbar(alert);
      }
    });
    
    // Listen to predictions
    _predictionSubscription = _wsService.predictions.listen((predictions) {
      setState(() {
        _latestPrediction = predictions;
      });
    });
  }

  Future<void> _connect() async {
    try {
      final connected = await _wsService.connect(
        host: _connectionHost,
        stationId: '1', // Subscribe to Station 1
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(connected 
              ? '✓ Connected to WebSocket server' 
              : '✗ Failed to connect'),
            backgroundColor: connected ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _disconnect() {
    _wsService.disconnect();
  }

  void _showAlertSnackbar(Map<String, dynamic> alert) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${alert['parameter']}: ${alert['message']}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildConnectionPanel(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.stream,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phase 6: Real-time Integration',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'WebSocket Live Updates • Alerts • ML Predictions',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _isConnected ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected ? 'LIVE' : 'OFFLINE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionPanel() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'WebSocket Server',
                hintText: 'localhost:8080',
                prefixIcon: const Icon(Icons.dns),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              controller: TextEditingController(text: _connectionHost),
              onChanged: (value) => _connectionHost = value,
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _isConnected ? _disconnect : _connect,
            icon: Icon(_isConnected ? Icons.stop : Icons.play_arrow),
            label: Text(_isConnected ? 'Disconnect' : 'Connect'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isConnected ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (!_isConnected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Not Connected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the backend server and connect to see real-time updates',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.terminal, size: 20, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Start Backend:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'cd ml_backend\npython3 phase6_integration.py',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.greenAccent,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Recent Updates
        Expanded(
          flex: 2,
          child: _buildUpdatesPanel(),
        ),
        const SizedBox(width: 16),
        // Right: Alerts & Predictions
        Expanded(
          child: Column(
            children: [
              Expanded(child: _buildAlertsPanel()),
              const SizedBox(height: 16),
              Expanded(child: _buildPredictionsPanel()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpdatesPanel() {
    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.update, color: Color(0xFF6366F1)),
              const SizedBox(width: 8),
              const Text(
                'Real-time Updates',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_recentUpdates.length} updates',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Expanded(
            child: _recentUpdates.isEmpty
                ? Center(
                    child: Text(
                      'Waiting for updates...',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                : ListView.builder(
                    itemCount: _recentUpdates.length,
                    itemBuilder: (context, index) {
                      final update = _recentUpdates[index];
                      final data = update['data'] as Map<String, dynamic>;
                      final time = update['time'] as DateTime;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.water_drop,
                                    size: 16,
                                    color: Colors.green[700],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    data['station_name'] ?? 'Station ${data['station_id']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatTime(time),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildDataChip('WQI', data['wqi']?.toString() ?? 'N/A'),
                                const SizedBox(width: 8),
                                _buildDataChip('pH', data['parameters']?['pH']?.toString() ?? 'N/A'),
                                const SizedBox(width: 8),
                                _buildDataChip('DO', data['parameters']?['DO']?.toString() ?? 'N/A'),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsPanel() {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(
                'Alerts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_alerts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_alerts.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 24),
          Expanded(
            child: _alerts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 48, color: Colors.green[300]),
                        const SizedBox(height: 8),
                        Text(
                          'No alerts',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _alerts.length,
                    itemBuilder: (context, index) {
                      final alert = _alerts[index];
                      final data = alert['data'] as Map<String, dynamic>;
                      final time = alert['time'] as DateTime;
                      final severity = data['severity'] as String? ?? 'warning';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: severity == 'critical' 
                              ? Colors.red[50] 
                              : Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: severity == 'critical'
                                ? Colors.red[200]!
                                : Colors.orange[200]!,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  severity == 'critical' 
                                      ? Icons.error 
                                      : Icons.warning,
                                  size: 16,
                                  color: severity == 'critical'
                                      ? Colors.red[700]
                                      : Colors.orange[700],
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    data['parameter'] ?? 'Alert',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: severity == 'critical'
                                          ? Colors.red[700]
                                          : Colors.orange[700],
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatTime(time),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['message'] ?? 'Threshold exceeded',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsPanel() {
    return Container(
      margin: const EdgeInsets.only(right: 16, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Color(0xFF8B5CF6)),
              const SizedBox(width: 8),
              const Text(
                'ML Predictions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Expanded(
            child: _latestPrediction == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.analytics, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text(
                          'Waiting for predictions...',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next Hour Forecast',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...((_latestPrediction!['predictions'] as List?) ?? []).map((pred) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    pred['parameter'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  pred['predicted_value']?.toString() ?? 'N/A',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple[700],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _getTrendIcon(pred['trend']),
                                  size: 16,
                                  color: _getTrendColor(pred['trend']),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          color: Colors.blue[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  IconData _getTrendIcon(String? trend) {
    switch (trend) {
      case 'increasing':
        return Icons.trending_up;
      case 'decreasing':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  Color _getTrendColor(String? trend) {
    switch (trend) {
      case 'increasing':
        return Colors.red;
      case 'decreasing':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
