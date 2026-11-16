# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- `SECRET_KEY_BASE` is now resolved in Rails production config instead of the Docker entrypoint: a non-empty `SECRET_KEY_BASE` env var takes precedence, otherwise the key is read from (or generated into) `storage/.secret_key_base`. Existing key files are picked up unchanged, so users stay logged in
- `SECRET_KEY_BASE` is optional everywhere and can be supplied through `docker-compose.yml`

### Fixed

- `bin/rails console`, `runner`, rake tasks and job workers inside the Docker container no longer fail with "secret_key_base is not set"
- Active Storage background jobs (analysis, purging) are now processed under Docker Compose by running Solid Queue inside Puma

### Removed

- Leftover `RAILS_MASTER_KEY` / Rails credentials references from deploy config and documentation; the app is configured only through environment variables

## [1.0.0] — 2026-05-04

### Added

- Player management: create, edit, and delete players with optional profile pictures
- Game library: create, edit, and delete games with optional box art and BoardGameGeek links
- Location management: create, edit, and delete named locations with optional coordinates
- Play recording: log sessions with date, location, notes, and multiple participants
- Per-participant scores and winner/draw tracking
- Head-to-head player comparison with optional per-game filtering
- Sortable index and history tables for players, games, locations, and plays
- Pagination across all index views
- Single-password authentication (no user accounts)
- Dark mode toggle
- Docker deployment support with auto-generated secret key
- Active Storage file uploads with square-image validation for profile pictures
