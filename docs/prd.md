# Pump Fiction Product Requirements Document (PRD)

## Goals and Background Context

### Goals
- Build a unified fitness ecosystem that combines training, nutrition, health tracking, and social commerce
- Provide adaptive, AI-driven workout and nutrition planning that evolves with user progress
- Create a verified trainer marketplace enabling coaching monetization and client management
- Establish a sustainable fitness economy through integrated e-commerce and affiliate revenue
- Drive long-term user consistency through gamification and social engagement
- Deliver predictive intelligence to forecast progress, detect plateaus, and prevent injuries

### Background Context

The fitness app market is saturated with single-purpose tools—workout loggers, calorie trackers, or social platforms—none of which provide a holistic, adaptive experience. Users are forced to juggle multiple apps, manually transfer data, and interpret their progress without intelligent guidance. Meanwhile, fitness coaches and content creators lack integrated platforms to monetize their expertise and manage clients effectively.

**Pump Fiction** addresses this fragmentation by creating a comprehensive "personal fitness OS" that combines AI-based predictions, verified coaching, and integrated e-commerce into one seamless experience. Unlike traditional logging apps, Pump Fiction actively learns from user behavior to provide forecasts, suggest adjustments, and maintain engagement through gamified social features. This positions the platform as both a user tool and a business ecosystem for trainers, gym owners, and product creators.

### Change Log

| Date | Version | Description | Author |
|------|---------|-------------|--------|
| 2025-10-13 | 1.0 | Initial PRD draft from project report | MacroHard Team |

---

## Requirements

### Functional Requirements

#### Phase 0: MVP Core Features

**FR1:** Users must be able to register accounts with email/password authentication

**FR2:** Users must be able to log in, log out, and reset passwords via email

**FR3:** System must implement role-based access control (User, Trainer, Admin roles)

**FR4:** New users must complete an onboarding flow capturing: fitness goals, experience level, available equipment, and training frequency

**FR5:** Users must be able to create and log workouts with exercises, sets, reps, weight, and RPE/RIR tracking

**FR6:** Users must be able to edit and delete previously logged workouts

**FR7:** System must automatically detect personal records (PRs) and notify users in-app

**FR8:** Users must be able to select from periodization templates (PPL, Upper/Lower, Full-body) during onboarding or settings

**FR9:** System must provide configurable rest timers with push notifications

**FR10:** Users must be able to log food via barcode scanning (using nutrition database API)

**FR11:** Users must be able to manually search and add foods to daily log

**FR12:** System must calculate and display macronutrient breakdowns (protein, carbs, fats, calories) with user-defined daily targets

**FR13:** Users must be able to set nutrition goals (cut, bulk, body recomposition) with system-generated calorie/macro targets based on TDEE calculations

**FR14:** Users must be able to log daily body weight and view historical trends via line chart visualization

**FR15:** Users must be able to track hydration (water intake in ml/oz) and sleep (hours) as daily metrics

**FR16:** Users must be able to export all personal data (workouts, nutrition, body metrics) in JSON/CSV format

**FR17:** Users must be able to delete their account and all associated data

**FR18:** System must send push notifications for: workout reminders, streak milestones, and PR achievements

#### Phase 1: Intelligence & Engagement

**FR19:** System must provide ML-driven forecasts for estimated 1RM (e1RM) progression using linear regression on historical workout data (minimum 4 weeks data required)

**FR20:** System must alert users to potential plateaus (defined as <2% strength gain over 3 weeks) and suggest volume adjustments (+10-15% sets/reps)

**FR21:** System must detect unusual training load spikes (>30% volume increase week-over-week) and display injury risk warnings

**FR22:** Users must be able to share PRs and progress photos to a social feed visible to followers

**FR23:** System must implement gamification features: XP (points per workout completion), badges (milestone achievements), and streak tracking (consecutive training days)

**FR24:** Users must be able to participate in time-bound challenges (e.g., "30-day squat challenge") with group leaderboards

