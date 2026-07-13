#!/usr/bin/env bash
# Build, package, and publish a Dyscover ABC release to GitHub.
# The device-side updater (abc-update.sh) pulls whatever this publishes.
#
#   deploy/release.sh ["release notes"]
#
# The version is read from lib/version.dart (kAppVersion), the single source of
# truth, and must already be bumped (along with pubspec.yaml) and committed.
set -euo pipefail

cd "$(dirname "$0")/.."
NOTES="${1:-}"

VERSION="$(grep -oE "kAppVersion *= *'[^']+'" lib/version.dart \
  | grep -oE "[0-9]+\.[0-9]+\.[0-9]+")"
[ -n "$VERSION" ] || { echo "could not read kAppVersion from lib/version.dart"; exit 1; }
TAG="v${VERSION}"
ASSET="dyscover-abc-pi4-64.tar.gz"
BUNDLE_DIR="build/flutter-pi/pi4-64"

# flutter-pi needs Flutter 3.41.x; prefer that worktree if present.
if [ -d "$HOME/development/flutter-3.41.9/bin" ]; then
  export PATH="$HOME/development/flutter-3.41.9/bin:$HOME/.pub-cache/bin:$PATH"
fi

echo "== building ${TAG} =="
flutter pub get
flutterpi_tool build --arch=arm64 --cpu=pi4 --release
echo "$VERSION" > "${BUNDLE_DIR}/VERSION"

echo "== packaging =="
DIST="$(mktemp -d)"
tar -czf "${DIST}/${ASSET}" -C "${BUNDLE_DIR}" .
SHA="$(shasum -a 256 "${DIST}/${ASSET}" | awk '{print $1}')"
printf '{"version":"%s","asset":"%s","sha256":"%s","notes":"%s"}\n' \
  "$VERSION" "$ASSET" "$SHA" "$NOTES" > "${DIST}/version.json"
echo "sha256=${SHA}"

echo "== publishing GitHub release ${TAG} =="
gh release create "$TAG" "${DIST}/${ASSET}" "${DIST}/version.json" \
  --title "Dyscover ABC ${TAG}" \
  --notes "${NOTES:-Release ${TAG}}"

echo "done: ${BASE_URL:-https://github.com/${GITHUB_REPO:-sunbiz/dyscover}}/releases/tag/${TAG}"
