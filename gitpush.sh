#!/bin/bash
# gitpush.sh - Git push helper for Freight Management app
# Version: 1.0.0

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="Freight Management"
REPO_URL="git@github.com:rogerboy38/freight_management.git"
USER_NAME="rogerboy38"
USER_EMAIL="rogerboy38@hotmail.com"

print_status() { echo -e "${BLUE}➤${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

show_header() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                 Freight Management Git Helper                ║"
    echo "║                        Version 1.0.0                         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo "Repository: https://github.com/rogerboy38/freight_management"
    echo "================================================================"
}

check_git_setup() {
    # Initialize git if needed
    if [ ! -d .git ]; then
        print_status "Initializing git repository..."
        git init
        git config user.email "$USER_EMAIL"
        git config user.name "$USER_NAME"
    fi
    
    # Set git config
    git config user.email "$USER_EMAIL" 2>/dev/null || true
    git config user.name "$USER_NAME" 2>/dev/null || true
    
    # Set remote if needed
    if ! git remote get-url origin > /dev/null 2>&1; then
        print_status "Setting remote origin..."
        git remote add origin "$REPO_URL"
    else
        # Update remote URL
        git remote set-url origin "$REPO_URL"
    fi
    
    print_success "Git setup complete"
}

check_ssh() {
    print_status "Testing SSH connection to GitHub..."
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        print_success "SSH connection verified"
        return 0
    else
        print_error "SSH connection failed"
        echo "Make sure your SSH key is added to GitHub:"
        echo "1. Check key: cat ~/.ssh/id_ed25519.pub"
        echo "2. Add at: https://github.com/settings/keys"
        return 1
    fi
}

auto_commit_message() {
    local changed_files=$(git status --porcelain | wc -l)
    if [ "$changed_files" -eq 0 ]; then
        echo "No changes"
    elif [ "$changed_files" -eq 1 ]; then
        echo "Update: $(git status --porcelain | cut -c4- | head -1)"
    elif [ "$changed_files" -le 3 ]; then
        echo "Update: $(git status --porcelain | cut -c4- | tr '\n' ',' | sed 's/,/, /g' | sed 's/, $//')"
    else
        echo "Update: $changed_files files"
    fi
}

show_changes() {
    local changed=$(git status --porcelain | wc -l)
    if [ "$changed" -gt 0 ]; then
        print_status "Changes to be committed ($changed files):"
        echo "----------------------------------------"
        git status --short
        echo "----------------------------------------"
    else
        print_status "No changes detected"
    fi
}

main() {
    show_header
    
    # Check and setup git
    check_git_setup
    
    # Check SSH
    check_ssh || return 1
    
    # Show current status
    print_status "Current branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
    
    # Check for changes
    if [ -z "$(git status --porcelain)" ]; then
        print_status "No changes to commit"
        return 0
    fi
    
    # Show changes
    show_changes
    
    # Get commit message
    local commit_msg="${1:-}"
    if [ -z "$commit_msg" ]; then
        commit_msg=$(auto_commit_message)
        if [ "$commit_msg" = "No changes" ]; then
            print_status "No changes to commit"
            return 0
        fi
    fi
    
    # Confirm
    echo ""
    print_status "Commit message: $commit_msg"
    read -p "Proceed with commit and push? (y/N): " confirm
    
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        print_status "Operation cancelled"
        return 0
    fi
    
    # Add, commit, push
    print_status "Adding changes..."
    git add -A
    
    print_status "Committing..."
    git commit -m "$commit_msg"
    
    print_status "Pushing to GitHub..."
    git push origin $(git branch --show-current)
    
    print_success "✅ Push completed successfully!"
    print_success "Commit: $(git log -1 --pretty=format:'%h - %s')"
    
    # Show next steps
    echo ""
    print_status "Next: Update your Frappe site:"
    echo "  bench --site [site-name] migrate"
}

# Run main function
main "$@"
