# Skill Agents & Platform Standards - Index

## 📚 Overview

This directory contains expert skill agent profiles for each platform component and universal development rules to ensure consistency across the SendIt platform.

---

## 🎯 Skill Agents (Platform Experts)

Each skill agent represents a **10+ years experienced expert** with deep specialization in their respective platform. They define coding standards, architecture principles, best practices, and code review checklists.

### 1. [Website Expert](file:///website-expert.md) 🌐
**Alex Martinez** - Senior Frontend Developer & SEO Specialist

**Expertise:**
- Next.js 14+, TypeScript, Tailwind CSS
- SEO optimization & Core Web Vitals
- Performance optimization
- Conversion rate optimization

**Key Standards:**
- Server Components by default
- Image optimization with next/image
- SEO metadata on all pages
- Lighthouse score > 90

**Use Case:** Building marketing website (Week 1-2)

---

### 2. [Admin Dashboard Expert](file:///admin-dashboard-expert.md) 🎛️
**Sarah Chen** - Full-Stack Admin Systems Architect

**Expertise:**
- Next.js with Shadcn UI
- Complex data tables (TanStack Table)
- Real-time dashboards (Socket.io)
- Role-Based Access Control (RBAC)
- Server Actions

**Key Standards:**
- Permission-based rendering
- Server-side pagination
- Optimistic UI updates
- Security-first approach

**Use Case:** Building admin dashboard (Week 3-5)

---

### 3. [Backend API Expert](file:///backend-api-expert.md) ⚙️
**Michael Rodriguez** - Senior Backend Architect & Database Specialist

**Expertise:**
- Node.js + Express + TypeScript
- PostgreSQL with Prisma ORM
- Redis caching & queues
- Clean Architecture
- Microservices patterns

**Key Standards:**
- Layered architecture (Controller → Service → Repository)
- Database transactions
- Background jobs (Bull Queue)
- 80% test coverage

**Use Case:** Building backend API (Week 6-11)

---

### 4. [Flutter Mobile Expert](file:///flutter-mobile-expert.md) 📱
**Priya Patel** - Senior Mobile Application Architect

**Expertise:**
- Flutter 3.16+, Dart 3.0+
- Riverpod state management
- Clean Architecture
- Google Maps, FCM, real-time
- iOS & Android best practices

**Key Standards:**
- Feature-first folder structure
- Immutable state
- 60 FPS animations
- 70% test coverage

**Use Case:** Building mobile apps (Week 12-15)

---

## 📋 Universal Rules & Standards

### [RULES.md](file:///../RULES.md) - **Master Standards Document**

Defines **cross-platform alignment** and **mandatory standards** for:

#### 🔗 API Contract Enforcement
- Identical request/response formats across all platforms
- Standard error codes
- Consistent date/time handling

#### 📐 Naming Conventions
- **Database:** `snake_case`
- **Backend:** `camelCase` (functions), `PascalCase` (classes)
- **Frontend:** `PascalCase` (components), `camelCase` (props)
- **Mobile:** `snake_case` (files), `PascalCase` (classes)

#### 🎨 Standard Values
- Order statuses: `pending`, `assigned`, `picked_up`, `in_transit`, `delivered`, `cancelled`
- Vehicle types: `bike`, `auto`, `mini_truck`, `ev_cycle`
- Payment methods: `wallet`, `card`, `upi`, `cash`

#### 🔐 Security Standards
- JWT token structure
- bcrypt password hashing (12 rounds)
- Input validation (client + server)
- No secrets in code

#### 📊 Data Format Standards
- ISO 8601 for dates
- Decimal for currency
- Formatted phone numbers

#### 🧪 Testing Requirements
- Backend: 80% coverage
- Frontend: 70% coverage
- Mobile: 70% coverage

---

## 🎯 How to Use These Documents

### For Developers

1. **Before starting work on a platform:**
   - Read the relevant skill agent document
   - Understand coding standards
   - Review architecture principles

2. **During development:**
   - Follow naming conventions from RULES.md
   - Use code examples from skill agent docs
   - Check API alignment requirements

