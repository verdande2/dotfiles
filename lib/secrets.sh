#!/usr/bin/env bash

SECRETS_DIR="$DOTFILES_DIR/secrets"
ENCRYPTED_FILE="$SECRETS_DIR/.env.age"
DECRYPTED_DIR="$HOME/.config/secrets"
DECRYPTED_FILE="$DECRYPTED_DIR/.env"
AGE_KEY_FILE="${AGE_KEY_FILE:-$HOME/.config/age/key.txt}"

secrets() {
    case "${1:-}" in
        encrypt)  secrets_encrypt ;;
        decrypt)  secrets_decrypt ;;
        edit)     secrets_edit ;;
        status)   secrets_status ;;
        *)
            echo "Usage:"
            echo "  ./dotfiles secrets encrypt"
            echo "  ./dotfiles secrets decrypt"
            echo "  ./dotfiles secrets edit"
            echo "  ./dotfiles secrets status"
            ;;
    esac
}

require_age() {
    if ! command -v age >/dev/null 2>&1; then
        error "age is not installed."
        error "Install from: https://github.com/FiloSottile/age"
        exit 1
    fi
}

require_age_key() {
    if [ ! -f "$AGE_KEY_FILE" ]; then
        error "Age key not found at $AGE_KEY_FILE"
        echo
        echo "Generate one using:"
        echo "  age-keygen -o $AGE_KEY_FILE"
        exit 1
    fi
}

secrets_encrypt() {
    require_age

    if [ ! -f "$DECRYPTED_FILE" ]; then
        error "No decrypted .env found at $DECRYPTED_FILE"
        exit 1
    fi

    mkdir -p "$SECRETS_DIR"

    recipient="$(grep '^# public key:' "$AGE_KEY_FILE" | awk '{print $4}')"

    if [ -z "$recipient" ]; then
        error "Could not extract public key from $AGE_KEY_FILE"
        exit 1
    fi

    info "Encrypting secrets..."
    age -r "$recipient" -o "$ENCRYPTED_FILE" "$DECRYPTED_FILE"

    success "Encrypted to $ENCRYPTED_FILE"
}

secrets_decrypt() {
    require_age
    require_age_key

    if [ ! -f "$ENCRYPTED_FILE" ]; then
        error "Encrypted file not found: $ENCRYPTED_FILE"
        exit 1
    fi

    mkdir -p "$DECRYPTED_DIR"

    info "Decrypting secrets..."
    age -d -i "$AGE_KEY_FILE" -o "$DECRYPTED_FILE" "$ENCRYPTED_FILE"

    chmod 600 "$DECRYPTED_FILE"

    success "Secrets decrypted to $DECRYPTED_FILE"
}

secrets_edit() {
    require_age
    require_age_key

    mkdir -p "$DECRYPTED_DIR"

    if [ -f "$ENCRYPTED_FILE" ]; then
        secrets_decrypt
    else
        warn "No encrypted file found. Creating new .env"
        touch "$DECRYPTED_FILE"
    fi

    ${EDITOR:-vim} "$DECRYPTED_FILE"

    secrets_encrypt
}

secrets_status() {
    echo
    info "Secrets Status"

    if command -v age >/dev/null 2>&1; then
        success "age installed"
    else
        warn "age NOT installed"
    fi

    if [ -f "$AGE_KEY_FILE" ]; then
        success "Age key present"
    else
        warn "Age key missing ($AGE_KEY_FILE)"
    fi

    if [ -f "$ENCRYPTED_FILE" ]; then
        success "Encrypted secrets present"
    else
        warn "Encrypted secrets missing"
    fi

    if [ -f "$DECRYPTED_FILE" ]; then
        warn "Decrypted .env present (ensure this is gitignored)"
    else
        info "No decrypted .env present"
    fi

    echo
}
