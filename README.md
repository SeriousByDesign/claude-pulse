# Claude Intelligence Dashboard

A live feed tracking Anthropic Claude model releases, Claude Code changelogs,
and news from 9 curated sources. Updated twice daily.

**→ [View the dashboard](https://seriousbydesign.github.io/claude-pulse/)**

---

## Sources

| Badge | Source |
|-------|--------|
| `NEWS` | [Anthropic News](https://www.anthropic.com/news) |
| `API` | [API Release Notes](https://docs.anthropic.com/en/release-notes/overview) |
| `CODE` | [Claude Code Changelog](https://docs.anthropic.com/en/release-notes/claude-code) |
| `BLOG` | [Claude Blog](https://claude.com/blog) |
| `ENG` | [Anthropic Engineering](https://www.anthropic.com/engineering) |
| `HN` | [Hacker News — anthropic claude](https://news.ycombinator.com) |
| `VERGE` | [The Verge — AI](https://www.theverge.com/ai-artificial-intelligence) |
| `SW` | [Simon Willison's Weblog](https://simonwillison.net) |
| `REDDIT` | [r/ClaudeAI](https://www.reddit.com/r/ClaudeAI/hot) |

---

## How it works

A local [Claude Code](https://docs.anthropic.com/en/docs/claude-code) agent
runs on a cron schedule. It dispatches all 9 sources simultaneously via a
`/notebooklm` skill, structures the results as JSON, and injects them directly
into `template.html` as an inline `<script>` constant — producing a fully
self-contained `index.html` with no external dependencies. A `git push`
publishes it to GitHub Pages instantly.

```
Claude Code + /notebooklm  →  data.json  →  index.html  →  git push  →  GitHub Pages
```

The dashboard itself is vanilla HTML and JS. No framework, no build step,
no runtime requests. Cards are draggable, order persists in `localStorage`,
and sources that errored on the last run are automatically sorted to the bottom.

---

## Repo layout

```
.
├── index.html      ← generated on each agent run — do not edit manually
├── template.html   ← display layer; edit this to change the UI
├── PROMPT.md       ← Claude Code agent instructions and source list
├── run.sh          ← orchestration script: timestamp injection, validation, injection, git push
└── README.md
```

---

## Fork this

**Prerequisites:**
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- A `/notebooklm` skill installed in your Claude Code environment — any skill that accepts `--urls <url>` and returns structured content will work

Each run takes roughly 3 minutes and consumes around 4% of a Claude Pro
session limit — measured with Claude Haiku and the `/notebooklm` skill
handling all fetches in a single parallel batch. Twice-daily scheduling
is well within limits.

`run.sh` has everything else you need.

To change which sources are monitored, edit the sources table in `PROMPT.md`.
To change the UI, edit `template.html`. The generated `index.html` is always
a build artifact — don't edit it directly.

**No `/notebooklm` skill?** You can adapt `PROMPT.md` to use Claude Code's
built-in web search instead — remove the notebooklm invocations and let the
agent fetch sources directly. Be aware this significantly increases token
consumption per run since each source requires multiple search and fetch
calls rather than a single skill invocation.

---

## License

MIT
