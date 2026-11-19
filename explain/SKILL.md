---
name: explain
description: Use when asked 'how does X work' type questions.
---

# Explain

Explore the code to answer “how does X work?” type questions.
If the scope is ambiguous, state your interpretation and explore. The user can redirect.

1. Explain
spawn a readonly subagent that explores and explains in one pass. Give it the user’s question and this brief:
  > You are writing an architectural explanation for a senior engineer. Explore the codebase and write an explaination that a senior engineer unfamiliar with this area could read and walk away with a solid mental model. They should understand the architecture well enough to start working in it confidentaly. You have read-only access to the codebase.
 
2. Present
Present the subagent’s output. Light edits for clarity or context from the conversation are fine. Do not substantially rewrite it. Class diagrams to capture the major structs/classes, simple sequence diagrams may also be helpful.