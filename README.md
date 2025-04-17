
# Sentinel Vision Control - Enterprise IP Camera Management System

A premium, enterprise-grade IP camera management application designed to discover, manage, and record video feeds from ONVIF and standard IP cameras.

![Sentinel Vision Control](https://i.imgur.com/ygZYZaP.jpg)

## Features

### Core Features
- Add new ONVIF cameras via IP address, username, and password
- Add standard IP cameras with RTSP/RTMP streams
- Auto-discover ONVIF cameras on the local network
- Retrieve RTSP stream URLs using ONVIF
- View camera status in real-time (online/offline, last heartbeat)
- Start/stop recording per camera using FFmpeg (hourly chunks)
- Delete/remove cameras from the system

### Storage Options
- Configure local disk or NAS (SMB, NFS) storage
- Mount NAS locations from the UI
- Organize recordings by camera name and date
- Configurable retention with auto-delete for older recordings

### Authentication
- Built-in user authentication
- LDAP integration for enterprise environments
- Active Directory support
- Role-based access control

### UI/UX
- Clean, responsive layout built with React and Tailwind CSS
- Enterprise-grade design inspired by modern applications
- Camera dashboard with grid view
- Live feed preview
- Modal-based add/edit/delete functionality

### System Architecture
- Frontend: React, TypeScript, Tailwind CSS, Shadcn UI
- Backend: Node.js with Express (REST APIs)
- Recording Engine: FFmpeg for stream processing
- Data Storage: PostgreSQL for camera metadata
- Comprehensive logging of system events

## Project Structure

```
src/
├── components/
│   ├── cameras/           # Camera-specific components
│   ├── layout/            # Layout components
│   └── ui/                # UI components from shadcn
├── lib/
│   └── api-client.ts      # API client for backend communication
├── pages/
│   ├── Dashboard.tsx      # Main dashboard page
│   └── Settings.tsx       # System settings page
└── types/
    └── index.ts           # TypeScript definitions
```

## Implementation Details

### Camera Management
- ONVIF protocol for camera discovery and control
- RTSP stream handling for video feeds
- Support for standard IP cameras via direct RTSP/RTMP URLs
- FFmpeg integration for recording capabilities
- Camera health monitoring and status reporting

### Recording System
- FFmpeg-based recording with hourly chunking
- Standardized naming convention for recordings
- Metadata tracking for easy search and retrieval

### Storage Management
- Flexible storage configuration (local/NAS)
- Automated cleanup based on retention policies
- Storage usage monitoring and alerts

### Authentication & Security
- Secure credential storage for camera access
- API security with rate limiting and authentication
- Encrypted connections for all communication
- LDAP and Active Directory integration for enterprise environments

## Environment Setup

### Prerequisites
- Node.js 18+
- FFmpeg for video processing
- PostgreSQL for database
- Redis for caching and session management
- Network access to IP cameras
- LDAP server or Active Directory (optional)

### Installation
```sh
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
```

## Deployment Guide

### Initial Deployment

1. Clone the repository to your local machine:
   ```bash
   git clone https://github.com/your-org/sentinel-vision-control.git
   ```

2. Make the deployment script executable:
   ```bash
   chmod +x deploy.sh
   ```

3. Run the deployment script as root:
   ```bash
   sudo ./deploy.sh
   ```

During deployment, you will be prompted to:
- Configure SSL/HTTPS for your domain
- Enter your domain name for SSL certificate generation

The deployment script will:
- Install all necessary system dependencies
- Configure PostgreSQL database
- Setup Redis for caching
- Configure Nginx as a reverse proxy
- Setup SSL certificate if enabled
- Configure automatic SSL renewal
- Setup system services
- Configure environment variables
- Setup storage directories
- Enable and configure firewall

### SSL Certificate Management

The system supports automatic SSL certificate management using Let's Encrypt:

- Certificates are automatically renewed before expiration
- Renewal status can be monitored in the Settings > SSL/HTTPS page
- Manual renewal can be triggered from the GUI if needed
- Certificate status is checked daily

### LDAP/Active Directory Configuration

The system supports external authentication via LDAP and Active Directory:

- Configurable from the Settings > Authentication page
- Support for secure connections via TLS
- Flexible user mapping and group permissions
- Test connectivity feature to verify settings

### Updating the Application

When you need to update the application with latest changes:

1. Make the update script executable:
   ```bash
   chmod +x update.sh
   ```

2. Run the update script as root:
   ```bash
   sudo ./update.sh
   ```

The update script will:
- Create a backup of the current application
- Check and renew SSL certificates if needed
- Pull latest changes from git
- Install/update dependencies
- Rebuild the application
- Restart necessary services

### Important Notes

- Before running either script, ensure you have:
  - Root access to the server
  - Git configured with appropriate access to the repository
  - Proper network connectivity
  - Sufficient disk space

- The scripts assume:
  - Ubuntu/Debian-based system
  - Node.js application structure
  - PostgreSQL database
  - Nginx web server
  - Redis for caching

- Default ports used:
  - HTTP: 80
  - HTTPS: 443 (if configured)
  - Application: 3000 (internal)
  - PostgreSQL: 5432
  - Redis: 6379

## License
Proprietary - All rights reserved.

## Project info

**URL**: https://lovable.dev/projects/892e44a0-7402-4e4c-9395-e522fa500236
