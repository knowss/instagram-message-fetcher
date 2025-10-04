# Instagram DM Bridge - Complete Setup

A complete Docker setup to access Instagram DMs through Matrix protocol using mautrix-meta bridge.

## 🎯 What This Does

- **Syncs Instagram DMs** to Matrix
- **Complete message history** fetching
- **Real-time messaging** between Instagram and Matrix
- **Works with username/password** login via browser cookies

## 📋 Requirements

- Docker & Docker Compose
- That's it!

## 🚀 Quick Start (Local Testing)

### 1. Start the Complete Stack

```bash
cd matrix-stack
./setup.sh
```

This starts:
- ✅ Synapse (Matrix homeserver)
- ✅ PostgreSQL (database)
- ✅ mautrix-meta (Instagram bridge)

### 2. Create Matrix Account

Go to https://app.element.io

- Click "Sign In"
- Click "Edit" next to homeserver
- Enter: `http://localhost:8008`
- Click "Create Account"
- Username: `admin`
- Password: (your choice)

### 3. Login to Instagram

In Element:
1. Click "Start Chat"
2. Enter: `@metabot:localhost`
3. Send: `login`
4. Open Instagram in browser (private window)
5. Open DevTools (F12) → Network → XHR
6. Login to Instagram
7. Find a "graphql" request
8. Right-click → Copy → Copy as cURL
9. Paste into Matrix chat with @metabot
10. ✅ Instagram DMs will sync!

## 🌐 Deploy to Production (Fly.io)

The bridge is already deployed at Fly.io, but you need your own Matrix homeserver.

### Option A: Use matrix-stack locally, bridge on Fly.io

1. Keep matrix-stack running locally
2. Update Fly.io bridge to connect to your public IP/domain
3. Use ngrok or similar to expose local Synapse

### Option B: Deploy everything to Fly.io

Deploy both Synapse and bridge to Fly.io (requires more setup)

## 📁 Project Structure

```
.
├── matrix-stack/          # Local Docker setup
│   ├── docker-compose.yml # Synapse + PostgreSQL + Bridge
│   ├── setup.sh          # Automated setup script
│   └── README.md         # Local setup guide
│
├── fly.toml              # Fly.io bridge deployment
├── meta/                 # mautrix-meta source (submodule)
└── README.md            # This file
```

## 🔧 How It Works

```
Instagram ←→ mautrix-meta ←→ Synapse ←→ Element
              (bridge)      (Matrix)    (you)
```

1. **You** use Element (Matrix client)
2. **Element** connects to Synapse (Matrix homeserver)
3. **Synapse** routes messages to mautrix-meta (bridge)
4. **mautrix-meta** connects to Instagram
5. Messages flow bidirectionally

## 📱 What You Can Do

- ✅ Read all Instagram DMs in Matrix
- ✅ Send Instagram DMs from Matrix
- ✅ Complete message history sync
- ✅ Real-time notifications
- ✅ Media attachments
- ✅ Reactions (limited)

## 🔐 Authentication

The bridge uses Instagram's web protocol:
- Login via browser
- Copy network request as cURL
- Paste to bridge
- No username/password stored
- Uses session cookies only

## 📊 View Logs

```bash
cd matrix-stack
docker-compose logs -f mautrix-meta
```

## 🛑 Stop Everything

```bash
cd matrix-stack
docker-compose down
```

## 🔄 Reset & Start Over

```bash
cd matrix-stack
docker-compose down -v
rm -rf synapse-data bridge-data postgres-data
./setup.sh
```

## 📚 Documentation

- [mautrix-meta docs](https://docs.mau.fi/bridges/go/meta/)
- [Matrix docs](https://matrix.org/docs/guides/)
- [Element](https://element.io)

## 🎯 Next Steps

1. **For local testing**: Use `matrix-stack/`
2. **For production**: Deploy Synapse to a server with public domain
3. **GitHub repo**: Push to GitHub for CI/CD (already configured)
4. **Fly.io**: Bridge deployment ready at `mautrix-meta-instagram.fly.dev`

## 💡 Tips

- Use Instagram account without 2FA for easier login
- Keep Element open for real-time sync
- Instagram may rate-limit on first sync (be patient)
- Check bridge logs if messages don't appear

## ⚠️ Important

- This bridges Instagram to Matrix (not a standalone client)
- Requires Matrix homeserver (Synapse)
- Uses Instagram's unofficial protocol
- Instagram may require verification on new logins
