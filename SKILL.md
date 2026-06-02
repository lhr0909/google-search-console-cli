---
name: google-search-console
description: Use this skill to run the bundled Google Search Console CLI with uv for OAuth setup, authentication troubleshooting, site and sitemap operations, URL inspection, analytics queries, diagnostics, and config management. No global installation is required.
---

# Google Search Console CLI Skill

Use this skill to operate and troubleshoot the bundled `gsc` CLI for Google Search Console.

## When To Use

Use this skill when the task involves any of:
- setting up OAuth credentials for Google Search Console
- authenticating this CLI
- listing properties, managing sitemaps, URL inspection, or Search Analytics queries
- diagnosing auth/config/API connectivity issues

## Self-Contained Usage

This skill is self-contained. Do not install the CLI globally and do not use `uv tool install` unless the human explicitly asks for that.

Let `SKILL_DIR` be the directory containing this `SKILL.md` file. If the folder has been copied into an agent skills directory and renamed to `google-search-console`, that folder is `SKILL_DIR`.

Run all CLI commands through `uv`:

```bash
uv run --project "$SKILL_DIR" gsc --help
```

If your shell is already in `SKILL_DIR`, the shorter form is also fine:

```bash
uv run gsc --help
```

For tests or development checks, include the dev extra:

```bash
uv run --project "$SKILL_DIR" --extra dev pytest
```

## Prerequisites

- `uv` available on `PATH`
- A Google account with access to at least one Search Console property
- Search Console API enabled for the Google Cloud project used by OAuth

If `uv` is missing, install it from <https://docs.astral.sh/uv/>.

## OAuth Client Setup In Google Cloud (Desktop App)

1. Open Google Cloud Console and select/create a project.
2. Enable the Search Console API for that project.
3. Configure OAuth consent screen:
   - choose `External` for personal/testing usage (or `Internal` for Workspace org-only)
   - fill required app fields (app name, support email, developer contact)
   - add your Google account as a test user if app is in testing mode
4. Go to `APIs & Services` -> `Credentials`.
5. Click `Create credentials` -> `OAuth client ID`.
6. Choose application type `Desktop app`.
7. Create and download the OAuth client JSON (`client_secret_*.json`).

Keep the downloaded JSON private.

## Authenticate This CLI

Preferred login flow:

```bash
uv run --project "$SKILL_DIR" gsc auth login --client-secret /absolute/path/to/client_secret.json
```

Useful auth options:
- `--readonly`: request readonly scope only (`webmasters.readonly`)
- `--no-launch-browser`: print the auth URL without auto-opening a browser

Verify credentials:

```bash
uv run --project "$SKILL_DIR" gsc auth whoami
uv run --project "$SKILL_DIR" gsc doctor
```

Default storage paths:
- credentials: `~/.config/gsc-cli/credentials.json`
- app config: `~/.config/gsc-cli/config.json`

Env overrides:
- `GSC_CREDENTIALS_FILE`
- `GSC_APP_CONFIG_FILE`
- `GSC_CONFIG_DIR`

## Optional: Set Default Property

```bash
uv run --project "$SKILL_DIR" gsc config set default-site sc-domain:example.com
uv run --project "$SKILL_DIR" gsc config get default-site
```

When set, commands that accept `--site` can omit it.

## Command Reference

Top-level:
- `uv run --project "$SKILL_DIR" gsc --version`
- `uv run --project "$SKILL_DIR" gsc --help`
- `uv run --project "$SKILL_DIR" gsc doctor`

### `auth`

- `uv run --project "$SKILL_DIR" gsc auth login --client-secret FILE [--readonly] [--no-launch-browser]`
- `uv run --project "$SKILL_DIR" gsc auth whoami [--output table|json]`

### `config`

- `uv run --project "$SKILL_DIR" gsc config set default-site SITE_URL`
- `uv run --project "$SKILL_DIR" gsc config get default-site`

### `site`

- `uv run --project "$SKILL_DIR" gsc site list [--output table|json|csv] [--csv-path FILE]`
- `uv run --project "$SKILL_DIR" gsc site get [--site SITE] [--output table|json|csv] [--csv-path FILE]`
- `uv run --project "$SKILL_DIR" gsc site add [--site SITE]`

`SITE` example: `sc-domain:example.com`.

### `sitemap`

- `uv run --project "$SKILL_DIR" gsc sitemap list [--site SITE] [--sitemap-index TEXT] [--output table|json|csv] [--csv-path FILE]`
- `uv run --project "$SKILL_DIR" gsc sitemap get [--site SITE] --feedpath TEXT [--output table|json|csv] [--csv-path FILE]`
- `uv run --project "$SKILL_DIR" gsc sitemap submit [--site SITE] --feedpath TEXT`
- `uv run --project "$SKILL_DIR" gsc sitemap delete [--site SITE] --feedpath TEXT`

`--feedpath` alias: `--path`.

### `url`

- `uv run --project "$SKILL_DIR" gsc url inspect [--site SITE] --url URL [--language-code CODE] [--output table|json|csv] [--csv-path FILE]`

Defaults:
- `--language-code en-US`

### `analytics`

- `uv run --project "$SKILL_DIR" gsc analytics query --start-date YYYY-MM-DD --end-date YYYY-MM-DD [options]`

Options:
- `--site SITE`
- `--dimension country|date|device|hour|page|query|searchAppearance` (repeatable)
- `--type discover|googleNews|image|news|video|web`
- `--aggregation-type auto|byNewsShowcasePanel|byPage|byProperty`
- `--row-limit 1..25000`
- `--start-row >=0`
- `--data-state all|final|hourly_all`
- `--filter dimension:operator:expression` (repeatable)
- `--output table|json|csv`
- `--csv-path FILE`

Supported filter dimensions:
- `country`, `device`, `page`, `query`, `searchAppearance`

Supported filter operators:
- `contains`, `equals`, `notContains`, `notEquals`, `includingRegex`, `excludingRegex`

Constraint:
- `--aggregation-type byProperty` cannot be combined with `page` dimension or `page` filter.

## Quick Examples

```bash
# List properties
uv run --project "$SKILL_DIR" gsc site list

# Get one property
uv run --project "$SKILL_DIR" gsc site get --site sc-domain:example.com

# List sitemaps
uv run --project "$SKILL_DIR" gsc sitemap list --site sc-domain:example.com

# Inspect one URL
uv run --project "$SKILL_DIR" gsc url inspect --site sc-domain:example.com --url https://example.com/page --output json

# Analytics query
uv run --project "$SKILL_DIR" gsc analytics query \
  --site sc-domain:example.com \
  --start-date 2026-01-01 \
  --end-date 2026-01-31 \
  --dimension date \
  --dimension query \
  --filter query:contains:brand
```

## Troubleshooting

- `Auth error: Stored credentials do not include required scope ...`
  - Re-run login with needed scope. For write commands, run login without `--readonly`.

- `No local OAuth credentials found...`
  - Run: `uv run --project "$SKILL_DIR" gsc auth login --client-secret <path>`

- `No site specified. Pass --site or set one...`
  - pass `--site` or set default via `uv run --project "$SKILL_DIR" gsc config set default-site ...`

- API failures / uncertain setup state
  - run `uv run --project "$SKILL_DIR" gsc doctor` first, then address failing checks.
