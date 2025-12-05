# Scrum Events

**Project:** BLIMP - Proximity Chat Application  
**Duration:** November 12, 2025 - December 4, 2025  
**Team Size:** 4 members (distributed/async work)  
**Sprint Length:** ~3 weeks total

**Note:** Scrum events were conducted asynchronously via Slack and GitHub rather than formal meetings. As per the instructor, brief coordination happened in-person after class.

---

## Sprint 1: Foundation (Nov 12-19)

### Sprint Planning (Nov 12-15, 2025)

**Format:** Mix of in-person (after class) and async via Slack #project-planning  
**Evidence:** Initial commits, project board setup, Slack threads, GitHub PR requirements

**Sprint Goal:** Set up project infrastructure and assign responsibilities.

**Work Division Finalized:**
- **Chat Team (2 members):** OAuth, messaging UI, user sessions, GitHub PR requirements
- **Location Team (1 member):** Geolocation API, coordinate conversion
- **Distance Team (1 member):** ECEF distance calculations, radius filtering

**Product Backlog Items Pulled:**
- Initialize Rails app and Git repo
- Design User and Message models
- Research ECEF coordinates for distance
- Plan OAuth integration
- Set up testing framework
- Configure GitHub PR requirements

**Decomposed Tasks (Project Board):**
- Create GitHub repo ✅
- Set up PR requirements and branch protection ✅
- Initialize Rails 8 app ✅
- Design database schema ✅
- Create feature branches ✅
- Assign initial responsibilities ✅

**In-Person Discussion (After Class - Nov 12):**
- One chat team member set up GitHub PR requirements
- Discussed branch strategy (main → dev → feature branches)
- Quick walkthrough of project board structure

**Evidence:**
- Initial commit: Nov 12
- GitHub branch protection rules configured
- PR template created
- 8 issues created on GitHub Projects
- 15 Slack messages in #project-planning

---

### Daily Scrum (Async)

**Format:** Slack #standup channel - team members posted updates when available  
**Frequency:** 3-4 updates per week per active member


**Actionable Plans Created:**
- Distance and location teams coordinated on ECEF format
- Chat team will work by creating temporary test accounts
- Regular commits pushed to feature branches
- PR reviews requirements to be set

**Evidence:**
- Slack messages
- commits from members
- GitHub activity showing consistent progress

---

### Sprint Review (Nov 18-19, 2025)

**Format:** Informal via Slack and git commits

**Work Completed:**
1. ✅ Rails app initialized and structured
2. ✅ GitHub repo with branch strategy and PR requirements
3. ✅ Database schema designed (Users, Messages tables)
4. ✅ Initial research on ECEF coordinates
5. ✅ OAuth configuration started
6. ✅ Project board with user stories

**Progress Discussed:** Foundation complete (~20%)

**Feedback Incorporated:**
- Professor approved ECEF approach
- Recommended test coverage >90%
- Suggested clear separation: chat team (OAuth/sessions), distance team (ECEF calculations)

**Product Backlog Adjusted:**
- Added comprehensive testing requirements
- Prioritized OAuth and distance logic
- Added deployment documentation

**Evidence:**
- git commits (Sprint 1)
- Project board updated with 6 completed tasks
- Class check-in with professor

---

### Sprint Retrospective (Nov 19, 2025)

**Format:** Slack #retrospective thread

**What Went Well:**
- Quick setup of infrastructure
- PR requirements set up early (good for code quality)
- Clear work division by feature
- Good async communication via Slack

**Problems Encountered:**
- Scheduling conflicts prevented formal meetings
- Inconsistent attendance in class
- Sparse project board updates
- Small team size means less redundancy

**How Problems Were Addressed:**
- Moved to fully async Scrum via Slack
- Used git commits as progress tracking
- Key decisions documented in Slack threads
- Brief after-class coordination when possible

**Improvements for Next Sprint:**
1. More granular GitHub issues (break down tasks better)
2. Tag team members in Slack for coordination
3. Use feature branch PRs for code review
4. Daily commits to show consistent work

**Evidence:** Retrospective thread in Slack (5 messages, 3 participants)

---

## Sprint 2: Core Development (Nov 19 - Dec 1)

### Sprint Planning (Nov 19-26, 2025)

**Format:** Slack thread + project board updates

**Sprint Goal:** Implement OAuth, distance calculations, and messaging with >90% test coverage.

**Product Backlog Items:**
- **Chat Team (2):** Google OAuth (US1.1-1.2), User model, sessions
- **Distance Team:** Finalize tests for message model with ECEF, distance_to method, within_radius scope (US4.1-4.3)
- **Location Team (1):** Lat-Long Coordinate conversion, location updates
- **All:** RSpec and Cucumber tests

**Decomposed Tasks:**
- Feature branches created for each component
- Tests written before implementation (TDD)
- Integration points documented in Slack

**Evidence:**
- 18 new issues on project board
- Feature branches: `feature/distance-logic`, `feature/user-profiles`, `feature/oauth`
- Slack thread with task assignments

---

### Daily Scrum (Async)

**Week 2-3 Sample Updates:**
```
Nov 21 - @distance-dev:
Completed: RSpec tests
Today: Implementing within_radius scope
Blockers: Need User model from chat

Nov 22 - @chat-dev-1:
Completed: OAuth callback working
Today: User validations (@tamu.edu only)
Blockers: None

Nov 24 - @location-dev:
Completed: Geolocation API integration
Today: Testing coordinate conversion
Blockers: None

Nov 25 - @distance-dev:
Completed: Distance calculations done, all tests passing
Today: Moving to User model (finished early)
Blockers: None

Nov 27 - @chat-dev-2:
Completed: Session management working
Today: Messaging UI
Blockers: None
```

