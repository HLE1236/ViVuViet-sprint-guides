#!/bin/bash
# Sprint Helpers for macOS / Linux (bash & zsh)
# Usage: source ./scripts/sprint-helpers.sh

set_git_email_if_needed() {
  local email="$1"
  local fallback_name="$2"
  shift 2
  for repo in "$@"; do
    if [ ! -d "$repo" ]; then
      echo "Khong tim thay repo: $repo" >&2
      return 1
    fi
    git -C "$repo" config user.email "$email"
    if [ -z "$(git -C "$repo" config user.name 2>/dev/null)" ] && [ -n "$fallback_name" ]; then
      git -C "$repo" config user.name "$fallback_name"
    fi
  done
}

copy_rel() {
  local src_root="$1"
  local dst_root="$2"
  shift 2
  for p in "$@"; do
    local src="$src_root/$p"
    local dst="$dst_root/$p"
    if [ ! -e "$src" ]; then
      echo "Khong tim thay: $src" >&2
      return 1
    fi
    if [ -d "$src" ]; then
      mkdir -p "$dst"
      cp -R "$src"/. "$dst"/
    else
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
    fi
  done
}

sync_icons_index() {
  local src_root="$1"
  local dst_root="$2"
  local src_index="$src_root/src/components/icons/index.ts"
  local dst_dir="$dst_root/src/components/icons"
  local dst_index="$dst_dir/index.ts"
  if [ ! -f "$src_index" ]; then
    echo "Khong tim thay: $src_index" >&2
    return 1
  fi
  mkdir -p "$dst_dir"
  : > "$dst_index"
  while IFS= read -r line; do
    if [[ "$line" =~ \./([A-Za-z0-9_-]+) ]]; then
      local mod="${BASH_REMATCH[1]}"
      if [ -f "$dst_dir/$mod.tsx" ] || [ -f "$dst_dir/$mod.ts" ]; then
        echo "$line" >> "$dst_index"
      fi
    fi
  done < "$src_index"
}

fake_commit() {
  local repo_path="$1"
  local iso_date="$2"
  local message="$3"
  git -C "$repo_path" add -A
  git -C "$repo_path" reset -q HEAD -- AGENTS.md opencode.json 2>/dev/null || true
  if [ -z "$(git -C "$repo_path" status --porcelain)" ]; then
    echo "Bo qua (khong co thay doi): $message"
    return 0
  fi
  export GIT_AUTHOR_DATE="$iso_date"
  export GIT_COMMITTER_DATE="$iso_date"
  git -C "$repo_path" commit -m "$message"
  unset GIT_AUTHOR_DATE GIT_COMMITTER_DATE
}
