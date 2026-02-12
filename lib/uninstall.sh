#!/usr/bin/env bash

uninstall() {
    parse_common_flags "$@"

    info "Uninstalling dotfiles..."

    if ! confirm "This will remove installed dotfiles from $HOME_DIR. Continue?"; then
        warn "Aborted."
        exit 0
    fi

    # Remove home dotfiles
    for file in "$DOTFILES_DIR/home/".*; do
        [ -e "$file" ] || continue
        dest="$HOME_DIR/$(basename "$file")"

        if [ -L "$dest" ] || [ -e "$dest" ]; then
            info "Removing $dest"
            run "rm -rf \"$dest\""
        fi
    done

    # Remove known extras
    for extra in ".vim" ".vimrc" ".bash_aliases" ".gitignore_global"; do
        dest="$HOME_DIR/$extra"
        if [ -L "$dest" ] || [ -e "$dest" ]; then
            info "Removing $dest"
            run "rm -rf \"$dest\""
        fi
    done

    echo
    success "Dotfiles removed."

    # Offer restore
    latest_backup="$(ls -dt "$HOME_DIR"/.dotfiles_backup_* 2>/dev/null | head -n 1 || true)"

    if [ -n "$latest_backup" ]; then
        echo
        if confirm "Restore latest backup from $latest_backup?"; then
            info "Restoring backup..."
            run "cp -r \"$latest_backup\"/* \"$HOME_DIR\"/"
            success "Backup restored."
        fi
    fi

    success "Uninstall complete."
}