**FR25:** Users must be able to interact with an AI chatbot for fitness Q&A using RAG (Retrieval-Augmented Generation) with context from: user's training history, nutrition logs, and verified fitness content database

**FR26:** AI chatbot responses must include citations to source material and display medical disclaimers for injury/health-related queries

#### Phase 2: Marketplace & Commerce

**FR27:** Trainers must be able to create verified profiles (requiring certification upload and admin approval)

**FR28:** Trainers must be able to publish service offerings (training programs, consultation packages) with pricing

**FR29:** Users must be able to browse trainer marketplace with filters (specialization, price, rating)

**FR30:** Trainers must be able to access client dashboards showing workout adherence, nutrition compliance, and progress metrics

**FR31:** Trainers must be able to conduct asynchronous check-ins with clients via in-app messaging and video feedback uploads

**FR32:** System must process trainer-client billing via integrated payment gateway (Stripe) with platform commission (15%)

**FR33:** System must provide a product catalog for fitness gear, apparel, and supplements with search and category filters

**FR34:** System must track affiliate revenue when users purchase products via tracked links

**FR35:** Gym owners and brands must be able to create storefronts with custom branding and product listings

---

### Non-Functional Requirements

#### Platform & Architecture

**NFR1:** The system must support cross-platform deployment (iOS, Android) using Flutter framework

**NFR2:** Backend APIs must be built with FastAPI (Python) following REST principles and OpenAPI specification

**NFR3:** System must use PostgreSQL (via Supabase) as the primary relational database

**NFR4:** System must implement Redis for session management, caching, and background job queues

**NFR5:** System must use Elasticsearch and pgvector for full-text search and semantic embedding storage

**NFR6:** Mobile app must support offline-first architecture for workout logging (sync when connectivity restored)

#### Security & Privacy

**NFR7:** System must encrypt all data at rest (AES-256) and in transit (TLS 1.3)

**NFR8:** System must implement API rate limiting (100 requests/minute per user) to prevent abuse

**NFR9:** Payment processing (FR32) must comply with PCI-DSS standards via certified payment gateway

**NFR10:** System must comply with GDPR-style data privacy controls including: consent management, data portability (FR16), and right to deletion (FR17)

#### Performance & Scalability

**NFR11:** API endpoints for workout logging (FR5) must respond within 500ms at 95th percentile

**NFR12:** Mobile app UI must render workout history and charts within 1 second on mid-range devices

**NFR13:** System architecture must support horizontal scaling to handle 100,000+ concurrent users

**NFR14:** Database queries must be optimized with indexing to maintain <200ms response time for dashboard loads

#### Quality & Operations

**NFR15:** Codebase must maintain minimum 80% unit test coverage for backend services

**NFR16:** System must implement CI/CD pipeline with automated testing and deployment to staging/production environments

**NFR17:** System must integrate error tracking (Sentry) and application monitoring (Datadog/Prometheus) for observability

**NFR18:** AI chatbot responses must enforce strict retrieval requirements (minimum 2 source citations per response) to prevent hallucination

**NFR19:** System must be designed for modular expansion with feature flags to enable/disable Phase 1 and Phase 2 functionality

#### Accessibility

**NFR20:** Mobile app must support accessibility features including: scalable text (up to 200%), screen reader compatibility (iOS VoiceOver, Android TalkBack), and high-contrast mode

---

## User Interface Design Goals

### Overall UX Vision

Pump Fiction's interface should feel like a **high-performance training companion**—powerful yet approachable. The design balances simplicity for beginners with depth for advanced users through progressive disclosure. Visual feedback (animations, progress indicators, celebration moments) reinforces achievement and consistency. The aesthetic should evoke energy, motivation, and athletic excellence without feeling intimidating.

**Core Principles:**
- **Clarity over cleverness:** Workout logging and nutrition tracking must be friction-free with minimal taps
- **Data visualization as motivation:** Charts, trends, and progress comparisons drive engagement
- **Contextual intelligence:** AI-driven insights surface at the right moments (post-workout, during plateaus)
- **Community presence without noise:** Social features enhance rather than distract from personal goals

