#!/usr/bin/env bash
set -euo pipefail

source_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
dest_dir="${HOME}/.codex/skills"

mkdir -p "$dest_dir"

synced=0
skipped=0

for skill in "$source_dir"/*; do
  [[ -d "$skill" ]] || continue
  [[ -f "$skill/SKILL.md" ]] || continue

  name="$(basename "$skill")"
  dest="${dest_dir}/${name}"

  if [[ -e "$dest" && ! -L "$dest" ]]; then
    printf 'Skipping %s: %s exists and is not a symlink\n' "$name" "$dest" >&2
    ((skipped += 1))
    continue
  fi

  ln -sfn "$skill" "$dest"
  ((synced += 1))
done

printf 'Synced %d skills to %s' "$synced" "$dest_dir"
if ((skipped > 0)); then
  printf ' (%d skipped)' "$skipped"
fi
printf '\n'
