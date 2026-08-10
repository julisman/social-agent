#!/bin/sh
# Shared helpers for every bin/ script.
#
# All machine-read settings live in config.json at the project root. Copy
# config.example.json to config.json and fill it in — see README.md.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

DATA="$ROOT/data"
BRANDS="$ROOT/brands"
CONFIG="$ROOT/config.json"

die() { echo "$*" >&2; exit 2; }

if [ ! -f "$CONFIG" ]; then
  echo "No config.json found at $CONFIG" >&2
  echo "" >&2
  echo "  cp config.example.json config.json" >&2
  echo "  \$EDITOR config.json" >&2
  echo "" >&2
  echo "config.json is gitignored — it holds your phone numbers, handles and caps." >&2
  exit 2
fi

command -v jq >/dev/null 2>&1 || die "jq is required but not installed (brew install jq)"

# cfg <jq-path> [default] — read a value out of config.json
cfg() {
  _v=$(jq -r "$1 // empty" "$CONFIG" 2>/dev/null)
  [ -n "$_v" ] && echo "$_v" || echo "$2"
}

# Timezone drives what "today" means for the daily cap, so it must be set before
# any date call. Bali is WITA (Asia/Makassar), not Asia/Jakarta — an hour's
# difference silently shifts the daily budget window.
TZ="$(cfg '.timezone' 'UTC')"
export TZ

now_iso()   { date +%Y-%m-%dT%H:%M:%S%z; }
now_epoch() { date +%s; }
today()     { date +%Y-%m-%d; }

# One person must not hear from us twice inside this window, across ALL brands.
# The single most important anti-spam rule in the project.
AUTHOR_TTL_DAYS="$(cfg '.defaults.author_dedupe_days' 30)"

# acct <brand> <platform> <field> — read one account field, empty if unset/null.
#
# Deliberately NOT `// empty`: jq's // treats `false` as absent, so `enabled: false`
# would come back indistinguishable from "not configured". That matters here — a
# disabled account and a missing account need different messages.
acct() {
  jq -r --arg b "$1" --arg p "$2" --arg f "$3" \
    '.brands[$b].accounts[$p][$f] as $v
     | if $v == null then "" else ($v|tostring) end' "$CONFIG" 2>/dev/null
}

# brand_exists <brand> — exit 0 if the brand is defined in config.json
brand_exists() {
  jq -e --arg b "$1" '.brands | has($b)' "$CONFIG" >/dev/null 2>&1
}

# chrome_profile <brand> [platform] — which Chrome profile this brand lives in.
#
# Prefers the brand-level chrome_profile; falls back to a per-platform override,
# then to the legacy per-account profile field.
#
# NOTE: nothing enforces this. The Chrome extension attaches to whichever browser
# is connected, so this is a label for the human running the session, not a
# control. Confirm the logged-in account on screen at the start of every run —
# that check is what actually prevents one brand replying as another.
chrome_profile() {
  jq -r --arg b "$1" --arg p "$2" \
    '.brands[$b] as $br
     | ($br.accounts[$p].profile // $br.chrome_profile // empty)' "$CONFIG" 2>/dev/null
}
