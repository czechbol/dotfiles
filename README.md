# dotfiles

Managed by [chezmoi](https://www.chezmoi.io/) with age encryption and Bitwarden integration.

## Branch Strategy

- **`main`** - Documentation only
- **`arnach`** - Configuration for arnach machine
- **`<hostname>`** - Create branches for additional machines

## New Machine Setup

```bash
# 1. Install prerequisites
yay -S chezmoi bitwarden-cli  # Arch
sudo dnf install chezmoi bitwarden-cli  # Fedora

# 2. Login to Bitwarden
bw login

# 3. Initialize and apply
chezmoi init --apply --branch $(hostnamectl hostname) git@github.com:czechbol/dotfiles.git
```

The install script automatically retrieves your age encryption key from Bitwarden, decrypts files, installs packages, and sets up your environment.

**If branch doesn't exist:**
```bash
cd ~/.local/share/chezmoi
git checkout -b $(hostnamectl hostname)
git push -u origin $(hostnamectl hostname)
```

## Daily Workflow

### Add Files

```bash
# Regular file
chezmoi add ~/.config/app/config.toml

# Encrypted file (passwords, API keys, etc)
chezmoi add --encrypt ~/.config/app/secrets.json

# Executable
chezmoi add --template ~/.local/bin/script

# Directory
chezmoi add ~/.config/hypr
```

### Edit Files

```bash
# Edit managed file
chezmoi edit ~/.config/app/config.toml

# Or edit source directly
chezmoi cd
# ... edit files ...
exit
```

### Commit & Push

```bash
chezmoi cd
git add -A
git commit -m "Update config"
git push
exit
```

### Apply Changes

```bash
# Pull and apply from repo
chezmoi update

# Preview changes
chezmoi diff

# Check what's managed
chezmoi managed
```

## Encrypted Files

Files encrypted with age:
- `pika-backup/*.json` - backup configs
- `clipse/clipboard_history.json` - clipboard history

Edit encrypted files with `chezmoi edit` - they're automatically decrypted/re-encrypted.

## File Naming

| Source | Target | Description |
|--------|--------|-------------|
| `dot_config` | `.config` | Dot prefix |
| `executable_script` | `script` (mode 755) | Executable |
| `encrypted_file.age` | `file` | Encrypted |
| `private_file` | `file` (mode 600) | Private |

Examples:
- `dot_zshrc` → `~/.zshrc`
- `dot_local/bin/executable_script` → `~/.local/bin/script`
- `encrypted_private_backup.json.age` → `backup.json` (encrypted, mode 600)

## Multi-Machine Management

```bash
# Sync changes
cd ~/.local/share/chezmoi
git pull
chezmoi apply

# Cherry-pick from another machine
git cherry-pick <commit-hash>

# Copy specific file from another branch
git checkout other-hostname -- home/dot_config/app/config.toml
```

## Useful Commands

```bash
chezmoi diff          # Preview changes
chezmoi status        # Check status
chezmoi re-add        # Re-add modified files
chezmoi cd            # Jump to source directory
chezmoi doctor        # Check for issues
```

## Troubleshooting

**Can't decrypt:**
```bash
bw get notes "chezmoi-age-key" > ~/.config/age/key.txt
chmod 600 ~/.config/age/key.txt
```

**Bitwarden locked:**
```bash
bw unlock
bw sync
```

---

Full docs: https://www.chezmoi.io/
