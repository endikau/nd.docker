# syntax=docker/dockerfile:1

FROM ghcr.io/rocker-org/r-ver:4.5.2

################################################################################
################################################################################
################################################################################

ENV R_LIBS=/usr/local/lib/R/site-library
ENV R_LIBS_SITE=/usr/local/lib/R/site-library
ENV R_LIBS_USER=/usr/local/lib/R/site-library

ENV S6_VERSION="v2.1.0.2"
# ENV MICROMAMBA_VERSION="2.4.0-0"
ENV SHINY_SERVER_VERSION="latest"

RUN /rocker_scripts/install_shiny_server.sh
COPY configs/shiny-server.conf /etc/shiny-server/shiny-server.conf
EXPOSE 3838
CMD ["/init"]

RUN apt-get update \
 && apt-get install -y --no-install-recommends git-all  \
 && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://pyenv.run | bash

# COPY scripts/install_micromamba.sh nd_docker_scripts/install_micromamba.sh
# RUN nd_docker_scripts/install_micromamba.sh
# ENV MAMBA_ROOT_PREFIX=/opt/micromamba
# ENV PATH="/root/.local/bin:${PATH}"

COPY scripts/install_extra.sh nd_docker_scripts/install_extra.sh
RUN nd_docker_scripts/install_extra.sh

COPY scripts /nd_docker_scripts
