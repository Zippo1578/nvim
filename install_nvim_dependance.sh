#!/usr/bin/env bash
set -euo pipefail

# ===========================================
# Neovim Nightly Installer (User-local)
# Works in minimal container environments
# ===========================================

### -------------------------
### Config
### -------------------------
NVIM_BRANCH="nightly"
FZF_VERSION="latest"
TREESITTERCLI_VERSION="latest"
LAZYGIT_VERSION="latest"
NODE_JS_VERSION="24"
NERD_FONT="Mononoki"
REQUIRED_CMDS=(curl jq tar unzip cp chmod git tar vim python3 jq curl rg luarocks fc-cache sudo)

NVIM_CONFIG_DIR="${HOME}/.config/nvim"
LOCAL_BIN="${HOME}/.local/bin"
LOCAL_SHARE="${HOME}/.local/share"
LOCAL_FONTS="${LOCAL_SHARE}/fonts"
BASHRC="${HOME}/.bashrc"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$LOCAL_BIN" "$LOCAL_SHARE" "$LOCAL_FONTS"

### -------------------------
### Ensure LOCAL_BIN in PATH
### -------------------------
if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
  echo "➕ Adding $LOCAL_BIN to PATH in $BASHRC"
  echo "" >> "$BASHRC"
  echo "# Added by nvim installer on $(date)" >> "$BASHRC"
  echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$BASHRC"
  export PATH="$LOCAL_BIN:$PATH"
fi

### -------------------------
### Arch detection
### -------------------------
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) FZF_ARCH="linux_amd64"; NVIM_ARCH="linux-x86_64" ;;
  aarch64|arm64) FZF_ARCH="linux_arm64"; NVIM_ARCH="linux-arm64" ;;
  *) echo "❌ Unsupported architecture: $ARCH"; exit 1 ;;
esac

### -------------------------
### Pre-install dependency check
### -------------------------
for cmd in "${REQUIRED_CMDS[@]}"; do
  if ! command -v "$cmd" >/dev/null; then
    echo "❌ Missing required command: $cmd"
    exit 1
  fi
done

### -------------------------
### Install fzf (GitHub binary)
### -------------------------
echo "📦 Installing fzf (${FZF_VERSION})"

FZF_API="https://api.github.com/repos/junegunn/fzf/releases/${FZF_VERSION}"
FZF_URL=$(curl -s "$FZF_API" | jq -r ".assets[] | select(.name | test(\"${FZF_ARCH}\")) | .browser_download_url")

if [[ -z "$FZF_URL" || "$FZF_URL" == "null" ]]; then
  echo "❌ Could not find fzf binary for ${FZF_ARCH}"
  exit 1
fi

cd "$TMP_DIR"
curl -fLO "$FZF_URL"
tar xzf "$(basename "$FZF_URL")"

cp -f fzf "$LOCAL_BIN/fzf"
chmod 0750 "$LOCAL_BIN/fzf"

### -------------------------
### Install Neovim Nightly
### -------------------------
echo "📦 Installing Neovim (${NVIM_BRANCH})"

NVIM_API="https://api.github.com/repos/neovim/neovim/releases/tags/${NVIM_BRANCH}"
NVIM_URL=$(curl -s "$NVIM_API" | jq -r ".assets[] | select(.browser_download_url | test(\"${NVIM_ARCH}.*appimage\$\")) | .browser_download_url")

if [[ -z "$NVIM_URL" || "$NVIM_URL" == "null" ]]; then
  echo "❌ Could not find Neovim build for ${NVIM_ARCH}"
  exit 1
fi

echo "⬇️  Downloading Neovim AppImage to $LOCAL_BIN/nvim..."
curl -fLo "$LOCAL_BIN/nvim" "$NVIM_URL"
chmod 0750 "$LOCAL_BIN/nvim"

# Ensure AppImage extracts runtime automatically
if ! grep -q "APPIMAGE_EXTRACT_AND_RUN" "$BASHRC"; then
  echo "export APPIMAGE_EXTRACT_AND_RUN=1" >> "$BASHRC"
fi

"$LOCAL_BIN/nvim" --appimage-extract-and-run --version | head -n 3

### -------------------------
### Setup Neovim directories
### -------------------------
mkdir -p "${HOME}/.config/nvim" "${LOCAL_SHARE}/nvim/site/pack/plugins/start"

### -------------------------
### Install tree-sitter CLI (latest release)
### -------------------------
echo "🌳 Installing tree-sitter CLI"

# Get latest release tag from GitHub API
TS_API="https://api.github.com/repos/tree-sitter/tree-sitter/releases/${TREESITTERCLI_VERSION}"
TS_TAG=$(curl -s "$TS_API" | jq -r '.tag_name')

case "$ARCH" in
  x86_64) TS_ASSET="tree-sitter-linux-x64.gz" ;;
  aarch64|arm64) TS_ASSET="tree-sitter-linux-arm64.gz" ;;
  *) echo "❌ Unsupported architecture for tree-sitter: $ARCH"; exit 1 ;;
esac

