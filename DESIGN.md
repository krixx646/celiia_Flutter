---
name: Celia AI Fitness Coach
description: Dark-first mobile fitness app with glassmorphism, warm orange energy accents, and high contrast.
colors:
  primary: "#FF6F00"
  secondary: "#FFB74D"
  neutral-dark: "#0F111A"
  neutral-surface: "#1A1D2D"
  neutral-glass: "#1E2235"
  neutral-border: "#2C3142"
  accent-green: "#00E676"
  accent-blue: "#1976D2"
  text-primary: "#FFFFFF"
  text-secondary: "#B0BEC5"
  text-muted: "#A6A6A6"
  light-background: "#FDFDFD"
  light-surface: "#FFFFFF"
  light-primary: "#F57C00"
  light-text-primary: "#212121"
  light-text-secondary: "#9E9E9E"
  error: "#FF0000"
typography:
  display:
    fontFamily: Urbanist
    fontSize: 4rem
    fontWeight: 700
  h1:
    fontFamily: Urbanist
    fontSize: 2.5rem
    fontWeight: 700
  h2:
    fontFamily: Urbanist
    fontSize: 1.5rem
    fontWeight: 600
  body-lg:
    fontFamily: Urbanist
    fontSize: 1.125rem
    fontWeight: 600
  body-md:
    fontFamily: Urbanist
    fontSize: 1rem
    fontWeight: 700
  body-sm:
    fontFamily: Urbanist
    fontSize: 0.875rem
    fontWeight: 400
  caption:
    fontFamily: Urbanist
    fontSize: 0.75rem
    fontWeight: 400
rounded:
  sm: 12px
  md: 16px
  lg: 20px
  xl: 24px
  full: 28px
spacing:
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 24px
  xxl: 32px
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.xl}"
    padding: 14px
  button-secondary:
    backgroundColor: "{colors.text-muted}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.xl}"
    padding: 14px
  button-primary-hover:
    backgroundColor: "{colors.secondary}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.xl}"
    padding: 14px
  card-glass:
    backgroundColor: "{colors.neutral-glass}"
    rounded: "{rounded.xl}"
    padding: 16px
  input-field:
    backgroundColor: transparent
    textColor: "{colors.text-primary}"
    rounded: "{rounded.xl}"
    padding: 14px
  chat-bubble-user:
    backgroundColor: "{colors.light-primary}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.md}"
    padding: 16px
  chat-bubble-bot:
    backgroundColor: "{colors.neutral-surface}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.md}"
    padding: 16px
  nav-bar:
    backgroundColor: "{colors.neutral-glass}"
    rounded: "{rounded.full}"
---

## Overview

Dark-first, high-energy fitness coaching app. The UI combines **glassmorphism** (translucent frosted surfaces over deep navy backgrounds) with **warm orange accents** that signal energy, motivation, and action. The result feels premium, modern, and athletic — like a high-end fitness studio app.

## Colors

The palette is rooted in deep navy neutrals with a single vibrant orange accent:

