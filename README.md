# **📘 Rails Application **

A minimal Ruby on Rails application with a basic homepage, RSpec tests, Cucumber acceptance tests, and a full GitHub Actions CI pipeline.

---

## **🔧 Requirements**

* **Ruby 3.4.5**
* **Rails 7.x**
* **Bundler**
* **SQLite** (development & test)
* **PostgreSQL** (recommended for production)

---

## **📦 Setup**

```bash
bundle install
bin/rails db:prepare
```

Start the server:

```bash
bin/rails server
```

Visit:
**[http://localhost:3000](http://localhost:3000)**

---

## **🧪 Running Tests**

### RSpec (unit + request tests, with SimpleCov ≥ 90%)

```bash
bundle exec rspec
```

### Cucumber (acceptance tests)

```bash
bundle exec cucumber
```

### RuboCop (lint)

```bash
bundle exec rubocop
```

### Security Tools

```bash
bundle exec brakeman
bundle exec bundle-audit check --update
```

---

## **🗄️ Database**

Development & test: **SQLite (default)**
Production: **PostgreSQL recommended**
Configure via `config/database.yml`.

---

## **🚀 Deployment**

* Heroku

---

## **🔄 Continuous Integration**

GitHub Actions runs automatically on:

* `main`
* `dev`

Checks include:

* RSpec
* Cucumber
* RuboCop
* Brakeman
* Bundler Audit

All must pass before merging.

---

## **📁 Project Structure**

* `app/` – core Rails MVC code
* `spec/` – RSpec tests
* `features/` – Cucumber scenarios
* `.github/workflows/ci.yml` – CI pipeline

