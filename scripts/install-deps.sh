#!/usr/bin/env bash
set -euo pipefail

echo "===== Installing Dependencies ====="

apt-get update

apt-get install -y \
    build-essential \
    git \
    cmake \
    pkg-config \
    apache2 \
    php \
    php-cli \
    php-xml \
    php-sqlite3 \
    sqlite3 \
    python3 \
    curl \
    wget \
    unzip

echo
echo "[PASS] Dependencies installed"