# Get download URL for the asset
TS_URL=$(curl -s "$TS_API" | jq -r ".assets[] | select(.name==\"${TS_ASSET}\") | .browser_download_url")

if [[ -z "$TS_URL" || "$TS_URL" == "null" ]]; then
  echo "❌ Could not find tree-sitter binary for $ARCH"
  exit 1
fi

cd "$TMP_DIR"
curl -fLO "$TS_URL"
gunzip -f "$TS_ASSET"

# Move and make executable
mv "${TS_ASSET%.gz}" "$LOCAL_BIN/tree-sitter"
chmod 0750 "$LOCAL_BIN/tree-sitter"

# Verify install
if ! "$LOCAL_BIN/tree-sitter" --version >/dev/null 2>&1; then
  echo "❌ tree-sitter CLI installation failed"
  exit 1
fi

echo "✅ tree-sitter CLI installed: $($LOCAL_BIN/tree-sitter --version)"

### -------------------------
### Install Neovim config (Zippo1578/nvim)
### -------------------------
echo "📥 Installing Neovim config from Zippo1578/nvim"

# Backup existing config if present
if [[ -d "$NVIM_CONFIG_DIR" && -n "$(ls -A "$NVIM_CONFIG_DIR" 2>/dev/null)" ]]; then
  echo "⚠️  Existing nvim config detected — backing up"
  mv "$NVIM_CONFIG_DIR" "${NVIM_CONFIG_DIR}.bak.$(date +%s)"
fi

git clone --depth=1 https://github.com/Zippo1578/nvim.git "$NVIM_CONFIG_DIR"


### -------------------------
### Install lazygit (latest release)
### -------------------------
echo "📦 Installing lazygit"

LAZYGIT_API="https://api.github.com/repos/jesseduffield/lazygit/releases/${LAZYGIT_VERSION}"

# Determine arch mapping
case "$ARCH" in
  x86_64) LAZYGIT_ARCH="linux_x86_64" ;;
  aarch64|arm64) LAZYGIT_ARCH="linux_arm64" ;;
  *) echo "❌ Unsupported architecture for lazygit: $ARCH"; exit 1 ;;
esac

LAZYGIT_URL=$(curl -s "$LAZYGIT_API" | jq -r ".assets[] | select(.name | test(\"${LAZYGIT_ARCH}.*tar.gz$\")) | .browser_download_url")

if [[ -z "$LAZYGIT_URL" || "$LAZYGIT_URL" == "null" ]]; then
  echo "❌ Could not find lazygit binary for $ARCH"
  exit 1
fi

cd "$TMP_DIR"
curl -fLO "$LAZYGIT_URL"
tar xzf "$(basename "$LAZYGIT_URL")"

# The tarball contains a single 'lazygit' binary
cp -f lazygit "$LOCAL_BIN/lazygit"
chmod 0750 "$LOCAL_BIN/lazygit"

# Verify
if ! "$LOCAL_BIN/lazygit" --version >/dev/null 2>&1; then
  echo "❌ lazygit installation failed"
  exit 1
fi

echo "✅ lazygit installed: $($LOCAL_BIN/lazygit --version)"


### -------------------------
### Install Nerd Font
### -------------------------
echo "🎨 Installing Nerd Font: $NERD_FONT"

FONT_API="https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"
FONT_TAG=$(curl -s "$FONT_API" | jq -r '.tag_name')
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_TAG}/${NERD_FONT}.zip"

cd "$TMP_DIR"
curl -fLO "$FONT_URL"
unzip -o "${NERD_FONT}.zip" -d "$LOCAL_FONTS"
fc-cache -vf "$LOCAL_FONTS"

### -------------------------
### Install npm + node
### https://nodejs.org/en/download/
### -------------------------

# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# in lieu of restarting the shell
\. "${HOME}/.nvm/nvm.sh"

# Download and install Node.js:
nvm install ${NODE_JS_VERSION}

# Verify the Node.js version:
node -v # Should print "v24.12.0".

# Verify npm version:
npm -v # Should print "11.6.2".

### -------------------------
### Run Neovim headless setup
### -------------------------
echo "⚙️  Running Neovim headless setup"

# Reload Bashrc
source ${BASHRC}

# issue https://github.com/NvChad/ui/issues/507
# :MasonToolsInstallSync dosnt work in headless
"$LOCAL_BIN/nvim" --appimage-extract-and-run --headless \
  -c 'Lazy! sync' \
  -c 'Lazy load nvim-treesitter' \
  -c 'TSUpdate' \
  -c 'Lazy load mason.nvim' \
  -c 'lua require("nvim-treesitter.install").update({force = true}):wait()' \
  -c 'Lazy load mason.nvim mason-lspconfig.nvim nvim-lspconfig mason-tool-installer.nvim' \
  -c 'MasonInstall lua-language-server ansible-language-server bash-language-server stylua yaml-language-server'  \
  -c 'qa'

### -------------------------
### Done
### -------------------------
echo "✅ Installation complete!"
echo "Restart your shell or run: source ~/.bashrc"

