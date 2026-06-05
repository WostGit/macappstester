#!/bin/zsh
set -euo pipefail
APP="EnterpriseDownloadableLevel1.app"
xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true
open "$APP"
