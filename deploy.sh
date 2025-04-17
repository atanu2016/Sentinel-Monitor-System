
#!/bin/bash

# Configuration variables
APP_DIR="/opt/sentinel-vision-control"
DB_USER="sentinel"
DB_NAME="sentinel_db"
LOG_DIR="${APP_DIR}/logs"
CONFIG_DIR="${APP_DIR}/config"
DATA_DIR="/data/recordings"
BACKUP_DIR="${APP_DIR}/backups"
CURRENT_DIR=$(pwd)
MIN_NODE_VERSION="18.0.0"
TARGET_NODE_VERSION="18.18.2" # Specific version to install
MAX_NODE_VERSION="18.99.99" # Set maximum version to avoid compatibility issues

# Source required modules
source_modules() {
    local base_dir="scripts"
    
    # Create the scripts directory structure if it doesn't exist
    mkdir -p $base_dir/install
    mkdir -p $base_dir/database
    mkdir -p $base_dir/auth
    mkdir -p $base_dir/application
    mkdir -p $base_dir/services
    mkdir -p $base_dir/maintenance
    mkdir -p $base_dir/utils
    mkdir -p $base_dir/update
    
    # Source the modules
    source $base_dir/install/check_system.sh
    source $base_dir/install/create_directories.sh
    source $base_dir/install/nodejs.sh
    source $base_dir/install/system_deps.sh
    source $base_dir/database/setup.sh
    source $base_dir/auth/jwt.sh
    source $base_dir/application/setup.sh
    source $base_dir/services/setup.sh
    source $base_dir/services/nginx.sh
    source $base_dir/services/service_control.sh
    source $base_dir/maintenance/backup.sh
    source $base_dir/utils/messages.sh
    
    # Source enhanced build script if it exists
    if [ -f "$base_dir/update/build-enhanced.sh" ]; then
        source $base_dir/update/build-enhanced.sh
    else
        source $base_dir/update/build.sh 2>/dev/null || source $base_dir/application/build.sh 2>/dev/null || true
    fi
}

# Main execution with enhanced error handling
main() {
    local VERSION="latest"
    local DOMAIN=""
    local EMAIL=""
    local ENABLE_SSL=false
    local USE_DOCKER=false
    
    # Parse command line arguments
    while getopts "v:d:e:sc" opt; do
        case $opt in
            v) VERSION="$OPTARG" ;;
            d) DOMAIN="$OPTARG" ;;
            e) EMAIL="$OPTARG" ;;
            s) ENABLE_SSL=true ;;
            c) USE_DOCKER=true ;;
            \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
        esac
    done
    
    # Start deployment
    check_root
    
    # Create deployment lock file
    if [ -f /tmp/sentinel-deploy.lock ]; then
        echo "ERROR: Another deployment is in progress"
        exit 1
    fi
    touch /tmp/sentinel-deploy.lock
    
    # Create essential directories first so logging works
    create_directories
    
    # Start logging after directories are created
    log "Starting deployment process..."
    
    # Cleanup function
    cleanup() {
        rm -f /tmp/sentinel-deploy.lock
        log "Deployment process completed/interrupted"
    }
    trap cleanup EXIT
    
    # Display banner and get confirmation
    show_banner "$VERSION" "$DOMAIN"
    get_confirmation
    validate_system
    
    # Check if Docker deployment is requested
    if [ "$USE_DOCKER" = true ]; then
        log "Docker deployment selected"
        deploy_docker
    else
        # Main installation steps with error handling for traditional deployment
        {
            install_system_deps &&
            setup_mysql &&
            setup_jwt &&
            setup_application_code "$VERSION" &&
            build_application &&
            setup_services &&
            setup_nginx "$DOMAIN" &&
            setup_ssl "$DOMAIN" "$EMAIL" "$ENABLE_SSL" &&
            setup_log_rotation &&
            setup_backup &&
            start_services &&
            set_permissions
        } || {
            log "ERROR: Deployment failed. Check logs for details"
            exit 1
        }
    fi
    
    show_completion_message "$DOMAIN"
    log "Deployment completed successfully"
}

# Docker deployment function
deploy_docker() {
    log "Setting up Docker deployment..."
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        log "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        usermod -aG docker $(whoami)
    fi
    
    # Check if Docker Compose is installed
    if ! command -v docker-compose &> /dev/null; then
        log "Installing Docker Compose..."
        curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi
    
    # Copy files to APP_DIR
    log "Copying application files to $APP_DIR..."
    mkdir -p $APP_DIR
    cp -r $CURRENT_DIR/* $APP_DIR/
    
    # Make sure docker-compose.yml exists
    if [ ! -f "$APP_DIR/docker-compose.yml" ]; then
        log "ERROR: docker-compose.yml not found"
        return 1
    fi
    
    # Create required directories for volumes
    mkdir -p $APP_DIR/config
    mkdir -p $APP_DIR/logs
    mkdir -p $DATA_DIR
    mkdir -p $APP_DIR/nginx/ssl
    
    # Create package-type.js if not present
    if [ ! -f "$APP_DIR/scripts/package-type.js" ]; then
        mkdir -p $APP_DIR/scripts
        cat > $APP_DIR/scripts/package-type.js << 'EOF'
// package-type.js - Script to modify package.json type field
const fs = require('fs');
const path = require('path');

function updatePackageType(projectDir, type) {
  const packagePath = path.join(projectDir, 'package.json');
  
  try {
    // Read the current package.json
    const packageContent = fs.readFileSync(packagePath, 'utf8');
    const packageJson = JSON.parse(packageContent);
    
    // Update or add the type field
    packageJson.type = type;
    
    // Write the updated package.json
    fs.writeFileSync(
      packagePath, 
      JSON.stringify(packageJson, null, 2), 
      'utf8'
    );
    
    console.log(`Updated package.json type to "${type}"`);
    return true;
  } catch (err) {
    console.error('Error updating package.json:', err);
    return false;
  }
}

// If called directly from command line
if (require.main === module) {
  const args = process.argv.slice(2);
  const projectDir = args[0] || process.cwd();
  const type = args[1] || 'commonjs';
  
  if (updatePackageType(projectDir, type)) {
    process.exit(0);
  } else {
    process.exit(1);
  }
}

module.exports = { updatePackageType };
EOF
    fi
    
    # Set package.json to CommonJS mode for compatibility
    log "Setting package.json type to commonjs for compatibility..."
    cd $APP_DIR
    node scripts/package-type.js $APP_DIR "commonjs"
    
    # Ensure files are executable
    chmod +x $APP_DIR/make_scripts_executable.sh
    $APP_DIR/make_scripts_executable.sh
    
    # Start the containers
    cd $APP_DIR
    log "Starting Docker containers..."
    docker-compose up -d --build
    
    # Check if containers are running
    if [ $? -eq 0 ] && docker-compose ps | grep -q "Up"; then
        log "Docker containers started successfully"
        return 0
    else
        log "ERROR: Failed to start Docker containers"
        docker-compose logs
        return 1
    fi
}

# Make scripts executable
chmod_scripts() {
    find scripts -type f -name "*.sh" -exec chmod +x {} \;
    chmod +x deploy.sh
    chmod +x update.sh
    if [ -f "docker-entrypoint.sh" ]; then
        chmod +x docker-entrypoint.sh
    fi
}

# Source modules, make them executable, and execute main
source_modules
chmod_scripts
main "$@"
