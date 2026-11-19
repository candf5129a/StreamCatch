# StreamCatch architecture and build plan

## Product boundary

The first release is a movie and series discovery app. It can show metadata, official trailers, and links to authorized viewing services. It does not host full movies until StreamCatch has title-specific distribution rights and an approved delivery provider. A metadata API key is not a license to stream a movie.

## Architecture

```text
Flutter app (Android first, Windows client)
    ├── REST + Dio ─────────── Go modular monolith on Render
    ├── WebSocket ──────────── Go chat / room events (later phase)
    └── Firebase messaging ─── Android push notifications (later phase)
                                ├── Supabase Auth
                                ├── Supabase PostgreSQL
                                └── Supabase Storage for approved artwork/media

Approved metadata provider ── Go catalogue adapter
Licensed video provider ───── Flutter player / authorized download service
```

Go owns application rules: account permissions, catalogue and search aggregation, watchlists, reviews, validation, chat membership, download authorization, moderation, and admin actions. Supabase Auth owns identity verification and token issuance. Go verifies the access token and enforces authorization before accessing protected records or media. PostgreSQL is the permanent source of truth. Redis is deferred until measured cache, coordination, or rate-limit needs justify operating it.

## Responsibility map

| Capability | Initial owner | Status |
| --- | --- | --- |
| Android and Windows client | Flutter/Dart | UI prototype exists |
| HTTP API | Go modular monolith | Not implemented |
| User registration, verification, recovery | Supabase Auth, called through Go policy | Planned; credentials/provider setup required |
| Movie metadata, search, genres | Go plus approved catalogue provider | Planned; provider key and attribution required |
| Watchlists and reviews | Go + PostgreSQL | Planned |
| Approved poster and user media files | Supabase Storage | Planned; access rules required |
| Authorized direct downloads and history | Flutter/Dio + Go validation | Planned; source authorization required |
| Link Scanner | Downloads feature only | UI validation is prototype-only |
| One-to-one/group chat | Go + WebSocket + PostgreSQL | Phase 2; current chat is local demo state |
| Online presence and temporary coordination | Add Redis only when needed | Deferred |
| Watch Together | Go + WebSocket, later supported player/provider | Later phase |
| Android notifications | Firebase Cloud Messaging | Later phase |
| Licensed full-length playback | Approved rights holder/provider + player/CDN | Not available until rights are secured |
| Admin, reports, audit events | Go + PostgreSQL | Planned before wider user testing |

## Data ownership and trust boundaries

- PostgreSQL stores profiles, catalogue references, watchlists, reviews, notification records, reports, room membership, and message history.
- Supabase Auth stores credentials, verification, recovery, and sessions. Passwords must never be stored by the Go service in plaintext.
- Supabase Storage is private by default for non-public user data. Go issues or validates scoped access after checking ownership and visibility.
- The Flutter client is untrusted. Go validates every identifier, permission, request limit, media URL, room membership, and download decision.
- Download URLs are not automatically authorized. Do not bypass DRM, paywalls, encryption, or authentication restrictions. Only allow sources StreamCatch has permission to access and users have permission to download.
- WebSocket connections authenticate once and authorize each conversation or room subscription. Persistent message writes go through the same membership checks as REST.

## Suggested repository organization

```text
StreamCatch/
  lib/
    main.dart
    app/
    core/config/
    core/network/
    core/theme/
    core/utilities/
    features/auth/
    features/home/
    features/movies/
    features/search/
    features/watchlist/
    features/reviews/
    features/downloads/
    features/chat/
    features/profile/
    shared/
  assets/
  test/
backend/
  cmd/api/
  internal/{auth,users,movies,search,watchlist,reviews,downloads,chat,notifications,watchtogether,moderation,admin}/
  migrations/
  config/
  tests/
docs/
```

The current UI stays in `lib/main.dart` until each integration is ready to extract; avoid empty packages that imply unfinished services already work. Backend feature packages should call shared application/database interfaces instead of reaching into one another's tables. Database changes ship as reviewed migrations.

## Phases

1. **Foundation:** Flutter shell, Git, environment config, Go service skeleton, PostgreSQL migrations, health endpoint, and CI/build checks.
2. **Accounts:** sign-up, email verification, sign-in/out, recovery, session handling, profile, and authorization checks.
3. **Movie discovery:** approved metadata adapter, attribution, home catalogue, categories, search, details, and official trailer links.
4. **Personal library:** watchlists, ratings/reviews, and viewing history.
5. **Downloads:** only authorized sources, server validation, progress/retry/cancel UI, device storage, and download history. Keep Link Scanner inside Downloads.
6. **Testing and launch preparation:** reports, moderation, admin tools, privacy/terms, backups, logging, rate limits, and load testing.
7. **Messaging:** REST conversation bootstrap, WebSocket message delivery, persisted history/read state, blocks/reports, then push notification support.
8. **Watch Together and streaming:** only after selecting compatible players/providers and securing the relevant rights.

## Development with current local tools

Flutter/Dart are installed on the development machine. Go, cloud credentials, provider API keys, Firebase setup, production signing keys, and streaming rights are not configured in this workspace. Continue with the Flutter UI and mock/repository interfaces locally; cloud-backed behavior needs those services before it can be truthfully tested end to end. Never commit `.env`, service-role keys, app signing keys, or private licensing documents.
