#!/usr/bin/env bash

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_DIR="$HOME"

DRY_RUN=0
INTERACTIVE=0
FORCE=0
LOG_FILE=""
OS_TYPE="unknown"
CAN_SYMLINK=1

# Colors
if [ -t 1 ]; then
    RED="\033[31m"
    GREEN="\033[32m"
    YELLOW="\033[33m"
    BLUE="\033[34m"
    RESET="\033[0m"
else
    RED=""; GREEN=""; YELLOW=""; BLUE=""; RESET=""
fi

info()    { echo -e "${BLUE}ℹ${RESET} $*"; }
success() { echo -e "${GREEN}✔${RESET} $*"; }
warn()    { echo -e "${YELLOW}⚠${RESET} $*"; }
error()   { echo -e "${RED}✖${RESET} $*"; }

log() {
    [ -n "$LOG_FILE" ] && echo "$*" >> "$LOG_FILE"
}

run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        info "[DRY RUN] $*"
        return
    fi
    log "$*"
    eval "$@"
}

confirm() {
    if [ "$INTERACTIVE" -eq 0 ]; then
        return 0
    fi
    read -rp "$1 [y/N]: " reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

parse_common_flags() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run) DRY_RUN=1 ;;
            --interactive) INTERACTIVE=1 ;;
            --force) FORCE=1 ;;
            --log)
                shift
                LOG_FILE="$1"
                ;;
            *)
                break
                ;;
        esac
        shift
    done
}

detect_os() {
    case "$(uname -s)" in
        Linux*) OS_TYPE="linux" ;;
        Darwin*) OS_TYPE="macos" ;;
        MINGW*|MSYS*) OS_TYPE="mingw" ;;
        CYGWIN*) OS_TYPE="cygwin" ;;
        *) OS_TYPE="unknown" ;;
    esac
}

detect_symlink_capability() {
    if [[ "$OS_TYPE" == "mingw" || "$OS_TYPE" == "cygwin" ]]; then
        if ln -s "$DOTFILES_DIR" "$HOME_DIR/.dotfiles_test" 2>/dev/null; then
            rm -f "$HOME_DIR/.dotfiles_test"
            CAN_SYMLINK=1
        else
            CAN_SYMLINK=0
            warn "Symlinks unavailable — using copy fallback."
        fi
    fi
}
