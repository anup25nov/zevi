#!/bin/bash
set -e
/Users/anupmishra/fvm/versions/stable/bin/flutter clean
/Users/anupmishra/fvm/versions/stable/bin/flutter pub get
/Users/anupmishra/fvm/versions/stable/bin/flutter build appbundle --release \
  --dart-define-from-file=.env.prod \
  --build-name=1.0.0 \
  --build-number=1
echo "✅ AAB built: build/app/outputs/bundle/release/app-release.aab"
ls -lh build/app/outputs/bundle/release/app-release.aab
