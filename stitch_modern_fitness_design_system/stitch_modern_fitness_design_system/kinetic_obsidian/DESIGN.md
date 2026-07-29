---
name: Kinetic Obsidian
colors:
  surface: '#11131c'
  surface-dim: '#11131c'
  surface-bright: '#373943'
  surface-container-lowest: '#0c0e17'
  surface-container-low: '#191b24'
  surface-container: '#1d1f29'
  surface-container-high: '#282933'
  surface-container-highest: '#32343e'
  on-surface: '#e1e1ef'
  on-surface-variant: '#e1bfb0'
  inverse-surface: '#e1e1ef'
  inverse-on-surface: '#2e303a'
  outline: '#a98a7c'
  outline-variant: '#594136'
  surface-tint: '#ffb691'
  primary: '#ffb691'
  on-primary: '#552000'
  primary-container: '#ff6f00'
  on-primary-container: '#592200'
  inverse-primary: '#9e4200'
  secondary: '#ffb954'
  on-secondary: '#452b00'
  secondary-container: '#c3841b'
  on-secondary-container: '#3c2500'
  tertiary: '#00e475'
  on-tertiary: '#003918'
  tertiary-container: '#00b25a'
  on-tertiary-container: '#003b1a'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdbcb'
  primary-fixed-dim: '#ffb691'
  on-primary-fixed: '#341100'
  on-primary-fixed-variant: '#793100'
  secondary-fixed: '#ffddb4'
  secondary-fixed-dim: '#ffb954'
  on-secondary-fixed: '#291800'
  on-secondary-fixed-variant: '#633f00'
  tertiary-fixed: '#62ff96'
  tertiary-fixed-dim: '#00e475'
  on-tertiary-fixed: '#00210b'
  on-tertiary-fixed-variant: '#005226'
  background: '#11131c'
  on-background: '#e1e1ef'
  surface-variant: '#32343e'
  glass-surface: rgba(30, 34, 53, 0.60)
  glass-border: rgba(255, 255, 255, 0.12)
  ink-surface: '#1A1D2D'
  text-primary: '#FFFFFF'
  text-secondary: '#B0BEC5'
  text-muted: rgba(255, 255, 255, 0.40)
typography:
  display:
    fontFamily: Urbanist
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Urbanist
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Urbanist
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: Urbanist
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  body-lg:
    fontFamily: Urbanist
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 28px
  body-md:
    fontFamily: Urbanist
    fontSize: 16px
    fontWeight: '700'
    lineHeight: 24px
  body-sm:
    fontFamily: Urbanist
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  label-caps:
    fontFamily: Urbanist
    fontSize: 12px
    fontWeight: '800'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-padding: 24px
  stack-gap-lg: 32px
  stack-gap-md: 16px
  stack-gap-sm: 8px
  inline-gutter: 12px
---

## Brand & Style

This design system embodies the "Kinetic Obsidian" aesthetic—a fusion of high-performance athletic energy and sophisticated digital craftsmanship. It is designed for the modern athlete who demands a professional, AI-driven coaching experience that feels as premium as elite gym equipment.

The style is defined by **Glassmorphism** and **Modern Dark-First** principles. By layering translucent, frosted surfaces over a deep, atmospheric navy background, the interface achieves a sense of physical depth. Vibrant orange accents provide a "high-vis" energy, signaling action and motivation against the dark, stable foundation. The mood is focused, high-fidelity, and authoritative, eliminating clutter in favor of polished, intentional layouts.

## Colors

The palette avoids pure black to maintain a premium, "ink" depth that feels more natural and less fatiguing. 

- **Primary & Secondary:** The "Forge Orange" duo drives the kinetic energy. Use the Primary for core actions and the Secondary for highlights and gradients.
- **Glass System:** Surfaces use a translucent navy base (`glass-surface`) paired with a crisp, low-opacity white border (`glass-border`). This combination is essential for the frosted glass effect.
- **Neutral Base:** The background is a deep `neutral-color_hex` (#0F111A), providing a sophisticated canvas for glass layers to stack upon.
- **Success Accent:** A vibrant green is reserved exclusively for completion states, streak milestones, and positive performance feedback.

## Typography

Urbanist is the cornerstone of the system’s modern, geometric feel. 

- **Weight as Hierarchy:** We utilize bold and extra-bold weights heavily, even in body text, to ensure high legibility during active movement or quick glances. 
- **The Chat Standard:** Chat messages from the AI Coach use `body-md` at a 700 weight. This reinforces the "Athletic Coach" persona—direct, strong, and clear.
- **Display:** Used for brand moments and large metric readouts (e.g., "15:00" remaining). 
- **Label Caps:** Used for metadata like "EASY" or "3 STEPS" to create an editorial, structured feel.

## Layout & Spacing

This system utilizes a **Fluid Grid** with generous safe-area margins to accommodate mobile-first usage.

- **Rhythm:** A base-4 spacing system is applied. Major content sections are separated by `stack-gap-lg` (32px) to prevent visual clutter and give the "Glass" elements room to breathe.
- **Horizontal Margins:** A standard 24px margin is applied to the main screen edges to ensure high-fidelity framing.
- **Chat Spacing:** Bubbles are spaced at 12px internally, with 24px between different speakers to clearly delineate the conversation flow.

## Elevation & Depth

Visual hierarchy is achieved through **Tonal Stacking** and **Backdrop Blurs**:

1.  **Level 0 (Base):** The #0F111A background.
2.  **Level 1 (Surface):** Solid `ink-surface` cards for static content. Subtle 4px blur shadows.
3.  **Level 2 (Float):** Glassmorphic panels (Nav bar, Floating Action Buttons). These use a `backdrop-filter: blur(12px)` and the `glass-border` to separate from Level 1.
4.  **Level 3 (Overlay):** High-priority modals and the chat input bar. These cast a diffused 20px blur shadow with 15% opacity to signify they are at the top of the stack.

## Shapes

The shape language is consistently soft and organic, echoing the ergonomics of modern fitness gear.

- **Standard Corners:** 16px is the default for cards and surfaces.
- **Interactive Pill:** 24px or "Stadium" shapes are used for buttons and input fields to make them feel more tactile and "tap-friendly."
- **Full Circles:** Reserved for specific actions like "Send" buttons, Profile avatars, and Play buttons.

## Components

- **Primary Buttons:** Stadium-shaped (fully rounded sides) with a Primary Orange fill. They should feel massive and energetic.
- **Glass Navigation Bar:** A floating container (detached from screen edges with 16px margin) using the Level 2 Elevation glass style. Active states are indicated by a subtle orange glow or low-opacity orange capsule behind the icon.
- **Chat Bubbles:**
    - **Coach:** `ink-surface` background, white text, 16px rounded corners.
    - **User:** Primary Orange background, white text, 16px rounded corners. 
    - *Note:* Remove all "tail" pointers from bubbles for a cleaner, modern look.
- **Workout Cards:** Use Level 1 Elevation. The top half should feature a high-contrast image or gradient background, while the bottom half contains the metadata in a structured, high-contrast layout.
- **Input Fields:** 24px rounded "pill" containers. In dark mode, these use a 5% white fill and the `glass-border` style for a refined, understated appearance.
- **Action Floating Buttons:** High-contrast orange circles with white icons, always positioned with Level 3 Elevation.