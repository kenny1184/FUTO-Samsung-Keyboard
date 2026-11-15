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

# Binary v202 of the Dutch AOSP wordlist already present in FUTO's dictionaries/.
dictionary_dir="$(mktemp -d)"
trap 'rm -rf -- "$dictionary_dir"' EXIT
dictionary="$dictionary_dir/main_nl.dict"
dictionary_revision=ff0cd52be8d9530200fefe8b296c53d4f662091e
dictionary_url="https://codeberg.org/Helium314/aosp-dictionaries/raw/commit/$dictionary_revision/dictionaries/main_nl.dict"
curl --fail --location --silent --show-error --proto '=https' --proto-redir '=https' \
    --retry 3 --connect-timeout 15 --max-time 120 --output "$dictionary" "$dictionary_url"
printf '537078e3ba369c87063031f03051d80a0ee121a5459f8192811ca254fc959d19  %s\n' "$dictionary" |
    sha256sum --check

git -C "$futo_dir" apply "$patch"
install -m 0644 "$repo_dir"/layouts/samsung_s25*.yaml "$layouts_dir/"
install -D -m 0644 "$dictionary" "$futo_dir/java/res-large/raw/main_nl.dict"
install -D -m 0644 "$futo_dir/LICENSE.md" "$futo_dir/java/assets/licenses/FUTO-LICENSE.md"
install -D -m 0644 "$futo_dir/NOTICE" "$futo_dir/java/assets/licenses/AOSP-NOTICE"
cat > "$futo_dir/java/assets/licenses/DUTCH-DICTIONARY-NOTICE.txt" <<EOF
Dutch AOSP LatinIME dictionary (main:nl, version 54).
Wordlist: dictionaries/nl_wordlist.combined.gz in FUTO revision $revision.
Binary: $dictionary_url
See AOSP-NOTICE for the Android Open Source Project notice and license.
EOF
