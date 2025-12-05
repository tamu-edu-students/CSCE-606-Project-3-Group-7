# Architecture Decision Records (ADRs)

## ADR-001: User Authentication via Google OAuth

**Status:** Accepted

**Context:**
The application requires a secure and reliable way to verify user identity to prevent spam and ensure accountability, even though the public-facing identity in the chat will be anonymous. We need to avoid the complexity and security risks associated with storing and managing user passwords (salting, hashing, reset flows) within our own database.

**Decision:**
We decided to use **Google OAuth 2.0** as the sole authentication provider.

**Consequences:**
* **Pro:** drastically reduces security liability since we do not store passwords.
* **Pro:** Simplifies the user onboarding process (one-click login) as most users already possess a Google account.
* **Pro:** Provides verified email addresses which can be used for administrative bans if necessary, despite the anonymous front-end.
* **Con:** Creates a hard dependency on Google's authentication services; if Google is down, users cannot log in.
* **Con:** Excludes users who do not wish to have a Google account.

---

## ADR-002: Choice of Database System

**Status:** Accepted

**Context:**
The application needs to store user profiles (linked to OAuth IDs), chat logs, and location metadata. The data is relational in nature (Users have many Messages; Messages belong to Rooms). We require a robust, ACID-compliant database that integrates seamlessly with the Ruby on Rails framework and is easily deployable on Heroku.

**Decision:**
We decided to use **PostgreSQL**.

**Consequences:**
* **Pro:** It is the default and most supported database for Rails applications deployed on Heroku.
* **Pro:** Excellent support for complex queries and indexing, which may be needed for querying messages by location/radius in the future (e.g., PostGIS extensions).
* **Pro:** Strong data integrity and consistency compared to NoSQL solutions for this specific relational data model.
* **Con:** Scaling a relational database for massive write-heavy chat loads can be more complex than some NoSQL alternatives, though sufficient for our current scope.

---

## ADR-003: Real-time Communication Framework

**Status:** Accepted

**Context:**
The core feature of the application is the "Location-Based Chat." Users expect messages to appear instantly without refreshing the page. We need a technology that maintains a persistent connection between the client and the server to push updates immediately.

**Decision:**
We decided to use **Rails Action Cable (WebSockets) combined with Turbo Streams**.

**Consequences:**
* **Pro:** Native integration with Rails allows us to reuse our existing Active Record models and authentication logic easily.
* **Pro:** Turbo Streams simplifies the frontend complexity by allowing us to send HTML partials directly over the socket, reducing the need for heavy JavaScript frameworks (like React or Vue) for this specific feature.
* **Con:** Requires managing persistent WebSocket connections, which consumes more server memory than stateless HTTP requests.
* **Con:** Requires a Redis instance (or similar adapter) in production to handle the subscription adapter, adding slight infrastructure complexity.

---

## ADR-004: Location-Based Anonymity Logic

**Status:** Accepted

**Context:**
The unique value proposition of the app is "Anonymous Location Chat." We need a strategy to display users in chat without revealing their real identities (derived from Google OAuth) while ensuring they are physically close enough to participate in the discussion.

**Decision:**
We decided to implement a **Session-Based Anonymous Naming System** with **Client-Side Geolocation**.

**Consequences:**
* **Pro:** Protects user privacy effectively; the "Real Name" is never sent to the chat view layer, only the generated alias (e.g., "BlueFalcon").
* **Pro:** Using browser-based Geolocation API is simpler than IP-based lookups and generally more accurate for local "radius" checks.
* **Con:** Users must explicitly grant browser permission for location; if denied, the core functionality of the app is blocked for that user.
* **Con:** Anonymous names may lead to reduced accountability in chat; we must rely on backend moderation tools linked to the hidden OAuth ID to ban abusive users.