
#!/bin/sh
set -e

echo "Starting Sentinel Vision Control..."

# Check if the dist directory exists and has content
if [ ! -d "/app/dist" ] || [ -z "$(ls -A /app/dist 2>/dev/null)" ]; then
    echo "Dist directory is missing or empty, attempting to build..."
    
    # Install build dependencies if needed
    if [ ! -d "/app/node_modules/vite" ]; then
        echo "Installing build dependencies..."
        npm install --no-save vite@4.5.2 @vitejs/plugin-react-swc@3.5.0
    fi
    
    # Try to build the application
    echo "Building application..."
    npx vite build || {
        echo "Build failed, creating a minimal dist directory..."
        mkdir -p /app/dist
        cat > /app/dist/index.html << EOF
<!DOCTYPE html>
<html>
<head>
  <title>Build Error</title>
  <style>
    body { font-family: Arial, sans-serif; padding: 20px; color: #333; }
    .error { background: #f8d7da; border: 1px solid #f5c6cb; padding: 15px; border-radius: 4px; }
  </style>
</head>
<body>
  <h1>Application Not Built</h1>
  <div class="error">
    <p>The application hasn't been built properly. Check the build logs for more information.</p>
    <p>Try running the build process again.</p>
  </div>
</body>
</html>
EOF
    }
fi

# Start the backend server in the background
cd /app
echo "Starting backend server..."
node backend/server.js &
BACKEND_PID=$!

# Start the frontend server
echo "Starting frontend server..."
cd /app
node scripts/serve-frontend.js &
FRONTEND_PID=$!

# Handle shutdown
trap 'kill $BACKEND_PID $FRONTEND_PID; exit 0' TERM INT

# Keep the container running
wait
