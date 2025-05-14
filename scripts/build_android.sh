#!/usr/bin/env bash

echo "Building Android 🛠️"

cd example

fvm flutter build apk --release
echo "✓ Built example/build/app/outputs/flutter-apk/app-release.apk"