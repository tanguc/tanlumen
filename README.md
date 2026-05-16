# tanlumen

Personal display preset manager for macOS. Drives [BetterDisplay](https://github.com/waydabber/BetterDisplay) over DDC to switch a multi-monitor setup between curated brightness / contrast / color-temperature presets — coding day, coding night, movies, meetings, gaming, deep-night warm, etc.

Designed for a Dell U2723QE + BenQ EW3270U pair, but the per-display tag IDs are env-overridable.

## Install

Requires `gh` CLI (private repo, no anonymous downloads):

```bash
brew install gh fzf betterdisplay
gh auth login
curl -fsSL https://raw.githubusercontent.com/tanguc/tanlumen/main/install.sh | bash
```

Pin a version:

```bash
curl -fsSL https://raw.githubusercontent.com/tanguc/tanlumen/main/install.sh | bash -s -- v0.1.0
```

Custom install location:

```bash
TANLUMEN_PREFIX=/usr/local/bin curl -fsSL .../install.sh | bash
```

## Usage

```bash
tanlumen                       # interactive picker with live preview
tanlumen <preset> [tier]       # apply directly (tier: low | med | high)
tanlumen contrast <tier>       # nudge contrast on current preset
tanlumen list                  # show all presets
tanlumen current               # show live values + last applied preset
tanlumen version
```

## Presets

11 presets × 3 contrast tiers (low / med / high). See `tanlumen list` for the full table.

Color temperature shifts are done via per-channel hardware gain (`redHardwareGain`, `greenHardwareGain`, `blueHardwareGain`) so warmth is panel-level, not a software overlay.

## Configuration

Env vars override defaults:

```bash
TANLUMEN_BD=/path/to/BetterDisplay     # binary path
TANLUMEN_DELL_TAG=4                    # BetterDisplay tagID for Dell
TANLUMEN_BENQ_TAG=3                    # BetterDisplay tagID for BenQ
```

Find tag IDs with:

```bash
/Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay get --identifiers | grep -E '"(name|tagID)"'
```

## Release

Tag and push — the `release.yml` workflow stamps the version, smoke-tests, and publishes a GitHub release with the binary, installer, and SHA256SUMS:

```bash
git tag v0.1.0
git push origin v0.1.0
```

## License

Private use.
