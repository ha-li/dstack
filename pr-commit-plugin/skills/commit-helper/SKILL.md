---
name: commit-helper
description: Use when the user asks to write or improve a git commit message.
---

1. Run `git diff --staged --name-only` to list the staged files. 
2. use the `repo-auditor` agent to scan the files from step 1 and ask it to check only those files.
Treat its **Blockers** like `secret_candidates`: stop and show them to the user before going on.
3. Run `git diff --staged` to see what changed.
4. Write a summary line under 100 characters in the imperative ("Add X", not "Added X").
5. Add a blank line, then explain *why* the change was made.
6. Show the message to the user before committing.
