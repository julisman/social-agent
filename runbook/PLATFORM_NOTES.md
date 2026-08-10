# Platform notes

Per-platform UI behavior. **Keep this file updated as you learn** — every session that
hits a surprise should leave a note here. These UIs change without warning, and this
file is the difference between a smooth run and rediscovering the same quirk monthly.

## Threads — the primary channel

**Why it's first:** genuine keyword search with a **Recent** sort. Text-first, so intent
is in the post itself rather than buried in a video. Highest leads-per-minute of the
three by a wide margin.

Verified working 2026-08-09. The site is `threads.com` (`threads.net` redirects). UI
language is Indonesian on these accounts.

### Search by URL — don't click the tabs

Navigate straight to the sorted results; it saves a click and a page settle each time.

```
Recent:  https://www.threads.com/search?q=<url-encoded>&serp_type=default&filter=recent
Top:     https://www.threads.com/search?q=<url-encoded>&serp_type=default
```

Both tabs are worth a pass, and they behave differently:

- **Recent** (`Terbaru`) — mostly sellers. The same rental accounts repost ads several
  times a day, so expect ~60% competitor noise and a handful of real buyers.
- **Top** (`Terpopuler`) — far better *buyer* posts, but most are 8-23 days old and die
  on the 7-day rule. Budget one usable lead per pass.

### Extraction recipe — two calls per query

1. `get_page_text` → author, relative age, and full post text for every result
2. `find` with the query **"post permalink timestamp links"** → returns author, exact
   timestamp, and `href` (`/@handle/post/<POST_ID>`) for each

`get_page_text` alone gives no URLs, and `find` alone gives no post text — you need
both. Scroll 2-3 times with a wait between before capturing to load more than the first
~8 results.

If `find` returns links without `href`, re-run it with a narrower query naming the
author ("timestamp permalink link inside <handle>'s post").

### Replying — the composer trap

**Clicking the inline reply box sometimes opens a "Utas baru" (new thread) composer on
top of the reply composer instead of focusing it.** Typing then goes nowhere visible and
submitting would publish a brand-new public thread from the account — content creation,
which this project must never do.

So, every time:

1. Click the `Balas ke <handle>...` box
2. Type
3. **Screenshot and read it before submitting** — non-negotiable
4. If a modal titled **"Utas baru"** is showing, click **"Batal"** (top-left). The
   composer underneath is the correct one — it quotes the target post and is headed
   **"Balas"**. Click into its input, retype, screenshot again, then send.

Submit is the **↑ arrow** on the inline box, or **"Kirim"** in the modal composer.

### Confirming a reply landed

A toast reads **"Diposting"**, and the post's comment count increments (15 → 16). Check
the count — the toast alone can appear while the reply is filtered. If the count doesn't
move, treat it as a suppression signal, don't retry, and run `social-health`.

### Direct messages — this is the real inbox

**Threads DMs matter far more than Instagram DMs for this business.** Measured
2026-08-09: Instagram had 6 threads, none of them live inquiries. Threads had 20+
threads and **four active rental inquiries that same morning**. Check Threads first,
not Instagram, regardless of what the general platform table says.

```
Inbox:   https://www.threads.com/messages/       ← /inbox 404s, don't guess it
Thread:  https://www.threads.com/messages/t/<thread_id>
```

Two tabs: **`Kotak Masuk`** (inbox) and **`Permintaan`** (requests).

**Inbound inquiries from strangers land in Permintaan and must be accepted before you
can reply.** Accepted threads show a system line: *"Anda menerima permintaan pesan
dari X"*. Accepting is the account owner's call, not the agent's — it also lets the
sender call the account and see activity status. Surface it, don't click it.

Composer is `Pesan...` at the bottom; send is the **paper-plane button** to its right.
Sent messages appear right-aligned with a timestamp; `Dilihat` under one means seen.

Timestamps in the thread list are relative (`14 menit`, `2 jam`, `1minggu`) and refer to
the **last message in the thread**, which may be outbound — don't read "2 jam" as "they
messaged 2 hours ago" without opening it.

### Gotchas

- **A click on the reply box can navigate away instead of focusing it.** Seen
  2026-08-10: clicking `Balas ke <handle>...` loaded a *different* post entirely. The
  tab title and URL change, so check them — if you type after that, you reply to the
  wrong person. Re-navigate to the intended post and click again, further from any
  link.
