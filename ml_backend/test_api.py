import requests
import pandas as pd
import json

BASE_URL = "http://localhost:8000"

# Step 1: Load the CSV file
df = pd.read_csv('water_quality_data.csv')
print(f"✅ Loaded {len(df)} records from CSV\n")

# Step 2: Convert to dict for JSON serialization
file_data = df.to_dict('list')
print(f"📊 Data shape: {df.shape}")
print(f"📊 Columns: {df.columns.tolist()}\n")

# Step 3: Send to chat API for analysis
data = {
    "message": "Please analyze this water quality data",
    "file_data": file_data
}

response = requests.post(
    f"{BASE_URL}/api/chat/process",
    json=data
)

print("🤖 AI Response:")
print("=" * 60)
result = response.json()
print(result['response'])
print("=" * 60)
print(f"\n📊 Intent: {result['intent']}")
print(f"📈 Confidence: {result['confidence']}")
if result['metadata'].get('prediction'):
    print(f"🎯 Prediction: {result['metadata']['prediction']}")
