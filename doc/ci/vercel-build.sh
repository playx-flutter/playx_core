#!/usr/bin/env bash
# Vercel: build a Flutter web app with playx secure env.
# Copy this file and vercel.json to the root of your app.
#
# Setup (Vercel > Project > Settings > Environment Variables):
#   PLAYX_ENV                e.g. prod (selects .env.prod and the secure env)
#   PLAYX_SECRET_<NAME>      one variable per secret, e.g. PLAYX_SECRET_MAPS_KEY
#   FLUTTER_VERSION          optional, defaults to the version below
#   SECURE_ENV_COMMAND       optional, `playx:secure_env` or
#                            `playx_core:secure_env`; detected from pubspec.yaml
#
# Note: a web app is a public bundle. Secure env keeps values out of plain
# sight, but keys that must stay secret belong in a serverless function
# (e.g. Vercel `api/`) that calls the third-party service for the app.
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.8}"
FLUTTER_DIR="${FLUTTER_DIR:-$HOME/flutter}"
FLUTTER="$FLUTTER_DIR/bin/flutter"

case "${1:-build}" in
  install)
    # Vercel doesn't ship Flutter: fetch the requested version once.
    if [ ! -x "$FLUTTER" ]; then
      git clone --depth 1 --branch "$FLUTTER_VERSION" \
        https://github.com/flutter/flutter.git "$FLUTTER_DIR"
    fi
    "$FLUTTER" config --no-analytics
    "$FLUTTER" pub get
    ;;
  build)
    export PATH="$FLUTTER_DIR/bin:$PATH"
    # Apps depending on playx use playx:secure_env, on playx_core only
    # playx_core:secure_env.
    if [ -z "${SECURE_ENV_COMMAND:-}" ]; then
      if grep -Eq '^[[:space:]]+playx:' pubspec.yaml; then
        SECURE_ENV_COMMAND="playx:secure_env"
      else
        SECURE_ENV_COMMAND="playx_core:secure_env"
      fi
    fi
    dart run "$SECURE_ENV_COMMAND" --from-env-prefix PLAYX_SECRET_
    flutter build web --release
    ;;
  *)
    echo "Usage: $0 [install|build]" >&2
    exit 64
    ;;
esac
