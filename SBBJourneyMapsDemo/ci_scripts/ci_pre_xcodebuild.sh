#!/bin/sh
set -euo pipefail

if [ -z "${JOURNEYMAPS_API_KEY:-}" ]; then
  echo "ERROR: JOURNEYMAPS_API_KEY is not set in Xcode Cloud workflow secrets." >&2
  exit 1
fi

INFO_PLIST="$CI_PRIMARY_REPOSITORY_PATH/SBBJourneyMapsDemo/SBBJourneyMapsDemo/Info.plist"

# Ensure the file exists
if [ ! -f "$INFO_PLIST" ]; then
  echo "ERROR: Info.plist not found at $INFO_PLIST" >&2
  exit 1
fi

# Set the API_KEY entry
/usr/libexec/PlistBuddy -c "Set :JOURNEYMAPS_API_KEY $JOURNEYMAPS_API_KEY" "$INFO_PLIST" || \
/usr/libexec/PlistBuddy -c "Add :JOURNEYMAPS_API_KEY string $JOURNEYMAPS_API_KEY" "$INFO_PLIST"

echo "Injected JOURNEYMAPS_API_KEY key into Info.plist $INFO_PLIST"