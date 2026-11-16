# Board Game Leaderboard — Copilot Agent Instructions

## What This App Does

Board Game Leaderboard (BGL) is a single-password, single-tenant Rails web app for tracking board game plays among a fixed group of players. Users log in with a shared password, then manage **Players**, **Games**, **Locations**, and **Plays** (each play records which players participated, their scores, and who won).

---

## Stack

| Layer | Technology |
|-------|-----------|
| Framework | Rails 8.1 (Ruby 3.4.5) |
| Database | SQLite3 (`sqlite3` gem ≥ 2.1) |
| Asset pipeline | Propshaft |
| CSS | Tailwind CSS v4 (`tailwindcss-rails`) |
| JS | Importmap + Hotwire (Turbo + Stimulus) |
| File uploads | Active Storage (local disk), synchronous analysis |
| Background jobs | Solid Queue |
| Cache | Solid Cache |
| Auth | Single bcrypt password hash in the `APP_PASSWORD` env var |
| Tests | Minitest + Capybara + Selenium (headless Chrome) |
| Linter | RuboCop (`rubocop-rails-omakase` style) |
| Security | Brakeman, bundler-audit, importmap audit |

> **Note:** The custom instructions for this repo mention PaperTrail, but it is **not** in the Gemfile or Gemfile.lock and is not used anywhere in the codebase. Ignore any references to PaperTrail.

---

## System Dependencies

`libvips` **must** be installed before running tests or the server. It is required by the `ruby-vips` gem (used by Active Storage image analysis and the `SquareImageValidator`).

```bash
# Debian/Ubuntu (including CI runners)
sudo apt-get install -y libvips

# Fedora/RHEL
sudo dnf install vips
```

The Dockerfile and CI workflow already install it automatically.

---

## Environment Setup

```bash
bundle install
rails db:create db:migrate
bin/rails test          # unit + controller tests
bin/rails test:system   # Capybara/Selenium system tests
```

### Environment variables (`.env` — gitignored)

The app does **not** use Rails credentials (`config/credentials.yml.enc` / `RAILS_MASTER_KEY`). All configuration is via environment variables, loaded from `.env` by `dotenv-rails` in development and test. Copy `.env.example` to `.env`.

| Variable | Required | Notes |
|---|---|---|
| `APP_PASSWORD` | Yes | bcrypt hash of the login password, read via `ENV.fetch("APP_PASSWORD")` in `ApplicationController` |
| `SECRET_KEY_BASE` | No | Development/test generate their own. In production, if unset, a key is generated on first boot and stored in `storage/.secret_key_base` (see `config/environments/production.rb`) |
| `BGG_API_TOKEN` | No | Enables "Fetch from BGG" on game forms |

Generate a bcrypt hash:
```bash
rails runner "puts BCrypt::Password.create('your-password-here')"
```

**For CI/testing**, no `APP_PASSWORD` is needed because `SessionsController#valid_password?` is stubbed via Mocha.

---

## Running Tests

```bash
bin/rails test              # unit + controller tests (parallel)
bin/rails test:system       # Capybara/Selenium, headless Chrome
bin/ci                      # full CI suite: setup → tests → lint → security scans
```

`bin/ci` runs these steps in order:
1. `bin/setup --skip-server` (bundle install + db:prepare)
2. `bin/rails test`
3. `bin/rails test:system`
4. `bin/rubocop`
5. `bin/bundler-audit`
6. `bin/importmap audit`
7. `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error`

Always run `bin/rails test` (and `bin/rails test:system` for UI changes) before finalising changes.

---

## Authentication

- All routes require `session[:authenticated]` (set by `ApplicationController#require_auth`).
- `SessionsController` (`/login`, `/logout`) skips `require_auth`.
- Only `new` and `create` on `SessionsController` are public.
- **In controller tests**: call `log_in` (defined in `AuthHelper`, included in `ActionDispatch::IntegrationTest`). It stubs `valid_password?` to return `true` and posts to `login_path`.
- **In system tests**: stub `valid_password?` via `SessionsController.any_instance.stubs(:valid_password?).returns(true)`, then visit `login_url` and fill in the password field.

---

## Data Model

