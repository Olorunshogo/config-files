# Animation Systems for Product-Grade Web Motion

**Source:** [https://www.aura.build/skills/6bfd1a89-6f9a-403f-ab0d-5e81110ecea6/animation-systems-for-product-grade-web-motion](https://www.aura.build/skills/6bfd1a89-6f9a-403f-ab0d-5e81110ecea6/animation-systems-for-product-grade-web-motion)

Guides designing and implementing tasteful, high-performance product-grade web animation systems inspired by Stripe, Linear, Apple, and Vercel.

| Field    | Value                                                                                                          |
| -------- | -------------------------------------------------------------------------------------------------------------- |
| VIEWS    | 1.7k                                                                                                           |
| USES     | 157                                                                                                            |
| UPDATED  | June 6, 2026                                                                                                   |
| AUTHOR   | [MengTo](https://github.com/MengTo)                                                                            |
| SOURCE   | [MengTo/Skills](https://github.com/MengTo/Skills/blob/main/agent-skills/web-design/animation-systems/SKILL.md) |
| Added by | Meng To                                                                                                        |
| Tags     | animation, motion, micro-interactions, scroll-effects, css, performance, accessibility, best-practices         |

## Metadata

| name        | animation-systems                                                                                                                                                                                                                                                                   |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| description | Use when designing or implementing product-grade web motion like Stripe, Linear, Apple, and Vercel. Covers motion principles, easing/duration defaults, choreography patterns, scroll/hover interactions, performance, accessibility (reduced motion), and implementation guidance. |
| keywords    | animation, motion, micro-interactions, scroll-effects, css, performance, accessibility, best-practices                                                                                                                                                                              |

---

# Animation Systems (Stripe x Linear x Apple x Vercel)

This skill helps you ship tasteful, product-grade motion. Not "more animation." Better animation: clarity, hierarchy, feedback, and delight - without jank.

## The goals (why motion exists)

Use animation to:

- Explain hierarchy (what matters)
- Confirm action (feedback)
- Guide attention (where to look next)
- Maintain continuity (spatial relationships)
- Add polish (craft signals)

If an animation doesn't serve one of these, delete it.

## The Stripe/Linear/Apple/Vercel style (shared traits)

### 1) Restraint

- Fewer animations, better chosen.
- One strong hero moment; the rest is supporting motion.

### 2) Clear choreography

- Primary element moves first.
- Secondary elements follow with small stagger.
- Motion establishes a "reading order."

### 3) Physical but not cartoony

- Use easing that feels human (soft acceleration + gentle settle).
- Avoid bouncy defaults for serious product UI.

### 4) Texture + depth (subtle)

- Small parallax, soft shadows, blur fades, light beams.
- Avoid heavy 3D unless it's the hero.

## Motion primitives (build these first)

Think in primitives you can reuse everywhere.

### A) Fade + rise (default entrance)

Use for: text blocks, cards, modals.

- Opacity: 0 -> 1
- Y: 12-24px -> 0
- Duration: 300-700ms depending on size

### B) Scale + fade (micro emphasis)

Use for: popovers, toasts, selected states.

- Scale: 0.98 -> 1
- Opacity: 0 -> 1

### C) Slide (navigation)

Use for: drawers, step transitions.

- Use transform translate; avoid animating layout.

### D) Morph / shared element (high craft)

Use for: tab indicators, expanding cards.

- Requires consistent geometry + measured layout.

## Defaults (practical numbers)

Use these as a starting system.

### Durations (rule of thumb)

- Micro (hover/press): 120-200ms
- UI state change (toggle, select): 180-260ms
- Small transitions (popover, toast): 220-320ms
- Page section entrance: 400-800ms
- Hero sequences: 800-1600ms (with internal beats)

### Easing (safe set)

Pick a small set and reuse.

- UI: ease-out with gentle settle
- Emphasis: slightly stronger ease
- Entering: ease-out
- Exiting: ease-in (faster)

If implementing:

- Use your animation library's "power2.out / expo.out" equivalents.
- Avoid elastic/bounce unless brand is playful.

### Stagger

- 40-90ms per element (text lines/cards)
- Use smaller stagger on mobile

## Choreography patterns

### 1) "Hero -> supporting elements"

- Hero visual animates in first.
- Headline appears next.
- CTA appears last.

### 2) "Section reveal on scroll"

- Trigger when section is ~20-30% visible.
- Animate once (don't replay on tiny scroll).

### 3) "Hover: lift + glow"

- Y: -2 to -6px
- Shadow: subtle increase
- Optional: border/gradient glow

### 4) "Focus ring + micro shift"

- For form fields: focus ring + tiny scale/translate for responsiveness.

## Performance rules (non-negotiable)

### Animate the right properties

Prefer:

- `transform` (translate/scale/rotate)
- `opacity`

Avoid (unless necessary):

- width/height/top/left
- expensive filters on large areas

### Respect the GPU

- Clamp device pixel ratio in heavy canvases (1-2)
- Keep blur subtle and small
- Avoid many simultaneous animated shadows

### Reduce reflows

- Don't measure layout every frame.
- For scroll effects, use a library that batches reads/writes.

## Accessibility: Reduced Motion

Always support `prefers-reduced-motion`. Policy:

- Keep content visible.
- Replace motion with instant state + subtle opacity.
- Disable scroll-scrub/pin.

Ask the user: "Do you want a reduced-motion mode that disables all non-essential motion?"

## Implementation guidance (library-agnostic)

### For simple sites

- CSS transitions for small hovers/toggles.
- Use a single motion library (GSAP or Framer Motion) for complex sequences.

### For product sites

- Create a motion token set:
  - durations
  - easing curves
  - standard offsets (8/16/24px)
  - stagger defaults

### For hero moments

- Use timelines (or keyframes) with labeled beats.
- Lock camera/scene movement first, then layer text.

## What to ask the user

- What's the brand lane: Stripe (polished), Linear (minimal), Apple (cinematic), Vercel (developer/product)?
- What are the key moments? (hero, scroll story, hover cards, nav transitions)
- Any performance constraints? (mobile, low-end devices)
- Reduced motion requirements?

## Output format (when asked to "add Stripe/Linear-style animation")

Return:

- Motion goals (what we're trying to communicate)
- Motion tokens (durations + easing + offsets)
- A choreography plan (timeline beats)
- Implementation notes (perf + reduced motion)
- A small code recipe (CSS or GSAP/Framer depending on stack)
