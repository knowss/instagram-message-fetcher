# Instagram Message History Fetcher

A Docker-based Instagram DM bridge that fetches and syncs your Instagram message history using the [mautrix-meta](https://github.com/mautrix/meta) bridge protocol.

## Features

✅ Fetch complete Instagram DM history
✅ Real-time message sync
✅ Uses official Instagram protocol via mautrix-meta
✅ Deploy to Fly.io with one click
✅ Auto-deploy via GitHub Actions

## Quick Deploy to Fly.io

### 1. Prerequisites

- [Fly.io account](https://fly.io/app/sign-up) (free tier available)
- [Matrix homeserver](https://matrix.org/docs/guides/installing-synapse) (Synapse, Dendrite, etc.)
- Instagram account

### 2. Fork this Repository

Click the "Fork" button at the top of this page.

### 3. Set up Fly.io

Install flyctl:
```bash
# macOS
brew install flyctl

# Linux
curl -L https://fly.io/install.sh | sh

# Windows
powershell -Command "iwr https://fly.io/install.ps1 -useb | iex"
```

Login and get your API token:
```bash
flyctl auth login
flyctl auth token
```

### 4. Create Fly.io App

```bash
flyctl apps create mautrix-meta-instagram
flyctl volumes create mautrix_meta_data --region iad --size 1 --app mautrix-meta-instagram
```

### 5. Add Secrets to GitHub

Go to your forked repository → Settings → Secrets and variables → Actions → New repository secret

Add:
- **Name**: `FLY_API_TOKEN`
- **Value**: (paste the token from step 3)

### 6. Deploy

Push to main branch or manually trigger:
- Go to Actions tab
- Click "Deploy to Fly.io"
- Click "Run workflow"

The app will auto-deploy on every push to `main`.

## Configuration

### First Time Setup

1. SSH into your Fly.io container:
```bash
flyctl ssh console -a mautrix-meta-instagram
```

2. Edit the config:
```bash
vi /data/config.yaml
```

3. Set Instagram mode:
```yaml
meta:
  mode: instagram
```

4. Configure your Matrix homeserver:
```yaml
homeserver:
  address: https://matrix.yourdomain.com
  domain: yourdomain.com
```

5. Set permissions (replace with your Matrix user ID):
```yaml
bridge:
  permissions:
    "@yourusername:yourdomain.com": admin
```

6. Save and exit, then restart:
```bash
exit
flyctl apps restart mautrix-meta-instagram
```

### Get Registration File

```bash
flyctl ssh console -a mautrix-meta-instagram
cat /data/registration.yaml
```

Add this to your Matrix homeserver config (`homeserver.yaml` for Synapse):
```yaml
app_service_config_files:
  - /path/to/mautrix-meta-registration.yaml
```

Restart your Matrix homeserver.

## Usage - Fetch Instagram Messages

### 1. Start Chat with Bridge Bot

On Matrix, message: `@metabot:yourdomain.com`

### 2. Login to Instagram

Send: `login`

The bot will ask for Instagram cookies.

### 3. Get Instagram Cookies

**Option A: Browser DevTools (Chrome/Firefox)**

1. Go to https://instagram.com and login
2. Press F12 to open DevTools
3. Go to: Application → Cookies → https://instagram.com
4. Copy these cookies:
   - `sessionid`
   - `ds_user_id`
   - `csrftoken`

**Option B: cURL from DevTools**

1. Go to instagram.com and login
2. Open DevTools (F12) → Network tab
3. Refresh page, right-click any request → Copy → Copy as cURL
4. Paste the entire cURL command to the bot

### 4. Send Cookies

Format as JSON:
```json
{
  "sessionid": "your_session_id",
  "ds_user_id": "your_user_id",
  "csrftoken": "your_csrf_token"
}
```

Or paste the cURL command directly.

### 5. Fetch Message History

The bridge will automatically:
- Connect to Instagram
- Create Matrix rooms for each DM conversation
- Sync complete message history (all past messages)
- Keep messages in sync in real-time

You'll see all your Instagram DMs appear as Matrix chats!

## Monitoring

### View Logs
```bash
flyctl logs -a mautrix-meta-instagram
```

### Check Status
```bash
flyctl status -a mautrix-meta-instagram
```

### SSH Access
```bash
flyctl ssh console -a mautrix-meta-instagram
```

## Local Development

### With Docker Compose

```bash
docker-compose up -d
```

Data stored in `./data/`

### Manual Docker Build

```bash
docker build -t mautrix-meta .
docker run -v $(pwd)/data:/data -p 29319:29319 mautrix-meta
```

## Troubleshooting

### Bridge won't connect
- Check logs: `flyctl logs`
- Verify config.yaml has `mode: instagram`
- Ensure Matrix homeserver has registration file
- Restart homeserver after adding registration

### Cookies expired
- Instagram cookies expire after ~90 days
- Re-run `login` command to refresh

### Missing messages
- The bridge syncs all history on first login
- Check Matrix rooms created by the bridge
- Some DMs may be in different room formats (groups vs 1-on-1)

### Reset Everything
```bash
flyctl volumes delete mautrix_meta_data -a mautrix-meta-instagram
flyctl volumes create mautrix_meta_data --region iad --size 1 -a mautrix-meta-instagram
flyctl deploy
```

## Architecture

```
Instagram ←→ mautrix-meta (Fly.io) ←→ Matrix Homeserver ←→ Matrix Client
```

The bridge:
1. Authenticates with Instagram using cookies
2. Maintains connection to Instagram's messaging protocol
3. Translates Instagram messages to/from Matrix protocol
4. Syncs all message history and real-time updates

## Costs

**Fly.io Free Tier includes:**
- 3 shared-cpu-1x VMs with 256MB RAM
- 3GB persistent volume storage
- 160GB outbound data transfer

**This setup costs:**
- ~$0.15/month for 1GB volume (within free tier if you have volume credits)

## Security

⚠️ **Important:**
- Keep your `config.yaml` and cookies secure
- Use 2FA on Instagram account
- Don't share your API tokens
- Use HTTPS for Matrix homeserver

## Credits

Built with:
- [mautrix-meta](https://github.com/mautrix/meta) - Matrix bridge for Instagram/Facebook
- [messagix](https://github.com/0xzer/messagix) - Instagram/Facebook protocol implementation

## License

This deployment setup is provided as-is. The mautrix-meta project has its own license (AGPL-3.0).

## Support

- Bridge issues: https://github.com/mautrix/meta/issues
- Matrix room: [#meta:maunium.net](https://matrix.to/#/#meta:maunium.net)
- Fly.io docs: https://fly.io/docs/
