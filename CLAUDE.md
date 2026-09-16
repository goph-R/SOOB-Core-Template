# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this repo is

A starter for a 2D SOOB-Core game. The engine — the C host, the build
fragments, the Lua engine modules — lives in `../SOOB-Core`. This repo holds
only per-game files: `app.lua`, `config.lua`, `assets.lua`, `scripts/`,
`assets/`, and three-line build files.

**Read `../SOOB-Core/CLAUDE.md` first** — it owns the coding conventions, and
`../SOOB-Core/SOOB-Lua.md` is the binding reference.

## Where things live

- `main.cpp` is 3 lines of code: it calls `soobRun()` from
  `../SOOB-Core/soob_main.h`. Do not reintroduce a per-game host loop. If a
  game needs native Lua bindings, use `SoobApp.onRegister` — documented in
  `main.cpp` itself.
- `Makefile`, `CMakeLists.txt` and `build_win10.bat` delegate to
  `../SOOB-Core/build/`. Change the shared fragment, not the stub.
- `build.bat` (Win98) is deliberately a full per-game copy — COMMAND.COM
  cannot safely `call` a shared script. It is **goto-only: no `setlocal`, no
  quoted `set`, no parenthesised if-blocks**. Its one per-game line is
  `set NAME=`.
- `scripts/engine/` is **generated** — copied from SOOB-Core on every build and
  gitignored. Never edit it here; fix the source in SOOB-Core.

## Build and verify

```sh
make                                    # needs libsdl1.2-dev, libopenal-dev
env ALSOFT_DRIVERS=null timeout 1.5 ./<bin> -windowed > /tmp/out 2>&1
```

Two things matter in that incantation. `ALSOFT_DRIVERS=null` is required
because OpenAL has its own backend chain independent of SDL — without it
`sndInit` fails and the process exits before Lua ever loads. And stdout must
go to a **file**: piping to `head` loses the buffer when `timeout` sends
SIGTERM, so you see nothing even though the run was fine.

A clean boot prints `Renderer:`, `Resolution:`, `VSync:`, the font atlas line,
`opt: persistence at ...`, `script: Lua 5.1 initialised`, each asset's load
line, then the `assets: N sound(s), ...` summary. A Lua traceback after
`script:` is a real error.

This confirms syntax, `require` resolution and asset registration — which
covers most refactor regressions. It cannot check colours, layout or animation
timing; those need the dev box.

## Constraints

- **No C++11.** Dev-C++ 4.x ships GCC 3.4: no `auto`, no `nullptr`, no
  range-for. C-style `NULL`, explicit types, `malloc`/`free`.
- **No shaders.** Fixed-function GL only; minimum GPU is a GeForce 4 MX 440.
- **Assets are relative-pathed.** No `chdir`, no absolute asset lookups.
- **Header-only modules with `static` functions** — one TU per target.
