#!/bin/bash

DEFAULT_BACKUP_DIR=~/gnome-custom-backup
EXT_DIR=~/.local/share/gnome-shell/extensions

# Colors 🌈
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
BLUE="\033[1;34m"
RESET="\033[0m"

# Function to check if a command is installed
check_dependency() {
    command -v "$1" >/dev/null 2>&1 || {
        echo -e "${RED}❌ Dependency '$1' is not installed.${RESET}"
        echo "Attempting to install it..."
        install_dependency "$1"
    }
}

# Function to install a missing dependency
install_dependency() {
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install -y "$1"
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y "$1"
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm "$1"
    else
        echo -e "${RED}❌ No supported package manager found. Please install '$1' manually.${RESET}"
        exit 1
    fi
}

# Check for dependencies
check_dependency "zip"
check_dependency "pv"

title() {
    echo -e "${BLUE}🌀 GNOME Setup Backup & Restore Tool 🌀${RESET}"
    echo
}

ask_action() {
    echo -e "${YELLOW}Do you want to backup or restore your GNOME setup?${RESET}"
    echo -e "(Type '${GREEN}b${RESET}' for backup, '${GREEN}r${RESET}' for restore): "
    read -rp "" action
}

progress_bar() {
    local message="$1"
    echo -ne "$message"
    for i in {1..20}; do
        echo -n "▓"
        sleep 0.05
    done
    echo ""
}

backup_gnome() {
    echo -e "${GREEN}📦 Backing up your GNOME setup...${RESET}"
    mkdir -p "$DEFAULT_BACKUP_DIR"

    echo "🔧 Saving dconf settings..."
    dconf dump / > "$DEFAULT_BACKUP_DIR/gnome-settings.dconf"
    dconf dump /org/gnome/terminal/ > "$DEFAULT_BACKUP_DIR/gnome-terminal.dconf"

    echo "🎨 Backing up themes & icons..."
    for folder in ~/.themes ~/.icons ~/.local/share/themes ~/.local/share/icons; do
        [ -d "$folder" ] && cp -r "$folder" "$DEFAULT_BACKUP_DIR/" | pv -p -t -e -b >/dev/null
    done

    echo "🧩 Backing up extensions..."
    cp -r "$EXT_DIR" "$DEFAULT_BACKUP_DIR/extensions" | pv -p -t -e -b >/dev/null

    echo "📋 Saving installed package list..."
    dpkg --get-selections > "$DEFAULT_BACKUP_DIR/package-list.txt"

    echo "📦 Compressing everything into a zip..."
    zip -r "${DEFAULT_BACKUP_DIR}.zip" "$DEFAULT_BACKUP_DIR" >/dev/null
    rm -rf $DEFAULT_BACKUP_DIR
    echo -e "${GREEN}✅ Backup complete!${RESET}"
    echo -e "📁 Your backup is at: ${YELLOW}${DEFAULT_BACKUP_DIR}.zip${RESET}"
    echo -e "☁️ Upload it to your cloud or save it safely!"
}

restore_gnome() {
    echo -e "${YELLOW}🗂️ Enter path to your backup folder or .zip file:${RESET}"
    read -rp "🔍 Backup path: " BACKUP_PATH

    # If zip, extract it
    if [[ "$BACKUP_PATH" == *.zip ]]; then
        echo "📦 Extracting zip..."
        unzip "$BACKUP_PATH" -d /tmp/gnome-restore-tmp >/dev/null
        BACKUP_DIR="/tmp/gnome-restore-tmp/$(basename "$DEFAULT_BACKUP_DIR")"
    elif [ -d "$BACKUP_PATH" ]; then
        BACKUP_DIR="$BACKUP_PATH"
    else
        echo -e "${RED}❌ Invalid backup path.${RESET}"
        exit 1
    fi

    echo "🔧 Restoring dconf settings..."
    dconf load / < "$BACKUP_DIR/gnome-settings.dconf"
    dconf load /org/gnome/terminal/ < "$BACKUP_DIR/gnome-terminal.dconf"

    echo "🎨 Restoring themes & icons..."
    for folder in .themes .icons themes icons; do
        src="$BACKUP_DIR/$folder"
        if [ -d "$src" ]; then
            dest=~
            [[ "$folder" == "themes" || "$folder" == "icons" ]] && dest=~/.local/share
            cp -r "$src" "$dest/" | pv -p -t -e -b >/dev/null
        fi
    done

    echo "🧩 Restoring extensions..."
    cp -r "$BACKUP_DIR/extensions" "$EXT_DIR" | pv -p -t -e -b >/dev/null

    echo -e "${YELLOW}📋 Package list found! To restore packages (if using Debian/Ubuntu):${RESET}"
    echo "   sudo dpkg --set-selections < $BACKUP_DIR/package-list.txt"
    echo "   sudo apt-get dselect-upgrade"

    echo -e "${GREEN}✅ Restore complete!${RESET}"
    echo "🔁 Log out and back in to apply changes."
}

# Main
clear
title
ask_action

if [[ "$action" == "b" ]]; then
    backup_gnome
elif [[ "$action" == "r" ]]; then
    restore_gnome
else
    echo -e "${RED}❌ Invalid option. Please run the script again.${RESET}"
fi