### Key Interaction Paradigms

**1. Quick-Capture Logging**
- Workout logging via swipe-based rest timer and quick weight/rep entry (large touch targets)
- Food logging via camera barcode scan with one-tap confirmation
- Minimal navigation: Most common actions accessible within 2 taps from home

**2. Progressive Disclosure**
- Beginners see simplified views (basic templates, guided workouts)
- Advanced users unlock analytics (volume tracking, fatigue indices, periodization charts)
- Trainers access additional "Pro Mode" with client management dashboard

**3. Gestural Efficiency**
- Swipe between exercises during active workout
- Long-press for quick actions (edit set, delete entry)
- Pull-to-refresh for feed updates

**4. Celebration Micro-Moments**
- Confetti animation on PR detection
- Streak flame icons growing with consecutive days
- Haptic feedback on milestone achievements

### Core Screens and Views

#### Phase 0: MVP
1. **Onboarding Flow** - Multi-step wizard (goals, experience, equipment, schedule)
2. **Home Dashboard** - Today's workout preview, nutrition summary, quick-action buttons
3. **Active Workout Screen** - Live exercise logging with rest timer, RPE selector, weight history
4. **Workout History** - Calendar view with completed sessions and PR badges
5. **Nutrition Tracker** - Daily food log with macro ring visualization
6. **Food Search/Scanner** - Barcode camera and search interface
7. **Progress Hub** - Weight chart, body measurements, photo timeline
8. **Profile & Settings** - Goal management, notifications, account settings

#### Phase 1: Intelligence & Engagement
9. **Analytics Dashboard** - Strength trends, volume charts, fatigue indicators
10. **Social Feed** - PR posts, progress photos, challenge leaderboards
11. **AI Chat Interface** - Conversational Q&A with context-aware suggestions
12. **Challenge Details** - Event info, leaderboard, participant list

#### Phase 2: Marketplace & Commerce
13. **Trainer Marketplace** - Browse/filter trainers with ratings and specializations
14. **Trainer Profile** - Bio, certifications, services, client testimonials
15. **Client Dashboard (Trainer View)** - Multi-client progress overview with quick check-in access
16. **Product Catalog** - E-commerce browse with cart and checkout

### Accessibility: WCAG AA

- Minimum contrast ratio 4.5:1 for text
- All interactive elements minimum 44x44pt touch targets
- Screen reader labels for all UI controls
- Scalable text up to 200% without layout breaking
- Alternative text for progress charts and images
- Keyboard navigation support (future web version)

### Branding

**Aesthetic:** Modern athletic minimalism with bold typography and dual-mode theming

#### Color Palette

##### Dark Mode (Default)

| Role | Color | Hex | Description |
|------|-------|-----|-------------|
| **Primary** | Black | `#000000` | Dominant background for a sleek, deep interface |
| **Secondary/Accent** | Soft Red | `#FF8383` | Highlights, call-to-actions, and emotional emphasis |
| **Highlight (Brand Primary)** | Deep Electric Blue | `#0066FF` | Represents energy and trust across UI elements |
| **CTA/Accent (Brand Secondary)** | Vibrant Orange | `#FF6B35` | For PRs, celebrations, and interactive prompts |
| **Neutral Background** | Dark Charcoal | `#1A1A1D` | Base neutral tone for cards and containers |
| **Success** | Neon Green | `#39FF14` | Indicates progress, streaks, and achievements |

##### Light Mode

| Role | Color | Hex | Description |
|------|-------|-----|-------------|
| **Primary** | White | `#FFFFFF` | Clean background for high readability and contrast |
| **Secondary/Accent** | Bright Pink | `#FF6079` | For highlights, interactions, and celebratory moments |
| **Highlight (Brand Primary)** | Deep Electric Blue | `#0066FF` | Reinforces trust and brand consistency |
| **CTA/Accent (Brand Secondary)** | Vibrant Orange | `#FF6B35` | Used for action elements like buttons and alerts |
| **Neutral Background** | Light Gray | `#F5F5F5` | Subtle contrast for cards and containers |
| **Success** | Neon Green | `#39FF14` | For positive feedback and success indicators |

