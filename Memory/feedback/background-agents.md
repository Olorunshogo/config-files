---
name: background-agents
description: "Use one background agent for slow bulk sweeps; never background a single task and sit idle waiting for it"
metadata:
  type: feedback
---

**Use a background agent for bulk slow work:** when a task needs many slow, independent network calls (availability sweeps, per-item HTTP probes), run it as one background agent, not a serial foreground loop.
Tell it to parallelise internally (`xargs -P`) and back off on rate limits, and keep answering the user while it runs.
Use one agent, not one per item.

**Don't background while idle:** if a single task is the only thing happening, do it directly in the foreground.
Backgrounding only makes sense when there is a genuine second workstream to run in parallel.

**Why:** a foreground loop over ~60 curl calls hit the Bash timeout and blocked the conversation ("use one background agent to make this faster").
Separately, the user stopped idle-waiting background agents with "take over from background since you aren't doing anything yet."
Delegating while idle only adds a round-trip, and the user would rather watch the work happen.

Related: [[no-repeat-locked-conventions]].
