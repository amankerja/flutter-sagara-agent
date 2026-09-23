---
name: Serene Transit
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#45464d'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#76777d'
  outline-variant: '#c6c6cd'
  surface-tint: '#565e74'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#131b2e'
  on-primary-container: '#7c839b'
  inverse-primary: '#bec6e0'
  secondary: '#006a61'
  on-secondary: '#ffffff'
  secondary-container: '#86f2e4'
  on-secondary-container: '#006f66'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#23005c'
  on-tertiary-container: '#9466ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2fd'
  primary-fixed-dim: '#bec6e0'
  on-primary-fixed: '#131b2e'
  on-primary-fixed-variant: '#3f465c'
  secondary-fixed: '#89f5e7'
  secondary-fixed-dim: '#6bd8cb'
  on-secondary-fixed: '#00201d'
  on-secondary-fixed-variant: '#005049'
  tertiary-fixed: '#e9ddff'
  tertiary-fixed-dim: '#d0bcff'
  on-tertiary-fixed: '#23005c'
  on-tertiary-fixed-variant: '#5516be'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 30px
    letterSpacing: -0.02em
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.01em
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '700'
    lineHeight: 22px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 15px
    fontWeight: '500'
    lineHeight: 22px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 18px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  label-xs:
    fontFamily: Plus Jakarta Sans
    fontSize: 10px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.02em
  code-mono:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '800'
    lineHeight: 24px
    letterSpacing: 0.05em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.875rem
  space-lg: 1.25rem
  space-xl: 1.75rem
---

## Brand & Style

This design system is crafted for contemporary mobile travel and ticket-booking experiences. It evokes effortless calm, optimism, and approachable modernity through an ultra-clean visual treatment. 

The aesthetic is anchored in:
- **Soft Pastel Atmospheres:** Tinted surface layers (mint ice, pale cyan, soft lavender, warm peach) provide gentle structural compartmentalization without rigid visual boundaries.
- **Friendly Geometry:** Pronounced corner radii (24px to 28px on primary cards and full pills for badges/actions) communicate tactile ease and comfort.
- **High-Contrast Grounding:** Deep obsidian/carbon black (`#0F172A` / `#000000`) primary buttons and key action focal points balance the airy pastel base with authoritative legibility.
- **Whimsical Utility:** Illustrated miniature transit icons, subtle dashed route trajectories, and tilted floating promotional vouchers imbue the booking journey with delight and fluidity.

## Colors

The palette balances airy, tinted pastel backgrounds with crisp dark anchor tones for text and primary call-to-actions.

### Palette Architecture
- **Base Canvas & Cards:**
  - Screen Background: `#F8FAFC` to `#F1F5F9` subtle gradient fade.
  - Surface White: `#FFFFFF` for elevated route cards and booking details.
  - Tinted Pastel Chips & Surfaces:
    - Mint / Train Teal: `#E6FFFA` (text/icon: `#0D9488`)
    - Sky / Flight Cyan: `#E0F2FE` (text/icon: `#0284C7`)
    - Soft Lavender / Boat Indigo: `#EDE9FE` (text/icon: `#7C3AED`)
    - Soft Peach / Bus Coral: `#FFEDD5` (text/icon: `#EA580C`)
- **Primary Dark Accents:**
  - High-impact CTA & Selected State: `#0F172A` (with pure `#FFFFFF` foreground).
- **Functional Accents & Badges:**
  - Accent Purple Glow (Vouchers): `#DDD6FE` to `#C4B5FD` with `#6D28D9` text.
  - Rating Gold / Point Stars: `#F59E0B`.
  - Notification Indicator: `#EF4444`.
- **Text & Borders:**
  - Primary Text: `#0F172A`
  - Secondary / Meta Text: `#64748B`
  - Subtle Dividing Lines / Dashed Traces: `#CBD5E1`
  - Border Strokes: `#F1F5F9`

## Typography

The type system relies on **Plus Jakarta Sans**, offering friendly, geometric, open apertures paired with sturdy vertical stems that ensure instantaneous readability across rapid ticket scanning and route browsing.

- **Display & Headlines:** Used for welcoming greetings (`Travel Made Effortless`) and destination search headers (`Find Your Best Trip`). Tight tracking creates an editorial, composed appearance.
- **Airport / Station IATA Codes:** Station acronyms (`CGK`, `HLM`, `PDLG`) leverage `code-mono` / extra-bold styling to stand out immediately against departure timelines.
- **Labels & Micro-copy:** Pill indicators, travel durations, and transit types maintain medium-to-semibold weights to preserve legibility against pastel backdrops.

