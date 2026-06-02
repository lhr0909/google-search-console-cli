# google-search-console

Self-contained agent skill and `uv`-run CLI for Google Search Console.

This folder is designed to be copied into an agent skills directory and recognized automatically via the root `SKILL.md`. You can rename the folder to `google-search-console`; no PyPI or global CLI installation is required.

## Highlights

- Self-contained skill folder with root `SKILL.md`
- Commands run through `uv` from the bundled source code
- Native OAuth login: no mandatory `gcloud` setup
- Site operations: list/get/add
- Sitemap operations: list/get/submit/delete
- URL inspection: manual index-status checks for specific pages
- Analytics queries by date/query/page with Search Console filters
- Output formats: table, json, csv
- Diagnostics: `gsc doctor`

## Prerequisite

Install `uv` if it is not already available:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Restart your shell after installing `uv`.

## Run Without Installing

From this folder:

```bash
uv run gsc --help
uv run gsc --version
```

From another working directory, point `uv` at the skill folder:

```bash
uv run --project /absolute/path/to/google-search-console gsc --help
```

Use that same `uv run --project ... gsc` prefix for all commands when you are not already inside the skill folder.

## OAuth Setup

Create a Google OAuth client of type **Desktop app**, then run:

```bash
uv run gsc auth login --client-secret /absolute/path/to/client_secret.json
```

Verify:

```bash
uv run gsc auth whoami
uv run gsc doctor
```

## Optional: Set Default Site

```bash
uv run gsc config set default-site sc-domain:example.com
uv run gsc config get default-site
```

After this, you can omit `--site` in commands that need a property.

## Usage

### Sites

```bash
uv run gsc site list
uv run gsc site get --site sc-domain:example.com
uv run gsc site add --site sc-domain:example.com
```

### Sitemaps

```bash
uv run gsc sitemap list --site sc-domain:example.com
uv run gsc sitemap get --site sc-domain:example.com --feedpath https://example.com/sitemap.xml
uv run gsc sitemap submit --site sc-domain:example.com --feedpath https://example.com/sitemap.xml
uv run gsc sitemap delete --site sc-domain:example.com --feedpath https://example.com/sitemap.xml
```

### URL Inspection

```bash
uv run gsc url inspect --site sc-domain:example.com --url https://example.com/page
```

Get full response in JSON:

```bash
uv run gsc url inspect \
  --site sc-domain:example.com \
  --url https://example.com/page \
  --output json
```

### Analytics

```bash
uv run gsc analytics query \
  --site sc-domain:example.com \
  --start-date 2026-01-01 \
  --end-date 2026-01-31 \
  --dimension date \
  --dimension query \
  --filter query:contains:brand \
  --filter device:equals:MOBILE
```

Save as CSV:

```bash
uv run gsc analytics query \
  --site sc-domain:example.com \
  --start-date 2026-01-01 \
  --end-date 2026-01-31 \
  --dimension page \
  --output csv \
  --csv-path ./analytics.csv
```

## Filter Syntax

Use repeatable filters in this format:

```text
dimension:operator:expression
```

Supported filter dimensions:
- `country`
- `device`
- `page`
- `query`
- `searchAppearance`

Supported operators:
- `contains`
- `equals`
- `notContains`
- `notEquals`
- `includingRegex`
- `excludingRegex`

## Convenience Script

Run OAuth setup from this self-contained folder:

```bash
./scripts/setup.sh /absolute/path/to/client_secret.json
```

The script invokes the CLI through `uv run --project <this-folder> gsc`; it does not install a global command.

## Tests

```bash
uv run --extra dev pytest
```

From another working directory:

```bash
uv run --project /absolute/path/to/google-search-console --extra dev pytest
```

## Credentials and Config Paths

By default:
- Credentials: `~/.config/gsc-cli/credentials.json`
- Config: `~/.config/gsc-cli/config.json`

Override with env vars:
- `GSC_CREDENTIALS_FILE`
- `GSC_APP_CONFIG_FILE`
- `GSC_CONFIG_DIR`

## ADC Fallback (Optional)

If you prefer ADC via `gcloud`, the CLI still supports it:

```bash
gcloud auth application-default login \
  --client-id-file=/absolute/path/to/client_secret.json \
  --scopes=https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/webmasters
```

## Notes

- Use Search Console property formats like `sc-domain:example.com` or URL-prefix properties.
- `site add` requires write scope (`webmasters`).
- `sitemap submit` and `sitemap delete` require write scope (`webmasters`).
- `url inspect` uses URL Inspection API for manual status checks only (no general "request indexing" endpoint in Search Console API).
- `analytics query --aggregation-type byProperty` cannot be combined with `page` grouping/filtering.
