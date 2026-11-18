# Apple Music Styled Offline Music Player for Android 🎵

A clean, modern offline local music player for Android crafted with Flutter, Material 3, and Apple Music's signature dark aesthetic.

---

## 📱 Features

### 🎧 Audio & Playback Engine
- **Background Playback**: Powered by `just_audio` and `audio_service`, keeps playing when the app is closed or the screen is locked.
- **Lockscreen & Notification Controls**: Full media notification with track artwork, play/pause, seek bar, previous/next, and repeat/shuffle toggles.
- **Synced Lyrics (`.lrc`)**: Automatically parses and displays local synchronized lyrics with smooth real-time auto-scrolling.
- **5-Band Equalizer & Bass Boost**: Android native audio effect integration with customizable bands and presets (Bass Boost, Vocal, Electronic, Rock, Acoustic, Flat).
- **Sleep Timer**: Customizable timer (15 min to 2 hours) with smooth auto-stop.
- **Queue Management**: Dynamic queue with drag-to-reorder, swipe-to-remove, "Play Next", and "Add to Queue".

### 📚 Library & Organization
- **Tabs**: Songs, Albums, Artists, Genres, and Folders.
- **Fast Sorting**: Sort by Title, Artist, Date Added, and Duration.
- **Smart Filter**: Option to automatically exclude short audio clips (< 30 seconds) like ringtones and voice notes.
- **Fast Rescan**: Pull-to-refresh to detect newly downloaded or transferred audio files.

### 💖 Personal & Collections
- **Favorites**: One-tap heart button on full player, mini player, and song sheets.
- **Playlists**: Create, rename, delete, reorder, and add songs to custom playlists backed by local SQLite database.
- **Listening History & Stats**: Recently played tracks and play counts.
- **Live Search**: Instant real-time multi-category search across Songs, Albums, and Artists.

### 🎨 Apple Music Clean Dark UI/UX
- **Pure Black Palette**: `#000000` deep background with `#1C1C1E` elevated cards and `#FA2D48` Apple Music red-pink accent.
- **Frosted Glass Blur**: Backdrop-filtered bottom navigation bar and floating mini player pill.
- **Dynamic Blurred Artwork**: Full player background dynamically blurs and tints to match the current track's album art.
- **Smooth Animations**: Seamless expand/collapse transition between the floating mini player and the immersive full player.
- **Marquee Text**: Smooth marquee scrolling for long titles and artist names.
- **100% Offline**: Zero internet permission (`android.permission.INTERNET` removed) for complete user privacy.

---

## 🛠️ Architecture

Feature-first structure with clean separation of concerns:

```
lib/
├── core/
│   ├── constants/        # AppColors, AppTypography
│   ├── services/         # MusicAudioHandler, PermissionService
│   ├── theme/            # Apple Music dark theme data
│   ├── utils/            # Formatters, LrcParser
│   └── widgets/          # GlassContainer, AppleMusicSliverAppBar, SongArtworkWidget
├── features/
│   ├── home/             # Listen Now, Quick Picks, Recently Played
│   ├── library/          # Songs, Albums, Artists, Folders tabs & repositories
│   ├── navigation/       # MainNavigationShell (Frosted bar + Mini player)
│   ├── player/           # FullPlayer, MiniPlayer, Queue, Equalizer, SleepTimer, Lyrics
│   ├── playlists/        # SQLite Database, Playlists & Detail screens
│   ├── search/           # Live search screen
│   └── settings/         # App settings & audio preferences
└── main.dart             # App entrypoint & audio service initialization
```

---

## 🚀 Building & Running

This project is configured with automated GitHub Actions CI/CD. Builds are executed via GitHub Actions to ensure consistent, clean, and reproducible release artifacts.

### GitHub Actions Workflow
The workflow (`.github/workflows/build_and_test.yml`) automatically performs:
1. Lint and Static Analysis (`flutter analyze` - 0 warnings)
2. Automated Unit & Widget Tests (`flutter test`)
3. Android Scaffolding & Release APK Build (`flutter build apk --release`)
4. Artifact Upload (`music-player-release-apk`)
