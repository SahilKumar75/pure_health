"""
Real-time WebSocket Server - Phase 6
Provides live water quality updates to Flutter dashboard
"""

import asyncio
import json
import logging
from datetime import datetime
from typing import Dict, Set, Optional
from aiohttp import web
import aiohttp
from collections import defaultdict

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class RealtimeWebSocketServer:
    """
    WebSocket server for real-time water quality data streaming
    Supports multiple clients and station subscriptions
    """
    
    def __init__(self):
        self.clients: Dict[str, web.WebSocketResponse] = {}
        self.station_subscriptions: Dict[int, Set[str]] = defaultdict(set)
        self.app = web.Application()
        self.setup_routes()
        
    def setup_routes(self):
        """Configure WebSocket routes"""
        self.app.router.add_get('/ws', self.websocket_handler)
        self.app.router.add_get('/ws/station/{station_id}', self.station_websocket_handler)
        self.app.router.add_get('/health', self.health_check)
        self.app.router.add_get('/stats', self.get_stats)
        
    async def health_check(self, request):
        """Health check endpoint"""
        return web.json_response({
            'status': 'healthy',
            'timestamp': datetime.now().isoformat(),
            'active_clients': len(self.clients),
            'subscriptions': sum(len(subs) for subs in self.station_subscriptions.values())
        })
    
    async def get_stats(self, request):
        """Get server statistics"""
        stats = {
            'active_connections': len(self.clients),
            'stations_monitored': len(self.station_subscriptions),
            'total_subscriptions': sum(len(subs) for subs in self.station_subscriptions.values()),
            'subscriptions_by_station': {
                station_id: len(clients) 
                for station_id, clients in self.station_subscriptions.items()
            }
        }
        return web.json_response(stats)
    
    async def websocket_handler(self, request):
        """
        General WebSocket handler
        Clients can subscribe to multiple stations
        """
        ws = web.WebSocketResponse()
        await ws.prepare(request)
        
        client_id = f"client_{id(ws)}"
        self.clients[client_id] = ws
        logger.info(f"Client {client_id} connected")
        
        try:
            # Send welcome message
            await ws.send_json({
                'type': 'connected',
                'client_id': client_id,
                'timestamp': datetime.now().isoformat(),
                'message': 'Connected to Pure Health WebSocket server'
            })
            
            async for msg in ws:
                if msg.type == aiohttp.WSMsgType.TEXT:
                    await self.handle_client_message(client_id, ws, msg.data)
                elif msg.type == aiohttp.WSMsgType.ERROR:
                    logger.error(f'WebSocket error: {ws.exception()}')
                    
        except Exception as e:
            logger.error(f"Error in websocket handler: {e}")
        finally:
            # Clean up on disconnect
            await self.cleanup_client(client_id)
            
        return ws
    
    async def station_websocket_handler(self, request):
        """
        Station-specific WebSocket handler
        Auto-subscribe to single station
        """
        station_id = int(request.match_info['station_id'])
        ws = web.WebSocketResponse()
        await ws.prepare(request)
        
        client_id = f"station_{station_id}_client_{id(ws)}"
        self.clients[client_id] = ws
        self.station_subscriptions[station_id].add(client_id)
        
        logger.info(f"Client {client_id} connected to station {station_id}")
        
        try:
            # Send welcome with station info
            await ws.send_json({
                'type': 'connected',
                'client_id': client_id,
                'station_id': station_id,
                'timestamp': datetime.now().isoformat(),
                'message': f'Subscribed to station {station_id} updates'
            })
            
            async for msg in ws:
                if msg.type == aiohttp.WSMsgType.TEXT:
                    await self.handle_client_message(client_id, ws, msg.data)
                elif msg.type == aiohttp.WSMsgType.ERROR:
                    logger.error(f'WebSocket error: {ws.exception()}')
                    
        except Exception as e:
            logger.error(f"Error in station websocket: {e}")
        finally:
            await self.cleanup_client(client_id)
            
        return ws
    
    async def handle_client_message(self, client_id: str, ws: web.WebSocketResponse, data: str):
        """Handle incoming messages from clients"""
        try:
            message = json.loads(data)
            msg_type = message.get('type')
            
            if msg_type == 'subscribe':
                # Subscribe to station updates
                station_id = message.get('station_id')
                if station_id:
                    self.station_subscriptions[station_id].add(client_id)
                    await ws.send_json({
                        'type': 'subscribed',
                        'station_id': station_id,
                        'timestamp': datetime.now().isoformat()
                    })
                    logger.info(f"Client {client_id} subscribed to station {station_id}")
                    
            elif msg_type == 'unsubscribe':
                # Unsubscribe from station
                station_id = message.get('station_id')
                if station_id and client_id in self.station_subscriptions[station_id]:
                    self.station_subscriptions[station_id].remove(client_id)
                    await ws.send_json({
                        'type': 'unsubscribed',
                        'station_id': station_id,
                        'timestamp': datetime.now().isoformat()
                    })
                    logger.info(f"Client {client_id} unsubscribed from station {station_id}")
                    
            elif msg_type == 'ping':
                # Respond to ping
                await ws.send_json({
                    'type': 'pong',
                    'timestamp': datetime.now().isoformat()
                })
                
            else:
                # Unknown message type
                await ws.send_json({
                    'type': 'error',
                    'message': f'Unknown message type: {msg_type}'
                })
                
        except json.JSONDecodeError:
            await ws.send_json({
                'type': 'error',
                'message': 'Invalid JSON format'
            })
        except Exception as e:
            logger.error(f"Error handling message: {e}")
            await ws.send_json({
                'type': 'error',
                'message': str(e)
            })
    
    async def cleanup_client(self, client_id: str):
        """Clean up client subscriptions and connections"""
        # Remove from all station subscriptions
        for station_id in list(self.station_subscriptions.keys()):
            if client_id in self.station_subscriptions[station_id]:
                self.station_subscriptions[station_id].remove(client_id)
                # Remove empty subscription sets
                if not self.station_subscriptions[station_id]:
                    del self.station_subscriptions[station_id]
        
        # Remove client connection
        if client_id in self.clients:
            del self.clients[client_id]
            
        logger.info(f"Client {client_id} disconnected and cleaned up")
    
    async def broadcast_update(self, station_id: int, data: dict):
        """
        Broadcast water quality update to all subscribed clients
        
        Args:
            station_id: Station ID
            data: Water quality data dictionary
        """
        if station_id not in self.station_subscriptions:
            return
        
        message = {
            'type': 'station_update',
            'station_id': station_id,
            'timestamp': datetime.now().isoformat(),
            'data': data
        }
        
        # Send to all subscribed clients
        disconnected_clients = []
        for client_id in self.station_subscriptions[station_id]:
            if client_id in self.clients:
                ws = self.clients[client_id]
                try:
                    await ws.send_json(message)
                except Exception as e:
                    logger.error(f"Error sending to {client_id}: {e}")
                    disconnected_clients.append(client_id)
        
        # Clean up disconnected clients
        for client_id in disconnected_clients:
            await self.cleanup_client(client_id)
    
    async def broadcast_alert(self, station_id: int, alert_data: dict):
        """
        Broadcast critical alert to subscribed clients
        
        Args:
            station_id: Station ID
            alert_data: Alert information
        """
        if station_id not in self.station_subscriptions:
            return
        
        message = {
            'type': 'alert',
            'station_id': station_id,
            'timestamp': datetime.now().isoformat(),
            'alert': alert_data,
            'priority': alert_data.get('severity', 'medium')
        }
        
        # Send to all subscribed clients
        for client_id in self.station_subscriptions[station_id]:
            if client_id in self.clients:
                ws = self.clients[client_id]
                try:
                    await ws.send_json(message)
                    logger.info(f"Alert sent to {client_id} for station {station_id}")
                except Exception as e:
                    logger.error(f"Error sending alert to {client_id}: {e}")
    
    async def broadcast_prediction(self, station_id: int, prediction_data: dict):
        """
        Broadcast ML prediction update
        
        Args:
            station_id: Station ID
            prediction_data: Prediction results from Phase 5 models
        """
        if station_id not in self.station_subscriptions:
            return
        
        message = {
            'type': 'prediction_update',
            'station_id': station_id,
            'timestamp': datetime.now().isoformat(),
            'predictions': prediction_data
        }
        
        for client_id in self.station_subscriptions[station_id]:
            if client_id in self.clients:
                ws = self.clients[client_id]
                try:
                    await ws.send_json(message)
                except Exception as e:
                    logger.error(f"Error sending prediction to {client_id}: {e}")
    
    async def send_to_client(self, client_id: str, message: dict):
        """Send message to specific client"""
        if client_id in self.clients:
            ws = self.clients[client_id]
            try:
                await ws.send_json(message)
            except Exception as e:
                logger.error(f"Error sending to {client_id}: {e}")
                await self.cleanup_client(client_id)
    
    def run(self, host='0.0.0.0', port=8080):
        """Start the WebSocket server"""
        logger.info(f"Starting WebSocket server on {host}:{port}")
        web.run_app(self.app, host=host, port=port)


# Standalone server for testing
if __name__ == '__main__':
    print("=== Pure Health WebSocket Server - Phase 6 ===\n")
    print("Starting WebSocket server...")
    print("Endpoints:")
    print("  - ws://localhost:8080/ws (general connection)")
    print("  - ws://localhost:8080/ws/station/{id} (station-specific)")
    print("  - http://localhost:8080/health (health check)")
    print("  - http://localhost:8080/stats (statistics)")
    print("\nPress Ctrl+C to stop\n")
    
    server = RealtimeWebSocketServer()
    
    try:
        server.run(host='0.0.0.0', port=8080)
    except KeyboardInterrupt:
        print("\n\nServer stopped")
