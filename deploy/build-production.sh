#!/bin/bash
# ===========================================
# Build everything for production
# Run on your dev machine BEFORE deploying
# ===========================================

set -e
cd "$(dirname "$0")/.."

DOMAIN="radardelfloro.pe"  # ← Cambiar a tu dominio

echo "🔨 Building Radar del Floro for production..."

# 1. Optimize images to WebP (if not done already)
if [ ! -d "data/images_webp" ]; then
    echo "🖼️  Optimizing images to WebP..."
    node scripts/07_optimize_images.js
else
    echo "🖼️  WebP images already exist, skipping optimization"
fi

# 2. Build Flutter Web with production CDN URL
echo "🌐 Building Flutter Web (production)..."
cd flutter_app

# Empty CDN_URL = same origin (nginx serves /images/ directly)
flutter build web --release \
    --dart-define=CDN_URL= \
    --base-href /

echo "   ✅ Flutter web build complete"

# 3. Build APK (optional — for Android download)
echo "📱 Building APK..."
flutter build apk --release --split-per-abi 2>/dev/null || echo "   ⚠️  APK build skipped (need Android SDK)"

cd ..

# 4. Copy everything to deploy/
echo "📦 Packaging for deploy..."
rm -rf deploy/web deploy/images
mkdir -p deploy/web deploy/images

cp -r flutter_app/build/web/* deploy/web/

if [ -d "data/images_webp" ]; then
    cp -r data/images_webp/* deploy/images/
else
    echo "   ⚠️  No WebP images, copying raw..."
    mkdir -p deploy/images/caricaturas_webp deploy/images/photos_webp
    cp data/caricatures/*.png deploy/images/caricaturas_webp/ 2>/dev/null || true
    cp data/photos/*.jpg deploy/images/photos_webp/ 2>/dev/null || true
fi

# Copy APK if exists
if ls flutter_app/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk 1> /dev/null 2>&1; then
    mkdir -p deploy/web/downloads
    cp flutter_app/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk \
        deploy/web/downloads/radar-del-floro.apk
fi

echo ""
echo "✅ Production build complete!"
echo ""
echo "📂 deploy/"
echo "   ├── web/          $(du -sh deploy/web | cut -f1) (Flutter + assets)"
echo "   ├── images/       $(du -sh deploy/images 2>/dev/null | cut -f1 || echo '0') (WebP optimizadas)"
echo "   ├── nginx/        (config)"
echo "   └── docker-compose.yml"
echo ""
echo "🚀 To deploy to VPS:"
echo "   scp -r deploy/ user@your-vps:/tmp/radardelfloro/"
echo "   ssh user@your-vps 'cd /tmp/radardelfloro && bash deploy.sh'"
