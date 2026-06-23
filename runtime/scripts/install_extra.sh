#!/usr/bin/env bash
set -euo pipefail

apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates \
    cmake \
    curl \
    git \
    libcurl4-openssl-dev \
    libglpk-dev \
    libgsl0-dev \
    libicu-dev \
    libmagick++-dev \
    libnode-dev \
    libpoppler-cpp-dev \
    libfribidi-dev \
    libharfbuzz-dev \
    libprotobuf-dev \
    libprotoc-dev \
    libxml2-dev \
    protobuf-compiler

rm -rf /var/lib/apt/lists/*
