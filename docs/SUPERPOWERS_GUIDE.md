# Claude Code Superpowers - Development Workflow

## 📋 Overview

This document explains how to use **Claude Code Superpowers** to accelerate development on the SendIt platform. Superpowers provide structured workflows for brainstorming, planning, and executing complex development tasks.

**GitHub Repository:** https://github.com/obra/superpowers

---

## 🚀 Available Superpowers

### 1. `/superpowers:brainstorm` - Interactive Design Refinement

**Use Case:** Refine ideas, explore alternatives, and design solutions collaboratively

**When to Use:**
- Designing a new feature architecture
- Solving complex technical challenges
- Exploring UX alternatives
- Database schema design
- API endpoint planning

**Example Scenarios:**

#### Scenario 1: Driver Matching Algorithm Design
```
/superpowers:brainstorm

I need to design the driver matching algorithm for our delivery platform.

Requirements:
- Match drivers within 5km radius
- Consider driver rating, vehicle type
- Handle multiple simultaneous requests
- Implement timeout (30s per driver)
- Fall back if no driver accepts

Current approach ideas:
1. Sequential matching (one driver at a time)
2. Broadcast to all (first to accept wins)
3. Priority queue based on rating + distance

What's the best approach considering scalability and user experience?
```

#### Scenario 2: Order Tracking UI Design
```
/superpowers:brainstorm

Designing the real-time order tracking screen for user app.

User needs to see:
- Current driver location (updates every 5s)
- ETA
- Driver details (name, photo, rating, phone)
- Order status timeline
- Contact options (call/chat)

Constraints:
- Must work offline (show last known location)
- Battery efficient
- Smooth animations

What UI pattern and state management approach should we use with GetX?
```

---

### 2. `/superpowers:write-plan` - Create Implementation Plan

**Use Case:** Generate detailed, step-by-step implementation plans for features or modules

**When to Use:**
- Starting a new feature
- Breaking down complex epics
- Planning refactoring work
- Database migration planning
- Integration of third-party services

**Example Scenarios:**

#### Scenario 1: Implement Wallet System
```
/superpowers:write-plan

Feature: User Wallet System

Requirements:
- Users can add money to wallet (Razorpay)
- Deduct from wallet on order creation
- Transaction history
- Withdrawal not allowed (credit only)
- Show balance on all relevant screens

Tech Stack:
- Backend: Node.js + PostgreSQL
- Frontend: Next.js (Admin), Flutter (User app)
- Payment: Razorpay

Please create a detailed implementation plan including:
1. Database schema changes
2. Backend API endpoints
3. Payment integration steps
4. Frontend implementation
5. Testing strategy
```

#### Scenario 2: Implement Real-Time Tracking
```
/superpowers:write-plan

Feature: Real-Time Order Tracking with Driver Location

Requirements:
- Pilot app sends location every 5s when job active
- User app receives live location updates
- Show driver on map with smooth animation
- Handle disconnections gracefully
- Store last known location

Tech Stack:
- Backend: Socket.io + Redis
- Mobile: Flutter + GetX + Google Maps

Generate implementation plan covering:
1. Socket.io setup on backend
2. Location service on pilot app
3. Map implementation on user app
4. State management with GetX
5. Error handling & offline support
```

---

### 3. `/superpowers:execute-plan` - Execute Plan in Batches

**Use Case:** Execute implementation plans step-by-step with validation between batches

**When to Use:**
- Implementing feature from approved plan
- Database migrations in stages
- Multi-platform feature rollout
- Complex refactoring

**Example Scenarios:**

#### Scenario 1: Execute Wallet Implementation
```
/superpowers:execute-plan

Execute the wallet system implementation plan in batches.

Plan File: docs/planning/wallet-feature-plan.md

Batch Size: 3 steps at a time

Validation: After each batch, I'll review and test before proceeding

Platform Order: Backend → Admin Dashboard → Mobile App

Start with:
1. Database schema creation
2. Backend API endpoints
3. Razorpay integration
```