```
Game           — name (required), bgg_url (optional URL), box_art (Active Storage, JPEG/PNG/WebP, ≤5 MB)
Player         — name (required), profile_picture (Active Storage, JPEG/PNG/WebP, ≤5 MB, must be square)
Location       — name (required), latitude/longitude (optional decimals)
Play           — belongs_to game (required), belongs_to location (optional), date (optional), notes (optional)
PlayParticipant — belongs_to play, belongs_to player, score (integer, optional), winner (boolean, default false)
```

`Play` accepts nested attributes for `play_participants` (`accept_nested_attributes_for`, `allow_destroy: true`). The `play_participants` join model is also exposed as a resource through the plays form; participants with a blank `player_id` are rejected automatically.

**No versioning/audit trail** — PaperTrail is not present despite older docs.

---

## Key Files

| Path | Purpose |
|------|---------|
| `app/models/` | All five models |
| `app/controllers/application_controller.rb` | Auth guard + `valid_password?` |
| `app/controllers/sessions_controller.rb` | Login/logout |
| `app/controllers/plays_controller.rb` | Full CRUD + sortable index |
| `app/validators/square_image_validator.rb` | Custom validator using `ruby-vips`; reads new uploads directly from IO before the blob is persisted |
| `app/javascript/controllers/play_form_controller.js` | Stimulus: add/remove participant rows dynamically |
| `app/javascript/controllers/dark_mode_controller.js` | Stimulus: toggle dark mode |
| `config/ci.rb` | Steps executed by `bin/ci` |
| `test/test_helper.rb` | Fixtures, parallel tests, `AuthHelper` |
| `test/application_system_test_case.rb` | Selenium headless Chrome |
| `test/fixtures/` | YAML fixtures for all five models |
| `db/schema.rb` | Canonical schema (do not edit manually; use migrations) |

---

## Conventions & Gotchas

1. **Do not add `Co-Authored-By` trailers** to git commit messages.
2. **Tailwind CSS v4** — class names follow v4 conventions. Do not use v3-only utilities. `bin/rails tailwindcss:watch` compiles CSS during development (`bin/dev`).
3. **Importmap** (no npm/webpack). Add JS packages with `bin/importmap pin <package>`, not via npm.
4. **Active Storage analysis is synchronous** (`config.active_storage.queues.analysis = nil`) so image dimensions are available immediately after upload — important for `SquareImageValidator`.
5. **`activerecord-sqlcipher-adapter` does not exist on RubyGems.** If at-rest encryption is needed, use filesystem-level encryption or `ActiveRecord::Encryption`.
6. **Do not introduce Rails credentials** (`credentials.yml.enc`, `master.key`, `RAILS_MASTER_KEY`). Configuration is via environment variables only; tests stub authentication so no `APP_PASSWORD` is needed in CI.
7. **RuboCop style** is `rubocop-rails-omakase`. Run `bin/rubocop -a` to auto-correct most offences before committing.
8. **System tests need Chrome** — the CI workflow relies on Chrome being available in the runner's environment. On a bare machine, install `google-chrome-stable` or `chromium-browser`.
9. **Fixtures use ERB** (`<%= 1.week.ago.to_date %>` etc.). Fixture names map to helpers in tests (`plays(:chess_night)`, `players(:alice)`, etc.).
10. **Sort safety in `PlaysController`** — the `sort` and `dir` params are validated against allowlists (`SORTABLE_COLUMNS`, `%w[asc desc]`). Do not loosen these checks.

---

## CI Workflow (`.github/workflows/ci.yml`)

Four parallel jobs: `test`, `lint`, `scan_ruby`, `scan_js`. All use `ubuntu-latest` and `ruby/setup-ruby@v1` (reads `.ruby-version` → 3.4.5). `test` sets `SECRET_KEY_BASE` and installs `libvips` before running migrations and both test suites.

---

## Errors Encountered During Onboarding & Workarounds

| Error | Root Cause | Workaround |
|-------|-----------|-----------|
| `Vips::Error` / missing `libvips` | `ruby-vips` requires the native `libvips` shared library | Install with `sudo apt-get install -y libvips` before running tests or the server |
| `KeyError: key not found: "APP_PASSWORD"` in test | `APP_PASSWORD` not set | Stub `valid_password?` in tests (already done in `AuthHelper` and system test setups) |
| `activerecord-sqlcipher-adapter` not found | Gem does not exist on RubyGems | Use plain `sqlite3` gem; consider `ActiveRecord::Encryption` if at-rest encryption is required |
