# Complete Matrix + Instagram Bridge Stack

This setup includes everything you need to test Instagram message fetching:
- **Synapse** (Matrix homeserver)
- **PostgreSQL** (database)
- **mautrix-meta** (Instagram bridge)

## Quick Start

### 1. Run the automated setup:

```bash
cd "/Users/paulsda/Desktop/docker test instagram/matrix-stack"
./setup.sh
```

This script will:
- Generate Synapse configuration
- Set up PostgreSQL database
- Configure the Instagram bridge
- Connect everything together
- Start all services

### 2. Create a Matrix account

Open your browser and go to: http://localhost:8008

Or use Element Web:
1. Go to https://app.element.io
2. Click "Sign In"
3. Click "Edit" next to homeserver
4. Enter: `http://localhost:8008`
5. Create account with username `admin` and a password

### 3. Test Instagram Connection

In Element:
1. Click "Start Chat" or "New Direct Message"
2. Enter: `@metabot:localhost`
3. Send message: `login`
4. The bot will guide you through Instagram authentication
5. Provide your Instagram cookies when prompted
6. Your Instagram DMs will start syncing!

## Getting Instagram Cookies

1. Open instagram.com in your browser and login
2. Press F12 to open DevTools
3. Go to: Application → Cookies → https://instagram.com
4. Copy these values:
   - `sessionid`
   - `ds_user_id`
   - `csrftoken`
5. Paste them when the bridge asks

## Useful Commands

### View bridge logs:
```bash
docker-compose logs -f mautrix-meta
```

### View Synapse logs:
```bash
docker-compose logs -f synapse
```

### Restart everything:
```bash
docker-compose restart
```

### Stop everything:
```bash
docker-compose down
```

### Reset and start over:
```bash
docker-compose down -v
rm -rf synapse-data bridge-data postgres-data
./setup.sh
```

## What Happens After Login

Once you provide Instagram credentials:
1. Bridge connects to Instagram
2. Creates Matrix rooms for each Instagram conversation
3. Syncs complete message history
4. Real-time syncing of new messages
5. You can send/receive Instagram DMs from Matrix!

## Ports

- **8008**: Synapse (Matrix homeserver)
- **29319**: mautrix-meta bridge (internal)

## Troubleshooting

### Can't connect to Synapse
- Make sure port 8008 is not in use: `lsof -i :8008`
- Check logs: `docker-compose logs synapse`

### Bridge not responding
- Check if it's running: `docker-compose ps`
- View logs: `docker-compose logs mautrix-meta`
- Restart: `docker-compose restart mautrix-meta`

### Can't see @metabot
- Make sure you registered with username containing "admin"
- Check bridge permissions in bridge-data/config.yaml
- Restart both services: `docker-compose restart`

## Architecture

```
Instagram ←→ mautrix-meta ←→ Synapse ←→ Element (you)
                ↓                ↓
           bridge-data    postgres-data
```

## Next Steps

After successful Instagram connection:
1. All your Instagram DMs appear as Matrix rooms
2. Complete chat history is synced
3. Send/receive messages through Matrix
4. Media, reactions, and more work automatically

## Production Deployment

For production, deploy to Fly.io (already set up):
- The mautrix-meta-instagram app is running
- Configure it to connect to your public Synapse instance
- Use a real domain instead of localhost
