# Sankofa Tiles

A Ghanaian Adinkra Mahjong solitaire tile-matching game built with Flutter.

Match pairs of Adinkra symbol tiles on 3D-layered boards following classic
Mahjong solitaire "free tile" rules. 380 playable levels spanning nineteen chapters, from novice boards to layered
royal courts, woven terraces, festival grounds, and quiet lakeside layouts. The planned campaign horizon is 400 levels.

**Version:** 1.0.0+3
**Platforms:** Android, iOS (portrait only)
**Tech:** Flutter + Riverpod + Firebase

The collection includes 97 Adinkra faces and eight Ghana Heritage portraits.
Heritage pairs begin at Level 21, with another portrait introduced every 20 levels.

## Quick Start

```bash
flutter pub get
flutter run
```

## Project Documentation

| Document | Purpose |
|---|---|
| `docs/heritage-tiles.md` | Heritage portraits, debut levels, matching cadence, and artwork credits |
| `docs/levels-361-380-production-assignment.md` | Latest 20 boards, design constraints, previews, and validation |
| `docs/LOCAL_REMINDERS.md` | Opt-in local reminder schedule, copy, platform setup, and validation |
| `CONTEXT.md` | Architecture, state management, conventions (AI handoff) |
| `docs/GAME_FLOW.md` | End-to-end user flow and experience mapping |
| `docs/SANKOFA_TILES_APP_CONTEXT.md` | Full app reference (screens, assets, checklist) |
| `docs/FIREBASE_TRACKING_NOTES.md` | Analytics events and Crashlytics details |
| `PRIVACY_POLICY_FINDINGS.md` | Privacy-relevant codebase audit |

## Key Dependencies

- **State:** flutter_riverpod
- **Routing:** go_router
- **Persistence:** shared_preferences
- **Audio:** audioplayers (.ogg SFX, .mp3 music)
- **Firebase:** Analytics + Crashlytics
- **Fonts:** Google Fonts (Cinzel, Nunito)
- **Animation:** flutter_animate, lottie

## Testing

```bash
flutter analyze
flutter test
```
