
#!/bin/bash

# Configuration variables
APP_DIR="/opt/sentinel-vision-control"
DB_USER="sentinel"
DB_NAME="sentinel_db"
LOG_DIR="${APP_DIR}/logs"
BACKUP_DIR="${APP_DIR}/backups"
CONFIG_DIR="${APP_DIR}/config"
CURRENT_DIR=$(pwd)
MIN_NODE_VERSION="18.0.0"
TARGET_NODE_VERSION="18.18.2" # Specific version to install if needed
MAX_NODE_VERSION="18.99.99" # Set maximum version to avoid compatibility issues

# Enhanced logging
log() {
    # Create log directory if it doesn't exist
    mkdir -p $LOG_DIR
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_DIR/update.log
}

# Version comparison function
version_gt() {
    test "$(printf '%s\n' "$1" "$2" | sort -V | head -n 1)" != "$1"
}

# Version less than or equal function
version_lte() {
    test "$(printf '%s\n' "$1" "$2" | sort -V | head -n 1)" = "$1"
}

# Create update modules directory if it doesn't exist
mkdir -p scripts/update

# Source required modules
source_modules() {
    local base_dir="scripts"
    
    # Create the scripts directory structure if it doesn't exist
    mkdir -p $base_dir/update
    
    # Source the modules
    source $base_dir/update/check_system.sh
    source $base_dir/update/nodejs.sh
    source $base_dir/update/backup.sh
    source $base_dir/update/code_update.sh
    source $base_dir/update/build.sh
    source $base_dir/update/database.sh
    source $base_dir/update/service_control.sh
    source $base_dir/update/cleanup.sh
    source $base_dir/update/health_check.sh
    
    # Make all scripts executable
    find $base_dir -type f -name "*.sh" -exec chmod +x {} \;
}

# Main update process
main() {
    # Check if script is run as root
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" 
        exit 1
    fi
    
    # Create update lock file
    if ! create_update_lock; then
        exit 1
    fi
    
    # Cleanup function
    cleanup() {
        rm -f /tmp/sentinel-update.lock
        log "Update process completed/interrupted"
    }
    trap cleanup EXIT
    
    # Display banner
    log "========================================================"
    log "Sentinel Vision Control - Update Script"
    log "========================================================"
    log "This script will update your Sentinel Vision installation"
    log "It will create a backup before proceeding"
    log "========================================================"
    
    # Validate current installation
    if ! validate_installation; then
        exit 1
    fi
    
    # Get user confirmation
    read -p "Continue with update? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Update cancelled by user"
        exit 1
    fi
    
    # Check and update Node.js version if needed
    if ! check_node_version; then
        if ! install_nodejs; then
            log "ERROR: Failed to update Node.js. Continuing with current version..."
        else
            log "Node.js updated successfully."
        fi
    fi
    
    # Generate timestamp for backups
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    
    # Create backups
    if ! create_backups "$TIMESTAMP"; then
        log "ERROR: Backup creation failed"
        exit 1
    fi
    
    # Stop services
    if ! stop_services; then
        log "ERROR: Failed to stop services properly"
        # Continue anyway
    fi
    
    # Update code
    if ! update_code; then
        log "ERROR: Failed to update code"
        log "Restarting services..."
        restart_services
        exit 1
    fi
    
    # Build application
    if ! build_application; then
        log "ERROR: Build failed"
        exit 1
    fi
    
    # Update database schema
    if ! update_database_schema "$TIMESTAMP"; then
        log "ERROR: Database schema update failed"
        exit 1
    fi
    
    # Update service scripts if needed
    if ! update_service_scripts; then
        log "ERROR: Service scripts update failed"
        exit 1
    fi
    
    # Restart services
    if ! restart_services; then
        log "ERROR: Failed to restart services"
        exit 1
    fi
    
    # Clean up old backups
    cleanup_old_backups
    
    log "========================================================"
    log "Sentinel Vision Control Update Complete!"
    log "========================================================"
    log "Update timestamp: $(date)"
    log "Backup created: $BACKUP_DIR/sentinel_backup_$TIMESTAMP.tar.gz"
    if [ -f "$BACKUP_DIR/sentinel_db_$TIMESTAMP.sql.gz" ]; then
        log "Database backup: $BACKUP_DIR/sentinel_db_$TIMESTAMP.sql.gz"
    fi
    log "========================================================"
    
    # Run health check
    run_health_check
    
    return 0
}

# Source modules and execute main function
source_modules
main
