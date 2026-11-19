# StreamCatch

StreamCatch is a movie discovery and viewing app for Android and Windows, built with Flutter and Dart. The interface follows the supplied cinema and social app references: a dark cinematic theme, poster led discovery, search, a saved library, downloads, profiles, messaging, communities, and Watch Together.

## Current build

The repository contains the Flutter app and Android, Windows, and Web runners. The current milestone is a navigable UI prototype with Welcome, Sign In, Home, Search, Movie Details, My Library, Downloads, Profile, Chat, Conversation, Communities, Watch Together, and Watch Room screens. The visual direction follows the supplied black-and-orange reference: a warm orange accent, image-led title cards, orange playback controls, and Chat in the five-item bottom navigation. The app renders as a single interactive Flutter interface at every window size. The Home screen follows the supplied dark cinema reference with orange accents, and Chat is available in the bottom navigation. The sample conversation composer works in memory for the current app session; there is no account-backed message delivery or cross-device sync yet. Sample catalogue details and image URLs are demonstration content. TMDB, accounts, playback, studio publishing, payments, and downloads are not connected yet.

The demo images are served from Unsplash at runtime. Replace them with appropriately licensed TMDB artwork or approved studio artwork when the catalogue provider is implemented. TMDB metadata and images must follow TMDB's terms and attribution requirements; metadata access does not grant movie streaming rights.

## Product and rights rules

- Use TMDB for movie metadata and artwork under its API terms. Show trailers only from official or otherwise authorized sources.
- Studios and distributors can publish only after account verification and title specific rights review. Ordinary viewers cannot upload movie files.
- Provide licensed streams from approved providers. Never extract or bypass DRM, encryption, authentication, or access controls.
- Plan for free ad supported and premium tiers, with access checked per title, territory, and license window.
- Offline downloads are available only when the title's license allows them. Keep Link Scanner inside Downloads and limit it to authorized direct MP4 and unencrypted HLS sources.
- Chat and Watch Together are planned as Phase 2 features; communities are Phase 3.

## Planned technology

| Area | Technology | Status |
| --- | --- | --- |
| Android and Windows clients | Flutter and Dart | UI prototype |
| Movie catalogue | TMDB API, through a provider interface | Planned |
| Business API and account rules | Go | Planned |
| Persistent data | PostgreSQL | Planned |
| Live chat, notifications, sync | WebSockets | Planned |
| Watch Together media coordination | WebRTC plus WebSocket room events | Planned |
| Offline downloads | Flutter plus Dio, for licensed sources | Planned |
| Media storage and delivery | Cloudflare R2 or another approved object store/CDN | Decision pending |
| Movie transcoding and streaming | Cloudflare Stream or Mux, subject to licensing and cost review | Decision pending |
| Optional managed services | Supabase for selected auth or storage needs | Optional |
| Payments | Provider supporting Nigeria and intended international markets | Decision pending |

The current implementation keeps its screen shell in `lib/main.dart`; the feature folders below are the target organization as service integrations are added. Cloud accounts, API credentials, content licenses, and payment providers are not configured. Do not commit secrets, signing keys, or private rights documents.

## Target code layout

```text
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
backend/
  cmd/api/
  internal/{auth,users,movies,search,watchlist,reviews,downloads,chat,notifications,watchtogether,moderation,admin}/
  migrations/
docs/
```

See [the architecture and phased rollout](docs/architecture.md) for service responsibilities, trust boundaries, and what can be developed with local tools before cloud accounts and media rights are available.

## Requirements

- Flutter stable SDK with Dart. The initial setup used Flutter 3.47.9 and Dart 3.13.7.
- Chrome for the browser preview.
- Android Studio and Android SDK for Android builds.
- Visual Studio with the **Desktop development with C++** workload for Windows desktop builds.

Check the local toolchain with:

```powershell
flutter doctor -v
```

## Run the app

From this repository directory:

```powershell
flutter pub get
flutter run -d chrome
```

Use `flutter devices` to find a connected Android device or emulator, then run `flutter run -d <device-id>`. For Windows, run `flutter run -d windows` after installing the C++ workload.

### Install the current demo on an Android phone

A debug APK is already built at `build/app/outputs/flutter-apk/app-debug.apk` (about 144 MiB). To rebuild it after changing the app, run:

```powershell
flutter build apk --debug
```

Then:

1. Copy `build/app/outputs/flutter-apk/app-debug.apk` to the phone with a USB cable, or upload it to a private cloud drive and download it on the phone.
2. Open the APK from the phone's Files or Downloads app. If Android asks, allow that app to install unknown apps, then return and tap **Install**.
3. Open StreamCatch. Share the APK file with testers through a private link or direct transfer; each Android tester installs their own copy.

This is a debug build for small-group feedback, not a Play Store release. The release APK command is `flutter build apk --release --split-per-abi`; it produces smaller per-processor packages, but a release build and signing key still need to be prepared before public distribution. A release build was not produced in this setup because Gradle could not resolve a dependency from Maven Central. The debug app's Chat tab and sample conversation work only in the current app session; there is no shared server, user accounts, or cross-device messaging yet. Catalogue, playback, and media services also remain unconnected.

## Repository layout

```text
lib/       Flutter app, UI, sample catalogue, and navigation
android/   Android runner
windows/   Windows desktop runner
web/       Browser preview runner
```

## Roadmap

1. Refine the discovery, search, title detail, library, downloads, and profile experience against the supplied references.
2. Add the Go API, PostgreSQL schema, account creation, and secure authentication.
3. Connect TMDB metadata, attribution, search, and official trailer links.
4. Build verified studio onboarding, title rights review, protected storage, and transcoding.
5. Add title level entitlements, licensed viewing, subscriptions, and ad support.
6. Add authorized offline downloads and the Downloads only Link Scanner.
7. Add moderated messaging and Watch Together, then communities.
8. Prepare Android and Windows release builds.

## Development notes

Keep metadata, playback, storage, and payment providers behind interfaces so they can be replaced without coupling the client to one vendor. Use pagination, image caching, low data settings, and adaptive playback as the catalogue grows. Never claim a guaranteed network speed; measure performance with the selected providers and real devices.
