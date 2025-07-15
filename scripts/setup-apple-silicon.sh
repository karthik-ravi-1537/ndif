#!/bin/bash
# Apple Silicon (M1/M2) Development Setup Script for NDIF
# This script optimizes the development environment for Apple Silicon

set -e

echo "🍎 Setting up NDIF for Apple Silicon (M1/M2)..."

# Detect Apple Silicon
if [[ $(uname -m) == "arm64" ]]; then
    echo "✅ Apple Silicon detected ($(uname -m))"
else
    echo "⚠️  Warning: This script is optimized for Apple Silicon, but detected $(uname -m)"
fi

# Set Apple Silicon optimized environment variables
export DOCKER_DEFAULT_PLATFORM=linux/arm64
export PYTORCH_ENABLE_MPS_FALLBACK=1
export PYTORCH_MPS_HIGH_WATERMARK_RATIO=0.0
export OMP_NUM_THREADS=8
export MKL_NUM_THREADS=8

echo "🔧 Setting up environment variables for Apple Silicon..."

# Create or update .env.apple-silicon
cat > compose/dev/.env.apple-silicon << EOF
# Apple Silicon (M1/M2) Optimized Configuration
DOCKER_DEFAULT_PLATFORM=linux/arm64
PYTORCH_ENABLE_MPS_FALLBACK=1
PYTORCH_MPS_HIGH_WATERMARK_RATIO=0.0
OMP_NUM_THREADS=8
MKL_NUM_THREADS=8

# Apple Silicon Memory Optimizations
RAY_OBJECT_STORE_MEMORY=2000000000
RAY_MEMORY_MONITOR_REFRESH_MS=100

# Docker Resource Limits for Apple Silicon
COMPOSE_HTTP_TIMEOUT=120
DOCKER_CLIENT_TIMEOUT=120
EOF

echo "📦 Building Apple Silicon optimized containers..."

# Force platform for Docker buildx
if ! docker buildx inspect apple-silicon >/dev/null 2>&1; then
    echo "Creating Apple Silicon buildx instance..."
    docker buildx create --name apple-silicon --platform linux/arm64 --use
fi

# Build with explicit platform
echo "🔨 Building base image for Apple Silicon..."
make build_base

echo "🚀 Starting NDIF with Apple Silicon optimizations..."
make up dev

echo "✅ NDIF is now running with Apple Silicon optimizations!"
echo ""
echo "🔍 You can monitor the services with:"
echo "  - Ray Dashboard: http://localhost:8266"
echo "  - API Health: http://localhost:5001/health"
echo "  - Grafana: http://localhost:3000"
echo ""
echo "🧪 Test the setup with: python scripts/test.py"
