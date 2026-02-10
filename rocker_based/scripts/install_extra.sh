#!/bin/bash
set -e

# a function to install apt packages only if they are not installed
function apt_install() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            apt-get update
        fi
        apt-get install -y --no-install-recommends "$@"
    fi
}

apt_install \
    libcurl4-openssl-dev \
    libicu-dev \
    libnode-dev \
    libxml2-dev \
    libmagick++-dev \
    libpoppler-cpp-dev \
    libglpk-dev \
    libgsl0-dev \
    libprotobuf-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libprotoc-dev \
    protobuf-compiler \
    nodejs \
    npm

# Clean up
rm -rf /var/lib/apt/lists/*