**Mode Selection:** System respects user's OS-level dark/light mode preference with manual override in settings

**Typography:**
- **Headers:** Bold sans-serif (e.g., Montserrat Bold) - commanding presence
- **Body:** Clean sans-serif (e.g., Inter) - high legibility

**Motion:**
- Smooth 200-300ms transitions
- Spring animations for success moments
- Subtle parallax on scroll for depth

**Tagline Integration:** "The only fiction is your limits" appears on empty states and motivation screens

### Target Device and Platforms: Mobile-First Cross-Platform

**Primary:** iOS and Android native builds via Flutter
- Optimized for smartphones (4.7" to 6.7" screens)
- Portrait orientation primary, landscape for charts

**Future Consideration:** Web responsive dashboard for trainers (desktop client management)

---

## Technical Assumptions

### Repository Structure: Monorepo

**Decision:** Single repository containing both Flutter mobile app and FastAPI backend

**Rationale:**
- Simplifies dependency management and versioning across frontend/backend
- Enables atomic commits for features spanning both layers
- Facilitates shared tooling (linting, CI/CD, documentation)
- Appropriate for team size and single product focus

**Structure:**
```
pump-fiction/
├── frontend/          # Flutter app
├── backend/         # FastAPI services
├── shared/          # Shared types, contracts
└── infrastructure/  # Docker, CI/CD configs
```

### Service Architecture: Modular Monolith (Backend)

**Decision:** Single FastAPI application with modular domain separation, deployed as monolith initially

**Rationale:**
- **Phase 0-1:** Monolith reduces operational complexity for MVP (single deployment, simpler debugging)
- **Modularity:** Code organized by domain (auth, workouts, nutrition, social, marketplace) to support future extraction into microservices if needed
- **Performance:** No inter-service latency for MVP feature set
- **Scalability:** Can scale horizontally behind load balancer; modular boundaries allow service extraction in Phase 2 if marketplace grows

**Future Path:** Marketplace (FR27-FR35) could become separate microservice in Phase 2 if transaction volume justifies it

### Testing Requirements: Full Testing Pyramid

**Decision:** Comprehensive testing strategy across all layers

**Backend (FastAPI):**
- **Unit tests:** 80%+ coverage for business logic (pytest)
- **Integration tests:** API endpoint tests with test database (pytest + TestClient)
- **E2E tests:** Critical user flows (authentication, workout logging) via API contract tests

**Mobile (Flutter):**
- **Unit tests:** Business logic and state management (dart test)
- **Widget tests:** UI component behavior
- **Integration tests:** Critical flows (onboarding, workout session) on emulators

**Manual Testing:**
- Pre-release checklist for platform-specific features (push notifications, offline sync)
- Beta testing with target users (beginners, trainers) in Phase 0

**CI/CD:** All tests run on every pull request; deployment blocked on failures

### Additional Technical Assumptions and Requests

#### Frontend (Flutter)

**Language & Framework:**
- **Flutter 3.x+** (Dart) for cross-platform mobile development
- **State Management:** Riverpod (reactive, testable, performant)
- **Local Storage:** SQLite (via sqflite) for offline-first workout logging
- **API Client:** Dio with interceptors for auth tokens and error handling
- **Charts:** fl_chart for progress visualizations

**Offline-First Strategy:**
- Workout logging writes to local SQLite immediately
- Background sync queue (work_manager) uploads when connectivity restored
- Conflict resolution: last-write-wins for MVP (user always sees their local data)

#### Backend (FastAPI)

