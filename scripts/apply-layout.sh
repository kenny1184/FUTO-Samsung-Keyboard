#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
futo_dir="$(cd "${1:?Give the path to the FUTO checkout}" && pwd)"
revision=7d61ab4132cfcbb7aa713190d934f0125dc38b03
patch="$repo_dir/patches/futo-samsung-s25-ultra.patch"
layouts_dir="$futo_dir/java/assets/layouts"

if [[ "$(git -C "$futo_dir" rev-parse HEAD)" != "$revision" ]]; then
    echo "Expected FUTO revision $revision." >&2
    exit 1
fi
if [[ ! -f "$layouts_dir/mapping.yaml" ]]; then
    echo "Initialize the FUTO layout submodule before applying the patch." >&2
    exit 1
fi

git -C "$futo_dir" apply --check "$patch"
git -C "$futo_dir" apply "$patch"
install -m 0644 "$repo_dir"/layouts/samsung_s25*.yaml "$layouts_dir/"
install -D -m 0644 "$futo_dir/LICENSE.md" "$futo_dir/java/assets/licenses/FUTO-LICENSE.md"
install -D -m 0644 "$futo_dir/NOTICE" "$futo_dir/java/assets/licenses/AOSP-NOTICE"
