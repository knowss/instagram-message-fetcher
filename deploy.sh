#!/bin/bash

set -e

echo "🚀 Deploying mautrix-meta Instagram bridge to Fly.io"

# Check if flyctl is installed
if ! command -v flyctl &> /dev/null; then
    echo "❌ flyctl is not installed. Install it from: https://fly.io/docs/hands-on/install-flyctl/"
    exit 1
fi

# Check if logged in
if ! flyctl auth whoami &> /dev/null; then
    echo "🔐 Not logged in to Fly.io. Please login:"
    flyctl auth login
fi

# Create app if it doesn't exist
if ! flyctl apps list | grep -q "mautrix-meta-instagram"; then
    echo "📦 Creating new Fly.io app..."
    flyctl apps create mautrix-meta-instagram

    echo "💾 Creating persistent volume for data..."
    flyctl volumes create mautrix_meta_data --region iad --size 1
fi

echo "🔨 Building and deploying..."
flyctl deploy

echo "✅ Deployment complete!"
echo ""
echo "📋 Next steps:"
echo "1. SSH into the app: flyctl ssh console"
echo "2. Edit config: vi /data/config.yaml"
echo "3. Set mode to 'instagram' in the config"
echo "4. Restart: flyctl apps restart mautrix-meta-instagram"
echo ""
echo "📊 View logs: flyctl logs"
echo "🔍 Check status: flyctl status"
