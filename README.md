# Board Game Leaderboard

A self-hosted web app for tracking board game play sessions and leaderboards among a fixed group of players.

## Features

- **Players & Games** — manage a roster of players and a library of games, each with optional profile pictures and box art
- **Play recording** — log play sessions with multiple participants, per-player scores, and winner/draw tracking
- **Leaderboards** — sortable history views per player and per game
- **Head-to-head comparison** — compare any two players across all games or filtered to a single game
- **Locations** — tag plays with an optional location
- **Single-password auth** — one shared password protects the app; no user accounts
- **Dark mode**
- **Docker-ready** — single-container deployment with a pre-built image on Docker Hub

## Screenshots

_Screenshots coming soon._

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Rails 8.1 (Ruby 3.4) |
| Database | SQLite3 |
| Asset pipeline | Propshaft |
| CSS | Tailwind CSS v4 |
| JavaScript | Importmap + Hotwire (Turbo + Stimulus) |
| File uploads | Active Storage (local disk) |
| Pagination | Pagy |
| Background jobs | Solid Queue |
| Cache | Solid Cache |
| Tests | Minitest + Capybara + Selenium |

## Prerequisites

- **Ruby 3.4.5** ([rbenv](https://github.com/rbenv/rbenv) recommended)
- **libvips** — required by Active Storage image analysis

  ```bash
  # Fedora/RHEL
  sudo dnf install vips

  # Debian/Ubuntu
  sudo apt install libvips
  ```

- **SQLite3**
- **Google Chrome** (for running system tests)

## Local Setup

```bash
git clone https://github.com/VoxSecundus/board-game-leaderboard.git
cd board-game-leaderboard
bundle install
cp .env.example .env
```

Edit `.env` and fill in the two required values (see [Configuration](#configuration) below), then:

```bash
rails db:create db:migrate
bin/dev
```

The app is now running at `http://localhost:3000`.

## Configuration

Environment variables are loaded from `.env` via `dotenv-rails`. Copy `.env.example` to `.env` and set:

| Variable | Required | Description |
|---|---|---|
| `APP_PASSWORD` | Yes | bcrypt hash of the login password |
| `SECRET_KEY_BASE` | Yes | Secret key for signing cookies/sessions |
| `BGG_API_TOKEN` | No | Bearer token for the BGG XML API (enables "Fetch from BGG" on game forms) |

### Generating a password hash

```bash
rails runner "puts BCrypt::Password.create('your-password-here')"
```

### Generating a secret key base

```bash
rails secret
```

## Docker

The easiest way to run the app. Copy `docker-compose.yml` to a directory on your server, then:

```bash
# Generate a bcrypt hash for your password
APP_PASSWORD=$(ruby -rbcrypt -e 'puts BCrypt::Password.create("your-password")') \
  docker compose up -d
```

Or if Ruby is not available locally:

```bash
APP_PASSWORD=$(docker run --rm ruby:3.4.5-slim ruby -rbcrypt -e 'puts BCrypt::Password.create("your-password")') \
  docker compose up -d
```

The app runs on port 3000. `SECRET_KEY_BASE` is generated automatically on first boot and persisted in the `storage_data` Docker volume alongside the database and uploads.

## Running Tests

```bash
rails test              # unit and controller tests
rails test:system       # Capybara/Selenium system tests (requires Chrome)
bin/ci                  # full suite: tests + lint + security scans
```

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## License

This project is released under the [MIT License](LICENSE).
