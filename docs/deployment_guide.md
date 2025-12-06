# **HEROKU_DEPLOYMENT_GUIDE.md**

### *Rails + Postgres + Google OAuth 2.0 Deployment Guide*

---

# **0. Quick Deployment Commands**

**For Development:**
1. Create `.env` file with `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`
2. Run `bin/rails server`
3. Test OAuth at [http://localhost:3000](http://localhost:3000)

**For Production (Heroku):**

Once Google OAuth is configured and Heroku app is created:

```bash
# 1. Set Rails master key (if using Rails credentials)
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key) --app project-3-rails-app

# 2. Set OAuth credentials
heroku config:set GOOGLE_CLIENT_ID="YOUR_CLIENT_ID" --app project-3-rails-app
heroku config:set GOOGLE_CLIENT_SECRET="YOUR_CLIENT_SECRET" --app project-3-rails-app

# 3. Deploy (pushes current branch to Heroku's main)
git push heroku $(git branch --show-current):main --force

# 4. Run migrations
heroku run rails db:migrate --app project-3-rails-app

# 5. Seed database (if needed)
heroku run rails db:seed --app project-3-rails-app

# 6. Open app
heroku open --app project-3-rails-app
```

---

# **1. Prerequisites**

✅ **Already Configured:**
- PostgreSQL gem (`gem "pg"`) in `Gemfile`
- `Procfile` with Puma configuration
- OAuth initializer (`config/initializers/omniauth.rb`)
- Production database configuration for PostgreSQL (`config/database.yml`)

---

# **2. Create & Configure Heroku App**

## **2.1 Login to Heroku**

```bash
heroku login
```

## **2.2 Create Heroku App**

```bash
heroku create project-3-rails-app
```

This automatically sets the git remote. Verify with:

```bash
git remote -v
```

## **2.3 Add PostgreSQL Add-on**

```bash
heroku addons:create heroku-postgresql:essential-0 --app project-3-rails-app
```

---

# **3. Google OAuth 2.0 Configuration (Google Cloud Console)**

## **3.1 Create Google Cloud Project**

Navigate to: [https://console.cloud.google.com/](https://console.cloud.google.com/)

* Click **New Project**
* Name it (e.g., *Proximity Chat Auth*)
* Click **Create**

## **3.2 Enable APIs**

Go to: **APIs & Services → Library**

Enable:
* **Google People API**
* **Google OAuth 2.0 Authorization API**

## **3.3 Create OAuth 2.0 Client**

Navigate: **APIs & Services → Credentials → Create Credentials → OAuth Client ID**

Choose:
* **Application Type:** Web Application
* Name: `Rails OAuth Client`

This will generate your:
* `GOOGLE_CLIENT_ID`
* `GOOGLE_CLIENT_SECRET`

**Keep these safe.**

---

# **4. Add Authorized Redirect URIs**

Navigate: **APIs & Services → Credentials → OAuth 2.0 Client → Edit**

Add *all redirect URIs* below.

## **4.1 Production Redirect URIs (Heroku)**

**Note:** Replace `HEROKU_APP_NAME` with your actual Heroku app name thats generated.

```
https://<HEROKU_APP_NAME>>.herokuapp.com/auth/google_oauth2/callback
```

## **4.2 Development Redirect URIs**

```
http://127.0.0.1:3000/auth/google_oauth2/callback
http://localhost:3000/auth/google_oauth2/callback
```

---

# **5. Configure Development Environment**

## **5.1 Create `.env` File**

Create a `.env` file in the project root (this file is already in `.gitignore`):

```bash
touch .env
```

## **5.2 Add OAuth Credentials to `.env`**

Add your Google OAuth credentials to the `.env` file:

```bash
GOOGLE_CLIENT_ID=your_client_id_here
GOOGLE_CLIENT_SECRET=your_client_secret_here
```

**Note:** Replace `your_client_id_here` and `your_client_secret_here` with the actual values from Google Cloud Console (section 3.3).

## **5.3 Verify Development Setup**

Start the Rails server:

```bash
bin/rails server
```

Visit: [http://localhost:3000](http://localhost:3000)

Test OAuth by clicking the sign-in link. You should be redirected to Google OAuth.

---

# **6. Configure Heroku Environment Variables (Production)**

## **6.1 Set Rails Master Key (if using Rails credentials)**

```bash
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key) --app project-3-rails-app
```

## **6.2 Set OAuth Credentials**

```bash
heroku config:set GOOGLE_CLIENT_ID="YOUR_CLIENT_ID" --app project-3-rails-app
heroku config:set GOOGLE_CLIENT_SECRET="YOUR_CLIENT_SECRET" --app project-3-rails-app
```

Verify configuration:

```bash
heroku config --app project-3-rails-app
```

---

# **7. Deploy to Heroku**

## **7.1 Push Code**

### **If you're on the `main` branch:**

```bash
git push heroku main:main
```

### **If you're on a different branch (feature branch, etc.):**

Push your current branch to Heroku's `main` branch:

```bash
git push heroku {BRANCH_NAME}:main --force
```

**Note:** The `--force` flag is typically needed when pushing a branch other than `main` because Heroku's remote branch may have different commits. This overwrites Heroku's main branch with your current branch, which is the standard workflow for Heroku deployments.

**Alternative:** If the above command doesn't work in your shell, you can use:

```bash
git push heroku HEAD:main --force
```

This pushes whatever branch you're currently on to Heroku's main branch.

## **7.2 Run Database Migrations**

```bash
heroku run rails db:migrate --app project-3-rails-app
```

## **7.3 Seed Database (if needed)**

```bash
heroku run rails db:seed --app project-3-rails-app
```

**Note:** The seed file creates an admin user for `harsh.wadhawe@tamu.edu`. If you need to add more admin users, see section 11 below.

---

# **8. Verify Deployment**

## **8.1 Check Logs**

```bash
heroku logs --tail --app project-3-rails-app
```

## **8.2 Open App**

```bash
heroku open --app project-3-rails-app
```

## **8.3 Restart Dynos (if needed)**

```bash
heroku restart --app project-3-rails-app
```

---

# **9. Configure Admin Users**

## **9.1 Automatic Admin Setup (via Seeds)**

The seed file automatically creates an admin user for `harsh.wadhawe@tamu.edu`. After running `db:seed`, this user will have admin privileges.

**Important:** The user must sign in via Google OAuth first before running seeds, or the seed will create a placeholder user that won't work with OAuth.

## **9.2 Add Additional Admin Users**

### **Option 1: Via Rails Console (Recommended)**

1. Sign in to your app with the Google account you want to make admin
2. Open Rails console on Heroku:

```bash
heroku run rails console --app project-3-rails-app
```

3. Find and update the user:

```ruby
user = User.find_by(email: 'your-email@tamu.edu')
user.update!(role: 'admin')
```

4. Verify:

```ruby
user.admin?  # Should return true
```

### **Option 2: Update Seeds File**

Edit `db/seeds.rb` to add more admin users. Update the `admin_emails` array:

```ruby
# List of admin user emails
admin_emails = ['harsh.wadhawe@tamu.edu', 'another-admin@tamu.edu']
```

The seeds file will:
- Find existing users (created via OAuth) and promote them to admin
- Create placeholder users if they don't exist yet (they'll be activated on first OAuth sign-in)

Then commit and redeploy:

```bash
git add db/seeds.rb
git commit -m "Add admin users"
git push heroku $(git branch --show-current):main --force
heroku run rails db:seed --app project-3-rails-app
```

## **9.3 Verify Admin Access**

After setting up admin users:
1. Sign in with a Google account that has admin role
2. You should see admin features (e.g., `/admin/messages`, `/admin/users`)
3. Regular users will only see standard chat features

---

# **10. Summary of Required Redirect URIs**

### **Production (Heroku)**

Replace `project-3-rails-app-06cc92ea7f1f` with your actual Heroku app name:

```
https://project-3-rails-app-06cc92ea7f1f.herokuapp.com/auth/google_oauth2/callback
```

### **Development**

```
http://127.0.0.1:3000/auth/google_oauth2/callback
http://localhost:3000/auth/google_oauth2/callback
```

---

# **11. Troubleshooting**

## **Check Environment Variables**

```bash
heroku config --app project-3-rails-app
```

## **View Recent Logs**

```bash
heroku logs --tail --app project-3-rails-app
```

## **Run Rails Console**

```bash
heroku run rails console --app project-3-rails-app
```

## **Check Database Connection**

```bash
heroku pg:info --app project-3-rails-app
```