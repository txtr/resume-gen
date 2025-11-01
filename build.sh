#!/bin/bash

# =============================================================================
# Script: run.sh
# Purpose: Set up Python virtual environment and run main.py
# =============================================================================

set -euo pipefail  # Exit on error, undefined var, pipe failure
IFS=$'\n\t'        # Better word splitting

# --- Configuration ---
VENV_DIR=".venv"
REQUIREMENTS="requirements.txt"
MAIN_SCRIPT="main.py"
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # Script dir

# --- Helper Functions ---
log() {
    echo "[+] $*" >&2
}

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

# --- Main ---
main() {
    cd "$WORKSPACE_ROOT"

    # Step 1: Create virtual environment if it doesn't exist
    if [[ ! -d "$VENV_DIR" ]]; then
        log "Virtual environment not found. Creating '$VENV_DIR'..."
        python3 -m venv "$VENV_DIR" || error "Failed to create virtual environment. Is 'python3 -m venv' available?"
    else
        log "Virtual environment found: '$VENV_DIR'"
    fi

    # Step 2: Activate virtual environment
    # shellcheck source=/dev/null
    source "$VENV_DIR/bin/activate" || error "Failed to activate virtual environment"

    # Step 3: Upgrade pip
    log "Upgrading pip..."
    pip install --upgrade pip > /dev/null

    # Step 4: Install requirements if requirements.txt exists
    if [[ -f "$REQUIREMENTS" ]]; then
        log "Installing dependencies from '$REQUIREMENTS'..."
        pip install -r "$REQUIREMENTS" || error "Failed to install requirements"
    else
        log "No '$REQUIREMENTS' found. Skipping dependency installation."
    fi

    # Step 5: Run the main script
    if [[ -f "$MAIN_SCRIPT" ]]; then
        log "Running '$MAIN_SCRIPT'..."
        python "$MAIN_SCRIPT" "$@"
    else
        error "Main script '$MAIN_SCRIPT' not found!"
    fi

    # Step 6: Deactivate (optional, for clarity)
    deactivate 2>/dev/null || true

    log "Done."
}

# Run main with all script arguments
main "$@"
