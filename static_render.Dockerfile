# syntax=docker/dockerfile:1

FROM ghcr.io/rocker-org/r-ver:4.5.2

################################################################################
################################################################################
################################################################################

ENV R_LIBS=/usr/local/lib/R/site-library
ENV R_LIBS_SITE=/usr/local/lib/R/site-library
ENV R_LIBS_USER=/usr/local/lib/R/site-library

ENV S6_VERSION="v2.1.0.2"
ENV PANDOC_VERSION="default"
ENV QUARTO_VERSION="default"

RUN /rocker_scripts/install_s6init.sh

RUN /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_quarto.sh

ENV HUGO_VERSION="0.152.2"
ENV MICROMAMBA_VERSION="2.4.0-0"

COPY scripts/install_hugo.sh nd_docker_scripts/install_hugo.sh
RUN nd_docker_scripts/install_hugo.sh

COPY scripts/install_micromamba.sh nd_docker_scripts/install_micromamba.sh
RUN nd_docker_scripts/install_micromamba.sh
ENV MAMBA_ROOT_PREFIX=/opt/micromamba
ENV PATH="$HOME/.local/bin:$PATH"

COPY scripts/install_extra.sh nd_docker_scripts/install_extra.sh
RUN nd_docker_scripts/install_extra.sh

COPY scripts /nd_docker_scripts

ENV RENV_PATHS_ROOT=/root/.cache/renv/
ENV CONDA_PKGS_DIRS=/root/.cache/conda/
ENV MAMBA_ROOT_PREFIX=/root/.cache/mamba/