---
name: comment-one-sentence-per-line
description: "Inside a multi-line comment, break lines after each sentence's full stop, never mid-sentence at a column width"
metadata:
  type: feedback
---

Inside a `/* ... */` or multi-line `//` comment, a new line starts right after a sentence ends, never mid-sentence to fit a column width.
The number of sentences decides the number of lines.

**Why:** the user wants every line boundary inside a comment to line up with a full stop, not with an ~80 column wrap.

**How to apply:**
- Write one full sentence per line, in every project.
- If a single sentence would run past roughly 100-120 characters, split it into two or three shorter sentences at a natural clause boundary. A very long single line still visually wraps like the banned pattern.
- Pairs with [[comment-rules]].
