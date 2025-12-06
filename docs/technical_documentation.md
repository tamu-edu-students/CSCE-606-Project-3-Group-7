# BLIMP: A Proximity Chat Application
_A location-based chat application where Texas A&M University students can send and view messages within a 500-meter radius of their current location._
---
### Technology Stack

- **Backend:** Ruby on Rails 8.0.3
- **Database:** SQLite3 (development), PostgreSQL (production)
- **Authentication:** OmniAuth + Google OAuth 2.0
- **Testing:** RSpec (96% coverage), Cucumber
- **Location:** ECEF Cartesian coordinates for distance calculations
- **Deployment:** Heroku
---
# Setup & Deployment

## Prerequisites

- Ruby 3.4.5
- Rails 8.0.3
- PostgreSQL (for production)
- SQLite3 (for development/testing)
- Git
- Heroku CLI
- Google Cloud Console account

---

## Part 1: Local Development Setup

1. Clone Repository
```bash
git clone https://github.com/tamu-edu-students/CSCE-606-Project-3-Group-7.git
cd CSCE-606-Project-3-Group-7
```

2. Install Dependencies
```bash
# Install Ruby gems
bundle install

# Install JavaScript packages (if needed)
npm install
```

3. Configure Environment Variables

Create `.env` file in project root:
```bash
touch .env
```

4. Add your Google OAuth credentials:
```
GOOGLE_CLIENT_ID=your_client_id_from_google_console
GOOGLE_CLIENT_SECRET=your_client_secret_from_google_console
```

**⚠️ Important:** 
- No quotes around values
- Add `.env` to `.gitignore` (already done)
- Never commit credentials to Git

5. Google OAuth Setup

