# Social Lead-Gen Agent

A [Claude Code](https://claude.com/claude-code) project that finds people publicly
asking for what your business sells, replies to them helpfully, answers your DMs and
comments, and routes everyone into WhatsApp.

It drives a **real, already-logged-in Chrome browser** — no API keys, no OAuth, no
platform app review. It acts as you, in your session, on Threads, TikTok and Instagram.

It is a **top-of-funnel router**. It creates no content and closes no sales.

```
Threads / TikTok / Instagram                     WhatsApp
   │                                                ▲
   ├─ prospect ──→ leads.jsonl                      │
   │                   │                            │
   │                   └─ engage ──→ public reply (no link — bio only)
   │                                                │
   ├─ DM inbox ────────→ triage ──→ wa.me link ─────┤
   │                        │                       │
   └─ comments on our own posts ────────────────────┘
                            │
                            └──→ escalations.md   (complaints, refunds, bookings → human)
```

## Why it's built this way

Most of this repo is guardrails, and that is deliberate. An agent replying to strangers
from a real business account can do lasting damage in three ways: it can get the account
suppressed, it can say something wrong in public, or it can quietly do nothing useful
while appearing to work. The design targets all three.

**The rules are shell scripts, not prompts.** A model can forget an instruction; it
can't forget an exit code. `bin/guard.sh` decides whether the agent may act at all, and
returns a number. Everything else follows from that.

**The agent cannot clear itself to speak.** `ramp_start` in `config.json` gates public
replies, and `.claude/settings.json` denies the agent write access to that file. A new
account starts read-only and stays read-only until a human sets a date.

**Reply templates are prose, not config.** They are shapes with worked examples, not
fields to fill. A reply assembled from JSON reads like a form letter, and a form letter
under someone's post is what gets an account reported by a person rather than flagged by
an algorithm.

## Quick start

Requirements: Claude Code, the Claude in Chrome extension, `jq`, and a Chrome profile
already logged in to the accounts you want to use.

```sh
git clone <your-fork> social-agent && cd social-agent

cp config.example.json config.json
$EDITOR config.json          # phone number, handles, Chrome profile, caps

bin/brand-init.sh my-brand   # scaffolds brands/my-brand/ from the template
$EDITOR brands/my-brand/BRAND.md    # what you sell, and your voice — write this yourself

bin/config-check.sh          # tells you what is still missing
claude                       # then: "prospect my-brand on threads"
```

Grant the Chrome extension site permissions for the platforms you'll use, and **put your
WhatsApp link in each account's bio** — public replies carry no link, so the bio is the
only path from a reply to a conversation.

Leave `ramp_start` as `null` until you have run prospecting read-only for a few days and
actually read the leads. That is the whole point of it.

## The skills

| Skill | Does | Speaks in public? |
|---|---|---|
| `social-prospect` | Finds intent, classifies it, writes `leads.jsonl` | No — read-only |
| `social-engage` | Replies to collected leads | **Yes** — capped and ramped |
| `social-dm` | Answers the inbox, hands off to WhatsApp | No — private |
| `social-comments` | Answers comments on **your own** posts | Yes — uncapped, no links |
| `social-health` | Checks whether the account is being suppressed | No |

The split matters. Prospecting runs freely because it never speaks. Engaging is capped
because it speaks to strangers. DMs and own-post comments are uncapped because answering
someone who came to you is not a spam signal — but comments carry no link and DMs do,
which is why they are separate skills rather than one.

## The guardrails

| Script | Enforces |
|---|---|
| `guard.sh` | Kill switch, per-account cooldown, enabled flag, remaining budget |
| `budget.sh` | Warm-up ramp and daily cap — returns **0** until a human sets `ramp_start` |
| `seen.sh` | No post twice, no person twice in 30 days, **across all brands** |
| `pace.sh` | Random gap between public actions (the randomness matters more than the average) |
| `cooldown.sh` | Parks an account after platform pushback |
| `log-action.sh` | Append-only audit log — the thing `budget.sh` counts |
| `config-check.sh` | Validates config and reports what's unfinished |

Stop everything at any time:

```sh
touch PAUSED     # every skill checks this before opening a tab
rm PAUSED
```

## Layout

```
config.json            your settings — GITIGNORED
config.example.json    template, documented
CLAUDE.md              operating rules, always loaded
bin/                   the guardrails
brands/_example/       brand kit template
brands/<slug>/         your real kits — GITIGNORED
data/                  leads, dedupe keys, audit log — GITIGNORED
reports/               daily reports, escalations — GITIGNORED
runbook/               SAFETY.md, PLATFORM_NOTES.md
.claude/skills/        the five skills
```

`config.json`, `brands/`, `data/` and `reports/` are all gitignored. Between them they
hold every phone number, price, customer name and competitor note. Check `git status`
before your first push.

## Honest limitations

**This is browser automation against platforms that don't want it.** Read-only
prospecting is low risk. Public replying is not: a dormant or brand-new account that
suddenly starts replying to strangers is the exact pattern platforms suppress, and a
suppressed account looks completely normal from the inside. `social-health` exists
because of this — run it, and check your replies logged-out.

**Platform UIs change without warning.** `runbook/PLATFORM_NOTES.md` records what
actually worked, with dates. Expect some of it to be wrong by the time you read it, and
update it as you go. Several entries in there are corrections of earlier entries.

**Prospecting yield is lower than you'd hope, and the inbox is richer than you'd think.**
In testing, a full day of prospecting found 7 leads; the same day's inboxes and requests
folders held 35+ real inquiries, most never answered. Clear your inboxes before you go
hunting.

**It is tuned for Indonesian-language Bali service businesses.** The mechanics generalise;
the keyword logic, seeker-vs-seller heuristics and reply voice do not. Rewrite them.

## License

MIT. No warranty — you are responsible for what this does from your accounts.
