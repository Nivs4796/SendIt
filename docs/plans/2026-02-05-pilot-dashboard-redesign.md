# Pilot App Dashboard Redesign

> **Design Document** - Minimal Dark Theme Dashboard

## Overview

Redesign the pilot app dashboard from a cluttered 6-section layout to a minimal, professional interface inspired by Uber Driver app.

**Goals:**
- Reduce visual clutter
- Professional dark theme with single accent color
- Clear information hierarchy
- Focus on primary action (going online)

---

## Design Decisions

### Priority Hierarchy
1. **Online/Offline Toggle** - Hero element, dominates screen
2. **Active Job Card** - Takes over when delivery in progress
3. **Earnings Display** - Simple, non-duplicated

### Removed from Dashboard
- Vehicle Card → Menu
- Quick Actions Grid → Bottom Nav + Menu
- Performance Stats (Today/Week tabs) → Earnings screen
- Header stats row → Removed (duplicate)

---

## Color Palette

| Element | Color | Hex Code |
|---------|-------|----------|
| Background | Deep Slate | `#0F172A` |
| Surface/Cards | Slate 800 | `#1E293B` |
| Card Border | Slate 700 | `#334155` |
| Primary Accent | Emerald | `#10B981` |
| Text Primary | White | `#F8FAFC` |
| Text Secondary | Slate 400 | `#94A3B8` |
| Online Glow | Emerald 20% | `#10B98133` |

### Styling Rules
1. **No gradients** - Solid colors only
2. **Subtle borders** - 1px slate borders instead of shadows
3. **Single accent** - Emerald ONLY for: online state, primary buttons, active indicators
4. **Large typography** - Bigger text, more whitespace
5. **Rounded corners** - 16px for cards, 50% for toggle button

---

## Layout Specifications

### State 1: Offline / Online (No Active Job)

```
┌─────────────────────────────────────┐
│                                     │
│  SendIt                      [≡]    │  ← Minimal header (logo + menu)
│                                     │
├─────────────────────────────────────┤
│                                     │
│                                     │
│       ┌───────────────────┐         │
│       │                   │         │
│       │                   │         │
│       │    ◉ GO ONLINE    │         │  ← Hero toggle button
│       │                   │         │   - 200px height
│       │   Tap to start    │         │   - Centered on screen
│       │     earning       │         │
│       │                   │         │
│       └───────────────────┘         │
│                                     │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  Today's Earnings                   │
│  ₹ 980                   12 trips   │  ← Simple stats bar
│                                     │
├─────────────────────────────────────┤
│                                     │
│  💡 Tip: Peak hours are 12-2 PM    │  ← Optional tips/empty state
│                                     │
└─────────────────────────────────────┘
│  Home  │ Earnings│ History│  Menu  │  ← Bottom navigation
└────────┴─────────┴────────┴────────┘
```

### State 2: Online with Active Job

```
┌─────────────────────────────────────┐
│                                     │
│  ● ONLINE                    [≡]    │  ← Small status dot + menu
│                                     │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐    │
│  │ ▌ ACTIVE DELIVERY          │    │  ← Emerald left border (4px)
│  │ ▌                          │    │
│  │ ▌ ●━━━━━━━━●━━━━━━━━○      │    │  ← Progress stepper
│  │ ▌ Pickup   In Transit  Drop│    │
│  │ ▌                          │    │
│  │ ▌ Drop Location            │    │
│  │ ▌ 📍 123 Main Street,      │    │
│  │ ▌    Satellite, Ahmedabad  │    │
│  │ ▌                          │    │
│  │ ▌ ┌─────────────────────┐  │    │
│  │ ▌ │     NAVIGATE        │  │    │  ← Primary action button
│  │ ▌ └─────────────────────┘  │    │
│  │ ▌                          │    │
│  │ ▌ ┌─────────────────────┐  │    │
│  │ ▌ │   UPDATE STATUS     │  │    │  ← Secondary action
│  │ ▌ └─────────────────────┘  │    │
│  └─────────────────────────────┘    │
├─────────────────────────────────────┤
│  Today: ₹980         Trips: 12     │  ← Compact stats
└─────────────────────────────────────┘
│  Home  │ Earnings│ History│  Menu  │
└────────┴─────────┴────────┴────────┘
```

---

## Component Specifications

### 1. Online Toggle Button

**Offline State:**
- Background: `#1E293B` (Slate 800)
- Border: 1px `#334155` (Slate 700)
- Text: "GO ONLINE" - White, 24px, bold
- Subtext: "Tap to start earning" - `#94A3B8`, 14px
- Icon: Power icon, white, 32px
- Size: Full width - 32px padding, 200px height
- Border radius: 24px

