
# Sentinel Vision Control - Production Deployment Guide

This document outlines the complete process for deploying the Sentinel Vision Control system to a production environment. Follow these instructions carefully to ensure a successful deployment.

## Pre-Deployment Checklist

Before proceeding with deployment, verify the following:

- [ ] All mock services have been replaced with production APIs
- [ ] Database connection has been configured and tested
- [ ] Storage paths have been configured for your environment
- [ ] SSL/TLS certificates are ready or can be obtained via Let's Encrypt
- [ ] All required ports are open in your network/firewall (80, 443, 3000)
- [ ] System meets hardware requirements (see below)

## Hardware Requirements

Recommended server specifications:

- CPU: 4+ cores
- RAM: 8GB minimum, 16GB recommended
- Storage: 100GB minimum, scaled based on retention period and number of cameras
- Network: 1Gbps minimum for optimal camera streaming
- Operating System: Ubuntu 20.04 LTS or newer

## Deployment Process

### 1. Prepare the Environment

#### A. Update System Packages

```bash
sudo apt update && sudo apt upgrade -y
```

#### B. Install Required Dependencies

```bash
sudo apt install -y curl git build-essential htop iotop ntp ffmpeg postgresql postgresql-contrib redis-server nginx
```

### 2. Clone the Repository

```bash
git clone https://github.com/your-org/sentinel-vision-control.git /tmp/sentinel-vision
```

### 3. Run the Deployment Script

Our system includes a comprehensive deployment script that handles most of the installation process:

```bash
cd /tmp/sentinel-vision
chmod +x deploy.sh
sudo ./deploy.sh -v stable -d yourdomain.com -e admin@yourdomain.com -s
```

Command-line arguments:
- `-v <version>`: Specific version tag to deploy (default: latest)
- `-d <domain>`: Domain name for SSL certificate
- `-e <email>`: Email address for SSL certificate notifications
- `-s`: Enable SSL/TLS configuration

### 4. Configure Production Settings

After the initial deployment, you need to complete the following configurations through the web interface:

1. Access the application at `https://yourdomain.com` or `http://your-server-ip`
2. Log in with the default credentials (provided in the console output during deployment)
3. Navigate to Settings and configure:
   - Database connection details
   - Storage location and retention policy
   - LDAP/AD authentication (if applicable)
   - Email notification settings
   - SSL/TLS certificate (if not configured during deployment)

### 5. Replace Mock Services with Production APIs

The application uses mock services during development. For production:

1. Navigate to the Settings page
2. Under Database settings, configure your production database connection
3. Test the connection before saving
4. Ensure all other integrations (LDAP, email, storage) are configured with production credentials

### 6. Configure Automatic Updates

To enable automatic updates:

1. Set up a cron job to run the update script periodically:

```bash
sudo crontab -e
```

2. Add the following line to run updates weekly:

```
0 2 * * 0 /opt/sentinel-vision-control/update.sh > /var/log/sentinel-update.log 2>&1
```

### 7. Security Considerations

After deployment, enhance security:

1. **Firewall Configuration**: Ensure only necessary ports are open
   ```bash
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```

2. **Set Up Fail2Ban**: To protect against brute force attacks
   ```bash
   sudo apt install fail2ban
   sudo systemctl enable fail2ban
   sudo systemctl start fail2ban
   ```

3. **Regular Updates**: Ensure system updates are applied regularly
   ```bash
   sudo apt install unattended-upgrades
   sudo dpkg-reconfigure -plow unattended-upgrades
   ```

### 8. Backup Strategy

Set up regular backups:

1. Database backups:
   ```bash
   sudo -u postgres pg_dump sentinelvision > /backup/db_backup_$(date +%Y%m%d).sql
   ```

2. Application configuration:
   ```bash
   tar -czf /backup/app_config_$(date +%Y%m%d).tar.gz /opt/sentinel-vision-control/config/
   ```

3. Add to cron for automatic backups:
   ```
   0 1 * * * sudo -u postgres pg_dump sentinelvision > /backup/db_backup_$(date +%Y%m%d).sql
   30 1 * * * tar -czf /backup/app_config_$(date +%Y%m%d).tar.gz /opt/sentinel-vision-control/config/
   ```

## Updating the Application

To update the application to the latest version:

```bash
cd /opt/sentinel-vision-control
sudo ./update.sh
```

The update script:
- Creates a backup before updating
- Checks and renews SSL certificates if needed
- Pulls the latest code changes
- Installs any new dependencies
- Rebuilds the application
- Restarts services

## Monitoring and Maintenance

### Health Checks

Set up monitoring for key services:

```bash
sudo apt install -y prometheus node-exporter
```

### Log Rotation

The deployment script configures log rotation, but you can verify it:

```bash
cat /etc/logrotate.d/sentinel-vision
```

### Performance Tuning

For systems with many cameras:
- Increase the PostgreSQL shared_buffers setting
- Adjust Redis maxmemory configuration
- Scale the Node.js max-old-space-size if needed

## Troubleshooting

Common issues and solutions:

### Service Won't Start

Check the service status:
```bash
sudo systemctl status sentinel-vision
```

View logs:
```bash
sudo journalctl -u sentinel-vision -f
```

### Database Connection Issues

Verify PostgreSQL is running:
```bash
sudo systemctl status postgresql
```

Check connection parameters in the application config.

### Camera Streaming Issues

Verify network connectivity to cameras:
```bash
ping [camera-ip]
```

Check FFmpeg installation:
```bash
ffmpeg -version
```

## Support

For additional support:
- Check the application logs: `/var/log/sentinel-vision/`
- Contact support at: support@sentinel-vision.com