## Layout & Spacing

The layout is optimized for single-hand mobile interactions using an adaptive single-column flow with generous horizontal safe paddings:
- **Canvas Margins:** Fixed `1.25rem` (20px) outer edge margins keep interactive elements safely inward from bezel contours.
- **Card Padding Hierarchy:** Content cards use `1.25rem` (20px) internal padding, whereas modal search containers expand up to `1.5rem` (24px) for tactile touch targets.
- **Horizontal Carousels:** Category selector rows and promotion strips bleed gently past the canvas margin with `1.25rem` leading inset to hint at horizontal scrollability.
- **Vertical Flow:** Section blocks maintain `1.75rem` (28px) separation, framed by concise section headers with companion "View All" tertiary link actions.

## Elevation & Depth

Visual hierarchy emphasizes softness and floating layers rather than severe drop shadows:

- **Surface Level 0 (Canvas):** Soft off-white to pale icy wash (`#F8FAFC`). Flat with no shadow.
- **Surface Level 1 (Default Ticket & Schedule Cards):** Pure white `#FFFFFF` with ultra-diffuse ambient shadows: `0px 8px 24px -4px rgba(15, 23, 42, 0.04), 0px 2px 6px -1px rgba(15, 23, 42, 0.02)`.
- **Surface Level 2 (Selected State & Modals):** White card with crisp `1px` subtle outline in `#F1F5F9` and `0px 16px 36px -8px rgba(15, 23, 42, 0.08)`.
- **Surface Floating (Promo Vouchers & Tooltips):** Tilted or floating elements feature a colored ambient glow: `0px 12px 28px -6px rgba(139, 92, 246, 0.25)`.
- **Bottom Navigation Dock:** Floating pill bar lifted `16px` above the bottom margin with backdrop blur (`16px`) and `0px 10px 30px -4px rgba(15, 23, 42, 0.06)`.

## Shapes

The shape system adopts hyper-rounded geometry (`3` - Pill-shaped) to reinforce warmth, approachability, and smooth interaction:

- **Large Content Cards:** Built with continuous curvature corners ranging between `24px` and `28px` (`rounded-3xl`).
- **Primary & Secondary Buttons:** Fully pill-shaped (`9999px` / `rounded-full`).
- **Input Fields & Search Row Containers:** Uniform `16px` to `20px` corner radii with soft pill icons.
- **Transit Ticket Cutouts:** Boarding passes and vouchers feature subtle inward circular cutout notches along lateral tear-lines (`radius: 10px`), visually simulating physical paper perforation.

## Components

### Buttons
- **Primary CTA:** Full pill (`rounded-full`), background `#0F172A`, text `#FFFFFF`, height `54px`, `label-lg`. Tap feedback triggers subtle scale down (`scale-98`).
- **Category Transit Buttons:** Rounded squircle cards (`20px` radius) styled with thematic pastel backgrounds (`#E6FFFA` for train, `#E0F2FE` for flights, `#EDE9FE` for boats, `#FFEDD5` for buses). Top contains cute vehicle vector artwork; bottom contains bold label.
- **Toggle Pills (One Way / Round Trip):** Contained in a slate-100 capsule. The active selection slides with a solid `#0F172A` pill and white text, while the inactive option is muted `#64748B`.

### Transit Badges & Route Lines
- **Dashed Journey Path:** A horizontal dashed line `#CBD5E1` connecting origin and destination IATA codes. At the center sits a miniature icon (train, airplane, or bus) bounded by tiny origin/destination circular terminal nodes (`6px`).
- **Status Pills:** Pill tags (e.g., `Ability to reschedule`, `One Way`, `Economy`) rendered in `#EDE9FE` with `#6D28D9` text or light neutral tinted borders.

### Booking Search Cards
- Input rows stacked vertically with light `#F8FAFC` recessed backgrounds, featuring an icon container on the left, primary selection text (`Jakarta`), and sub-label above (`From`). An absolute-positioned swap button (`#8B5CF6` circle) bridges origin and destination fields.

### Floating Vouchers
- Decorative promo ticket rendered with an angled skew (`-4deg`), pastel purple/cyan gradient mesh, perforated coupon notch edge, and prominent discount typography (`30% off`). Accompanied by a colored drop glow.

### Ticket Detail Cards
- Multi-section cards separated by dashed perforations. Upper section displays origin/destination station codes, times, and transit logo; lower segment highlights seat class, baggage allowance, gate number, and a high-contrast black CTA button or barcode view.