**Online State:**
- Background: `#10B981` (Emerald)
- Box shadow: 0 0 40px `#10B98133` (glow effect)
- Text: "ONLINE" - White, 24px, bold
- Subtext: "Accepting deliveries" - White 80%, 14px
- Icon: Pulse animation circle
- Size: Same as offline

### 2. Active Job Card

- Background: `#1E293B`
- Left border: 4px `#10B981`
- Border radius: 16px
- Padding: 20px
- No shadows, no gradients

**Contents:**
- Title: "ACTIVE DELIVERY" - White, 16px, semibold
- Progress stepper: Horizontal dots with emerald active state
- Address: White, 14px
- Navigate button: Emerald background, white text, full width
- Update Status button: Transparent with emerald border

### 3. Earnings Bar

- Background: `#1E293B`
- Padding: 16px 20px
- Layout: Row with space-between

**Left side:**
- Label: "Today's Earnings" - `#94A3B8`, 12px
- Value: "₹ 980" - White, 24px, bold

**Right side:**
- Label: "Trips" - `#94A3B8`, 12px
- Value: "12" - White, 24px, bold

### 4. Bottom Navigation

- Background: `#1E293B`
- Height: 64px
- Border top: 1px `#334155`
- 4 items: Home, Earnings, History, Menu
- Active: Emerald icon + text
- Inactive: `#94A3B8` icon + text

### 5. Header

- Background: Transparent (shows `#0F172A`)
- Height: 56px
- Padding: 16px 20px
- Left: "SendIt" logo or text (White)
- Right: Menu icon (hamburger), white
- When online: Small emerald dot indicator before "ONLINE" text

---

## Navigation Structure

### Bottom Navigation
| Tab | Icon | Screen |
|-----|------|--------|
| Home | Home icon | Dashboard (this design) |
| Earnings | Chart icon | Detailed earnings with charts |
| History | List icon | Past deliveries |
| Menu | Hamburger | Profile & settings |

### Menu Screen Items
1. **Profile** - Photo, name, phone, rating
2. **My Vehicle** - Current vehicle, switch option
3. **Wallet** - Balance, transactions
4. **Rewards** - Points, achievements
5. **Documents** - KYC, license status
6. **Support** - Help, contact
7. **Settings** - Notifications, language, theme
8. **Logout**

---

## Files to Modify

### Theme & Colors
- `pilot_app/lib/app/core/theme/app_colors.dart` - Update color scheme
- `pilot_app/lib/app/core/theme/app_theme.dart` - Update theme data

### Dashboard
- `pilot_app/lib/app/modules/home/views/home_view.dart` - Complete rewrite
- `pilot_app/lib/app/modules/home/controllers/home_controller.dart` - Simplify state

### New Components
- `pilot_app/lib/app/core/widgets/online_toggle_button.dart` - New hero toggle
- `pilot_app/lib/app/core/widgets/active_job_card.dart` - New minimal job card
- `pilot_app/lib/app/core/widgets/earnings_bar.dart` - Simple stats bar
- `pilot_app/lib/app/core/widgets/bottom_nav_bar.dart` - New bottom navigation

### Navigation
- `pilot_app/lib/app/routes/app_pages.dart` - Add bottom nav routes
- `pilot_app/lib/app/modules/menu/` - New menu screen

---

## Implementation Order

1. **Phase 1: Theme Update**
   - Update `app_colors.dart` with new palette
   - Update `app_theme.dart` with dark theme defaults

2. **Phase 2: New Components**
   - Create `OnlineToggleButton` widget
   - Create `ActiveJobCard` widget
   - Create `EarningsBar` widget
   - Create `BottomNavBar` widget

3. **Phase 3: Dashboard Rewrite**
   - Rewrite `home_view.dart` with new layout
   - Simplify `home_controller.dart`

4. **Phase 4: Navigation**
   - Add bottom navigation shell
   - Create Menu screen
   - Move Vehicle, Wallet, Rewards to menu

---

## Success Criteria

- [ ] Dashboard has max 3 visual elements (toggle, job card, earnings)
- [ ] Only emerald accent color used (no orange, no gradients)
- [ ] Online toggle is hero element (60%+ of screen when no job)
- [ ] Active job card uses minimal styling (dark + emerald border)
- [ ] Bottom navigation implemented with 4 tabs
- [ ] Menu contains: Profile, Vehicle, Wallet, Rewards, Documents, Support, Settings

---

*Design approved: February 5, 2026*
