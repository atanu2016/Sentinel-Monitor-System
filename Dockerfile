
FROM node:18-alpine as base

# Create app directory
WORKDIR /app

# Create required script directories
RUN mkdir -p /app/scripts

# Copy package-type.js script first if it exists
COPY scripts/package-type.js* /app/scripts/

# Helper function to set package.json type
RUN echo '// Quick function to ensure package.json has type: "commonjs"' > /app/ensure-commonjs.js \
    && echo 'const fs = require("fs");' >> /app/ensure-commonjs.js \
    && echo 'try {' >> /app/ensure-commonjs.js \
    && echo '  const pkg = JSON.parse(fs.readFileSync("./package.json"));' >> /app/ensure-commonjs.js \
    && echo '  pkg.type = "commonjs";' >> /app/ensure-commonjs.js \
    && echo '  fs.writeFileSync("./package.json", JSON.stringify(pkg, null, 2));' >> /app/ensure-commonjs.js \
    && echo '  console.log("Set package.json type to commonjs");' >> /app/ensure-commonjs.js \
    && echo '} catch (e) {' >> /app/ensure-commonjs.js \
    && echo '  console.error("Failed to update package.json:", e);' >> /app/ensure-commonjs.js \
    && echo '}' >> /app/ensure-commonjs.js

# Copy package files
COPY package.json package-lock.json* ./

# Set package.json type to commonjs
RUN node /app/ensure-commonjs.js

# Install dependencies including build tools
RUN npm install --production=false

# Explicitly install Vite and its plugin
RUN npm install --no-save vite@4.5.2 @vitejs/plugin-react-swc@3.5.0

# Copy application code
COPY . .

# Ensure build script is executable
RUN chmod +x /app/scripts/application/setup.sh || echo "No setup.sh found"
RUN chmod +x /app/scripts/update/build.sh || echo "No build.sh found"
RUN chmod +x /app/make_scripts_executable.sh || echo "No make_scripts_executable.sh found"
RUN if [ -f "/app/make_scripts_executable.sh" ]; then /app/make_scripts_executable.sh; fi

# Ensure package.json has type: "commonjs" for the build
RUN node /app/ensure-commonjs.js

# Build the application
RUN npx vite build || echo "Build failed in Docker, will be built at runtime"

# Create a minimal server.js fallback in case build fails
RUN echo 'console.log("Server starting..."); require("./scripts/serve-frontend.js");' > /app/server.js

# Production stage
FROM node:18-alpine as production

WORKDIR /app

# Copy built assets from build stage
COPY --from=base /app/dist ./dist
COPY --from=base /app/backend ./backend
COPY --from=base /app/scripts ./scripts
COPY --from=base /app/server.js ./server.js

# Copy package files and install production dependencies
COPY package.json package-lock.json* ./
RUN npm install --production=true

# Copy Docker-specific entry script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 3000 3001

CMD ["/docker-entrypoint.sh"]
