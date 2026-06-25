#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

find "$REPO_ROOT" -type f -name "*.sh" -print0 |
  xargs -0 shfmt -i 2 -w
