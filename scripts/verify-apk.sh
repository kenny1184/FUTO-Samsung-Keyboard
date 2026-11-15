#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
apk="${1:?Give the path to the APK}"
sdk_dir="${ANDROID_HOME:-${ANDROID_SDK_ROOT:?Set ANDROID_HOME to the Android SDK}}"
build_tools="$sdk_dir/build-tools/35.0.0"

"$build_tools/apksigner" verify --print-certs "$apk"
unzip -tq "$apk"

badging="$("$build_tools/aapt" dump badging "$apk")"
permissions="$("$build_tools/aapt" dump permissions "$apk")"
manifest="$("$build_tools/aapt" dump xmltree "$apk" AndroidManifest.xml)"

if [[ "$badging" != *"package: name='org.futo.inputmethod.latin.s25'"* ]]; then
    echo "The APK is missing the separate S25 package ID." >&2
    exit 1
fi
if [[ "$badging" != *"native-code:"*"'arm64-v8a'"* ]]; then
    echo "The APK is missing the S25 Ultra's arm64-v8a ABI." >&2
    exit 1
fi
if [[ "$permissions" == *"android.permission.INTERNET"* ]]; then
    echo "The APK requests internet access." >&2
    exit 1
fi
if ! awk '/android:allowBackup\(/ && /0x0$/ { disabled = 1 } END { exit !disabled }' <<< "$manifest"; then
    echo "The APK does not disable Android automatic backup." >&2
    exit 1
fi

for layout in "$repo_dir"/layouts/samsung_s25*.yaml; do
    unzip -p "$apk" "assets/layouts/${layout##*/}" | cmp "$layout" -
done

python3 - "$apk" <<'PY'
import sys
from zipfile import ZipFile

models = (
    "honorable_sturgeon/model_fp32.pte",
    "magic_macaw/model_fp32.pte",
    "chosen_planarian/context_lm.pte",
)
with ZipFile(sys.argv[1]) as apk:
    for language in ("en", "nl"):
        path = f"res/raw/main_{language}.dict"
        with apk.open(path) as dictionary:
            if dictionary.read(6) != bytes.fromhex("9bc13afe00ca"):
                raise SystemExit(f"Offline dictionary has an unexpected format: {path}")

    for model in models:
        entry = apk.getinfo(f"assets/futo-swipe/{model}")
        if entry.file_size < 4096:
            raise SystemExit(f"Offline swipe model missing or still a Git LFS pointer: {model}")
PY

echo "Verified the signed S25 APK, its layouts, offline dictionaries and privacy settings."