- **The viewport resizes between screenshots** (1200x656 / 1416x840 / 1486x812 all seen
  in one session). Coordinates from an earlier screenshot go stale. Re-screenshot
  immediately before any click that matters.
- **Don't batch click → type → submit.** The permission layer intermittently denies
  `type` inside a `browser_batch` while allowing it as a single call. Batching is fine
  for navigate/wait/read; step through anything that writes.
- No DM API exists, which is why Threads DMs must be browser-driven. Threads DMs route
  through Instagram's inbox for linked accounts; check both.
- Rate limits are less aggressive than Instagram's, but suppression is quiet. Logged-out
  visibility checks matter most here.

### UI labels (Indonesian)

`Terpopuler` Top · `Terbaru` Recent · `Balas` Reply · `Batal` Cancel · `Kirim` Send ·
`Utas baru` New thread · `Diposting` Posted · `Pesan` Messages · `Aktivitas` Activity

## TikTok

Verified working 2026-08-09. The test account had ~2.8k followers here versus a few dozen on Threads —
audience size does not track with which inbox is busiest.

### Loading — do not navigate straight to a search URL

Going directly to `tiktok.com/search?q=...` reliably fails: `screenshot`,
`get_page_text` and `read_page` all time out waiting for `document_idle` (45s). The tab
loads but no script can be injected.

**Drive the UI instead**, and give it time:

1. Navigate to `https://www.tiktok.com/foryou`
2. Wait ~10s. The first screenshot shows grey skeleton placeholders — that is normal,
   wait and shoot again rather than concluding it's broken.
3. Click the **`Cari`** box (top-left sidebar), type the query, press Return.

That works consistently. An early session mistook the direct-URL timeout for a hard
block — it isn't one, and no `cooldown.sh` should ever be set for it.

**Exception: `business-suite/*` URLs navigate directly and reliably.** It is the main
app (`/foryou`, `/search`, `/@handle`, `/@handle/video/...`) that needs the UI path and
patience. Those *do* eventually load — give them 15-20s and screenshot twice; the first
screenshot showing grey skeletons is normal, not a failure.

### Prospecting — poor, for two structural reasons

**1. Caption search returns sellers only.** `sewa motor bali` produced 14 results on
2026-08-09: every single one a rental business or a paid partnership. Zero buyers. Same pattern as Threads Recent, but total rather than partial.

**2. The comment intent is real but always stale.** Comments are where buyers actually
are — a single video yielded *"Syarat rental motor ap aj kak"*, *"rental dmn kak
motor"*, *"Kaka perhari brp sewa mtornya"*. But that video was posted **2025-07-24** and
those comments are from 2025-08 and 2025-09 — roughly a year old. Every result on page
one dated months back.

**There is no upload-date filter in TikTok web search** — only category tabs
(`Teratas` / `Pengguna` / `Video` / `LIVE` / `Foto`). The mobile app has one; the web UI
does not. So there is no way to reach fresh comment intent through search, and anything
found will fail the 7-day freshness rule.

**Conclusion: do not spend prospecting time here.** TikTok's value on this account is
the inbox, not search — same lesson as Instagram. Revisit only if a date filter appears
or if the account starts posting and drawing comments on its own videos.

### Comments on our own videos — verified 2026-08-09

**Do not use Business Suite for comments.** `/business-suite/comments` lists videos with
a `N komentar baru` badge, but it **never renders the comment text** — the accessibility
tree confirms it isn't in the DOM. Worse, **clicking a video clears its unread badge
immediately**, so you lose the signal without ever seeing what was asked. Clicking a
comment notification lands there too, with `video_id` and `comment_id` in the URL, and
still shows only the video plus a `Tambah komentar` box — which posts a **new top-level
comment**, not a threaded reply.

**Use this instead:**

1. **Find them:** profile → **`Aktivitas`** → filter **`Komentar`**. This lists every
   comment with its author, full text and date. `get_page_text` reads it cleanly.

   **It lists answered and unanswered comments alike** — there is no "needs reply"
   marker. Treating the list as a backlog overstates the work badly: on 2026-08-09 it
   showed ~15 items of which most already had replies. Verify on the video (step 3)
   before assuming anything is outstanding.
2. **Open the video:** `https://www.tiktok.com/@<handle>/video/<video_id>` — the
   `video_id` is in the Business Suite URL if you came from a notification. Wait ~15s.
3. **Read:** right panel → **`Komentar`** tab. Existing replies hide behind
   **`Lihat N balasan`** — always expand before replying, or you will answer twice.
