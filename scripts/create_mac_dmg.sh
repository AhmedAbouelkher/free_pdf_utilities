#!/bin/sh
test -f sidekick.dmg && rm sidekick.dmg

create-dmg \
  --volname "Free PDF Utilities Installer" \
  --volicon "../assets/icons/app_icon.icns" \
  --background "../assets/dmg_background.png" \
  --window-pos 200 120 \
  --window-size 800 530 \
  --icon-size 130 \
  --text-size 14 \
  --icon "Free PDF Utilities.app" 260 250 \
  --hide-extension "Free PDF Utilities.app" \
  --app-drop-link 540 250 \
  --hdiutil-quiet \
  "../executables/Free PDF Utilities.dmg" \
  "../build/macos/Build/Products/Release/Free PDF Utilities.app"