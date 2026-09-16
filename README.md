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
├── SOOB-Template/   ← this repo (rename the folder)
└── SOOB-Core/       ← clone alongside
```

```sh
git clone git@github.com:goph-R/SOOB-Core.git
```

## Rename it

```sh
./tools/rename.sh "My Game" mygame
rm -rf .git && git init
```

That edits six lines across five files. By hand it's:

| File | Line |
|---|---|
| `app.lua` | `name = "My Game",` |
| `app.lua` | `id = "mygame",` |
| `Makefile` | `BIN     = mygame` |
| `CMakeLists.txt` | `project(MyGame)` |
| `build.bat` | `set NAME=MyGame` |
| `build_win10.bat` | the stem argument to the shared script |

Then swap `web/icon.svg` for your own art, and set `description` and
`background` in `app.lua`.

## Build and run

| Target | Command | Output |
|---|---|---|
| Linux | `make` (needs `libsdl1.2-dev`, `libopenal-dev`) | `./mygame` |
| Windows 98 / Dev-C++ | `build.bat` | `MyGame.exe` |
| Windows 10 / portable MinGW | `build_win10.bat` | `MyGame_w10.exe` |
| CMake | `mkdir build && cd build && cmake .. && make` | `MyGame` |

**Run from the repo root** — assets load by relative path.

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

Both players run your Lua scripts and `assets.lua` unchanged:

- [SOOB-Core-Web](https://github.com/goph-R/SOOB-Core-Web) — point it at this
  folder and run `npm run dev`.
- [SOOB-Core-Android](https://github.com/goph-R/SOOB-Core-Android) — set
  `soobGame` to this folder and `./gradlew :app:assembleDebug`.

## Licensing

Template code is MIT (see `LICENSE`). The bundled third-party libraries in
SOOB-Core keep their own licenses (SDL 1.2 and OpenAL Soft LGPL 2.1,
dynamically linked; Lua 5.1.5 MIT; stb public domain). Your art and audio are
yours — this template ships none.
