#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "→ Generating Xcode project"
xcodegen generate

echo "→ Running package unit tests (macOS host)"
for pkg in VeiraCore VeiraDomain VeiraNetworking VeiraData VeiraStoreKit; do
  echo "  • $pkg"
  swift test --package-path "Packages/$pkg"
done

DESTINATION="${VEIRA_DESTINATION:-platform=iOS Simulator,name=iPhone 17,OS=26.5}"
echo "→ Building Veira ($DESTINATION)"
xcodebuild \
  -project Veira.xcodeproj \
  -scheme Veira \
  -destination "$DESTINATION" \
  -quiet \
  build

echo "→ Running Veira unit tests"
xcodebuild \
  -project Veira.xcodeproj \
  -scheme Veira \
  -destination "$DESTINATION" \
  -only-testing:VeiraTests \
  -quiet \
  test

echo "✓ Foundation verification complete"
