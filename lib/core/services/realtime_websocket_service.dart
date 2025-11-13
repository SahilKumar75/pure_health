import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

/// WebSocket Service - Phase 6
/// Provides real-time data updates from backend WebSocket server
class RealtimeWebSocketService {
  static const String defaultHost = 'localhost:8080';
  
  WebSocketChannel? _channel;
  String? _clientId;
  bool _isConnected = false;
  Set<String> _subscribedStations = {};
  
  // Stream controllers for different update types
  final _stationUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _alertController = StreamController<Map<String, dynamic>>.broadcast();
  final _predictionController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  
  // Getters for streams
  Stream<Map<String, dynamic>> get stationUpdates => _stationUpdateController.stream;
  Stream<Map<String, dynamic>> get alerts => _alertController.stream;
  Stream<Map<String, dynamic>> get predictions => _predictionController.stream;
  Stream<bool> get connectionStatus => _connectionController.stream;
  
  bool get isConnected => _isConnected;
  String? get clientId => _clientId;
  
  /// Connect to WebSocket server
  /// 
  /// [host] WebSocket server address (default: localhost:8080)
  /// [stationId] Optional station ID to auto-subscribe
  Future<bool> connect({String host = defaultHost, String? stationId}) async {
    try {
      print('[WEBSOCKET] Connecting to ws://$host/ws${stationId != null ? '/station/$stationId' : ''}...');
      
      final uri = Uri.parse('ws://$host/ws${stationId != null ? '/station/$stationId' : ''}');
      _channel = WebSocketChannel.connect(uri);
      
      // Listen to incoming messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: false,
      );
      
      _isConnected = true;
      _connectionController.add(true);
      print('[WEBSOCKET] Connected successfully');
      
      return true;
    } catch (e) {
      print('[WEBSOCKET] Connection error: $e');
      _isConnected = false;
      _connectionController.add(false);
      return false;
    }
  }
  
  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    try {
      print('[WEBSOCKET] Disconnecting...');
      await _channel?.sink.close(status.goingAway);
      _isConnected = false;
      _clientId = null;
      _subscribedStations.clear();
      _connectionController.add(false);
      print('[WEBSOCKET] Disconnected');
    } catch (e) {
      print('[WEBSOCKET] Disconnect error: $e');
    }
  }
  
  /// Subscribe to station updates
  void subscribeToStation(String stationId) {
    if (!_isConnected) {
      print('[WEBSOCKET] Not connected. Cannot subscribe');
      return;
    }
    
    if (_subscribedStations.contains(stationId)) {
      print('[WEBSOCKET] Already subscribed to station $stationId');
      return;
    }
    
    final message = {
      'type': 'subscribe',
      'station_id': int.parse(stationId),
    };
    
    _sendMessage(message);
    _subscribedStations.add(stationId);
    print('[WEBSOCKET] Subscribed to station $stationId');
  }
  
  /// Unsubscribe from station updates
  void unsubscribeFromStation(String stationId) {
    if (!_isConnected || !_subscribedStations.contains(stationId)) {
      return;
    }
    
    final message = {
      'type': 'unsubscribe',
      'station_id': int.parse(stationId),
    };
    
    _sendMessage(message);
    _subscribedStations.remove(stationId);
    print('[WEBSOCKET] Unsubscribed from station $stationId');
  }
  
  /// Send ping to keep connection alive
  void sendPing() {
    if (!_isConnected) return;
    
    _sendMessage({'type': 'ping'});
  }
  
  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final type = data['type'] as String?;
      
      print('[WEBSOCKET] Received message type: $type');
      
      switch (type) {
        case 'connected':
          _handleConnected(data);
          break;
          
        case 'subscribed':
          print('[WEBSOCKET] Subscription confirmed for station ${data['station_id']}');
          break;
          
        case 'unsubscribed':
          print('[WEBSOCKET] Unsubscribed from station ${data['station_id']}');
          break;
          
        case 'station_update':
          _handleStationUpdate(data);
          break;
          
        case 'alert':
          _handleAlert(data);
          break;
          
        case 'prediction_update':
          _handlePredictionUpdate(data);
          break;
          
        case 'pong':
          // Ping response received
          break;
          
        case 'error':
          print('[WEBSOCKET] Server error: ${data['message']}');
          break;
          
        default:
          print('[WEBSOCKET] Unknown message type: $type');
      }
    } catch (e) {
      print('[WEBSOCKET] Error handling message: $e');
    }
  }
  
  void _handleConnected(Map<String, dynamic> data) {
    _clientId = data['client_id'] as String?;
    print('[WEBSOCKET] Connected with client ID: $_clientId');
    
    if (data.containsKey('station_id')) {
      final stationId = data['station_id'].toString();
      _subscribedStations.add(stationId);
      print('[WEBSOCKET] Auto-subscribed to station $stationId');
    }
  }
  
  void _handleStationUpdate(Map<String, dynamic> data) {
    final stationId = data['station_id'].toString();
    final updateData = data['data'] as Map<String, dynamic>?;
    
    if (updateData != null) {
      print('[WEBSOCKET] Station update for $stationId: WQI=${updateData['wqi']}');
      
      // Add station ID to the data
      updateData['station_id'] = stationId;
      updateData['timestamp'] = data['timestamp'];
      
      // Broadcast to subscribers
      _stationUpdateController.add(updateData);
    }
  }
  
  void _handleAlert(Map<String, dynamic> data) {
    final stationId = data['station_id'].toString();
    final alertData = data['alert'] as Map<String, dynamic>?;
    
    if (alertData != null) {
      print('[WEBSOCKET] ⚠️ Alert for station $stationId: ${alertData['message']}');
      
      // Add context
      alertData['station_id'] = stationId;
      alertData['timestamp'] = data['timestamp'];
      
      // Broadcast alert
      _alertController.add(alertData);
    }
  }
  
  void _handlePredictionUpdate(Map<String, dynamic> data) {
    final stationId = data['station_id'].toString();
    final predictions = data['predictions'] as Map<String, dynamic>?;
    
    if (predictions != null) {
      print('[WEBSOCKET] Prediction update for station $stationId');
      
      // Add context
      predictions['station_id'] = stationId;
      predictions['timestamp'] = data['timestamp'];
      
      // Broadcast predictions
      _predictionController.add(predictions);
    }
  }
  
  void _handleError(error) {
    print('[WEBSOCKET] Connection error: $error');
    _isConnected = false;
    _connectionController.add(false);
  }
  
  void _handleDisconnect() {
    print('[WEBSOCKET] Connection closed');
    _isConnected = false;
    _clientId = null;
    _subscribedStations.clear();
    _connectionController.add(false);
  }
  
  void _sendMessage(Map<String, dynamic> message) {
    try {
      final jsonMessage = jsonEncode(message);
      _channel?.sink.add(jsonMessage);
    } catch (e) {
      print('[WEBSOCKET] Error sending message: $e');
    }
  }
  
  /// Dispose resources
  void dispose() {
    _stationUpdateController.close();
    _alertController.close();
    _predictionController.close();
    _connectionController.close();
    disconnect();
  }
}
