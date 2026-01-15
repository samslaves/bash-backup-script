# Incremental Backup Script 💾

A robust bash script for performing space-efficient incremental backups using `rsync` and hard links.

## 📋 Table of Contents

- [Features](#features)
- [How It Works](#how-it-works)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Directory Structure](#directory-structure)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)
- [Safety Features](#safety-features)

## ✨ Features

- **Space-efficient**: Only stores changed files, using hard links for unchanged files
- **Safe interruption handling**: Cleans up incomplete backups if interrupted (Ctrl+C)
- **Automatic versioning**: Each backup is timestamped and kept separately
- **Easy restore**: Access any backup version by browsing dated folders
- **Exclude patterns**: Skip unnecessary files/folders via exclude list
- **First-run ready**: Works correctly on initial backup without previous data

## 🔧 How It Works

The script uses **incremental backups with hard links**:

1. **First Backup**: Copies all files from source to backup destination
2. **Subsequent Backups**: 
   - Unchanged files → Hard links to previous backup (no extra space!)
   - Changed/new files → Fresh copies
   - Deleted files → Removed (with `--delete` flag)

**Space Savings Example:**
- Source: 100GB of data
- Day 1 backup: 100GB
- Day 2 backup (5GB changed): Only 5GB additional space used!
- You can still browse both complete 100GB backups separately

## 📦 Requirements

- Linux/Unix system (or macOS, WSL on Windows)
- `rsync` installed
- `bash` shell
- Sufficient disk space on backup destination
- Read permissions on source directory
- Write permissions on backup directory

## 🚀 Installation

1. **Clone or download the script:**
```bash
   git clone https://github.com/samslaves/bash-backup-script.git
   cd bash-backup-script
```

2. **Make it executable:**
```bash
   chmod +x backup-script.sh
```

3. **Configure paths** (edit the script):
```bash
   readonly SOURCE_DIR="/mnt/media/"      # Change to your source
   readonly BACKUP_DIR="/mnt/backup/media" # Change to your backup location
```

## ⚙️ Configuration

### 1. Edit Source and Destination

Open `backup-script.sh` and modify these lines:
```bash
readonly SOURCE_DIR="/path/to/your/data/"
readonly BACKUP_DIR="/path/to/backup/location"
```

### 2. Create Exclude List (Optional)

Create `exclude-list.txt` in the same directory to skip files/folders:
```txt
# Example exclude-list.txt
*.tmp
*.cache
.DS_Store
node_modules/
__pycache__/
*.log
```

**Pattern examples:**
- `*.tmp` → All `.tmp` files
- `*.log` → All log files
- `cache/` → All folders named "cache"
- `/specific/path` → Specific path from source root

## 📖 Usage

### Basic Usage
```bash
./backup-script.sh
```

### Automated Backups with Cron

Run daily at 2 AM:
```bash
# Edit crontab
crontab -e

# Add this line:
0 2 * * * /path/to/backup-script.sh >> /var/log/backup.log 2>&1
```

### Manual Restore

To restore from a specific backup:
```bash
# List available backups
ls -la /mnt/backup/media/

# Restore from specific date
rsync -av /mnt/backup/media/2024-01-15_14-30-00/ /mnt/media/

# Or restore from latest
rsync -av /mnt/backup/media/latest/ /mnt/media/
```

## 📁 Directory Structure

After running the script, your backup directory looks like this:
```
/mnt/backup/media/
├── 2024-01-15_10-00-00/   # First backup (100GB actual)
├── 2024-01-16_10-00-00/   # Second backup (5GB actual, 100GB apparent)
├── 2024-01-17_10-00-00/   # Third backup (3GB actual, 100GB apparent)
└── latest -> 2024-01-17_10-00-00/  # Symlink to most recent
```

**Check actual vs apparent size:**
```bash
# Apparent size (what you see when browsing)
du -sh /mnt/backup/media/2024-01-16_10-00-00/

# Actual disk usage
du -sh --apparent-size /mnt/backup/media/2024-01-16_10-00-00/
```

## 💡 Examples

### Example 1: Backup Photos
```bash
# In backup-script.sh
readonly SOURCE_DIR="/home/user/Photos/"
readonly BACKUP_DIR="/mnt/external/photo-backups"

# Run backup
./backup-script.sh
# Output: Backup completed successfully: /mnt/external/photo-backups/2024-01-15_14-30-00
```

### Example 2: Backup with Excludes
```bash
# Create exclude-list.txt
echo "*.raw" > exclude-list.txt
echo "*.psd" >> exclude-list.txt
echo "Temp/" >> exclude-list.txt

# Run backup (skips RAW files, PSDs, and Temp folder)
./backup-script.sh
```

### Example 3: Check Backup Integrity
```bash
# Compare source with latest backup
rsync -avcn --delete /mnt/media/ /mnt/backup/media/latest/
# (dry-run with -n flag, shows differences without changing anything)
```

## 🐛 Troubleshooting

### Problem: "Permission denied"
**Solution:** Run with `sudo` or fix permissions:
```bash
sudo chown -R $USER:$USER /mnt/backup/media
```

### Problem: "No space left on device"
**Solution:** 
- Check available space: `df -h /mnt/backup`
- Remove old backups: `rm -rf /mnt/backup/media/2024-01-10_*`

### Problem: Script stops without cleaning up
**Solution:** The script now includes EXIT trap - incomplete backups are automatically removed

### Problem: rsync is slow
**Solution:** Add compression for network transfers:
```bash
rsync -avz ...  # Add 'z' flag for compression
```

## 🛡️ Safety Features

1. **`set -euo pipefail`**: Script stops immediately on any error
2. **Trap on SIGINT/SIGTERM/EXIT**: Cleans up incomplete backups if interrupted
3. **Hard link safety**: Original files are never modified
4. **Atomic symlink update**: `latest` link always points to complete backup
5. **Process tracking**: Background rsync process is properly monitored

## 📊 Monitoring Backup Size
```bash
# Total space used by all backups
du -sh /mnt/backup/media/

# Space used per backup
du -sh /mnt/backup/media/*/

# Number of hard links (files shared between backups)
find /mnt/backup/media/ -type f -links +1 | wc -l
```

## 🤝 Contributing

Feel free to submit issues or pull requests to improve this script!

## 📄 License

This script is provided as-is under the MIT License.

## ⚠️ Important Notes

- **Test first!** Run the script with test data before using on important files
- **Monitor disk space**: Ensure backup destination has enough space
- **Verify backups**: Periodically check that backups are working correctly
- **Keep multiple backups**: Consider keeping backups in multiple locations

---

**Happy Backing Up! 🚀**
