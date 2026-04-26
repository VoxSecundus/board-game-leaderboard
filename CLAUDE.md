# Board Game Leaderboard — Developer Notes

## Stack

- Rails 8.1, Ruby 3.4
- SQLite3 (plain, not encrypted — volume-level security in production)
- Tailwind CSS v4, Importmap, Hotwire (Turbo + Stimulus)
- Active Storage (local disk), synchronous analysis enabled
- PaperTrail (JSON serializer) on Play and PlayParticipant
- Minitest + Capybara + Selenium for tests

## Local setup

```bash
bundle install
rails credentials:edit   # set app_password, secret_key_base
rails db:create db:migrate
bin/dev                  # starts Rails + Tailwind watcher
```

## Credentials

`config/credentials.yml.enc` is **gitignored**. Create it on each machine:

```bash
EDITOR="code --wait" rails credentials:edit
```

Required keys:

```yaml
secret_key_base: <run: rails secret>
app_password: <bcrypt hash — see below>
```

### Setting the app password

Generate a bcrypt hash in the Rails console and paste it as `app_password`:

```ruby
BCrypt::Password.create("your-password-here")
```

## Docker

```bash
cp .env.example .env        # fill in RAILS_MASTER_KEY
docker compose build
docker compose up
```

The app runs on port 3000. Named Docker volumes persist the database and uploads.

## Running tests

```bash
rails test                  # unit + controller tests
rails test:system           # Capybara/Selenium system tests
bin/ci                      # both (exits non-zero on failure)
```

## Git

Do not include `Co-Authored-By` trailers in commit messages.

## Resetting the password

From the Rails console (production):

```ruby
new_hash = BCrypt::Password.create("new-password")
# Then update the credentials file with the new hash
```
