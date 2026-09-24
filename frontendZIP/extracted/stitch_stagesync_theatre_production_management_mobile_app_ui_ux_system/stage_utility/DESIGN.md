---
name: Stage Utility
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#574144'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#8a7174'
  outline-variant: '#debfc2'
  surface-tint: '#aa304f'
  primary: '#640023'
  on-primary: '#ffffff'
  primary-container: '#881337'
  on-primary-container: '#ff93a6'
  inverse-primary: '#ffb2bd'
  secondary: '#904d00'
  on-secondary: '#ffffff'
  secondary-container: '#fe932c'
  on-secondary-container: '#663500'
  tertiary: '#223042'
  on-tertiary: '#ffffff'
  tertiary-container: '#384659'
  on-tertiary-container: '#a5b4cb'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffd9dd'
  primary-fixed-dim: '#ffb2bd'
  on-primary-fixed: '#400014'
  on-primary-fixed-variant: '#8a1538'
  secondary-fixed: '#ffdcc3'
  secondary-fixed-dim: '#ffb77d'
  on-secondary-fixed: '#2f1500'
  on-secondary-fixed-variant: '#6e3900'
  tertiary-fixed: '#d5e3fc'
  tertiary-fixed-dim: '#b9c7df'
  on-tertiary-fixed: '#0d1c2e'
  on-tertiary-fixed-variant: '#3a485b'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
typography:
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  title-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.03em
  metadata-code:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.04em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-sm: 0.75rem
  margin: 1rem
  margin-tablet: 1.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
---

## Brand & Style

This design system is engineered specifically for mobile-first theatre management, rehearsal operations, and technical stage administration. Rather than adopting the playful, neon-lit vernacular of consumer entertainment apps, the aesthetic draws from backstage discipline, callboards, and classical production bibles: calm, hyper-organized, authoritative, and tactfully quiet.

The style unites **Minimalist Utility** with **Tonal Structural Precision**:
- High-density information delivery without visual congestion.
- Strict suppression of neon or hyper-saturated hues in favor of subdued, ink-like dignity.
- Deliberate hierarchy that allows stage managers, technical directors, and cast members to parse urgent schedules, venue notes, and cast calls at a glance under backstage or daylight lighting conditions.

## Colors

The palette relies on an architectural balance of neutral slate surfaces and restrained theatrical accents:

- **Primary (`#881337`)**: Deep Theatrical Velvet Crimson. Used sparingly for critical forward actions, active primary navigation icons, and essential interactive anchors. It represents authority and operational readiness without screaming.
- **Secondary (`#D97706`)**: Stage Warm Amber. Dedicated to callboard bulletins, pending audition confirmations, and standby notices.
- **Tertiary (`#475569`)**: Calm Slate Blue. Anchors secondary structural elements, passive iconography, and non-urgent category tags.
- **Neutral (`#0F172A`)**: Deep Charcoal Slate. Establishes unambiguous contrast against pale backgrounds for all high-priority typographic data.

### Functional & State Tones
- **Canvas Base**: `#F8F9FA` with structural content sections resting on `#F1F5F9`.
- **Card & Sheet Surface**: Pure `#FFFFFF`.
- **Dividers & Structural Borders**: Hairline `#E2E8F0`.
- **Muted Text / Secondary Data**: `#64748B`.
- **Conflict / Error Alert**: Subdued Crimson `#B91C1C` paired with an ultra-light tint `#FEF2F2`.
- **Schedule Overlap / Warning**: Rust Amber `#C2410C` paired with `#FFFBEB`.
- **Affirmation / Completed Cue**: Low-chroma Olive Slate `#15803D`.

## Typography

The type system blends the structural poise of **Plus Jakarta Sans** for display sections and view headers with the micro-legibility of **Inter** for dense scheduling data, cue timings, call lists, and utility labels.

- Numeric figures across times, rehearsal counts, and cue identifiers must always use tabular figure settings (`font-variant-numeric: tabular-nums`) to preserve vertical alignment across timeline columns.
- Section titles and modal headers rely on medium-to-semibold weights, avoiding aggressive bold weights that degrade rapid scanning.
- Metadata and tracking indicators employ subtle uppercase tracking to distinguish role designations (e.g., `SM`, `DIR`, `LIGHTING CUE`) from body narration.

## Layout & Spacing

The layout is built upon a standard 4-column mobile grid expanding into a 6-column rhythm on compact tablets, calibrated for high one-handed ergonomic efficiency:

- **Horizontal Margins**: A constant `1rem` (16px) margin anchors mobile viewports, extending to `1.5rem` on tablet screens.
- **Vertical Flow**: A compact 4px base rhythm dictates padding tiers. Schedule items, cue runs, and personnel rows maintain tight inner paddings (`space-sm` to `space-md`) to ensure critical day-of-show data fits within the fold.
- **Safe Areas**: Strict top insets accommodate status indicators, while bottom sheets and main view contents incorporate a minimum `80px` bottom clearing to prevent occlusion by the global Bottom Navigation bar.

