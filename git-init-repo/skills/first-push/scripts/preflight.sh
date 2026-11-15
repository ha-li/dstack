#!/usr/bin/env bash
# Prints the repo's state as key=value lines so the first-push skill can
# decide what to do. It only reads; it never changes the repo.
set -u

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "is_repo=no"
  exit 0
fi
echo "is_repo=yes"
echo "repo_root=$(git rev-parse --show-toplevel)"

# Branch (empty when HEAD is detached)
branch=$(git branch --show-current)
if [ -z "$branch" ]; then
  echo "detached_head=yes"
else
  echo "detached_head=no"
fi
echo "branch=$branch"

# Commit count (0 in a brand-new repo)
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  echo "commits=$(git rev-list --count HEAD)"
else
  echo "commits=0"
fi

# Uncommitted changes (they won't be pushed; the user may want them included)
echo "uncommitted_changes=$(git status --porcelain | wc -l | tr -d ' ')"

# Existing remotes, as name=url pairs separated by spaces
remotes=$(git remote -v | awk '$3=="(push)"{printf "%s=%s ", $1, $2}')
echo "remotes=${remotes% }"

# Committed files that look like secrets
secrets=$(git ls-files | grep -E '(^|/)(\.env(\..+)?|id_rsa|id_ed25519|[^/]*\.pem|[^/]*\.key|credentials(\.json)?|\.npmrc|\.pypirc)$' \
  | grep -vE '\.env\.(example|sample|template)$' | tr '\n' ' ')
echo "secret_candidates=${secrets% }"

# Committed files over 100 MB (GitHub's hard limit)
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  large=$(git ls-tree -r -l HEAD | awk '$4 != "-" && $4 > 100000000 {print $5}' | tr '\n' ' ')
else
  large=""
fi
echo "large_files=${large% }"

# Is the GitHub CLI installed and logged in?
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  echo "gh_ready=yes"
else
  echo "gh_ready=no"
fi
