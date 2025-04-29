#!/usr/bin/env bash

echo "Building Android 🛠️"

make pre_build

cd example


fvm flutter build apk --release