## Elevation & Depth

Visual hierarchy uses crisp hairline borders combined with tonal canvas layering rather than diffuse, floating drop shadows:

- **Level 0 (Canvas Base)**: `#F8F9FA` or `#F1F5F9`. Flat, non-interactive surface.
- **Level 1 (Cards, Schedule Modules, Containers)**: Solid `#FFFFFF` fill resting on the canvas, bounded by a 1px border of `#E2E8F0`. No drop shadow in default state.
- **Level 2 (Active/Pressed Rows & Elevated Chips)**: `#FFFFFF` fill, 1px `#CBD5E1` border, accompanied by an ambient micro-shadow: `0 1px 3px rgba(15, 23, 42, 0.06)`.
- **Level 3 (Sticky Headers & Floating Action Bar / Bottom Nav)**: Solid `#FFFFFF` fill, with a single hairline bottom/top separation border (`#E2E8F0`) and an ambient anchor shadow: `0 -2px 8px rgba(15, 23, 42, 0.04)`.
- **Level 4 (Modals, Conflict Sheets, Action Sheets)**: Background dimming via `rgba(15, 23, 42, 0.45)` backdrop scrim, with sheets surfaced in `#FFFFFF` bordered at the perimeter by `#E2E8F0` and shadowed via `0 12px 32px rgba(15, 23, 42, 0.12)`.

## Shapes

The design system implements a soft, disciplined shape scale (`roundedness: 1`):

- **Default UI Containers & Cards**: `0.25rem` (4px) to `0.375rem` (6px). Keeps schedules and data tables architectural, clean, and space-efficient.
- **Buttons, Form Inputs, & Banners**: `0.375rem` (6px) to `0.5rem` (8px). Provides subtle tactile softness without resembling playful consumer cards.
- **Chips, Badges, & Avatars**: Fixed pill shapes (`9999px`) are reserved exclusively for contextual status chips, conflict flags, and filter tags to visually isolate them from functional operational blocks.

## Components

### Buttons
- **Primary**: Solid Deep Velvet Crimson (`#881337`) background, pure white text, 40px default height, 8px corner radius, semibold 14px type. State changes apply an overlay tint rather than a hue shift.
- **Secondary / Outlined**: 1px `#E2E8F0` border, transparent background, `#0F172A` text. On press: `#F1F5F9` background.
- **Destructive**: Subdued Crimson `#B91C1C` fill or outline for schedule cancellation and role removal.

### Segmented Filters & Switches
- Enclosed container with `#F1F5F9` background and 1px `#E2E8F0` outline.
- Active segment transitions to pure `#FFFFFF` with an ultra-light hairline outline and subtle ambient shadow; text changes to `#0F172A` with semibold weight.
- Inactive segment renders with `#64748B` label text.

### Schedule Time-Blocks
- Timeline items sit inside clean white modular cards bordered with `#E2E8F0`.
- Left-side indicator strip (3px wide) color-codes category type:
  - Velvet Crimson (`#881337`): Tech Rehearsal / Full Run.
  - Stage Warm Amber (`#D97706`): Wardrobe Fitting / Callboard Notice.
  - Slate Blue (`#475569`): Table Read / Blocking.
- Monospaced or tabular numeric timestamp (e.g., `14:30 – 16:00`) pinned to top left of the card in `#0F172A`.

### Conflict Alert Banners
- Non-dismissible full-width or card banner featuring a soft `#FEF2F2` background and a `#FCA5A5` 1px border.
- Leading icon: Restrained Crimson (`#B91C1C`) warning shield or exclamation.
- Text uses `#991B1B` for header and `#7F1D1D` for conflict details (e.g., *"Actor double-booked: Rehearsal Room B vs Costume Fitting"*).
- Includes inline tertiary text action button for immediate resolution.

### Badges & Status Chips
- Height of 22px to 24px, pill rounded.
- Padding: 4px horizontal, 2px vertical.
- Neutral Chip: `#F1F5F9` background, `#475569` text.
- Confirmed Chip: `#F0FDF4` background, `#166534` text.
- Audition Notice Chip: `#FFFBEB` background, `#92400E` text.

### Bottom Navigation Bar
- Pinned to bottom viewport with height of 64px (excluding device safe area).
- Surface `#FFFFFF` separated from canvas by 1px top hairline border `#E2E8F0`.
- Four dedicated destinations: **Home**, **Schedule**, **Productions**, **Profile**.
- Inactive state: 20px stroked line icon with `#64748B` icon and label.
- Active state: `#881337` filled/accented icon and text label with a subtle 2px active indicator pill beneath the icon.

### Form Inputs
- 40px height with `#FFFFFF` background, 1px `#CBD5E1` resting border, 6px border radius.
- Focus state: Hairline 1px border `#881337` accompanied by a 1px ring overlay of `rgba(136, 19, 55, 0.15)`.
- Labels rendered in 12px semibold `#475569` positioned above the input field with tight 4px spacing.