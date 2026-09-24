---
name: comment-rules
description: "Comments go above the declaration/block only; no trailing or inline comments on a line, of any length"
metadata:
  type: feedback
---

A comment goes in exactly one place: above the declaration, block, or function it explains.
Trailing comments are banned entirely, not just long ones.

- `field: Type; // short note` is banned. If a field is obvious it gets no comment, and if it needs explaining, the explanation goes once above the whole declaration.
- Don't scatter a comment per statement inside a function body. Use one comment above the block.
- Don't add an inline comment beside a changed line explaining why it changed, not even a trimmed one-liner. The diff, commit, or decision record carries that.
- Don't invent a top-of-block comment to replace deleted inline ones if the code is obvious without them.
- This overrides a codebase's own habit of long explanatory inline comments.

**Why:** the rule tightened several times after repeated violations: comments wedged between object literal properties, then an over-long trailing comment as the "fix", then trailing comments of any length were banned outright.

**How to apply:** before writing any comment, check whether it would sit on the same line as code. If so, move it above the declaration or drop it. Default to no comment.
When a subagent is asked to fix comment placement, give it this exact rule.
The authoritative version lives in the `coding-assistant` skill.
Pairs with [[comment-one-sentence-per-line]].