- **Primary (#FF6F00):** Warm amber-orange. The sole driver of interaction — buttons, active indicators, highlights. In light mode, shifts to #F57C00 for softer contrast against white.
- **Secondary (#FFB74D):** Lighter orange used in gradients (header background) and hover states.
- **Neutral Dark (#0F111A):** Deep ink-navy. The app's scaffold background in dark mode. Almost black but with a subtle blue undertone that feels softer than pure #000.
- **Neutral Surface (#1A1D2D):** Elevated cards and chat bubbles. Slightly lifted from the background.
- **Neutral Glass (#1E2235):** The glassmorphism base — always used with transparency (typically 0.6 alpha) over dark backgrounds. Paired with a subtle border in #363D52 (0.5 alpha).
- **Neutral Border (#2C3142):** Subtle dividers and borders, visible but never dominant.
- **Accent Green (#00E676):** Used sparingly for success states and positive reinforcement (e.g., completion indicators).
- **Text hierarchy:** White (#FFFFFF) for primary content, slate (#B0BEC5) for secondary, and 40% white for tertiary/muted.

### Light Mode
Light mode inverts the dark scheme: warm white background (#FDFDFD), pure white surfaces, orange shifts to #F57C00, and text becomes near-black (#DE000000) with grey secondaries.

## Typography

**Urbanist** is the single brand font across all text. It's a geometric sans-serif that balances modern cleanliness with warmth — no cold, sterile feel.

- Display (4rem / bold): Used sparingly — the "celia" logotype on the landing page.
- H1 (2.5rem / bold): Major screen titles.
- H2 (1.5rem / semibold): Section headers, card titles.
- Body Large (1.125rem / semibold): Emphasis body text.
- Body Medium (1rem / bold): Default body text and chat messages. Bold weight is intentional — chat messages at 16px bold ensure readability for fitness instructions.
- Body Small (0.875rem / regular): Supporting text, metadata.
- Caption (0.75rem / regular): Version numbers, fine print.

All body text uses 1.5 line-height for readability. Letter spacing is never tightened — fitness content needs clarity.

## Layout & Spacing

- Spacing scale: 4px, 8px, 12px, 16px, 24px, 32px
- Screen padding: 16px horizontal on most screens, 24px on home header
- Section gaps: 32px between major sections, 12-16px within sections
- Component internal padding: 14-16px
- Chat bubbles have 16px vertical / 18px horizontal internal padding with 8px gap between bubbles
- Nav bar uses 16px side padding from screen edges

## Elevation & Depth

Three layers of depth:

1. **Background (0):** #0F111A, the deepest layer. No shadows cast onto it.
2. **Surface (1):** Cards, chat bubbles, elevated containers. Subtle 6px blur shadows with 0.06 alpha black.
3. **Floating (2):** Navigation bar, bottom sheets. Stronger 16-20px blur shadows with 0.12-0.15 alpha black. These use the glassmorphism surface.

## Shapes

- **Rounded scale:** 12px (images, chat bubbles), 16px (cards, buttons, user bubbles), 20px (input areas), 24px (glass panels, input fields, pills), 28px (nav bar)
- **Circles:** Send button, FABs, and profile avatars use `BoxShape.circle`
- **Header gradient section:** Bottom corners only rounded (32px) — the top is flush with the screen edge
- **Glass panels:** Always paired with a 0.5 alpha border in the glass border color

## Components

### Primary Button
Orange fill (#FF6F00), white text, 24px rounded, 14px vertical padding. Used for high-emphasis actions (Sign Up, Log In, Send). Stadium shape variant on the landing page.

### Secondary / Outline Button
Transparent or semi-transparent background (#FFFFFF10), white text, 24px rounded. Used for less emphasis (file attach, cancel).

### Chat Option Buttons
Outlined style with orange tint background (24% opacity) and orange border (70% opacity). Round 24px shape. After interaction, they grey out to #FFFFFF10 background with #FFFFFF54 text to signal the choice was made.

### Glass Card
Translucent dark surface (#1E2235 at 60% opacity) with 24px rounded corners, a subtle border (#363D52 at 50%), and a 16px blur shadow. Used for bottom sheets, the navigation bar background, and the chat input bar.

### Chat Bubbles
- **User:** Orange fill (#F57C00), white bold 16px text, 16px rounded, shadow with 0.06 alpha.
- **Bot (dark mode):** Surface color (#1A1D2D), white bold 16px text, 16px rounded, shadow.
- **Bot (light mode):** Grey 200 (#EEEEEE), near-black bold 16px text.

### Input Field
Dark mode: rounded 24px pill shape with a subtle white border (10% opacity) and white 5% background. Placeholder text in muted white (54% opacity).
Light mode: grey 100 background (#F5F5F5) with grey 300 border.

### Navigation Bar
Glass card style (translucent surface) with 28px rounded corners. Orange indicator (20% opacity) on the selected tab. 72px height. Animated slide in/out.

## Gradients

- **Home header:** Linear gradient from secondary (#FFB74D) top-left to primary (#FF6F00) bottom-right. Creates a warm, energetic header backdrop.

## Do's and Don'ts

- **DO** use the orange accent ONLY for interactive elements (buttons, active tabs, highlights). Never for static text or backgrounds.
- **DO** keep dark mode as the default and preferred experience.
- **DO** use the glassmorphism surface for any element that floats above the background (nav bar, bottom sheets, chat input).
- **DO** use 16px bold body text for chat messages — fitness instructions need readability.
- **DO** pair glass surfaces with a border — the border is what makes the frosted glass effect readable.
- **DON'T** use pure black (#000000) — the navy base (#0F111A) is intentionally softer.
- **DON'T** tighten letter spacing. Legibility over aesthetics for fitness content.
- **DON'T** use more than 3 elevation levels. The visual hierarchy should feel deliberate, not chaotic.
