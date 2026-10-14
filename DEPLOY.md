# dsaialap deploy notes

Existing mobile APIs (`/api/auth`, `/api/users`, `/api/messages`) and Socket.io events are unchanged.
B2B lives only under `/api/b2b`.

## Google VPS (Docker + Nginx)

```bash
cd backend
cp .env.example .env
docker compose -f docker-compose.prod.yml up -d --build
bash scripts/issue-certs.sh
chmod +x scripts/dsaialap_monitor.sh
```

Cron (every minute):

```bash
* * * * * /opt/dsaialap/backend/scripts/dsaialap_monitor.sh
```

## Flutter release APKs (non-destructive)

```bash
cd mobile
flutter pub get
flutter gen-l10n
flutter build apk --release --split-per-abi
```

Outputs:

- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`
- `build/app/outputs/flutter-apk/app-x86_64-release.apk`

## Vercel / Netlify SPA dashboard

Publish `dashboard/`. Root `vercel.json` and `netlify.toml` rewrite unknown paths to `index.html`.
