#!/bin/bash
# Start backend in PRODUCTION MODE with all 4,495 stations

export STATION_TEST_MODE=false
export FLASK_ENV=development

echo "🚀 Starting PureHealth Backend in PRODUCTION MODE"
echo "📊 Loading all 4,495 Maharashtra water stations..."
echo ""

python3 app.py