4. **Reply:** click **`Jawab`** under the comment. That spawns a separate inline
   **`Tambah balasan...`** input with its own send arrow. **Click into that new input
   before typing** — typing straight after `Jawab` goes nowhere, silently.
5. **Confirm:** the comment count increments and the reply appears nested.

### Direct messages — this is what TikTok is for

DMs live in **Business Suite**, not the main app UI:

```
Messages:  https://www.tiktok.com/business-suite/messages
Comments:  https://www.tiktok.com/business-suite/comments
```

Reach it by clicking **`Pesan`** in the left sidebar. Composer is `Kirim pesan...`;
send is the **red paper-plane** at bottom-right. There's a `Hanya belum dibaca`
(unread-only) checkbox and a `Filter` dropdown.

**The unread badge lies.** "Pesan 62" sounds like 62 waiting customers. Filtering to
unread on 2026-08-09 showed almost all of them were **`Membagikan video`** — people
using TikTok's share-to-DM feature — and weeks to months old. The two genuine rental
inquiries were sitting in the **read** list, because someone had opened them, replied
once, and abandoned them.

**So do not triage by unread on TikTok.** Sort by recency and read the actual last
message. An inquiry that got one reply and then stalled is marked read and will never
resurface in an unread filter.

The `Komentar` badge behaves the same way — it counted comments on videos from January
and February, long past any useful window.

- Caption search works; filter to recent uploads.
- **The comments are where the intent is.** Open 2-3 recent popular Bali videos on the
  topic and read the comment threads. "ada yang tau sewa motor murah di canggu?" gets
  posted under someone else's video far more often than as an original post.
- Comment replies are nested — make sure you're replying to the person, not the video.
- TikTok suppresses comments containing anything link-shaped, including bare domains and
  spaced-out numbers. Plain text only.
- Loading is heavy; give pages time before deciding an element is missing.

## Instagram

- **Keyword search does not work** — it returns accounts and hashtags, not post text.
  Do not build a prospecting session around it.
- Prospecting, such as it is: hashtag pages and comments on recent Reels from Bali
  travel accounts. Low yield. Last priority.
- The most aggressive of the three about automation. Keep IG `daily_cap` lower than the
  others (default 10).

### Direct messages

Lower volume than Threads for this business (verified 2026-08-09), but the requests
folder is where leads go to die, so it still gets checked every run.

```
Inbox:            https://www.instagram.com/direct/inbox/
Requests:         https://www.instagram.com/direct/requests/
Hidden requests:  https://www.instagram.com/direct/requests/hidden/
```

Tabs: `Primary` · `General` · `From ads` · `Permintaan` (requests).

**Always open Permintaan and Permintaan Disembunyikan.** Cold inbound from non-followers
lands there silently and is missed for weeks — the one real IG lead found on 2026-08-09
had been sitting there 9 days after handing over a phone number. Instagram even
auto-labels these: *"Kami telah mengidentifikasi prospek"*.

**Danger controls — never click:**
- **`Hapus`** / **`Delete 1`** / **`Hapus semua`** — delete, at the bottom of request lists
- **`Blokir`** — block, next to Terima on an open request
- **`Terima`** (accept) is not destructive, but it lets the sender call the account and
  see activity status. That's an account-reachability change: propose it, let the owner
  decide.

Reading a request does **not** notify the sender, so triage is safe. Replying requires
accepting first.

## All platforms

**Never click** delete, block, report, "discard draft?", or any control that opens a
native browser dialog. A modal freezes browser automation entirely and the session
cannot dismiss it — it needs a human at the keyboard.

**Session hygiene:** call `tabs_context_mcp` first; never reuse a tab ID from a previous
session. If a tool errors saying a tab is invalid, get fresh context rather than
guessing.

**Screenshot before submitting** any reply. The check that matters: is this the right
post, and am I logged in as the right account? Cross-brand replies are the most visible
possible failure.

**Stop after 2-3 failed attempts** on the same element. Report it and move on. Repeatedly
hammering a stuck UI is how sessions burn an hour achieving nothing.

## Chrome profiles

One profile per brand, named after the brand. This is what prevents the travel account
replying as the jastip one. `list_connected_browsers` and `select_browser` address them.

Confirm the active account in the UI at the start of every session — profile isolation
helps, but multi-account switchers inside the apps can still leave you as the wrong one.

## Surprises log

Add dated notes here as things change.

- TODO
