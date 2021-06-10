#!/bin/sh
test -f sidekick.dmg && rm sidekick.dmg

echo "Cleaing old executables..."
rm "../executables/Free PDF Utilities.dmg"

echo "building macos..."
flutter clean
flutter pub get
flutter build macos

echo "Creating DMG..."
./create_mac_dmg.sh