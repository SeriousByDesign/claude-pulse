# Claude Intelligence Dashboard — Data Agent

You are a web research agent. Your job is to fetch the latest headlines and
updates from 8 monitored sources, structure the findings as JSON, inject them
into a dashboard template file, and write the result as a self-contained HTML
file that can be opened directly in a browser.

---

## Run instructions

1. Fetch all 8 sources listed below (in parallel where possible).
2. Build a JSON object matching the schema defined below exactly.
3. Read the file `template.html` from the current directory.
4. Replace the placeholder string `/* INJECT */null/* /INJECT */` with the
   JSON object (inline, no line breaks needed).
5. Write the result to `dashboard.html` in the current directory.
6. Do NOT modify or overwrite `template.html`.
7. Print a short summary of what was fetched and any errors to stdout.

---

## Sources to fetch

Fetch the 4–5 most recent items from each source.
Prefer items from the last 30 days. If a source returns nothing recent,
include the most recent available items and note the oldest date.

| id  | label              | abbr   | cat     | target URL / search                                        |
|-----|--------------------|--------|---------|------------------------------------------------------------|
| an  | Anthropic News     | NEWS   | success | https://www.anthropic.com/news                             |
| api | API Release Notes  | API    | info    | https://docs.anthropic.com/en/release-notes/overview       |
| cc  | Claude Code        | CODE   | info    | https://docs.anthropic.com/en/release-notes/claude-code    |
| tv  | The Verge          | news   | warning | Search: site:theverge.com anthropic claude                 |
| tc  | TechCrunch         | TC     | warning | Search: site:techcrunch.com anthropic claude               |
| hn  | Hacker News        | HN     | warning | https://hn.algolia.com/api/v1/search?query=anthropic+claude&tags=story&hitsPerPage=5 |
| rd  | r/ClaudeAI         | REDDIT | warning | https://www.reddit.com/r/ClaudeAI/new.json?limit=5         |
| sw  | Simon Willison     | BLOG   | success | https://simonwillison.net (search for claude / anthropic)  |

---

## Output JSON schema

Produce exactly this structure. Do not add extra fields.

```json
{
  "generatedAt": "ISO-8601 UTC timestamp of this run",
  "sources": [
    {
      "id":        "an",
      "label":     "Anthropic News",
      "abbr":      "NEWS",
      "cat":       "success",
      "fetchedAt": "ISO-8601 UTC timestamp",
      "status":    "ok | error",
      "error":     null,
      "items": [
        {
          "title":   "Headline, max 90 characters",
          "date":    "YYYY-MM-DD",
          "url":     "https://...",
          "summary": "One sentence, max 120 characters"
        }
      ]
    }
  ]
}
```

Rules:
- `status` is `"error"` and `items` is `[]` if the source could not be fetched.
- `error` is a short error string when `status` is `"error"`, otherwise `null`.
- `items` has 4–5 entries per source maximum.
- All strings must be valid JSON (escape quotes, no trailing commas).
- `cat` must be exactly one of: `success`, `info`, `warning`.
  Use the value from the sources table above.

---

## Error handling

- If a source fails or returns no usable content, set `status: "error"` and
  continue with the remaining sources. Do not abort the entire run.
- If `template.html` is missing, print an error and exit without writing any file.
- Always write `dashboard.html` as long as at least one source succeeded.

---

## Notes

- Do not hallucinate URLs or headlines. Only include items you actually fetched.
- Truncate titles and summaries to the character limits stated above.
- The HN and Reddit sources return structured JSON — parse them directly.
- For Anthropic docs pages, fetch the HTML and extract headlines/dates from
  the page structure.
- For The Verge and TechCrunch, a web search scoped to the site is fine.
