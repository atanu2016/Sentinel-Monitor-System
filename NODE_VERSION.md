
# Node.js Version Management for Sentinel Vision Control

This document provides guidance on managing Node.js versions for the Sentinel Vision Control system.

## Supported Node.js Versions

The Sentinel Vision Control application is designed to work with:
- **Minimum Node.js version**: 18.0.0
- **Maximum Node.js version**: 18.99.99 (Node.js 18.x LTS series)
- **Recommended Node.js version**: 18.18.2 (specific tested version)

## Why Version Constraints?

1. **Stability**: The application has been thoroughly tested with Node.js 18.x LTS.
2. **Compatibility**: Some dependencies may not work correctly with newer Node.js versions.
3. **Consistency**: Using a consistent Node.js version across development and production environments ensures reliable behavior.

## Checking Node.js Version

To check your current Node.js version:

```bash
node -v
```

## Installation/Downgrade Methods

The deployment and update scripts include methods to install or downgrade Node.js if needed. These methods are:

### 1. Using NVM (Node Version Manager)

The scripts will attempt to install NVM and use it to install the correct Node.js version. This method:
- Creates a local NVM installation
- Installs the target Node.js version
- Creates symlinks to make the Node.js version available system-wide

### 2. Using Nodeenv (Alternative Method)

If NVM fails, the scripts will try nodeenv as an alternative:
- Installs the Python nodeenv package
- Creates an isolated Node.js environment
- Links it to the system path

## Manually Managing Node.js Version

If you need to manually install a compatible Node.js version:

```bash
# Remove existing Node.js
sudo apt-get remove -y nodejs npm

# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
source ~/.bashrc

# Install specific Node.js version
nvm install 18.18.2
nvm use 18.18.2

# Make it available system-wide (optional)
sudo ln -sf $(which node) /usr/bin/node
sudo ln -sf $(which npm) /usr/bin/npm

# Install specific npm version
npm install -g npm@9.8.1
```

## Troubleshooting

If you encounter Node.js version issues:

1. Check the logs at `/opt/sentinel-vision-control/logs/deploy.log` or `/opt/sentinel-vision-control/logs/update.log`
2. Verify if Node.js is properly installed and available in PATH:
   ```bash
   which node
   node -v
   ```
3. Try manually installing the correct Node.js version following the instructions above
4. Ensure npm is also at a compatible version (9.8.1 is recommended):
   ```bash
   npm -v
   ```

## Supported npm Versions

- **Recommended npm version**: 9.8.1 (compatible with Node.js 18.x)

The deployment and update scripts will attempt to install this specific npm version.
