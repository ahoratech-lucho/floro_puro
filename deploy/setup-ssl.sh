#!/bin/bash
# ===========================================
# Setup SSL with Let's Encrypt (free)
# Run after deploy.sh and DNS is pointed
# ===========================================

DOMAIN="radardelfloro.pe"  # ← Cambiar a tu dominio
EMAIL="tu@email.com"       # ← Cambiar

set -e

echo "🔒 Setting up SSL for $DOMAIN..."

# Install certbot
sudo apt-get update
sudo apt-get install -y certbot

# Stop nginx temporarily for certbot
cd /opt/radardelfloro
sudo docker compose down

# Get certificate
sudo certbot certonly --standalone \
    -d $DOMAIN \
    -d www.$DOMAIN \
    --email $EMAIL \
    --agree-tos \
    --non-interactive

# Copy certs to deploy directory
sudo mkdir -p /opt/radardelfloro/ssl
sudo cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem /opt/radardelfloro/ssl/
sudo cp /etc/letsencrypt/live/$DOMAIN/privkey.pem /opt/radardelfloro/ssl/

# Update docker-compose to mount SSL
echo ""
echo "⚠️  Now uncomment the SSL volume mounts in docker-compose.yml"
echo "   and uncomment the HTTPS server block in nginx.conf"
echo ""

# Restart
sudo docker compose up -d

# Setup auto-renewal
echo "0 3 * * * root certbot renew --post-hook 'cp /etc/letsencrypt/live/$DOMAIN/*.pem /opt/radardelfloro/ssl/ && cd /opt/radardelfloro && docker compose restart'" | sudo tee /etc/cron.d/certbot-renew

echo "✅ SSL configured! Site available at https://$DOMAIN"
