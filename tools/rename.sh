#!/bin/sh
# rename.sh — turn this template into a named game.
#
#   ./tools/rename.sh "My Game" mygame [com.example.mygame]
#
#   $1  display name  — window title, app label, PWA name
#   $2  id            — lowercase, no spaces. The Linux binary name, the
#                       save-file stem (<id>.dat) and the web storage key.
#   $3  android id    — optional, only needed if you ship the android/ module.
#
# Everything this touches is a single line in a single file; run it once, read
# the diff, then delete this script. It deliberately does NOT touch git — do
# `rm -rf .git && git init` yourself when you're ready.
set -e

if [ $# -lt 2 ]; then
    sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
    exit 1
fi

NAME="$1"
ID="$2"
APPID="${3:-}"

# Exe stem for the Windows builds: the display name with spaces removed.
STEM=$(printf '%s' "$NAME" | tr -d ' ')

cd "$(dirname "$0")/.."

# app.lua — identity, read by all three hosts.
sed -i "s/^    name        = .*/    name        = \"$NAME\",/" app.lua
sed -i "s/^    id          = .*/    id          = \"$ID\",/"   app.lua

# Linux build: the output binary.
sed -i "s/^BIN     = .*/BIN     = $ID/" Makefile

# CMake: the target name.
sed -i "s/^project(.*)/project($STEM)/" CMakeLists.txt

# Win98 build: the one per-game line (CRLF file, so match without \$).
sed -i "s/set NAME=[A-Za-z0-9_]*/set NAME=$STEM/" build.bat

# Win10 build: the exe stem argument passed to the shared script.
sed -i "s/build_win10.bat [A-Za-z0-9_]*/build_win10.bat $STEM/" build_win10.bat

# .gitignore: the binary name.
sed -i "s/^soobtemplate$/$ID/" .gitignore

# Android module, if present.
if [ -n "$APPID" ] && [ -f android/app/build.gradle ]; then
    sed -i "s/^def appId = .*/def appId = '$APPID'/" android/app/build.gradle
fi

echo "Renamed to: $NAME (id=$ID, stem=$STEM)"
[ -n "$APPID" ] && echo "Android applicationId: $APPID"
echo
echo "Still to do by hand:"
echo "  - app.lua:  description and background colour"
echo "  - web/icon.svg (and android/.../ic_launcher_foreground.xml) — your art"
echo "  - rm -rf .git && git init"
