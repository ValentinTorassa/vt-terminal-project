#!/usr/bin/env bash
set -euo pipefail

echo "[*] Installing packages for macOS..."

# ---------- Homebrew ----------
if ! command -v brew &>/dev/null; then
  echo "[*] Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

if ! command -v brew &>/dev/null; then
  echo "[!] Homebrew is not installed and automatic installation failed."
  echo "    Install it manually: https://brew.sh"
  exit 1
fi

echo "[*] Updating Homebrew..."
brew update || echo "  [!] brew update had warnings, continuing..."

# ---------- Oh My Zsh ----------
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "[*] Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ---------- CLI tools (formulas) ----------
BREW_FORMULAS=(
  # Core
  git
  curl
  wget
  jq

  # Modern replacements
  fzf
  fd
  ripgrep
  bat
  eza
  zoxide
  thefuck
  tldr

  # Git/Docker TUIs
  lazygit
  lazydocker

  # System tools
  dust
  glow
  delta
  yazi
)

echo "[*] Installing CLI tools..."
for pkg in "${BREW_FORMULAS[@]}"; do
  if ! brew list --formula "$pkg" &>/dev/null; then
    echo "  -> $pkg"
    brew install "$pkg" || echo "  [!] Failed to install $pkg, continuing..."
  else
    echo "  -> $pkg (already installed)"
  fi
done

# ---------- GUI apps (casks) ----------
BREW_CASKS=(
  zed
  ghostty
  font-jetbrains-mono-nerd-font
)

echo "[*] Installing GUI apps..."
for cask in "${BREW_CASKS[@]}"; do
  if ! brew list --cask "$cask" &>/dev/null; then
    echo "  -> $cask"
    brew install --cask "$cask" || echo "  [!] Failed to install $cask, continuing..."
  else
    echo "  -> $cask (already installed)"
  fi
done

# ---------- fzf key bindings ----------
if [[ -f "$(brew --prefix)/opt/fzf/install" ]]; then
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
fi

echo "[*] macOS package installation complete!"
