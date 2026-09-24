---
name: rust-string-conventions
description: "Rust conventions: `{}` placeholders over captured identifiers, capitalized user-facing strings, file-header doc blocks, two section-heading levels"
metadata:
  type: feedback
---

1. **`format!` style:** use explicit `{}` placeholders with separate arguments, e.g. `format!("Checked out by member with id: {}", member_id)`, not `format!("checked out by member {member_id}")`. This applies to `println!` and error messages too.
2. **Capitalized user-facing strings:** errors, status labels, and messages start with a capital letter (`"Year must be positive"`).
3. **File-header doc block:** a `// === Title` line, a blank line, then a `/** ... */` block with one sentence per line explaining what the file does and why. Don't stack `//` lines for this.
   ```
   // === Library errors

   /**
    * Every expected failure in the library is one of these variants.
    * No `unwrap()` / `expect()` is used on any path a user can trigger.
    */

   use std::fmt;
   ```
4. **Heading levels:** only the single file-title comment uses `// === Name`. Every other section heading uses `// == Name`, including headings inside `impl` blocks. Group a file's type declarations in one `// == Types` section, then give each type's `impl` its own `// == TypeName` section. There is no third level.

**Why:** stated preferences, confirmed by the user correcting drift back to these forms.
