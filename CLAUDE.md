# Board Game Leaderboard — Developer Notes

## Stack

- Rails 8.1, Ruby 3.4
- SQLite3 (plain sqlite3 gem — `activerecord-sqlcipher-adapter` does not exist on RubyGems; if at-rest encryption is required in future, consider filesystem-level encryption or `ActiveRecord::Encryption`)
- Tailwind CSS v4, Importmap, Hotwire (Turbo + Stimulus)
- Active Storage (local disk), synchronous analysis enabled
- PaperTrail (JSON serializer) on Play and PlayParticipant
- Minitest + Capybara + Selenium for tests

## Local setup

**System dependency:** `libvips` must be installed for Active Storage image analysis (used by the square-image validator and image variants). On Fedora: `sudo dnf install vips`. On Debian/Ubuntu: `sudo apt install libvips`. The Dockerfile installs it automatically.

```bash
bundle install
cp .env.example .env     # fill in APP_PASSWORD and SECRET_KEY_BASE
rails db:create db:migrate
bin/dev                  # starts Rails + Tailwind watcher
```

`dotenv-rails` loads `.env` automatically in development and test.

## Environment variables

| Variable | Required | Description |
|---|---|---|
| `APP_PASSWORD` | Yes | bcrypt hash of the login password |
| `SECRET_KEY_BASE` | Yes (auto-generated in Docker) | secret key for signing cookies/sessions; must be set in `.env` for local dev |
| `BGG_API_TOKEN` | No | Bearer token for the BGG XML API; enables "Fetch from BGG" on game forms |

In Docker, `SECRET_KEY_BASE` is generated automatically on first boot and persisted in the storage volume. In local development it must be set in `.env`.

### Setting the app password

Generate a bcrypt hash and set it as `APP_PASSWORD`:

```bash
rails runner "puts BCrypt::Password.create('your-password-here')"
```

### Generating a secret key base (local dev)

```bash
rails secret
```

## Docker

Download `docker-compose.yml`, create a `.env` file with your app password, and start:

```bash
echo "APP_PASSWORD=$(docker run --rm ruby:3.4.5-slim ruby -rbcrypt -e 'puts BCrypt::Password.create("your-password")')" > .env
docker compose up
```

Or generate the hash locally if Ruby is available:

```bash
echo "APP_PASSWORD=$(ruby -rbcrypt -e 'puts BCrypt::Password.create("your-password")')" > .env
docker compose up
```

The app runs on port 3000. Named Docker volumes persist the database, uploads, and the auto-generated secret key.

## Running tests

```bash
rails test                  # unit + controller tests
rails test:system           # Capybara/Selenium system tests
bin/ci                      # both (exits non-zero on failure)
```

## Git

Do not include `Co-Authored-By` trailers in commit messages.

## Resetting the password

Generate a new hash and update `APP_PASSWORD` in `.env`:

```bash
rails runner "puts BCrypt::Password.create('new-password-here')"
```
