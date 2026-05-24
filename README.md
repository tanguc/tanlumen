# tanlumen

Personal display preset manager for macOS. Drives [BetterDisplay](https://github.com/waydabber/BetterDisplay) over DDC to switch a multi-monitor setup between curated contrast / color-temperature presets — coding day, coding night, movies, meetings, gaming, deep-night warm, etc.

Designed for a Dell U2723QE + BenQ EW3270U pair plus the MacBook built-in display. Per-display tag IDs are env-overridable.

## Install

```bash
brew install fzf betterdisplay
curl -fsSL https://raw.githubusercontent.com/tanguc/tanlumen/main/install.sh | bash
```

Pin a version:

```bash
curl -fsSL https://raw.githubusercontent.com/tanguc/tanlumen/main/install.sh | bash -s -- v0.1.4
```

Custom install location:

```bash
TANLUMEN_PREFIX=/usr/local/bin curl -fsSL \
  https://raw.githubusercontent.com/tanguc/tanlumen/main/install.sh | bash
```

## Usage

```bash
tanlumen                       # interactive picker with live preview
tanlumen <preset> [tier]       # apply directly (tier: low | med | high)
tanlumen contrast <tier>       # nudge contrast on current preset
tanlumen list                  # show all presets
tanlumen current               # show live values + last applied preset
tanlumen update [tag]          # self-update from github releases (default: latest)
tanlumen version
```

## Tiers (absolute hardware DDC contrast)

| tier | value |
|------|-------|
| low  | 0.20  |
| med  | 0.50  |
| high | 0.80  |

All presets support all three tiers.

## Behavior notes

- **Brightness is never touched.** Adjust the backlight manually via macOS / BetterDisplay. The script intentionally leaves it alone.
- **`hardwareContrast`, not `contrast`.** BetterDisplay's `contrast` feature is a combined software+hardware slider that halves the effective DDC value. The script writes the real DDC register via `hardwareContrast`, matching what the BetterDisplay "DDC Control" panel shows.
- **MacBook built-in skips contrast.** The internal display has no real DDC contrast (BetterDisplay emulates it via software gamma). The script applies only RGB color gain to the MBP tag, leaving contrast at system default.
- **Color temperature via hardware gain.** Per-channel `redHardwareGain` / `greenHardwareGain` / `blueHardwareGain` so warmth is panel-level, not a software overlay.

## Configuration

Env vars override defaults:

```bash
TANLUMEN_BD=/path/to/BetterDisplay     # binary path
TANLUMEN_DELL_TAG=4                    # BetterDisplay tagID for Dell
TANLUMEN_BENQ_TAG=3                    # BetterDisplay tagID for BenQ
TANLUMEN_MBP_TAG=1                     # BetterDisplay tagID for MacBook built-in
TANLUMEN_DEBOUNCE_MS=1000              # fzf focus-debounce window
```

Find tag IDs with:

```bash
/Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay get --identifiers \
  | grep -E '"(name|tagID)"'
```

## Release pipeline (auto)

Conventional Commits → [cocogitto](https://docs.cocogitto.io) auto-bumps semver, updates `CHANGELOG.md`, tags, and triggers `release.yml` which builds and uploads the binary.

- `feat: …` → minor bump
- `fix: …` → patch bump
- `BREAKING CHANGE:` footer → major bump
- `chore:` / `docs:` / `refactor:` / `ci:` / `test:` / `style:` → no release

Commit-check CI rejects non-conventional commit messages since the latest tag, so accidental non-bump commits can't slip into `main`.

Manual tag still works:

```bash
git tag v0.2.0 && git push origin v0.2.0
```

## License

Private use.