**Language & Framework:**
- **Python 3.11+** with FastAPI (async/await for high concurrency)
- **ORM:** SQLAlchemy 2.0 with async support
- **Validation:** Pydantic v2 for request/response schemas
- **Authentication:** JWT tokens (access + refresh) via python-jose
- **Task Queue:** Celery + Redis for background jobs (ML predictions, notification sends)

**API Design:**
- RESTful endpoints following OpenAPI 3.0 spec
- Versioned URLs (e.g., `/api/v1/workouts`)
- Pagination for list endpoints (limit/offset)
- Standardized error responses with HTTP status codes + error codes

#### Database (Supabase/PostgreSQL)

**Primary Database:**
- **PostgreSQL 15+** via Supabase managed service
- **Extensions:** pgvector (for AI embeddings in Phase 1), pg_trgm (fuzzy search)
- **Connection Pooling:** pgBouncer (via Supabase) for efficient connection management

**Schema Strategy:**
- Normalized relational design for core entities (users, workouts, exercises, meals)
- JSONB columns for flexible metadata (e.g., exercise-specific fields, custom workout notes)
- Soft deletes (deleted_at timestamp) for audit trail and GDPR compliance

#### Caching & Queue (Redis)

**Use Cases:**
- Session storage (JWT refresh tokens)
- API response caching (exercise database, food database lookups)
- Rate limiting counters (NFR8)
- Celery task queue broker

**Deployment:** Redis Cloud free tier (30MB) for MVP, upgrade to dedicated instance in Phase 1

#### Search & AI (Elasticsearch + pgvector)

**Elasticsearch:**
- Food database full-text search (barcode lookup, fuzzy matching)
- Exercise library search with autocomplete
- Trainer marketplace filtering (Phase 2)

**pgvector (Phase 1):**
- Semantic embeddings for AI chatbot RAG retrieval
- Exercise similarity matching (suggest alternatives)

**Embedding Model:** OpenAI text-embedding-3-small (cost-effective, low latency)

#### Third-Party APIs & Services

**MVP (Phase 0):**
- **Authentication:** Supabase Auth (OAuth, email/password)
- **Nutrition Data:** Open Food Facts API (free, barcode scanning)
- **Push Notifications:** Firebase Cloud Messaging (FCM) for both iOS/Android
- **Error Tracking:** Sentry (free tier: 5k events/month)

**Phase 1:**
- **AI Chatbot:** OpenAI GPT-4o-mini for cost-effective RAG responses
- **Image Storage:** Supabase Storage for progress photos, trainer media

**Phase 2:**
- **Payment Processing:** Stripe Connect (marketplace payments with platform fees)
- **Email Service:** SendGrid (transactional emails, newsletters)

#### Deployment & Infrastructure

**MVP Hosting:**
- **Backend:** Railway.app or Render (simple PaaS, free tier available)
- **Database:** Supabase free tier (500MB storage, 2GB bandwidth)
- **Redis:** Redis Cloud free tier
- **Mobile App:** App Store + Google Play beta testing tracks

**CI/CD:**
- **GitHub Actions** for automated testing and deployment
- **Environments:** Development (local), Staging (cloud), Production
- **Mobile:** Fastlane for automated iOS/Android builds and uploads

**Monitoring (Phase 1):**
- Application monitoring: Sentry for errors
- Analytics: Mixpanel or PostHog (self-hosted) for user behavior tracking
- Backend metrics: Prometheus + Grafana (if not using PaaS built-in monitoring)

#### Security Assumptions

- **API Authentication:** JWT bearer tokens (15min access, 7-day refresh)
- **Password Storage:** bcrypt hashing (cost factor 12)
- **HTTPS Only:** All API traffic over TLS 1.3
- **Secrets Management:** Environment variables (never committed to repo)
- **CORS:** Strict origin whitelist (mobile app + future web dashboard)

#### Development Workflow

**Version Control:**
- **Git** with GitHub
- **Branch Strategy:** Feature branches → PR → main (protected)
- **Commit Convention:** Conventional Commits for auto-changelog

