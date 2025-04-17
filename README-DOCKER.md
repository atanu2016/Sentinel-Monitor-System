
# Sentinel Vision Control - Docker Deployment

This document outlines how to deploy the Sentinel Vision Control system using Docker.

## Prerequisites

- Docker and Docker Compose installed on your system
- Basic understanding of Docker concepts

## Getting Started

1. Clone the repository to your local machine:
   ```bash
   git clone https://github.com/your-org/sentinel-vision-control.git
   cd sentinel-vision-control
   ```

2. Start the containers:
   ```bash
   docker-compose up -d
   ```

3. Access the application:
   - Frontend: http://localhost:80
   - API: http://localhost:80/api

## Configuration

The Docker setup uses the following volumes:
- `./config`: Application configuration
- `./logs`: Application logs
- `./data`: Video recordings storage
- `mysql-data`: Database storage (Docker managed volume)

## Services

The Docker setup includes the following services:
- `app`: The main application container (frontend + backend)
- `db`: MySQL database
- `nginx`: Web server and reverse proxy

## Environment Variables

You can modify the environment variables in the `docker-compose.yml` file:
- Database credentials
- Node environment
- Other application settings

## SSL/HTTPS Setup

To enable HTTPS:

1. Create a directory for SSL certificates:
   ```bash
   mkdir -p nginx/ssl
   ```

2. Add your certificates to `nginx/ssl/`:
   - `nginx/ssl/cert.pem`: SSL certificate
   - `nginx/ssl/key.pem`: SSL private key

3. Update the nginx configuration to use SSL

## Updating the Application

To update to the latest version:

1. Pull the latest changes:
   ```bash
   git pull
   ```

2. Rebuild and restart the containers:
   ```bash
   docker-compose down
   docker-compose up -d --build
   ```

## Troubleshooting

### Build Issues

If you encounter build issues related to Vite:

1. Verify that Vite is correctly installed in the container:
   ```bash
   docker-compose exec app ls -la /app/node_modules/vite
   ```

2. If Vite is missing, you can force a reinstall:
   ```bash
   docker-compose exec app npm install --no-save vite@4.5.2
   ```

3. Manually run the build process:
   ```bash
   docker-compose exec app npx vite build
   ```

4. Check logs for detailed error messages:
   ```bash
   docker-compose logs app
   ```

### Container Startup Issues

- **Container fails to start**: Check the logs with `docker-compose logs app`
- **Cannot connect to database**: Ensure the database container is running with `docker-compose logs db`
- **Web interface not loading**: Check nginx logs with `docker-compose logs nginx`

For additional support, please check the main documentation or contact support.
