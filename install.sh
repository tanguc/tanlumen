#!/usr/bin/env bash
# tanlumen installer — downloads latest (or pinned) release from GitHub and installs to ~/.local/bin
#
# usage (private repo — must go through gh CLI, raw.githubusercontent.com returns 404):
#   gh api repos/tanguc/tanlumen/contents/install.sh -H "Accept: application/vnd.github.raw" | bash
#   gh api repos/tanguc/tanlumen/contents/install.sh -H "Accept: application/vnd.github.raw" | bash -s -- v0.2.0
#   TANLUMEN_PREFIX=/usr/local/bin <same> | bash

set -euo pipefail

REPO="tanguc/tanlumen"
BIN="tanlumen"
VERSION="${1:-latest}"
PREFIX="${TANLUMEN_PREFIX:-$HOME/.local/bin}"

color() { printf "\033[%sm%s\033[0m" "$1" "$2"; }
info()  { echo "$(color "1;34" "==>") $*"; }
ok()    { echo "$(color "1;32" "✓") $*"; }
warn()  { echo "$(color "1;33" "!") $*" >&2; }
die()   { echo "$(color "1;31" "✗") $*" >&2; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || die "tanlumen is macOS-only"

command -v curl >/dev/null || die "curl is required"

# this is a private repo — gh CLI is the only auth path that works without exposing tokens
if ! command -v gh >/dev/null; then
  die "gh CLI required for private repo download — install with: brew install gh && gh auth login"
fi
gh auth status >/dev/null 2>&1 || die "not authenticated — run: gh auth login"

info "resolving release ($VERSION) of $REPO"
if [[ "$VERSION" == "latest" ]]; then
  TAG=$(gh release view --repo "$REPO" --json tagName --jq .tagName 2>/dev/null) \
    || die "no releases found for $REPO"
else
  TAG="$VERSION"
fi
ok "tag: $TAG"

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

info "downloading $BIN and checksums"
gh release download "$TAG" --repo "$REPO" --pattern "$BIN" --pattern "SHA256SUMS" --dir "$TMP" --clobber \
  || die "download failed"

if [[ -f "$TMP/SHA256SUMS" ]]; then
  info "verifying checksum"
  ( cd "$TMP" && grep " $BIN\$" SHA256SUMS | shasum -a 256 -c - >/dev/null ) \
    && ok "checksum ok" \
    || die "checksum mismatch"
else
  warn "no SHA256SUMS in release — skipping verification"
fi

mkdir -p "$PREFIX"
install -m 0755 "$TMP/$BIN" "$PREFIX/$BIN"
ok "installed: $PREFIX/$BIN"

if ! echo ":$PATH:" | grep -q ":$PREFIX:"; then
  warn "$PREFIX is not in your PATH — add this to your shell rc:"
  echo "    export PATH=\"$PREFIX:\$PATH\""
fi

echo
"$PREFIX/$BIN" version || true
echo
info "try it: $BIN          (interactive picker)"
info "or:    $BIN list      (see all presets)"