**Code Quality:**
- **Backend:** Black (formatting), Ruff (linting), mypy (type checking)
- **Frontend:** Dart formatter, flutter_lints
- **Pre-commit Hooks:** Format and lint checks before commit

---

## Epic List

### Epic 1: Foundation & Authentication
Establish project infrastructure (monorepo setup, CI/CD, core services) and implement complete authentication system with user registration, login, and account management. Delivers a functional app with user accounts and basic navigation shell.

### Epic 2: Workout Core & Logging
Build the complete workout experience including exercise library, workout creation/logging, set tracking with RPE/RIR, rest timers, PR detection, and workout history. Delivers the primary training value proposition.

### Epic 3: Nutrition Tracking & Body Metrics
Implement food logging (barcode scanning, search, manual entry), macro calculation, daily targets, and body metrics tracking (weight, measurements). Delivers the nutrition tracking value proposition.

### Epic 4: Progress Visualization & Onboarding
Create comprehensive progress dashboards (charts, trends, photo timeline), implement guided onboarding flow for new users, and add notifications for reminders and achievements. Polishes the MVP user experience.

### Epic 5: Predictive Intelligence & Analytics *(Phase 1)*
Implement ML-driven features including 1RM forecasting, plateau detection, injury risk warnings, and advanced analytics dashboard. Delivers the AI-powered insights differentiator.

### Epic 6: Social Features & Gamification *(Phase 1)*
Build social feed for PR sharing, implement gamification (XP, badges, streaks, leaderboards), and create challenge system. Drives engagement and retention.

### Epic 7: AI Chatbot & Knowledge Hub *(Phase 1)*
Implement RAG-based AI chatbot with fitness Q&A, context-aware suggestions from user data, citation system, and safety guardrails. Delivers personalized guidance at scale.

### Epic 8: Trainer Marketplace Foundation *(Phase 2)*
Build trainer verification system, marketplace browse/filter, trainer profiles with certifications and services, and booking/inquiry system. Establishes the coaching economy foundation.

### Epic 9: Client Management & Communication *(Phase 2)*
Create trainer-side client dashboards, check-in workflows, messaging system, video feedback uploads, and progress tracking tools. Enables effective remote coaching.

### Epic 10: E-commerce & Payments *(Phase 2)*
Implement payment processing (Stripe Connect), trainer-client billing, product catalog, affiliate tracking, and storefronts for gym owners/brands. Completes the revenue ecosystem.

---

_Note: Detailed user stories with acceptance criteria for all 10 epics are available in the full PRD document. Each epic contains 7-14 stories representing vertical slices of functionality that can be implemented by development teams._

---

## Next Steps

This PRD provides a comprehensive blueprint for building Pump Fiction across three phases:

**Phase 0 (MVP):** Epics 1-4 - Core fitness tracking with authentication, workouts, nutrition, and progress visualization

**Phase 1:** Epics 5-7 - Intelligence layer with ML predictions, social engagement, and AI coaching

**Phase 2:** Epics 8-10 - Marketplace economy with trainer services, client management, and e-commerce

The next steps are to:

1. **Architecture Design:** Work with the architect to translate technical assumptions into detailed system architecture
2. **UX Design:** Collaborate with UX expert to create high-fidelity designs based on UI goals and color system
3. **Epic Prioritization:** Finalize Phase 0 epic sequencing and story breakdown for sprint planning
4. **Team Formation:** Assemble development team (backend, mobile, DevOps) and assign epic ownership
5. **Sprint 0:** Set up infrastructure (monorepo, CI/CD, development environments) per Epic 1 stories

**Estimated Timeline:**
- Phase 0 MVP: 4-6 months (assuming 2-3 person team)
- Phase 1: 3-4 months additional
- Phase 2: 4-6 months additional

**Success Metrics:**
- MVP: 1,000 active users with 60% retention after 30 days
- Phase 1: 10,000 users with 70% retention, 5,000 social interactions/week
- Phase 2: 100 verified trainers, $10K monthly marketplace GMV