* Go to [Google Cloud Console](https://console.cloud.google.com/)
* Create a new project: "Proximity Chat App"
* Navigate to **APIs & Services** → **Credentials**
* Click **Create Credentials** → **OAuth 2.0 Client ID**
* Configure OAuth consent screen:
* User Type: External
   - App name: "Proximity Chat"
   - User support email: your email
   - Authorized domains: `localhost` (for dev)
* Create OAuth Client ID:
    - Application type: Web application
    - Authorized redirect URIs:
     - `http://localhost:3000/auth/google_oauth2/callback` (development)
     - `https://your-app-name.herokuapp.com/auth/google_oauth2/callback` (production)
* Copy **Client ID** and **Client Secret** to `.env` file

6. Setup Database
```bash
# Create database
rails db:create

# Run migrations
rails db:migrate

# Optional: Seed data
rails db:seed
```

7. Run Tests
```bash
# Run RSpec unit tests
bundle exec rspec

# Run Cucumber acceptance tests
bundle exec cucumber

# View coverage report
open coverage/index.html
```

All tests should pass with >90% coverage.

8. Start Development Server
```bash
rails server
```

Visit `http://localhost:3000` and test Google OAuth login.

---

## Part 2: Heroku Deployment

1. Install Heroku CLI
```bash
# macOS
brew tap heroku/brew && brew install heroku

# Or download from: https://devcenter.heroku.com/articles/heroku-cli
```

Verify installation:
```bash
heroku --version
```

2. Login to Heroku
```bash
heroku login
```

This opens browser for authentication.

3. Create Heroku App
```bash
# Create app (replace with your desired name)
heroku create tamu-proximity-chat

# Or let Heroku generate name:
heroku create
```

**Note:** App will be available at `https://tamu-proximity-chat.herokuapp.com`

4. Add PostgreSQL Database
```bash
heroku addons:create heroku-postgresql:mini
```

This provisions a PostgreSQL database (free tier: mini).

5. Configure Environment Variables on Heroku
```bash
heroku config:set GOOGLE_CLIENT_ID=your_client_id_here
heroku config:set GOOGLE_CLIENT_SECRET=your_client_secret_here
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)
```

**Update Google OAuth redirect URI:**
1. Go back to Google Cloud Console
2. Add production callback URL: `https://your-app-name.herokuapp.com/auth/google_oauth2/callback`
3. Save

6. Deploy to Heroku
```bash
# Make sure you're on main branch
git checkout main

# Push to Heroku
git push heroku main
```

Heroku will:
- Detect Rails app
- Install dependencies
- Compile assets
- Deploy application

7. Run Database Migrations
```bash
heroku run rails db:migrate
```

8. Verify Deployment
```bash
# Open app in browser
heroku open

# Check logs
heroku logs --tail
```

---

## Part 3: Continuous Deployment (Optional)

### Setup GitHub Actions for Auto-Deploy

Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy to Heroku

on:
  push:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.4.5
      - name: Install dependencies
        run: bundle install
      - name: Run tests
        run: |
          bundle exec rspec
          bundle exec cucumber
  
  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: akhileshns/heroku-deploy@v3.12.12
        with:
          heroku_api_key: ${{secrets.HEROKU_API_KEY}}
          heroku_app_name: "your-app-name"
          heroku_email: "your-email@example.com"
```

Add Heroku API key to GitHub secrets:
1. Get API key: `heroku auth:token`
2. GitHub repo → Settings → Secrets → New repository secret
3. Name: `HEROKU_API_KEY`, Value: your token

---

## Troubleshooting

### OAuth Errors

**Error:** `redirect_uri_mismatch`
- **Solution:** Check Google Console redirect URIs match exactly
- Development: `http://localhost:3000/auth/google_oauth2/callback`
- Production: `https://your-app.herokuapp.com/auth/google_oauth2/callback`

**Error:** `Only TAMU emails allowed`
- **Solution:** Use @tamu.edu Google account, not personal Gmail

### Database Errors

**Error:** `PG::ConnectionBad`
- **Solution:** Check Heroku PostgreSQL addon is provisioned: `heroku addons`
- Restart dynos: `heroku restart`

**Error:** `Migrations pending`
- **Solution:** Run: `heroku run rails db:migrate`

### Deployment Failures

**Error:** Build failed
- **Solution:** Check `Gemfile.lock` is committed: `git add Gemfile.lock`
- Check Ruby version matches Heroku: `cat .ruby-version`

**Error:** Assets not compiling
- **Solution:** Precompile locally: `RAILS_ENV=production rails assets:precompile`
- Commit: `git add public/assets`

### Heroku Commands Cheatsheet
```bash
# View logs
heroku logs --tail

# Open Rails console
heroku run rails console

# Restart app
heroku restart

# Check config vars
heroku config

# Open app
heroku open

# Check dyno status
heroku ps

# Run migrations
heroku run rails db:migrate

# Reset database (⚠️ destroys data)
heroku pg:reset DATABASE_URL
heroku run rails db:migrate
```

---

## Performance Optimization (Production)

1. Enable Caching
```bash
heroku run rails cache:enable
```

2. Scale Dynos (if needed)
```bash
# Check current dynos
heroku ps

# Scale web dynos
heroku ps:scale web=2
```

3. Add Redis for Caching (Optional)
```bash
heroku addons:create heroku-redis:mini
```

---

## Security Checklist

- ✅ Environment variables set via `heroku config`
- ✅ `.env` in `.gitignore`
- ✅ `config/master.key` not committed
- ✅ HTTPS enforced (automatic on Heroku)
- ✅ CSRF protection enabled
- ✅ OAuth 2.0 for authentication
- ✅ Email domain restriction (@tamu.edu)

---

## Support

For issues:
1. Check [Heroku Status](https://status.heroku.com/)
2. Review logs: `heroku logs --tail`
3. Check GitHub Issues
4. Contact team via course Slack
---
## Team

**Course:** CSCE 606 - Software Engineering  
**Semester:** Fall 2025 
**Institution:** Texas A&M University

---

## License

This project is part of an academic course assignment.