#!/usr/bin/env bash

doctor() {
    parse_common_flags "$@"
    detect_os
    detect_symlink_capability

    info "Running dotfiles doctor..."
    echo

    # ---------------------------------
    # OS
    # ---------------------------------
    info "Operating System"
    echo "  OS Type: $OS_TYPE"
    echo

    # ---------------------------------
    # Symlink Capability
    # ---------------------------------
    info "Symlink Capability"
    if [ "$CAN_SYMLINK" -eq 1 ]; then
        success "Symlinks supported"
    else
        warn "Symlinks NOT supported (copy fallback in use)"
    fi
    echo

    # ---------------------------------
    # Git Repo
    # ---------------------------------
    info "Git Repository"

    if git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        success "Valid git repository"

        branch="$(git -C "$DOTFILES_DIR" rev-parse --abbrev-ref HEAD)"
        echo "  Branch: $branch"

        if [ -n "$(git -C "$DOTFILES_DIR" status --porcelain)" ]; then
            warn "Uncommitted changes detected"
        else
            success "Working tree clean"
        fi
    else
        error "Not a git repository"
    fi

    echo

    # ---------------------------------
    # Git Identity
    # ---------------------------------
    info "Git Identity"

    name="$(git config --global user.name || true)"
    email="$(git config --global user.email || true)"

    [ -n "$name" ] && echo "  user.name : $name" || warn "  user.name not set"
    [ -n "$email" ] && echo "  user.email: $email" || warn "  user.email not set"

    echo

    # ---------------------------------
    # Secrets Check
    # ---------------------------------
    info "Secrets Health"

    AGE_KEY_FILE="${AGE_KEY_FILE:-$HOME/.config/age/key.txt}"
    ENCRYPTED_FILE="$DOTFILES_DIR/secrets/.env.age"
    DECRYPTED_FILE="$HOME/.config/secrets/.env"

    if command -v age >/dev/null 2>&1; then
        success "age installed"
    else
        warn "age not installed"
    fi

    if [ -f "$AGE_KEY_FILE" ]; then
        success "Age key present"
    else
        warn "Age key missing ($AGE_KEY_FILE)"
    fi

    if [ -f "$ENCRYPTED_FILE" ]; then
        success "Encrypted secrets file exists"
    else
        warn "Encrypted secrets file missing"
    fi

    if [ -f "$DECRYPTED_FILE" ]; then
        perms="$(stat -c "%a" "$DECRYPTED_FILE" 2>/dev/null || stat -f "%Lp" "$DECRYPTED_FILE" 2>/dev/null || echo "unknown")"
        echo "  Decrypted file permissions: $perms"

        if [ "$perms" != "600" ]; then
            warn "Decrypted .env should have 600 permissions"
        fi
    else
        info "No decrypted secrets currently present"
    fi

    # Check accidental plaintext in repo
    if [ -f "$DOTFILES_DIR/secrets/.env" ]; then
        error "Plaintext secrets file detected in repo!"
    fi

    echo
    success "Doctor finished."
}
