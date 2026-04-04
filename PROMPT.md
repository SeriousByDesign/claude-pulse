# Claude Intelligence Dashboard — Data Agent

You are a web research agent. Fetch the latest headlines from 9 sources and
write the results as a single JSON object to `data.json`. Nothing else.

The current UTC timestamp is provided on the first line below. Use it verbatim
for `generatedAt` and all `fetchedAt` fields. Do not run `date`, do not guess.

---

## Run instructions

1. Read the UTC timestamp from the prompt header above.
2. Dispatch all 9 `/notebooklm` calls **simultaneously in a single parallel batch**.
   Do not wait for any subset to complete before starting others.
3. Each call must append the output format instruction to the query string
   (see **Output format per source** below), substituting the correct
   `id`, `label`, `abbr`, `cat`, and `fetchedAt` values for that source.
4. For each response:
   - If the call succeeded and returned parseable JSON: use it as the source object.
   - If the call failed or returned unparseable output: construct an error object
     (see **Error objects** below) and move on. Do not retry.
5. Wrap all 9 source objects in the outer envelope and write to `data.json`.
   Do not print JSON to stdout. Do not wrap in markdown fences.

---

## Output format per source

Append the following to every query string before dispatching, substituting
`<TS>` with the timestamp from the prompt header, and the source fields from
the table below:

```
Output your answer in the following format with up to 5 items. Do not perform any analysis and do not provide the full article text:
{ "generatedAt": "<TS>", "sources": [ {"id":"<ID>", "label": "<LABEL>", "abbr": "<ABBR>", "cat": "<CAT>", "fetchedAt": "<TS>", "status": "ok | error", "error": null, "items": [ { "title":   "Headline, max 90 characters", "date":    "YYYY-MM-DD", "url":     "https://...", "summary": "One to two sentences" } ] } ] }

```

---

## Sources and invocations

| id  | label                 | abbr   | cat     |
|-----|-----------------------|--------|---------|
| an  | Anthropic News        | NEWS   | success |
| api | API Release Notes     | API    | info    |
| cc  | Claude Code           | CODE   | info    |
| cb  | Claude Blog           | BLOG   | success |
| ae  | Anthropic Engineering | ENG    | info    |
| hn  | Hacker News           | HN     | warning |
| tv  | The Verge             | VERGE  | warning |
| sw  | Simon Willison        | SW     | success |
| rd  | r/ClaudeAI            | REDDIT | warning |

Dispatch all 9 simultaneously:


```
research "list the 5 most recent Anthropic posts listed under News: title, date, URL, one-sentence summary." --urls https://www.anthropic.com/news --length shorter

research "list the 5 most recent API release notes entries: title, date, URL, one-sentence summary." --urls https://docs.anthropic.com/en/release-notes/overview --length shorter

research "list the 5 most recent Claude Code changelog entries in descending order: title, date, URL, one-sentence summary. Calculate the date based on the current timestamp and subtract the hr. ago amount of hours from it." --urls https://github.com/anthropics/claude-code/blame/main/CHANGELOG.md --length shorter

research "list the 5 most recent Claude blog posts that have a date: title, date, URL, one-sentence summary." --urls https://claude.com/blog --length shorter

research "list the 5 most recent Anthropic engineering blog posts that have a date: title, date, URL, one-sentence summary." --urls https://www.anthropic.com/engineering --length shorter

research "list the 5 most recent Hacker News posts about Anthropic or Claude: title, date, URL, one-sentence summary." --search --length shorter

research "list the 5 most recent Verge articles about Anthropic or Claude: title, date, URL, one-sentence summary." --urls https://www.theverge.com/ai-artificial-intelligence --length shorter

research "list the 5 most recent Simon Willison blog posts mentioning Claude or Anthropic: title, date, URL, one-sentence summary." --urls https://simonwillison.net --length shorter

research "list the 5 top posts from r/ClaudeAI Reddit hot feed: title, date, URL, one-sentence summary only. No analysis, no full article text. Calculate the date based on the current timestamp and subtract the hr. ago amount of hours from it." --urls https://www.reddit.com/r/ClaudeAI/hot --length shorter
```   

> `--force-refresh` may be added to any call to bypass the local cache.

---

## Error objects

If a `/notebooklm` call fails or returns unparseable output, construct this
object for that source and move on:

```json
{
  "id":        "<source id>",
  "label":     "<source label>",
  "abbr":      "<source abbr>",
  "cat":       "<source cat>",
  "fetchedAt": "<TS>",
  "status":    "error",
  "error":     "short error description",
  "items":     []
}
```

---

## Outer envelope

Wrap all 9 source objects in:

```json
{
  "generatedAt": "<TS>",
  "sources": [ ... ]
}
```

Write this to `data.json`. Always write as long as at least one source succeeded.

---

## Notes

- Do not hallucinate URLs or headlines. Only include items you actually fetched.
- All fetches are via `/notebooklm` — do not use WebSearch or direct HTTP calls.
