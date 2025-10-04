# Deploy mautrix-meta Instagram Bridge to Fly.io

This guide shows you how to deploy the Instagram DM bridge to Fly.io.

## Prerequisites

1. Install flyctl CLI: https://fly.io/docs/hands-on/install-flyctl/
2. Create a Fly.io account (free tier available)
3. Have a Matrix homeserver running (Synapse, Dendrite, etc.)

## Quick Deploy

```bash
./deploy.sh
```

The script will:
- Create a Fly.io app named `mautrix-meta-instagram`
- Create a 1GB persistent volume for data
- Build and deploy the Docker image

## Manual Deployment

### 1. Install flyctl

```bash
# macOS
brew install flyctl

# Linux
curl -L https://fly.io/install.sh | sh

# Windows
powershell -Command "iwr https://fly.io/install.ps1 -useb | iex"
```

### 2. Login to Fly.io

```bash
flyctl auth login
```

### 3. Create the app

```bash
flyctl apps create mautrix-meta-instagram
```

### 4. Create persistent volume

```bash
flyctl volumes create mautrix_meta_data --region iad --size 1
```

Change `iad` to your preferred region. Available regions:
- `iad` - Ashburn, Virginia (US)
- `lhr` - London (UK)
- `fra` - Frankfurt (Germany)
- `syd` - Sydney (Australia)
- `sin` - Singapore
- See all: `flyctl platform regions`

### 5. Deploy

```bash
flyctl deploy
```

## Configuration

### First Run - Generate Config

On first deployment, the bridge generates a default config at `/data/config.yaml`.

SSH into the container:
```bash
flyctl ssh console
```

Edit the config:
```bash
vi /data/config.yaml
```

Key settings to configure:

```yaml
# Set platform mode
meta:
  mode: instagram

# Configure your Matrix homeserver
homeserver:
  address: https://matrix.yourdomain.com
  domain: yourdomain.com

# Set bridge permissions (replace with your Matrix user ID)
bridge:
  permissions:
    "@yourusername:yourdomain.com": admin
```

Save and restart:
```bash
exit
flyctl apps restart mautrix-meta-instagram
```

### Generate Registration File

After configuring, restart to generate the registration file:

```bash
flyctl ssh console
cat /data/registration.yaml
```

Copy this registration file to your Matrix homeserver config.

For Synapse, add to `homeserver.yaml`:
```yaml
app_service_config_files:
  - /path/to/mautrix-meta-registration.yaml
```

Restart your Matrix homeserver.

## Usage

### Login to Instagram

1. Message the bridge bot on Matrix: `@metabot:yourdomain.com`
2. Send: `login`
3. The bot will ask for Instagram cookies
4. Get cookies from your browser:
   - Open instagram.com and login
   - Open DevTools (F12) → Application → Cookies
   - Copy required cookies: `sessionid`, `ds_user_id`, etc.
   - Send as JSON to the bot
5. The bridge will connect and sync your DMs

### View Logs

```bash
flyctl logs
```

### Monitor Status

```bash
flyctl status
```

### Scale Resources

```bash
# Scale memory
flyctl scale memory 512

# Scale VM
flyctl scale vm shared-cpu-1x
```

## Persistent Data

All data is stored in the mounted volume at `/data/`:
- `config.yaml` - Bridge configuration
- `registration.yaml` - Matrix registration
- `mautrix-meta.db` - SQLite database with messages

The volume persists across deployments and restarts.

## Troubleshooting

### Check logs
```bash
flyctl logs --app mautrix-meta-instagram
```

### SSH into container
```bash
flyctl ssh console
```

### Restart app
```bash
flyctl apps restart mautrix-meta-instagram
```

### Delete volume (reset everything)
```bash
flyctl volumes delete mautrix_meta_data
flyctl volumes create mautrix_meta_data --region iad --size 1
flyctl deploy
```

## Costs

- **Free tier**: 3 shared-cpu-1x VMs with 256MB RAM
- **Volume**: $0.15/GB/month (1GB = $0.15/month)
- **Bandwidth**: 100GB/month free

This setup should fit within the free tier.

## Security Notes

1. Keep your `config.yaml` secure - it contains bridge secrets
2. Use Matrix homeserver with proper TLS/SSL
3. Don't share your Instagram cookies
4. Use strong passwords and 2FA on both Instagram and Matrix

## Documentation

- Full bridge docs: https://docs.mau.fi/bridges/go/meta/
- Fly.io docs: https://fly.io/docs/
- Matrix homeserver: https://matrix.org/docs/guides/
