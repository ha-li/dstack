---
name: commit-helper
description: Use when the user asks to write or improve a git commit message.
---

1. Run `git diff --staged` to see what changed.
2. Write a summary line under 100 characters in the imperative ("Add X", not "Added X").
3. Add a blank line, then explain *why* the change was made.
4. Show the message to the user before committing.
