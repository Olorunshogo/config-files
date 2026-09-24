---
name: component-split-by-data-fetch
description: "Split pages by data-fetch boundary: each independently fetched resource gets its own component and loading state; shells pass only IDs via context"
metadata:
  type: feedback
---

Split detail and dashboard pages into components along data-fetching boundaries, not just visual ones.
Any part of the UI that needs its own API request must be its own component.

- A layout/shell component does no fetching. It arranges regions and provides a context with the minimal identifier (e.g. `listingId`), never the full fetched object.
- Each child needing a distinct resource reads the id from context, runs its own fetch hook, and owns its own loading/error/skeleton state.
- Never pass one big fetched object down through props to children that each use a slice of it.

**Why:** from a senior dev review: "if one endpoint delays to respond that means the entire ui will be in the loading state."
Passing the whole object down also causes prop drilling and re-renders on unrelated field changes.

**How to apply:**
- On any multi-resource detail view (listing details vs. vendor info vs. bookings/reviews), check which pieces come from separate endpoints.
- Split one component per endpoint, wired by a shell that only carries ids. In Vue, use `provide`/`inject` or a composable.
- Check the real backend route shapes first, and don't split further than the API does.
- The full convention lives in the `frontend-architecture` skill.
