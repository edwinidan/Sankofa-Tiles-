# Sankofa Tiles

A Ghanaian Adinkra Mahjong solitaire tile-matching game built with Flutter.

Match pairs of Adinkra symbol tiles on 3D-layered boards following classic
Mahjong solitaire "free tile" rules. 50 levels spanning five difficulty tiers,
from novice to master.

**Version:** 1.0.0+3
**Platforms:** Android, iOS (portrait only)
**Tech:** Flutter + Riverpod + Firebase

## Quick Start

```bash
flutter pub get
flutter run
```

## Project Documentation

| Document | Purpose |
|---|---|
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
