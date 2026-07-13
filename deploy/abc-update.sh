#!/usr/bin/env bash
# Dyscover ABC over-the-air updater.
#
# Pulls the latest release from GitHub, verifies its checksum, swaps it into
# place and restarts the kiosk. Runs on a schedule (abc-update.timer) and on
# demand from the app's About screen (via abc-update.service). Idempotent: it
# exits cleanly when already on the latest version.
#
# The device only ever makes outbound HTTPS requests, so this works from behind
# NAT with no inbound access. Most knobs are env-overridable so the logic can be
# exercised off-device (see deploy/README.md and the Docker test).
#
#   abc-update.sh            download + verify + swap + restart if newer
#   abc-update.sh --check    print installed/latest/update=yes|no, change nothing
set -euo pipefail

REPO="${ABC_REPO:-sunbiz/dyscover}"
APP_DIR="${ABC_APP_DIR:-/opt/abc-app}"
BASE_URL="${ABC_BASE_URL:-https://github.com/${REPO}/releases/latest/download}"
RESTART_CMD="${ABC_RESTART_CMD:-systemctl restart abc-kiosk}"
HEALTH_CMD="${ABC_HEALTH_CMD:-systemctl is-active --quiet abc-kiosk}"
ASSET_DEFAULT="dyscover-abc-pi4-64.tar.gz"

log() { echo "[abc-update] $*"; }

# Minimal JSON string-field reader (avoids a jq dependency on the Pi).
json_field() { # $1=field  $2=file
  sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" "$2" | head -n1
}

installed_version() { cat "${APP_DIR}/VERSION" 2>/dev/null || echo "none"; }

roll_back() { # $1=previous dir
  log "rolling back"
  rm -rf "$APP_DIR"
  [ -e "$1" ] && mv "$1" "$APP_DIR"
  eval "$RESTART_CMD" || true
}

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

CHECK_ONLY=0
[ "${1:-}" = "--check" ] && CHECK_ONLY=1

INSTALLED="$(installed_version)"

if ! curl -fsSL --retry 3 --retry-delay 2 "${BASE_URL}/version.json" \
      -o "${TMP}/version.json"; then
  log "could not fetch manifest (offline?)"
  [ "$CHECK_ONLY" = 1 ] && echo "installed=${INSTALLED} latest=unknown update=error"
  exit 0   # transient; the timer will try again
fi

LATEST="$(json_field version "${TMP}/version.json")"
SHA="$(json_field sha256 "${TMP}/version.json")"
ASSET="$(json_field asset "${TMP}/version.json")"
[ -n "$ASSET" ] || ASSET="$ASSET_DEFAULT"
[ -n "$LATEST" ] || { log "manifest has no version"; exit 1; }

UPDATE=no
[ "$LATEST" != "$INSTALLED" ] && UPDATE=yes

if [ "$CHECK_ONLY" = 1 ]; then
  echo "installed=${INSTALLED} latest=${LATEST} update=${UPDATE}"
  exit 0
fi

if [ "$UPDATE" = no ]; then
  log "up to date (${INSTALLED})"
  exit 0
fi

log "updating ${INSTALLED} -> ${LATEST}"
curl -fsSL --retry 3 --retry-delay 2 "${BASE_URL}/${ASSET}" -o "${TMP}/bundle.tar.gz"

if [ -n "$SHA" ]; then
  echo "${SHA}  ${TMP}/bundle.tar.gz" | sha256sum -c - >/dev/null \
    || { log "checksum FAILED, aborting"; exit 1; }
  log "checksum ok"
else
  log "WARNING: manifest has no sha256, skipping integrity check"
fi

NEW="${APP_DIR}.new"
PREV="${APP_DIR}.prev"
rm -rf "$NEW"
mkdir -p "$NEW"
tar -xzf "${TMP}/bundle.tar.gz" -C "$NEW"
echo "$LATEST" > "${NEW}/VERSION"

# Swap in the new bundle, keeping the old one as .prev for rollback.
rm -rf "$PREV"
[ -e "$APP_DIR" ] && mv "$APP_DIR" "$PREV"
mv "$NEW" "$APP_DIR"

log "restarting kiosk"
eval "$RESTART_CMD" || { roll_back "$PREV"; exit 1; }

# Give the new build a moment to come up; roll back if it will not run.
sleep 5
if ! eval "$HEALTH_CMD"; then
  log "kiosk unhealthy after update"
  roll_back "$PREV"
  exit 1
fi

log "updated to ${LATEST}"
