#!/bin/bash

set -e

echo "=== Matrix + Instagram Bridge Setup ==="
echo ""

# Create directories
mkdir -p synapse-data bridge-data postgres-data

echo "Step 1: Generating Synapse config..."
docker-compose run --rm synapse generate

echo ""
echo "Step 2: Updating Synapse config for local testing..."

# Update synapse config
cat >> synapse-data/homeserver.yaml << 'EOF'

# Allow registration without email
enable_registration: true
enable_registration_without_verification: true

# Trust all proxy headers (for local testing)
trusted_key_servers: []

# App service registration files
app_service_config_files:
  - /data/mautrix-meta-registration.yaml
EOF

echo ""
echo "Step 3: Starting Synapse..."
docker-compose up -d synapse postgres

echo "Waiting for Synapse to start..."
sleep 10

echo ""
echo "Step 4: Generating bridge config..."
docker-compose run --rm mautrix-meta

echo ""
echo "Step 5: Configuring bridge for Instagram..."

# Update bridge config
cat > bridge-data/config.yaml << 'EOF'
homeserver:
  address: http://synapse:8008
  domain: localhost

appservice:
  address: http://mautrix-meta:29319
  hostname: 0.0.0.0
  port: 29319
  database:
    type: sqlite3-fk-wal
    uri: file:/data/mautrix-meta.db

  id: meta
  bot:
    username: metabot
    displayname: Meta Bridge Bot
    avatar: mxc://maunium.net/YEYXhHTqRGYpCGYCBFhCDvFL

  as_token: generate
  hs_token: generate

meta:
  mode: instagram

bridge:
  username_template: instagram_{{.}}
  displayname_template: "{{or .DisplayName .Username}}"

  permissions:
    "*": relay
    "localhost": user
    "@admin:localhost": admin

  encryption:
    allow: false
    default: false

logging:
  min_level: debug
  writers:
  - type: stdout
    format: pretty-colored
EOF

echo ""
echo "Step 6: Generating bridge registration..."
docker-compose run --rm mautrix-meta

# Copy registration to synapse
cp bridge-data/registration.yaml synapse-data/mautrix-meta-registration.yaml

echo ""
echo "Step 7: Restarting Synapse with bridge registration..."
docker-compose restart synapse

echo "Waiting for Synapse to restart..."
sleep 5

echo ""
echo "Step 8: Starting bridge..."
docker-compose up -d mautrix-meta

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Next steps:"
echo "1. Create a Matrix account:"
echo "   Username: admin"
echo "   Password: <your-choice>"
echo "   Register at: http://localhost:8008"
echo ""
echo "2. Use Element Web to connect:"
echo "   https://app.element.io"
echo "   Custom homeserver: http://localhost:8008"
echo ""
echo "3. Start a chat with @metabot:localhost"
echo "4. Send: login"
echo "5. Follow the Instagram authentication flow"
echo ""
echo "View logs:"
echo "  docker-compose logs -f mautrix-meta"
echo ""
