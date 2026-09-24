---
name: no-repeat-locked-conventions
description: "Don't restate CLAUDE.md or skill style rules when briefing subagents; only pass task-specific facts"
metadata:
  type: feedback
---

When writing prompts for forks or subagents, don't re-explain conventions already loaded from CLAUDE.md or active skills (comment style, no em dash, state typing, no `any`, etc.).
State only task-specific facts the subagent can't derive: file paths, what's already built, and judgment calls from the conversation.

**Why:** the user flagged it directly: "you still repeated the comments thing that has been said several times and even locked in context."
It pads the prompt and reads as not having internalized the standing rules.

**How to apply:** CLAUDE.md and skills reload into every subagent automatically, including fresh ones.
Only conversation-derived context needs restating.
