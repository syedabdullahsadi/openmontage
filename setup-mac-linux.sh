#!/usr/bin/env bash
# OpenMontage one-click setup for macOS / Ubuntu / Debian
# Run:  bash setup-mac-linux.sh
set -euo pipefail

echo "==> Installing prerequisites (Python, FFmpeg, Node.js, Git)..."
if [[ "$(uname)" == "Darwin" ]]; then
    if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
    fi
    brew install python@3.12 ffmpeg node git make
else
    sudo apt-get update
    sudo apt-get install -y python3 python3-venv python3-pip ffmpeg git make curl ca-certificates
    # Distro Node.js is often too old; install Node 20 LTS from NodeSource
    node_major=$(node -v 2>/dev/null | sed 's/v\([0-9]*\).*/\1/' || echo 0)
    if [[ "${node_major:-0}" -lt 18 ]]; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
fi

echo "==> Installing Claude Code..."
command -v claude >/dev/null 2>&1 || curl -fsSL https://claude.ai/install.sh | bash

echo "==> Cloning OpenMontage..."
target="$HOME/OpenMontage"
[[ -d "$target" ]] || git clone https://github.com/calesthio/OpenMontage.git "$target"
cd "$target"

echo "==> Running make setup..."
make setup

echo
echo "Done! OpenMontage is at $target"
echo "Next:"
echo "  cd $target && source .venv/bin/activate"
echo "  claude        # then ask: Make a 60-second animated explainer about ..."
