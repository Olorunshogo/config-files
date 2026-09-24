---
name: spacing-flex-grid-gap
description: "Layout spacing between siblings uses flex/grid + gap, never margin or space-x/space-y utilities"
metadata:
  type: feedback
---

Spacing between elements is done with `flex` / `grid` plus `gap-*`.
Don't use `space-y-*` / `space-x-*`, and don't use `mt-*` / `mb-*` / `ml-*` / `mr-*` to create rhythm between siblings.
In the user's words: "on no account are we using margin or space or padding in place of grid or flex and gaps. except absolutely necessary."

**Why:** spacing lives on the container instead of scattered across children, so layout is predictable and easy to restructure.

**How to apply:**
- Between siblings, wrap them in `flex`/`grid` and set `gap`.
- A component's own inset (button or card padding) can use padding.
- Centering a block with `mx-auto` is fine.
- Anchor offsets with `scroll-mt-*` are fine.
- Only use a margin when there is genuinely no container to put a gap on.
