#!/bin/bash
# Sign the complete bundle before packaging. Never treat ad hoc as Developer ID.
set -euo pipefail
app_path="${1:?Usage: sign-macos-app.sh /path/to/KuroCat.app}"
bundle_id="com.kurocat.pet"
[[ -d "$app_path/Contents" ]] || { echo 'App bundle missing' >&2; exit 1; }
if [[ -n "${APPLE_SIGNING_IDENTITY:-}" ]]; then
  [[ "$APPLE_SIGNING_IDENTITY" == 'Developer ID Application:'* ]] || { echo 'Use a Developer ID Application identity.' >&2; exit 1; }
  : "${APPLE_NOTARY_PROFILE:?Provide a notarytool keychain profile for notarization}"
  codesign --force --options runtime --timestamp --sign "$APPLE_SIGNING_IDENTITY" --identifier "$bundle_id" "$app_path"
  codesign --verify --strict --all-architectures --verbose=2 "$app_path"
  temp_dir=$(mktemp -d)
  trap 'rm -rf "$temp_dir"' EXIT
  ditto -c -k --sequesterRsrc --keepParent "$app_path" "$temp_dir/notarize.zip"
  xcrun notarytool submit "$temp_dir/notarize.zip" --keychain-profile "$APPLE_NOTARY_PROFILE" --wait
  # Stapling fails if the service did not accept the submitted app.
  xcrun stapler staple "$app_path"
  xcrun stapler validate "$app_path"
  spctl --assess --type execute --verbose=2 "$app_path"
  echo 'Developer ID signature and notarization verified.'
else
  [[ "${ALLOW_ADHOC:-0}" == 1 ]] || { echo 'No Developer ID identity configured. Refusing a formal macOS release. Set ALLOW_ADHOC=1 only for explicitly unnotarized test builds.' >&2; exit 1; }
  codesign --force --sign - --identifier "$bundle_id" "$app_path"
  codesign --verify --strict --all-architectures --verbose=2 "$app_path"
  echo 'WARNING: local ad hoc signature only; NOT Apple Developer ID signed or notarized. Updates may require renewed permissions.' >&2
fi
