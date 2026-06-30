#!/usr/bin/env bash
#
# Checks every recipe that builds from a GitHub release tarball for a newer
# upstream version. For each one that is behind, it rewrites the recipe's
# context.version, source.sha256, and build.number (reset to 0) in place.
#
# A summary of the bumps is written to .recipe-updates.txt at the repo root
# (only when something changed) so the calling workflow can open a PR.
#
# Requires: gh (authenticated), curl, sha256sum, sed, grep.
# Optionally pass one or more recipe names to limit the check, e.g.
#   ./scripts/check-recipe-updates.sh croppy pixiline
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
summary_file="$repo_root/.recipe-updates.txt"
rm -f "$summary_file"

# Build the list of recipes to check (all of them by default).
if [ "$#" -gt 0 ]; then
  recipes=()
  for name in "$@"; do
    recipes+=("$repo_root/recipes/$name/recipe.yaml")
  done
else
  recipes=("$repo_root"/recipes/*/recipe.yaml)
fi

changed=()

for recipe in "${recipes[@]}"; do
  [ -f "$recipe" ] || { echo "::warning::no recipe at $recipe"; continue; }
  name="$(basename "$(dirname "$recipe")")"

  # Only handle recipes whose source is a GitHub archive tarball.
  url_line="$(grep -E '^[[:space:]]*url:[[:space:]]*https://github.com/' "$recipe" || true)"
  if [ -z "$url_line" ]; then
    echo "$name: not a github-tarball recipe, skipping"
    continue
  fi

  # .../github.com/OWNER/REPO/archive/refs/tags/v${{ version }}.tar.gz
  slug="$(printf '%s' "$url_line" | sed -E 's#.*github.com/([^/]+/[^/]+)/archive.*#\1#')"

  # Current version is the first quoted version line (context.version).
  current="$(sed -nE 's/^[[:space:]]*version:[[:space:]]*"([^"]+)".*/\1/p' "$recipe" | head -1)"
  if [ -z "$current" ]; then
    echo "::warning::$name: could not read current version"
    continue
  fi

  latest_tag="$(gh release view --repo "$slug" --json tagName -q .tagName 2>/dev/null || true)"
  if [ -z "$latest_tag" ]; then
    echo "::warning::$name: no GitHub release found for $slug"
    continue
  fi
  latest="${latest_tag#v}"

  if [ "$current" = "$latest" ]; then
    echo "$name: up to date ($current)"
    continue
  fi

  echo "$name: $current -> $latest"
  dl="https://github.com/$slug/archive/refs/tags/${latest_tag}.tar.gz"
  sha="$(curl -fsSL "$dl" | sha256sum | cut -d' ' -f1)"

  # context.version: replace the first quoted version line only (leaves
  # package.version: ${{ version }} untouched).
  sed -i -E "0,/^([[:space:]]*version:[[:space:]]*)\"[^\"]+\"/s//\1\"$latest\"/" "$recipe"
  # source.sha256
  sed -i -E "s/^([[:space:]]*sha256:[[:space:]]*).*/\1$sha/" "$recipe"
  # build.number resets to 0 on a fresh version.
  sed -i -E "s/^([[:space:]]*number:[[:space:]]*).*/\10/" "$recipe"

  changed+=("$name: $current -> $latest")
done

if [ "${#changed[@]}" -eq 0 ]; then
  echo "No recipe updates available."
  exit 0
fi

{
  for c in "${changed[@]}"; do
    echo "- $c"
  done
} > "$summary_file"

echo
echo "Updated ${#changed[@]} recipe(s); summary written to $summary_file"