#### Scenario 2: Execute Multi-Platform Feature
```
/superpowers:execute-plan

Feature: Push Notifications

Execute in platform order:
1. Backend (FCM integration, notification APIs)
2. Mobile (FCM setup, notification handlers)
3. Admin Dashboard (send notifications UI)

Plan: docs/planning/notifications-plan.md

Pause for testing after each platform before moving to next
```

---

## 🎯 Workflow: From Idea to Implementation

### Step 1: Brainstorm & Design
```
/superpowers:brainstorm

Feature idea or problem description...
```

**Output:**
- Refined design
- Alternative approaches discussed
- Recommended solution
- Potential challenges identified

### Step 2: Create Implementation Plan
```
/superpowers:write-plan

Detailed feature requirements based on brainstorming...
```

**Output:**
- Step-by-step implementation plan
- File structure
- Code scaffolding
- Testing checklist

### Step 3: Execute in Batches
```
/superpowers:execute-plan

Reference to the plan created in Step 2...
Specify batch size and validation points
```

**Output:**
- Code implementation
- Tests
- Documentation
- Validation checkpoints

---

## 📚 Best Practices

### 1. **Start with Brainstorm for Complex Features**

✅ **Good:**
```
/superpowers:brainstorm

I need to implement surge pricing. Current thoughts:
- Zone-based (define high-demand zones)
- Demand/supply ratio (orders vs available drivers)
- Time-based (peak hours)

Which approach or combination works best?
```

❌ **Bad:**
```
Implement surge pricing
```

### 2. **Be Specific in Plans**

✅ **Good:**
```
/superpowers:write-plan

Feature: Coupon System

Requirements:
- Admin creates coupons (flat discount, percentage, first-order only)
- Users apply at checkout
- Validate: active, not expired, usage limit
- Track usage per user

Output needed:
- Database tables
- API endpoints (CRUD + validate)
- Admin UI screens
- Mobile app integration
```

❌ **Bad:**
```
Create a coupon system
```

### 3. **Execute in Logical Batches**

✅ **Good Batch Order:**
```
Batch 1: Database + Backend API
Batch 2: Admin Dashboard Integration
Batch 3: Mobile App Integration
Batch 4: Testing & Bug Fixes
```

❌ **Bad Batch Order:**
```
Batch 1: Mobile app UI
Batch 2: Backend API (app can't work without this!)
```

---

## 🛠️ Platform-Specific Examples

### Backend API Development

```
/superpowers:brainstorm

Designing order status state machine for backend.

States: pending → searching_driver → assigned → picked_up → in_transit → delivered
Also need: cancelled, no_driver_found

Questions:
- Which states can transition to cancelled?
- How to handle driver cancellation vs user cancellation?
- When to charge cancellation fees?

Database implications?
```

### Admin Dashboard

```
/superpowers:write-plan

Feature: Real-Time Order Monitoring Dashboard

Requirements:
- Kanban board view (columns by status)
- Real-time updates via Socket.io
- Click order to see details
- Manual driver reassignment
- Order filtering & search

Tech: Next.js, Shadcn UI, TanStack Table, Socket.io client

Plan needed for:
- Component structure
- Real-time connection setup
- State management (Zustand)
- API integration
```

### Mobile App (Flutter + GetX)

```
/superpowers:write-plan

Feature: Order Tracking Screen (Flutter)

Requirements:
- Google Maps with driver marker
- Driver info card (swipeable)
- ETA countdown
- Live location updates
- Call/Chat driver buttons
- Order status timeline

Tech: Flutter, GetX, Google Maps Flutter, Socket.io

Cover:
- GetX controller structure
- Socket.io integration
- Map implementation
- State management
```

---

## 📋 Templates

### Brainstorming Template

```
/superpowers:brainstorm

[Feature/Problem Name]

Context:
- Current situation
- Pain points
- User needs

Requirements:
- Must have
- Nice to have
- Constraints

Initial Ideas:
- Option 1: [description]
- Option 2: [description]
- Option 3: [description]

Questions:
1. [Specific question]
2. [Specific question]

Tech Stack Considerations:
- Platform: [Web/Mobile/Backend]
- Current tools: [List]
```

### Planning Template

