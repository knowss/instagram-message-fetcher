# Quick Deploy Instructions

## Deploy to Fly.io (Step by Step)

### 1. Install flyctl (if not already installed)

```bash
brew install flyctl
```

### 2. Login to Fly.io

```bash
flyctl auth login
```

### 3. Deploy directly (Fly.io will auto-configure)

```bash
cd "/Users/paulsda/Desktop/docker test instagram"
flyctl deploy --ha=false
```

This will:
- Create the app automatically
- Build the Docker image
- Deploy to Fly.io
- Create a volume if needed

### 4. After first deploy, create persistent volume

```bash
flyctl volumes create mautrix_meta_data --size 1
```

### 5. Scale down to free tier

```bash
flyctl scale count 1
flyctl scale vm shared-cpu-1x --memory 256
```

### 6. Configure the app

SSH into the container:
```bash
flyctl ssh console
```

Edit config:
```bash
vi /data/config.yaml
```

Set mode to `instagram`:
```yaml
meta:
  mode: instagram

homeserver:
  address: https://matrix.yourdomain.com
  domain: yourdomain.com

bridge:
  permissions:
    "@yourusername:yourdomain.com": admin
```

Save and restart:
```bash
exit
flyctl apps restart
```

## Alternative: Manual App Creation

If you want more control:

```bash
# Create app manually
flyctl apps create mautrix-meta-instagram

# Create volume
flyctl volumes create mautrix_meta_data --size 1 --app mautrix-meta-instagram

# Deploy
flyctl deploy --app mautrix-meta-instagram
```

## GitHub Actions Auto-Deploy

Set the `FLY_API_TOKEN` secret:

```bash
flyctl auth token
```

Copy the token and add to GitHub:
- Go to: https://github.com/knowss/instagram-message-fetcher/settings/secrets/actions
- New secret: `FLY_API_TOKEN` = (paste token)

Now every push to `main` will auto-deploy!
