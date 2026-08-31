#!/usr/bin/env bash
# ==============================================================================
# The Workshop - Jailed IPA Modification Patch Script
# Target: Sideloadable iOS Application Packaging
# ==============================================================================

set -e

IPA_INPUT="TargetApp.ipa"
IPA_OUTPUT="ModifiedApp.ipa"
DYLIB_NAME="WorkshopTweak.dylib"

echo "========================================================"
echo "  BUILDING JAILED MODIFICATION PACKAGE"
echo "========================================================"

# 1. Extract Target IPA Bundle
echo "[1/4] Unpacking IPA..."
rm -rf extracted
unzip -q "$IPA_INPUT" -d extracted

# 2. Patch Assets & Resources
echo "[2/4] Patching Bundle Assets..."
if [ -d "assets" ]; then
    cp -Rf assets/* extracted/Payload/*.app/
fi

# 3. Inject Dylib & Resign
echo "[3/4] Injecting Dynamic Library..."
if [ -f "$DYLIB_NAME" ]; then
    optool inject -s -t "extracted/Payload/*.app/TargetApp" -p "@executable_path/$DYLIB_NAME"
fi

# 4. Repackage IPA
echo "[4/4] Packing Modified IPA..."
cd extracted
zip -qr "../$IPA_OUTPUT" Payload
cd ..

echo "========================================================"
echo "  SUCCESS! Jailed IPA ready for sideloading: $IPA_OUTPUT"
echo "========================================================"
