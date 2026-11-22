# CSS Border Gradient Skill

**Source:** [https://www.aura.build/skills/e81a2c78-df63-4454-b223-375b197bb62c/css-border-gradient-skill](https://www.aura.build/skills/e81a2c78-df63-4454-b223-375b197bb62c/css-border-gradient-skill)

Teach how to create and customize CSS gradient borders using a pseudo-element mask, including Tailwind-friendly usage and common pitfalls.

| Field    | Value                                                                                                            |
| -------- | ---------------------------------------------------------------------------------------------------------------- |
| VIEWS    | 1.4k                                                                                                             |
| USES     | 47                                                                                                               |
| UPDATED  | June 6, 2026                                                                                                     |
| AUTHOR   | [MengTo](https://github.com/MengTo)                                                                              |
| SOURCE   | [MengTo/Skills](https://github.com/MengTo/Skills/blob/main/agent-skills/web-design/css-border-gradient/SKILL.md) |
| Added by | Meng To                                                                                                          |
| Tags     | css, web-design, ui-design, best-practices                                                                       |

## Metadata

| name        | css-border-gradient                                                                                                                                                                                                                                                                                                       |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| description | Create and apply CSS gradient borders using a pseudo-element mask (the .border-gradient::before technique), including Tailwind-friendly usage and customization of angle, colors, border thickness, and radius. Use when asked for gradient borders, border glow, or the specific mask-composite border gradient snippet. |
| keywords    | css, web-design, ui-design, best-practices                                                                                                                                                                                                                                                                                |

---

# CSS Border Gradient Skill

## Workflow

- Confirm environment (plain CSS vs Tailwind) and gather missing specs (border radius, thickness, angle, colors).
- Provide the baseline snippet and a short usage checklist.
- Offer focused tweaks only (change angle, colors, thickness, radius) and avoid redesigning the component.

## Baseline snippet

```css
.border-gradient {
  position: relative;
}

.border-gradient::before {
  content: "";
  position: absolute;
  inset: 0;
  border-radius: 10px;
  padding: 1px;
  -webkit-mask:
    linear-gradient(#fff 0 0) content-box,
    linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  background: linear-gradient(
    225deg,
    rgba(255, 255, 255, 0) 0%,
    rgba(255, 255, 255, 0.2) 50%,
    rgba(255, 255, 255, 0) 100%
  );
  pointer-events: none;
}
```

## Usage checklist

- Insert the snippet in global CSS or the page `<head>`.
- Add `border-gradient` to the element.
- Remove any existing `border` styles.
- Match the element radius to the pseudo-element radius.

## Tailwind example

```html
<div class="border-gradient rounded-lg before:rounded-lg">...</div>
```

If a project uses Tailwind layers, wrap the class in `@layer utilities`.

## Customization knobs

- **Thickness:** change `padding` (for example `2px`).
- **Radius:** change `border-radius` or the `before:rounded-*` class.
- **Angle:** change the `linear-gradient(225deg, ...)` angle.
- **Colors:** adjust the `rgba(...)` stops to fit the theme.

## Common pitfalls

- Mismatched radius between the element and pseudo-element.
- Leaving an existing border on the element (double border).
- Tailwind purge removing the class because it is not referenced in content files.

## Questions to ask when specs are missing

- What border radius and thickness do you want?
- What gradient angle and colors should it use?
- Is this for light, dark, or both themes?
