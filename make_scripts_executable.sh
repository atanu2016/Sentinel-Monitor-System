
#!/bin/bash
# Make all script files executable
find scripts -type f -name "*.sh" -exec chmod +x {} \;
chmod +x deploy.sh
chmod +x update.sh
if [ -f "docker-entrypoint.sh" ]; then
  chmod +x docker-entrypoint.sh
fi

# Ensure specific scripts are executable
if [ -f "scripts/update/build.sh" ]; then
  chmod +x scripts/update/build.sh
fi

if [ -f "scripts/update/build-enhanced.sh" ]; then
  chmod +x scripts/update/build-enhanced.sh
fi

if [ -f "scripts/application/setup.sh" ]; then
  chmod +x scripts/application/setup.sh
fi

if [ -f "scripts/install/system_deps.sh" ]; then
  chmod +x scripts/install/system_deps.sh
fi

# Make package-type.js executable
if [ -f "scripts/package-type.js" ]; then
  chmod +x scripts/package-type.js
fi

# Make package-type.cjs executable
if [ -f "scripts/package-type.cjs" ]; then
  chmod +x scripts/package-type.cjs
fi

echo "All scripts are now executable."
