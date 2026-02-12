update() {
    parse_common_flags "$@"

    info "Updating dotfiles..."

    git -C "$DOTFILES_DIR" fetch

    if [ -n "$(git -C "$DOTFILES_DIR" status --porcelain)" ] && [ "$FORCE" -eq 0 ]; then
        error "Uncommitted changes. Use --force."
        exit 1
    fi

    git -C "$DOTFILES_DIR" pull --ff-only

    success "Updated."
}
