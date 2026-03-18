#!/bin/bash
# ===========================================
# Radar del Floro - Deploy Script
# Run on VPS: bash deploy.sh
# ===========================================

set -e

DEPLOY_DIR="/opt/radardelfloro"
REPO_URL="https://github.com/TU_USUARIO/FLORO_POLITICO.git"  # ← Cambiar

echo "🚀 Deploying Radar del Floro..."

# 1. Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    sudo systemctl enable docker
    sudo systemctl start docker
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "📦 Installing Docker Compose..."
    sudo apt-get install -y docker-compose-plugin
fi

# 2. Create directory structure
echo "📁 Setting up directories..."
sudo mkdir -p $DEPLOY_DIR/{web,images/caricaturas_webp,images/photos_webp,nginx,downloads}

# 3. Copy config files
echo "⚙️  Copying nginx config..."
sudo cp nginx/nginx.conf $DEPLOY_DIR/nginx/
sudo cp nginx/mime.types $DEPLOY_DIR/nginx/
sudo cp docker-compose.yml $DEPLOY_DIR/

# 4. Copy Flutter web build
echo "🌐 Copying Flutter web build..."
if [ -d "../flutter_app/build/web" ]; then
    sudo cp -r ../flutter_app/build/web/* $DEPLOY_DIR/web/
    echo "   ✅ Web build copied"
else
    echo "   ⚠️  No web build found. Run: cd flutter_app && flutter build web --release"
fi

# 5. Copy optimized images
echo "🖼️  Copying images..."
if [ -d "../data/images_webp/caricaturas" ]; then
    sudo cp -r ../data/images_webp/caricaturas/* $DEPLOY_DIR/images/caricaturas_webp/
    sudo cp -r ../data/images_webp/photos/* $DEPLOY_DIR/images/photos_webp/
    echo "   ✅ WebP images copied"
elif [ -d "../data/caricatures" ]; then
    echo "   ⚠️  No WebP images. Copying raw images (run optimize script first!)"
    sudo cp -r ../data/caricatures/* $DEPLOY_DIR/images/caricaturas_webp/ 2>/dev/null || true
    sudo cp -r ../data/photos/* $DEPLOY_DIR/images/photos_webp/ 2>/dev/null || true
fi

# 6. Copy APK if exists
if ls ../flutter_app/build/app/outputs/flutter-apk/*.apk 1> /dev/null 2>&1; then
    echo "📱 Copying APK..."
    sudo mkdir -p $DEPLOY_DIR/web/downloads
    sudo cp ../flutter_app/build/app/outputs/flutter-apk/app-release.apk \
        $DEPLOY_DIR/web/downloads/radar-del-floro.apk
fi

# 7. Start/restart containers
echo "🐳 Starting Docker containers..."
cd $DEPLOY_DIR
sudo docker compose down 2>/dev/null || true
sudo docker compose up -d

echo ""
echo "✅ Deploy complete!"
echo "   Web:    http://$(hostname -I | awk '{print $1}')"
echo "   Health: http://$(hostname -I | awk '{print $1}')/health"
echo ""
echo "📌 Next steps:"
echo "   1. Point your domain DNS to this server's IP"
echo "   2. Set up SSL with certbot (see setup-ssl.sh)"
echo "   3. Update nginx.conf to uncomment HTTPS blocks"
