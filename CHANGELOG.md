# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
