# cobe.js Lightweight WebGL Globe Skill

**Source:** [https://www.aura.build/skills/73fc8502-3e99-47ef-bcee-6d7661183d36/cobe-js-lightweight-webgl-globe-skill](https://www.aura.build/skills/73fc8502-3e99-47ef-bcee-6d7661183d36/cobe-js-lightweight-webgl-globe-skill)

Implement a lightweight interactive WebGL globe with cobe.js, including responsive canvas setup, markers, interaction, and React/Next.js integration.

| Field    | Value                                                                                               |
| -------- | --------------------------------------------------------------------------------------------------- |
| VIEWS    | 1.2k                                                                                                |
| USES     | 19                                                                                                  |
| UPDATED  | June 5, 2026                                                                                        |
| AUTHOR   | [MengTo](https://github.com/MengTo)                                                                 |
| SOURCE   | [MengTo/Skills](https://github.com/MengTo/Skills/blob/main/agent-skills/web-design/cobejs/SKILL.md) |
| Added by | Meng To                                                                                             |
| Tags     | web-design, ui-design, javascript, performance, best-practices, react, nextjs                       |

## Metadata

| name        | cobejs                                                                                                                                       |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| description | Use when adding a lightweight interactive globe with cobe (canvas setup, markers, interaction, performance, integration with React/Next.js). |
| keywords    | web-design, ui-design, javascript, performance, best-practices, react, nextjs                                                                |

---

# cobe.js - Lightweight WebGL Globe Skill

## When to use

- A "spinning globe" / location markers in hero or about pages
- You want a small, focused globe lib (not full three.js)
- Decorative + interactive (markers, rotation) with minimal setup

## Key APIs/patterns

- Core:
  - `import createGlobe from "cobe"`
  - `const globe = createGlobe(canvas, { ...options, onRender(state) { ... } })`
- Important options (common):
  - `devicePixelRatio`, `width`, `height`
  - `phi`, `theta` (rotation angles)
  - `scale`, `dark`, `diffuse`
  - `baseColor`, `markerColor`, `glowColor`
  - `markers: [{ location: [lat, lon], size, color? }]`
- Lifecycle:
  - `globe.toggle()` pauses RAF
  - `globe.destroy()` removes instance

## Common pitfalls

- Canvas sizing mismatch
  - Set CSS size AND set canvas `width/height` scaled for DPR.
- Not updating on resize
  - Recompute width/height and recreate or update params.
- Too high DPR on mobile
  - Clamp DPR to 1-2.

## Quick recipe: responsive globe with markers

```js
import createGlobe from "cobe";

const canvas = document.getElementById("cobe");
let phi = 0;

function setup() {
  const rect = canvas.getBoundingClientRect();
  const dpr = Math.min(window.devicePixelRatio, 2);
  canvas.width = Math.round(rect.width * dpr);
  canvas.height = Math.round(rect.height * dpr);

  const globe = createGlobe(canvas, {
    devicePixelRatio: dpr,
    width: canvas.width,
    height: canvas.height,
    phi: 0,
    theta: 0.2,
    dark: 0,
    diffuse: 1.2,
    scale: 1,
    mapSamples: 16000,
    mapBrightness: 6,
    baseColor: [0.2, 0.2, 0.25],
    glowColor: [1, 1, 1],
    markerColor: [0.8, 0.5, 1],
    markers: [{ location: [1.3521, 103.8198], size: 0.08 }],
    onRender: (state) => {
      state.phi = phi;
      phi += 0.01;
    },
  });

  return globe;
}

let globe = setup();
window.addEventListener("resize", () => {
  globe.destroy();
  globe = setup();
});
```

## What to ask the user

- Globe size and placement (hero, section, card)?
- Marker locations + colors (brand-aligned)?
- Interaction needs (drag to rotate vs. ambient spin)?
