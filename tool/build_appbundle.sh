#!/usr/bin/env bash
set -euo pipefail

flavor="${1:-}"
if [[ "$flavor" != "testing" && "$flavor" != "production" ]]; then
  echo "Usage: $0 testing|production" >&2
  exit 2
fi

defines=("--dart-define=CALGO_FLAVOR=$flavor")
gradle_flavor="$flavor"
if [[ "$flavor" == "testing" ]]; then
  gradle_flavor="calgoTesting"
fi
if [[ "$flavor" == "production" ]]; then
  if [[ -n "${CALGO_ADMOB_APP_ID:-}" ]]; then
    defines+=("--dart-define=ADMOB_APP_ID=${CALGO_ADMOB_APP_ID}")
  fi
  if [[ -n "${CALGO_ADMOB_BANNER_UNIT_ID:-}" ]]; then
    defines+=("--dart-define=ADMOB_BANNER_UNIT_ID=${CALGO_ADMOB_BANNER_UNIT_ID}")
  fi
fi

exec flutter build appbundle \
  --release \
  --flavor "$gradle_flavor" \
  "${defines[@]}" \
  "${@:2}"
