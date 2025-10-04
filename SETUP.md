# Instagram Message Bridge Setup

This Docker setup uses mautrix-meta to bridge Instagram DMs with Matrix.

## Prerequisites

1. Install Docker and Docker Compose
2. A Matrix homeserver account
3. Instagram account credentials

## Quick Start

### 1. Build and Run

```bash
docker-compose up -d
```

On first run, it will generate a default config file at `./data/config.yaml`.

### 2. Configure the Bridge

Edit `./data/config.yaml`:

- Set `meta.mode` to `instagram`
- Configure your Matrix homeserver details:
  ```yaml
  homeserver:
    address: https://your-homeserver.com
    domain: your-homeserver.com
  ```
- Set bridge permissions for your Matrix user ID

### 3. Restart to Generate Registration

```bash
docker-compose restart
```

This generates `./data/registration.yaml`.

### 4. Register the Bridge with Matrix Homeserver

Add the registration file to your Matrix homeserver config and restart the homeserver.

For Synapse, add to `homeserver.yaml`:
```yaml
app_service_config_files:
  - /path/to/registration.yaml
```

### 5. Start the Bridge

```bash
docker-compose up -d
```

### 6. Login to Instagram

1. Start a chat with the bridge bot on Matrix (`@metabot:your-homeserver.com`)
2. Send: `login`
3. Follow the authentication flow
4. The bridge will sync your Instagram DM conversations

## Commands

In Matrix, message the bridge bot:

- `login` - Authenticate with Instagram
- `logout` - Disconnect from Instagram
- `reconnect` - Reconnect to Instagram
- `help` - Show all available commands

## Data Storage

All data is stored in `./data/`:
- `config.yaml` - Bridge configuration
- `registration.yaml` - Matrix registration
- `mautrix-meta.db` - Bridge database

## Troubleshooting

View logs:
```bash
docker-compose logs -f
```

Reset and reconfigure:
```bash
docker-compose down
rm -rf ./data
docker-compose up -d
```

## Documentation

Full documentation: https://docs.mau.fi/bridges/go/meta/index.html
