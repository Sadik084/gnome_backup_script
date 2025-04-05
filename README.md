# GNOME Backup & Restore Script

A simple script to back up and restore your GNOME customizations, including settings, extensions, themes, icons, and installed packages.

## How to Use

1. Clone the repo:

    ```bash
    git clone https://github.com/Sadik084/gnome_backup_script.git
    cd gnome_backup_script
    ```

2. Make the script executable:

    ```bash
    chmod a+x setup.sh
    ```

3. Run it to either **backup** or **restore** your GNOME setup:

    ```bash
    ./setup.sh
    ```

---

## What It Backs Up

- **GNOME settings** (dconf & GNOME terminal)
- **Themes & Icons**
- **GNOME Extensions**
- **Installed packages** (for Debian/Ubuntu systems)

---

## Dependencies

You'll need:
- `zip`
- `pv` (for progress bars)

The script will install these if they're missing.

---
