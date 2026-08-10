#!/bin/sh
# lead-add.sh   (JSON object on stdin)
#
# Append one lead to data/leads.jsonl. This is the deliverable of prospecting —
# a person with intent, plus the link back to what they said.
#
# Required: platform, brand, author, post_url, text, intent
#   intent: high | medium        (reject-tier posts are never written here)
#
# Recommended: post_id, author_url, posted_at, query, language, status
#   status: collected            (set by prospecting)
#         | replied              (set by engage, via lead-update)
#         | skipped              (dedupe or budget)

. "$(dirname "$0")/common.sh"

IN=$(cat)
[ -n "$IN" ] || die "lead-add.sh: nothing on stdin"

echo "$IN" | jq -e '.platform and .brand and .author and .post_url and .text and .intent' >/dev/null \
  || die "lead-add.sh: platform, brand, author, post_url, text, intent are all required"

echo "$IN" | jq -e '.intent == "high" or .intent == "medium"' >/dev/null \
  || die "lead-add.sh: intent must be high or medium — reject-tier posts are not leads"

echo "$IN" | jq -c --arg t "$(now_iso)" --argjson e "$(now_epoch)" \
  '{status:"collected"} + . + {collected_at:$t, epoch:$e}' >> "$DATA/leads.jsonl"
