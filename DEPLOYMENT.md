# Complete Deployment Guide

## 📦 What You Have

1. **Local Stack** (`matrix-stack/`) - Synapse + Bridge running locally
2. **Fly.io Bridge** - mautrix-meta deployed at `mautrix-meta-instagram.fly.dev`
3. **GitHub Repo** - https://github.com/knowss/instagram-message-fetcher

## 🎯 Deployment Options

### Option 1: Local Testing (Easiest)

**Already done!** Your matrix-stack is ready.

```bash
cd "/Users/paulsda/Desktop/docker test instagram/matrix-stack"
./setup.sh   # If not already running
```

Then:
1. Go to https://app.element.io
2. Homeserver: `http://localhost:8008`
3. Create account: username `admin`
4. Chat with `@metabot:localhost`
5. Send: `login`
6. Follow Instagram auth

### Option 2: Host Everything on Fly.io

Deploy both Synapse and bridge to Fly.io.

#### Step 1: Deploy Synapse to Fly.io

```bash
cd "/Users/paulsda/Desktop/docker test instagram"

# Create Synapse app
export FLYCTL_INSTALL="/Users/paulsda/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

flyctl apps create instagram-synapse

# Create volume for data
flyctl volumes create synapse_data --size 10 --app instagram-synapse

# Create fly.toml for Synapse
cat > synapse-fly.toml << 'EOF'
app = "instagram-synapse"
primary_region = "iad"

[build]
  image = "matrixdotorg/synapse:latest"

[env]
  SYNAPSE_SERVER_NAME = "instagram-synapse.fly.dev"
  SYNAPSE_REPORT_STATS = "no"

[mounts]
  source = "synapse_data"
  destination = "/data"

[[services]]
  internal_port = 8008
  protocol = "tcp"

  [[services.ports]]
    handlers = ["http"]
    port = 80

  [[services.ports]]
    handlers = ["tls", "http"]
    port = 443
EOF

# Deploy
flyctl deploy -c synapse-fly.toml
```

#### Step 2: Update Bridge to Connect to Synapse

Update the existing bridge config on Fly.io:

```bash
flyctl ssh console -a mautrix-meta-instagram

# Edit config
vi /data/config.yaml

# Change homeserver address to:
homeserver:
  address: https://instagram-synapse.fly.dev
  domain: instagram-synapse.fly.dev

# Save and exit
exit

# Restart bridge
flyctl apps restart mautrix-meta-instagram
```

#### Step 3: Use It

1. Go to https://app.element.io
2. Homeserver: `https://instagram-synapse.fly.dev`
3. Create account
4. Chat with `@metabot:instagram-synapse.fly.dev`
5. Send: `login`

### Option 3: GitHub Actions Auto-Deploy

Your repo is already configured with GitHub Actions.

#### Current Setup:
- Repo: https://github.com/knowss/instagram-message-fetcher
- Workflow: `.github/workflows/fly-deploy.yml`
- Secret: `FLY_API_TOKEN` (already set)

Every push to `main` auto-deploys the bridge to Fly.io.

To deploy Synapse too:

1. Create `.github/workflows/deploy-synapse.yml`:

```yaml
name: Deploy Synapse to Fly.io

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: superfly/flyctl-actions/setup-flyctl@master
      - name: Deploy Synapse
        run: flyctl deploy -c synapse-fly.toml
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
```

2. Push to GitHub:

```bash
cd "/Users/paulsda/Desktop/docker test instagram"
git add .
git commit -m "Add Synapse deployment"
git push
```

## 🔐 Instagram Login Process

**No matter which deployment option:**

1. Start chat with bridge bot
2. Send: `login`
3. Bot responds with instructions
4. Open Instagram in private browser window
5. Open DevTools (F12) → Network tab → XHR filter
6. Login to Instagram normally
7. Find any "graphql" request
8. Right-click → Copy → Copy as cURL
9. Paste the ENTIRE cURL command to bot
10. Bot extracts cookies and logs you in
11. Instagram DMs start syncing!

## 📊 Monitor Deployments

### Local:
```bash
cd matrix-stack
docker-compose logs -f
```

### Fly.io Bridge:
```bash
flyctl logs -a mautrix-meta-instagram
```

### Fly.io Synapse (if deployed):
```bash
flyctl logs -a instagram-synapse
```

## 🔄 Update Bridge Code

### Local:
```bash
cd matrix-stack
docker-compose pull
docker-compose up -d
```

### Fly.io (Manual):
```bash
cd "/Users/paulsda/Desktop/docker test instagram"
git pull
flyctl deploy
```

### Fly.io (Auto):
Just push to GitHub main branch - GitHub Actions will deploy automatically!

## 📁 Where to Host GitHub Repo

Your repo is already at: https://github.com/knowss/instagram-message-fetcher

To update it:
```bash
cd "/Users/paulsda/Desktop/docker test instagram"
git add .
git commit -m "Update configuration"
git push
```

## ✅ Summary

**What's Working Now:**
- ✅ matrix-stack (local) - Synapse + Bridge running on your Mac
- ✅ Fly.io deployment - Bridge deployed and running
- ✅ GitHub repo - Code pushed and CI/CD configured

**To Test Instagram:**
1. Use local stack: `cd matrix-stack && ./setup.sh`
2. Element: `http://localhost:8008`
3. Chat: `@metabot:localhost`
4. Login: paste Instagram cURL command
5. Done!

**For Production:**
- Deploy Synapse to Fly.io (Option 2 above)
- Or use any Matrix homeserver (matrix.org, etc.)
- Bridge is ready at `mautrix-meta-instagram.fly.dev`