```
/superpowers:write-plan

Feature: [Name]

User Story:
As a [user type], I want to [action] so that [benefit]

Acceptance Criteria:
1. [Criterion 1]
2. [Criterion 2]
3. [Criterion 3]

Technical Requirements:
- Platform: [Backend/Admin/User App/Pilot App]
- Tech Stack: [Specific technologies]
- Dependencies: [External services, other features]

Deliverables:
- [ ] Database changes
- [ ] API endpoints
- [ ] UI components
- [ ] Tests
- [ ] Documentation

Plan Structure Needed:
1. Database schema
2. Backend implementation
3. Frontend implementation
4. Integration points
5. Testing approach
6. Deployment steps
```

### Execution Template

```
/superpowers:execute-plan

Plan Location: [path/to/plan.md]

Batch Strategy:
- Batch 1: [Steps 1-3]
- Batch 2: [Steps 4-6]
- Batch 3: [Steps 7-9]

Validation Points:
- After Batch 1: [What to test]
- After Batch 2: [What to test]
- After Batch 3: [What to test]

Platform Order: [Backend → Admin → Mobile]

Special Considerations:
- [Note 1]
- [Note 2]
```

---

## 🎓 Learning Path

### Week 1: Start Simple
1. Use brainstorm for design decisions
2. Write plans for small features
3. Execute 1-2 features end-to-end

### Week 2: Complex Features
1. Brainstorm multi-platform features
2. Create comprehensive plans
3. Execute in batches with validations

### Week 3: Full Workflows
1. Complete feature from idea to deployment
2. Use all three superpowers in sequence
3. Document learnings

---

## 📊 Success Metrics

**Good Indicator:**
- ✅ Plan is clear and actionable
- ✅ All edge cases covered
- ✅ Implementation follows plan closely
- ✅ Minimal rework needed
- ✅ Code review comments minimal

**Needs Improvement:**
- ❌ Plan too vague
- ❌ Missing error cases
- ❌ Implementation deviates significantly
- ❌ Multiple iterations required
- ❌ Major bugs found in testing

---

## 🔗 Integration with Project Docs

### Reference Existing Plans

Point superpowers to existing documentation:

```
/superpowers:brainstorm

Refining the driver matching algorithm.

Current design: docs/planning/business-logic-algorithms.md (section 1)

Issues identified:
1. Timeout too short
2. No fallback for busy areas
3. Battery drain from frequent location updates

How can we improve this?
```

### Update Documentation

After using superpowers:

```
/superpowers:write-plan

Update docs/planning/backend-api-plan.md with new wallet endpoints

Current doc has orders, users, pilots APIs.
Need to add wallet section with same structure.
```

---

## ⚠️ Important Notes

1. **Always validate after batches** - Don't rush through execution
2. **Reference existing docs** - Use skill-agents, RULES.md, planning docs
3. **Follow standards** - All code must align with RULES.md
4. **Test thoroughly** - Each batch should be tested before moving on
5. **Update docs** - Keep planning documents in sync

---

## 🚀 Quick Start

**First Time Using Superpowers?**

1. Pick a small feature (e.g., "Add profile picture upload")
2. Start with brainstorm to explore approaches
3. Write a detailed plan
4. Execute in 2-3 batches
5. Review and iterate

**Example End-to-End:**

```bash
# Step 1: Brainstorm
/superpowers:brainstorm
Feature: Add profile picture upload for users
Current: No way to upload profile picture
Need: S3 upload + API + Frontend integration
Question: Client-side resize or server-side?

# Step 2: Plan (after brainstorm concludes)
/superpowers:write-plan
Based on brainstorm, implement profile picture upload
Backend: S3 upload endpoint + update user profile
Frontend: Image picker + upload UI
Mobile: Same implementation

# Step 3: Execute (after plan approved)
/superpowers:execute-plan
Plan: [generated plan from step 2]
Batch 1: S3 setup + Backend API
Batch 2: Admin Dashboard UI
Batch 3: Mobile App (User + Pilot)
```

---

**Remember:** Superpowers are tools to enhance productivity. They work best when combined with clear requirements and thorough validation! 🚀

**Status:** Active  
**Last Updated:** 2026-01-29  
**Maintained By:** Development Team