**Evidence:**
- Slack messages in #standup (Sprint 2)
- Regular PR activity and reviews on github

---

### Sprint Review (Nov 30 - Dec 1, 2025)

**Format:** Git commits and informal class update

**Completed Work:**
1. ✅ Google OAuth fully working (chat team)
2. ✅ User model with TAMU validation
3. ✅ Message model with ECEF coordinates
4. ✅ Distance calculations: `distance_to`, `within_radius`
5. ✅ RSpec coverage: 91%
6. ✅ Cucumber scenarios for OAuth (chat team)
7. ✅ Basic messaging UI (chat team)
8. ✅ Coordinate conversion working (location team)

**Progress:** ~70% complete

**Stakeholder Feedback (Instructor):**
- Good test coverage
- Deployment to be done
- Need comprehensive documentation

**Backlog Adjusted:**
- High priority: Technical documentation, deployment
- Added: Architecture diagrams, user guide
- Added: ADRs for key decisions

**Evidence:**
- Major features completed
- In-class demo showing OAuth + distance filtering working

---

### Sprint Retrospective (Dec 1, 2025)

**Format:** Slack thread

**What Went Well:**
- Core features implemented successfully
- High test coverage maintained
- TDD approach worked well
- Good async collaboration despite no meetings
- PR requirements ensured code quality

**Problems Encountered:**
- Sparse project board (not all work tracked)
- Some merge conflicts due to User model changes
- Half team sometimes unavailable

**How Problems Were Solved:**
- Focused on git commit sizes as primary evidence
- Coordinated merges via Slack
- Active members picked up slack
- Quick after-class coordination when needed

**Improvements for Final Sprint:**
1. Focus on documentation
2. Clean up project board
3. Coordinate final deployment
4. Create comprehensive README

**Evidence:** Slack thread (4 messages)

---

## Sprint 2 Continued: Documentation & Deployment (Dec 1-4)

### Sprint Planning (Dec 1, 2025)

**Format:** Slack + project board

**Sprint Goal:** Complete documentation and deploy to Heroku.

**Tasks:**
- Technical setup documentation
- User guide
- System architecture diagrams
- Database ERD
- ADRs
- Heroku deployment
- Final testing

**Work Division:**
- **Documentation:** All written docs
- **Deployment:** Heroku setup
- **Testing (location team member):** Final QA
- **UI Polish**
  **Evidence:** 12 tasks added to project board

---

### Daily Scrum (In Class)

**Dec 1-4 Updates:**
```
Dec 3 - @distance-dev:
Completed: Technical documentation, setup guide
Today: setup guide
Blockers: None

Dec 3 - @chat-dev-1:
Completed: Heroku app created, PostgreSQL configured
Today: Environment variables, final deploy
Blockers: Need master.key

Dec 3 - @location-dev:
Completed: Final QA testing
Today: Documentation review
Blockers: None
```

**Evidence:** Slack messages, commits on documentation

---

### Sprint Review (Dec 4, 2025)

**Format:** Final submission + git commits

**Completed Work:**
1. ✅ Complete technical documentation
2. ✅ User guide
3. ✅ System architecture diagrams
4. ✅ Database schema/ERD
5. ✅ ADRs (ECEF, OAuth)
6. ✅ Deployed to Heroku

**Progress:** 100% (MVP complete)

**Evidence:**
- Complete README and docs/ folder
- Working Heroku deployment
- All tests passing

---

### Sprint Retrospective (Dec 4, 2025)

**Format:** Final Slack thread

**What Went Well:**
- Successfully completed MVP with small team
- Excellent documentation created
- High test coverage maintained
- Heroku deployment working
- PR requirements kept code quality high

**Challenges:**
- Distributed team made coordination difficult
- Project board underutilized
- Small team = high individual workload

**Key Learnings:**
1. Async Scrum can work with good communication
2. Git commits and Slack are viable alternatives to formal meetings
3. Small focused team can be very effective
4. PR requirements crucial for code quality
5. Documentation as important as code

**For Future Projects:**
- Better project board hygiene
- More structured async standups
- Earlier deployment
- Regular PR reviews

---

## Evidence Summary

**Sprint Planning:**
- In-person coordination (during or after class, Nov 12)
- Slack threads with task assignments
- Project board issues created
- Feature branches established
- Clear work division documented
- PR requirements configured

**Daily Scrum:**
- Slack standup messages across 3 sprints
- Consistent git commit activity
- Regular coordination in Slack channels
- Actionable plans in commit messages and PRs

**Sprint Review:**
- Completed features merged to dev
- Class check-ins with TA/Instructor
- Working demos of OAuth and distance filtering
- Incremental progress tracked in git history

**Sprint Retrospective:**
- Slack retrospective threads (3 total)
- Issues documented for next sprint
- Process improvements implemented
- Lessons learned documented

**Overall Activity:**
- **Team Size:** 4 members
- **Git Commits:** Commits (Nov 12 - Dec 4)
- **Slack Messages:** Messages across channels
- **Project Board:** All issues closed
- **Pull Requests:** Major PRs merged (with reviews per PR requirements)
- **Test Coverage:** Maintained >90% throughout

---