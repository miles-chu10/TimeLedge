#!/usr/bin/env bash
set -euo pipefail

swift package resolve
git status --short
