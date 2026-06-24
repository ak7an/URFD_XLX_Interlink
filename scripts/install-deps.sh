#!/usr/bin/env bash
set -euo pipefail

echo "===== Installing Dependencies ====="
echo "[INFO] Monit is optional/historical; install it separately with scripts/install-monit.sh if needed."

apt-get update

apt-get install -y \
    build-essential \
    nlohmann-json3-dev \
    git \
    cmake \
    pkg-config \
    apache2 \
    apache2-utils \
    php \
    php-cli \
    php-xml \
    php-sqlite3 \
    sqlite3 \
    python3 \
    curl \
    libcurl4-openssl-dev \
    wget \
    unzip

echo
echo "[PASS] Dependencies installed"
