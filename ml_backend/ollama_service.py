import requests
import json
from typing import Optional, List, Dict

class OllamaAIService:
    def __init__(self, base_url: str = "http://localhost:11434", model: str = "mistral"):
        self.base_url = base_url
        self.model = model
        self.conversation_history: List[Dict] = []
    
    def check_connection(self) -> bool:
        """Check if Ollama is running"""
        try:
            response = requests.get(f"{self.base_url}/api/tags", timeout=5)
            return response.status_code == 200
        except:
            return False
    
    def list_models(self) -> List[str]:
        """Get available models"""
        try:
            response = requests.get(f"{self.base_url}/api/tags", timeout=5)
            if response.status_code == 200:
                data = response.json()
                return [model['name'] for model in data.get('models', [])]
            return []
        except Exception as e:
            print(f"Error listing models: {e}")
            return []
    
    def chat(self, message: str, file_data: Optional[Dict] = None) -> str:
        """Chat with Ollama"""
        
        # Add file analysis to message if provided
        system_msg = "You are an expert water quality analyst helping users understand their water quality data. Provide clear, actionable insights."
        
        if file_data:
            system_msg += f"\n\nAnalyze this water quality data:\n{json.dumps(file_data, indent=2)}"
        
        # Add to conversation history
        self.conversation_history.append({
            "role": "user",
            "content": message
        })
        
        try:
            response = requests.post(
                f"{self.base_url}/api/chat",
                json={
                    "model": self.model,
                    "messages": self.conversation_history,
                    "stream": False,
                    "system": system_msg
                },
                timeout=120
            )
            
            if response.status_code == 200:
                result = response.json()
                ai_response = result['message']['content']
                
                # Add to history
                self.conversation_history.append({
                    "role": "assistant",
                    "content": ai_response
                })
                
                return ai_response
            else:
                return f"❌ Ollama error: Status {response.status_code}"
                
        except requests.exceptions.Timeout:
            return "⏱️ Ollama is taking too long. Please try again."
        except requests.exceptions.ConnectionError:
            return "❌ Cannot connect to Ollama. Make sure it's running: ollama serve"
        except Exception as e:
            return f"❌ Error: {str(e)}"
    
    def clear_history(self):
        """Clear conversation"""
        self.conversation_history = []
