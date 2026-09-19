# SOOB-Template

A clone-and-rename starter for a 2D [SOOB-Core](https://github.com/goph-R/SOOB-Core)
game. Targets everything from Windows 98 (Pentium-class, SDL 1.2,
fixed-function OpenGL, optional CPU rasterizer) through modern Linux and
Windows — plus the browser and Android, via the shared player repos.

Almost nothing here is code. The C host, the four build systems and the Lua
engine modules all live in SOOB-Core; this repo is the handful of files that
say *which game this is*.

## Setup

Clone the shared engine as a sibling — the build scripts resolve `../SOOB-Core`:

```
Games/
├── SOOB-Template/       ← this repo (rename the folder)
├── SOOB-Core/           ← clone alongside
└── SOOB-Core-Android/   ← only if you ship an APK
```

```sh
git clone git@github.com:goph-R/SOOB-Core.git
git clone git@github.com:goph-R/SOOB-Core-Android.git   # optional
```

## Rename it

```sh
./tools/rename.sh "My Game" mygame com.example.mygame
rm -rf .git && git init
```

The third argument is the Android `applicationId` — leave it off if you are not
shipping an APK. That edits seven lines across six files. By hand it's:

| File | Line |
|---|---|
| `app.lua` | `name = "My Game",` |
| `app.lua` | `id = "mygame",` |
| `Makefile` | `BIN     = mygame` |
| `CMakeLists.txt` | `project(MyGame)` |
| `build.bat` | `set NAME=MyGame` |
| `build_win10.bat` | the stem argument to the shared script |
| `android/app/build.gradle` | `def appId = 'com.example.mygame'` |

Then swap `web/icon.svg` and
`android/app/src/main/res/drawable/ic_launcher_foreground.xml` for your own art,
and set `description` and `background` in `app.lua`.

## Build and run

| Target | Command | Output |
|---|---|---|
| Linux | `make` (needs `libsdl1.2-dev`, `libopenal-dev`) | `./mygame` |
| Windows 98 / Dev-C++ | `build.bat` | `MyGame.exe` |
| Windows 10 / portable MinGW | `build_win10.bat` | `MyGame_w10.exe` |
| CMake | `mkdir build && cd build && cmake .. && make` | `MyGame` |
| Android | `cd android && ./gradlew :app:assembleDebug` | `android/app/build/outputs/apk/…` |

**Run the desktop builds from the repo root** — assets load by relative path.

CLI flags: `-w <width>`, `-h <height>`, `-fullscreen`, `-windowed`,
`-opengl`, `-software`. F12 dumps the current frame to `<id>_shot_NNN.bmp`.

## The five files you edit

- **`app.lua`** — identity. Window title, save-file stem, PWA name, launcher
  label, screen orientation, clear colour. All three hosts read this one file.
- **`config.lua`** — display defaults (desktop only): size, fullscreen, vsync,
  and `render = "opengl" | "software"`.
- **`assets.lua`** — the content manifest: sounds, music, textures, regions,
  fonts. Adding an asset is a Lua-only edit; nothing is hardcoded in C.
- **`scripts/main.lua`** — your game. Starts as one scene drawing a label.
- **`main.cpp`** — 3 lines of code. Only touch it to change the virtual canvas
  height or to register native Lua bindings; both are documented in the file.

Plus two per-platform wrappers that carry no game logic: `web/icon.svg` and the
`android/` module (see below). Both are optional — delete either if you are not
shipping that target.

## What you get from the engine

`scripts/engine/` is copied from SOOB-Core at build time (and gitignored —
SOOB-Core is the source of truth):

- **`engine.scene`** — a scene stack with transitions. `installHooks` wires the
  `on*` globals into it, so scenes just define `:update(dt)`, `:render()`,
  `:mouseDown(x, y, b)` and friends.
- **`engine.widget`** — labels, images, buttons, checkboxes, sliders, line
  edits, quads, and panels that lay them out and route focus.
- **`engine.animation`** — easings plus composable actions (`moveTo`, `fadeTo`,
  `sequence`, `parallel`, `delay`, `call`).
- **`engine.transition`** — `cut`, `fade`, `fadeThroughBlack`, `slide`, `zoom`.
- **`engine.dialog`** — modal dialogs: drop-in bounce, dim backdrop, buttons,
  dialog-to-dialog hand-off. Theme it once with `dialog.setDefaults{}`.

The full Lua binding reference is
[`SOOB-Core/SOOB-Lua.md`](https://github.com/goph-R/SOOB-Core/blob/main/SOOB-Lua.md).

## Coordinates

One virtual canvas: origin at the screen centre, **Y grows down**,
`UI_VIRTUAL_H` (480) units tall, width scaling with the window's aspect ratio.
`viewSize()` reports the current extent. Drawing is 1:1 at the reference
resolution, so one source pixel is one virtual unit.

## Web and Android

Both players run your Lua scripts and `assets.lua` unchanged.

**Web** — [SOOB-Core-Web](https://github.com/goph-R/SOOB-Core-Web) builds the
page. Point its `soobGame` at this folder and run `npm run dev`; your PWA icon
is `web/icon.svg`.

**Android** — `android/` is the APK, and it is the same idea as `web/icon.svg`:
per-game identity, no engine. It holds an `applicationId`, a `versionCode`, a
launcher icon and a manifest, and pulls the whole player —
[SOOB-Core-Android](https://github.com/goph-R/SOOB-Core-Android)'s Kotlin host,
the JNI bridge and Lua — out of the sibling checkout with a composite build.
There is **no Kotlin here**: `SoobActivity` is concrete, so the manifest names
it directly.

```sh
cd android
./gradlew :app:assembleDebug     # syncGame copies the bundle in first
./gradlew :app:installDebug      # to a connected device
adb logcat -s SOOB               # print(), engine messages, load errors
```

Needs the Android SDK 36 and NDK 29, plus `SOOB-Core` and `SOOB-Core-Android`
as siblings of this repo. `android/local.properties` (`sdk.dir=…`) is yours and
untracked; Android Studio writes it when you open the `android/` folder.

Two paths are written down once, in `android/gradle.properties`: `soobPlayer`
(where the player lives) and `soobGame` (`..`, this repo). Nothing else in
`android/` knows where anything is.

`android/app/src/main/assets/` is generated and gitignored — `syncGame` copies
`scripts/`, `assets/`, `assets.lua` and `app.lua` in, plus SOOB-Core's
`scripts/engine`, so an APK builds on a machine with no desktop toolchain.
`config.lua` is deliberately left out: every field in it is desktop-only.

The game still names itself once. `app.lua`'s `name` becomes the launcher
label, `background` the window and adaptive-icon colour, `id` the save file and
`orientation` the screen orientation — so the only per-game things left in
`android/` are the `applicationId` and the icon art.

For a signed release, put an untracked `keystore.properties` next to
`android/settings.gradle`:

```properties
storeFile=C:/keys/mygame.jks
storePassword=...
keyAlias=mygame
keyPassword=...
```

```sh
./gradlew :app:bundleRelease     # AAB for Play; assembleRelease for an APK
```

Without that file the release build still assembles, unsigned.

## Licensing

Template code is MIT (see `LICENSE`). The bundled third-party libraries in
SOOB-Core keep their own licenses (SDL 1.2 and OpenAL Soft LGPL 2.1,
dynamically linked; Lua 5.1.5 MIT; stb public domain). Your art and audio are
yours — this template ships none.
