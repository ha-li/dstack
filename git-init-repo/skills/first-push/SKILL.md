---
name: first-push
description: Use when the user wants to push a local git repo to a remote for the first time, such as "push this to GitHub", "publish this repo", "set up a remote", or "add origin and push", especially when no remote is configured yet or the remote URL is unknown. Not for routine pushes to an existing upstream.
---

# First push to a new remote

Goal: connect this local repo to a remote and push the current branch, setting
upstream tracking. Do it safely: a first push is public and hard to take back.

## Step 1: Check the repo's state

Run the preflight script and read its output:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/first-push/scripts/preflight.sh"
```

It prints `key=value` lines. Act on them in this order:

- `is_repo=no`: ask the user whether to run `git init`. Do not run it without a yes.
- `commits=0`: nothing to push yet. Show `git status --short` and ask the user
  what to commit, then make the first commit. Never stage everything with
  `git add .` without showing the user the list first.
- `secret_candidates=` (not empty): **stop.** List the files and ask the user
  whether they really should be pushed. Suggest adding them to `.gitignore` and
  removing them with `git rm --cached <file>`. Secrets pushed to a remote should
  be treated as leaked, even if deleted later.
- `large_files=` (not empty): warn that GitHub rejects files over 100 MB, and
  suggest Git LFS or `.gitignore`.
- `detached_head=yes`: ask the user which branch to push. Don't guess.

## Step 2: Find out where to push

The remote is unknown, so never invent a URL. Pick the case that applies:

1. **`remotes=` already lists a remote** (usually `origin`): show it to the user
   and ask whether to push there. If they say no, ask for the new URL.
2. **The user gave a URL**: use it.
3. **No URL and `gh_ready=yes`**: offer to create the repo with the GitHub CLI.
   Ask for the repo name (default: the folder name) and whether it should be
   **private** (the default) or public. Then:
   ```bash
   gh repo create <name> --private --source=. --remote=origin
   ```
   This adds `origin` but doesn't push. Continue at Step 4.
4. **No URL and no `gh`**: ask the user for the URL, and explain how to get one:
   create an **empty** repo (no README, license, or .gitignore) on GitHub,
   GitLab, or similar, then copy its HTTPS or SSH URL.

Never put a password or token in the URL (`https://user:token@...`). Git
stores the URL in plain text in `.git/config`.

## Step 3: Check the remote before adding it

```bash
git ls-remote <url>
```

- **Error** (not found, permission denied, auth failed): show the error and
  stop. Typical causes: a typo in the URL, the repo doesn't exist yet, or the
  user isn't logged in (for SSH, `ssh -T git@github.com` tests access).
- **No output**: the remote is empty. This is the expected case. Continue.
- **Output with branches**: the remote already has commits (often an
  auto-created README). **Never force-push.** Explain the options and let the
  user choose:
  - recreate the remote repo empty, or
  - `git pull --rebase origin <branch>` to put local commits on top
    (if histories are unrelated, add `--allow-unrelated-histories`; this
    can create conflicts).

Then add it (skip if `origin` already points to this URL):

```bash
git remote add origin <url>
```

If `origin` exists with a different URL, ask before running
`git remote set-url origin <url>`.

## Step 4: Push and set upstream

```bash
git push -u origin <branch>
```

Use the `branch=` value from preflight. `-u` sets tracking, so later plain
`git push` and `git pull` work.

If the push is rejected, show the exact error and explain it. Do not retry with
`--force` or `--force-with-lease`.

## Step 5: Confirm

```bash
git status -sb
git remote -v
```

The first line should look like `## main...origin/main`. Tell the user the
remote URL and the branch now being tracked. If it's a GitHub repo, give them
the web URL (the remote URL without `.git`, in `https://github.com/owner/repo`
form).
