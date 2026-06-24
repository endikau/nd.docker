#!/usr/bin/env bash
set -euo pipefail

apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates \
    cmake \
    curl \
    git \
    locales \
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

locales_to_generate=(
    "de_DE.UTF-8 UTF-8"
    "de_AT.UTF-8 UTF-8"
    "de_CH.UTF-8 UTF-8"
    "en_US.UTF-8 UTF-8"
    "en_GB.UTF-8 UTF-8"
    "en_CA.UTF-8 UTF-8"
    "en_AU.UTF-8 UTF-8"
    "fr_FR.UTF-8 UTF-8"
    "fr_CH.UTF-8 UTF-8"
    "es_ES.UTF-8 UTF-8"
    "es_MX.UTF-8 UTF-8"
    "it_IT.UTF-8 UTF-8"
    "nl_NL.UTF-8 UTF-8"
    "pt_BR.UTF-8 UTF-8"
    "pt_PT.UTF-8 UTF-8"
    "da_DK.UTF-8 UTF-8"
    "fi_FI.UTF-8 UTF-8"
    "nb_NO.UTF-8 UTF-8"
    "sv_SE.UTF-8 UTF-8"
    "cs_CZ.UTF-8 UTF-8"
    "pl_PL.UTF-8 UTF-8"
    "ru_RU.UTF-8 UTF-8"
    "tr_TR.UTF-8 UTF-8"
    "ja_JP.UTF-8 UTF-8"
    "ko_KR.UTF-8 UTF-8"
    "zh_CN.UTF-8 UTF-8"
    "zh_TW.UTF-8 UTF-8"
)

printf "%s\n" "${locales_to_generate[@]}" > /etc/locale.gen
locale-gen

locale -a | grep -Fxq "de_DE.utf8"
locale -a | grep -Fxq "en_US.utf8"

rm -rf /var/lib/apt/lists/*
