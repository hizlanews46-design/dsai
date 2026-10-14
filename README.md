# Nexus Comm

Hybrid E2EE communication platform: internet signaling, offline mesh voice, and SIM fallback.

## Layout

```
backend/     Node.js + TypeScript API, Socket.io signaling, Prisma, Redis OTP
mobile/       Flutter client (BLoC, i18n en/bn, 4-tab shell)
```

## Backend

Required env: copy `backend/.env.example` to `backend/.env`.

```bash
cd backend
npm ci
npx prisma generate
npm run dev
```

Docker:

```bash
cd backend
cp .env.example .env
docker compose up --build
```

### Auth

- `POST /api/auth/otp/request` — SMS OTP, Redis TTL 180s, max 3 / 15 min
- `POST /api/auth/otp/verify` — JWT access 15m + HTTP-only refresh cookie
- `POST /api/auth/refresh` / `POST /api/auth/logout`
- `POST /api/auth/backup/register` and restore endpoints for offline backup keys

### Signaling (Socket.io)

Authenticated with Bearer access token. Events: `call:offer|answer|ice|hangup`, `message:send|delivered|read`, `e2ee:prekey`.

## Mobile

```bash
cd mobile
flutter pub get
flutter gen-l10n
flutter build apk --release --split-per-abi
```

Language switches at runtime via `LocaleCubit` without restart.