3. **Before submitting PR:**
   - Run through code review checklist
   - Verify cross-platform consistency
   - Ensure tests pass

### For Code Reviewers

1. **Verify Standards:**
   - Check naming conventions (RULES.md)
   - Validate API contract alignment
   - Confirm security practices

2. **Platform-Specific:**
   - Use skill agent checklist
   - Verify architecture pattern
   - Check performance standards

3. **Cross-Platform:**
   - Ensure error codes match
   - Validate data formats
   - Check type consistency

---

## 📊 Skills Matrix

| Platform | Expert | Primary Framework | State Management | Testing | Experience |
|----------|--------|-------------------|------------------|---------|------------|
| **Website** | Alex Martinez | Next.js 14+ | React Context | Playwright | 10+ years |
| **Admin Dashboard** | Sarah Chen | Next.js 14+ | Zustand + React Query | Jest + Playwright | 10+ years |
| **Backend API** | Michael Rodriguez | Node.js + Express | N/A | Jest + Supertest | 10+ years |
| **Mobile Apps** | Priya Patel | Flutter 3.16+ | Riverpod | Widget + Integration | 10+ years |

---

## ✅ Alignment Checklist

Use this before any major feature implementation:

### API Changes
- [ ] Backend API updated
- [ ] Admin dashboard client updated
- [ ] Mobile app models updated
- [ ] Error codes documented
- [ ] All platforms tested

### Database Changes
- [ ] Migration created
- [ ] Indexes added
- [ ] Seed data updated
- [ ] Backed up (production)

### New Feature
- [ ] Planned in all relevant platforms
- [ ] API contracts defined
- [ ] UI/UX mocks approved
- [ ] Error scenarios documented
- [ ] Tests planned

---

## 🚀 Quick Reference

### Need to implement a feature?

1. **Check RULES.md** for standards
2. **Read relevant skill agent** for best practices
3. **Follow architecture pattern** from expert doc
4. **Use code examples** as templates
5. **Run through checklist** before PR

### Common Questions

**Q: How should I name this variable/function?**  
A: Check RULES.md → Naming Conventions section

**Q: How do I structure my API response?**  
A: Check backend-api-expert.md → Error Handling section + RULES.md → Error Handling

**Q: What state management should I use?**  
A: 
- Website: React Context (simple), Zustand (complex)
- Admin Dashboard: Zustand + React Query
- Mobile: Riverpod

**Q: How do I handle errors?**  
A: All platforms use standardized error format from RULES.md

---

## 📝 Document Versions

| Document | Version | Last Updated | Status |
|----------|---------|--------------|--------|
| website-expert.md | 1.0 | 2026-01-29 | Active |
| admin-dashboard-expert.md | 1.0 | 2026-01-29 | Active |
| backend-api-expert.md | 1.0 | 2026-01-29 | Active |
| flutter-mobile-expert.md | 1.0 | 2026-01-29 | Active |
| RULES.md | 1.0 | 2026-01-29 | **MANDATORY** |

---

## 🎓 Learning Path

### New to the Project?

**Week 1: Foundation**
1. Read RULES.md (1 hour)
2. Skim all skill agent docs (2 hours)
3. Review platform-flows.md (1 hour)

**Week 2: Deep Dive**
1. Deep dive into your platform's skill agent doc
2. Study code examples
3. Practice with starter tasks

**Week 3: Contribution**
1. Pick a small feature
2. Follow architecture patterns
3. Submit first PR using checklists

---

## 📞 Support

**Questions about:**
- **Standards:** Refer to RULES.md
- **Platform specifics:** Check skill agent docs
- **Architecture:** Review implementation_plan.md
- **Flows:** See platform-flows.md

**Still stuck?**
- Open a discussion in GitHub
- Ask in #dev-help Slack channel
- Tag the relevant platform expert

---

**Remember:**
> "These are not suggestions. These are the standards that make our platform consistent, secure, and maintainable. Follow them precisely."

**Status:** 🟢 Active & Enforced  
**Compliance:** Mandatory for all PRs  
**Last Review:** 2026-01-29
