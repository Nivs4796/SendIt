# User App Theme Alignment Design

> **Goal:** Align Flutter user app theme with admin panel's Emerald + Amber glassmorphism design.

**Date:** 2026-01-31

---

## Color Palette

### Primary Colors (Emerald)
| Name | Hex | Usage |
|------|-----|-------|
| Primary | `#10B981` | Main actions, buttons, links |
| Primary Light | `#34D399` | Hover states, highlights |
| Primary Dark | `#059669` | Pressed states |

### Accent Colors (Amber)
| Name | Hex | Usage |
|------|-----|-------|
| Accent | `#F59E0B` | Secondary actions, highlights |
| Accent Light | `#FBBF24` | Badges, notifications |

### Secondary Colors (Slate)
| Name | Hex | Usage |
|------|-----|-------|
| Secondary | `#F1F5F9` | Backgrounds, muted areas |
| Secondary Dark | `#1E293B` | Dark text on light bg |

### Semantic Colors
| Name | Hex | Usage |
|------|-----|-------|
| Success | `#10B981` | Success states |
| Warning | `#F59E0B` | Warning states |
| Error | `#EF4444` | Error states |
| Info | `#3B82F6` | Info states |

### Text Colors
| Name | Hex | Usage |
|------|-----|-------|
| Text Primary | `#0F172A` | Main text |
| Text Secondary | `#64748B` | Secondary text |
| Text Hint | `#94A3B8` | Placeholder text |
| Text Disabled | `#CBD5E1` | Disabled text |

### Background Colors
| Name | Hex | Usage |
|------|-----|-------|
| Background | `#ECFDF5` | Main background (mint tint) |
| Surface | `#FFFFFF` | Cards, dialogs |
| Surface Variant | `#F8FAFC` | Alternate surfaces |

### Border Colors
| Name | Value | Usage |
|------|-------|-------|
| Border | `#10B981` @ 40% | Default borders |
| Border Light | `#10B981` @ 20% | Subtle borders |

---

## Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| Small | 12px | Chips, badges, small buttons |
| Medium | 16px | Inputs, standard buttons |
| Large | 20px | Cards, dialogs |
| XLarge | 24px | Bottom sheets, modals |
| Full | 9999px | Pills, avatars |

---

## Shadows

### Light Mode Shadows
```dart
shadowSmall:  BoxShadow(
  color: Color(0x1410B981), // 8% opacity
  blurRadius: 8,
  offset: Offset(0, 2),
)

shadowMedium: BoxShadow(
  color: Color(0x1F10B981), // 12% opacity
  blurRadius: 16,
  offset: Offset(0, 4),
)

shadowLarge: BoxShadow(
  color: Color(0x2610B981), // 15% opacity
  blurRadius: 24,
  offset: Offset(0, 8),
)

cardShadow: [
  BoxShadow(
    color: Color(0x0F000000), // 6% black
    blurRadius: 24,
    offset: Offset(0, 4),
  ),
  BoxShadow(
    color: Color(0x1A10B981), // 10% emerald
    blurRadius: 8,
    offset: Offset(0, 2),
  ),
]
```

---

## Component Styling

### Buttons
- **Height:** 48-52px
- **Radius:** 16px (medium)
- **Primary:** Emerald bg, white text, shadow
- **Outlined:** Emerald 30% border, emerald text
- **Ghost:** Transparent, emerald text, hover emerald 10% bg

### Input Fields
- **Height:** 52px
- **Radius:** 16px
- **Background:** White 90% opacity
- **Border:** Emerald 40% opacity
- **Focus:** Solid emerald border with 15% glow ring

### Cards
- **Radius:** 24px
- **Background:** White 95% opacity
- **Border:** Emerald 20% opacity
- **Shadow:** Card shadow (emerald-tinted)

---

## Files to Update

1. `lib/app/core/theme/app_colors.dart` - Full color palette update
2. `lib/app/core/theme/app_theme.dart` - Theme configuration update
3. `lib/app/core/theme/app_shadows.dart` - New shadow definitions
4. `lib/app/core/theme/app_text_styles.dart` - Minor color updates

---

## Font

**Keep Poppins** via Google Fonts - already configured, works well on mobile.
