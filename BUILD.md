
# Sentinel Vision Control - Build Requirements

This document outlines the specific build requirements for the Sentinel Vision Control application.

## Build Tools

The application uses the following build tools:

### Vite

- **Required version**: 4.5.2
- **Plugin**: @vitejs/plugin-react-swc 3.5.0

These specific versions are required for compatibility with the Node.js 18.x LTS series that the application supports.

## Build Process

The build process is automated in both the `deploy.sh` and `update.sh` scripts. If you need to manually build the application:

1. Ensure you have Node.js 18.x LTS installed
2. Install the specific versions of build tools:
   ```bash
   npm install --no-save vite@4.5.2 @vitejs/plugin-react-swc@3.5.0
   ```
3. Install dependencies:
   ```bash
   npm install --production --legacy-peer-deps
   ```
4. Build the application:
   ```bash
   npx --no-install vite build
   ```

## ES Modules Support

The application uses ES Modules syntax. When dealing with direct Node.js execution for building:

1. Use `.mjs` extension for ES Module scripts
2. Use `import` instead of `require` for imports
3. For bridging between ES modules and CommonJS:
   ```javascript
   import { createRequire } from 'module';
   const require = createRequire(import.meta.url);
   ```
4. For direct build execution:
   ```bash
   node build-script.mjs
   ```
5. When creating custom build scripts, leverage Node.js built-ins to ensure compatibility:
   ```javascript
   import { fileURLToPath } from 'url';
   import { dirname, resolve, join } from 'path';
   import { createRequire } from 'module';
   import fs from 'fs';

   const __filename = fileURLToPath(import.meta.url);
   const __dirname = dirname(__filename);
   const require = createRequire(import.meta.url);
   
   // Now you can dynamically find and load Vite
   const possiblePaths = [
     join(__dirname, 'node_modules/vite/dist/node/index.js'),
     join(__dirname, 'node_modules/vite/dist/index.js'),
     'vite'
   ];
   
   // Try each path and use the first one that works
   ```

## Dependency Conflicts

If you encounter dependency conflicts during the build process (particularly between Vite versions):

1. Use the `--legacy-peer-deps` flag during installation:
   ```bash
   npm install --legacy-peer-deps
   ```

2. Alternatively, you can use `--force` if needed:
   ```bash
   npm install --force
   ```

3. For development environments, you can temporarily disable the lovable-tagger package if it's causing conflicts:
   ```bash
   # In vite.config.ts, conditionally apply the plugin
   plugins: [
     react(),
     mode === 'development' && componentTagger(),
   ].filter(Boolean),
   ```

4. Use `--no-save` when installing build tools temporarily:
   ```bash
   npm install --no-save vite@4.5.2
   ```

## Troubleshooting Build Issues

If you encounter build failures:

1. Check the Node.js version using `node -v` - it should be a version in the 18.x series
2. Verify that Vite is installed in the local node_modules:
   ```bash
   ls -la node_modules/vite
   ```
3. Try clearing the npm cache:
   ```bash
   npm cache clean --force
   ```
4. Remove node_modules and reinstall:
   ```bash
   rm -rf node_modules
   npm install --production --legacy-peer-deps
   npm install --no-save vite@4.5.2 @vitejs/plugin-react-swc@3.5.0
   ```
5. If the npx command is not found, ensure npm is properly installed:
   ```bash
   which npm
   npm -v
   ```
6. Try building directly with node:
   ```bash
   node node_modules/vite/bin/vite.js build
   ```
7. If encountering ES Module issues with custom build scripts:
   - Ensure you're using the `.mjs` extension
   - Use `createRequire` from the `module` package to bridge between ES modules and CommonJS
   - Set up proper file paths using `fileURLToPath` and `dirname`
   - Use the `fs` module to check if files exist before trying to require them
   - Try multiple possible paths where Vite could be installed

8. For module resolution issues, use a recursive file search:
   ```javascript
   const findViteFile = (dir, depth = 0) => {
     if (depth > 3) return null; // Limit recursion depth
     
     const files = fs.readdirSync(dir);
     for (const file of files) {
       const filePath = join(dir, file);
       const stat = fs.statSync(filePath);
       
       if (stat.isDirectory()) {
         if (file === 'vite' && fs.existsSync(join(filePath, 'dist/node/index.js'))) {
           return join(filePath, 'dist/node/index.js');
         } else if (depth < 3) {
           const result = findViteFile(filePath, depth + 1);
           if (result) return result;
         }
       }
     }
     return null;
   };
   ```

9. Check for multiple Vite installations in different locations:
   ```bash
   find . -name "vite" -type d
   ```

If issues persist, check the logs at `$APP_DIR/logs/deploy.log` or `$APP_DIR/logs/update.log` for more detailed error information.

