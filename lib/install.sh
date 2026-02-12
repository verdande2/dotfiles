install() {
    parse_common_flags "$@"
    detect_os
    detect_symlink_capability

    info "Installing dotfiles..."

    for file in "$DOTFILES_DIR/home/".*; do
        [ -e "$file" ] || continue
        dest="$HOME_DIR/$(basename "$file")"
        install_item "$file" "$dest"
    done

    success "Install complete."
}
