# syntax=docker/dockerfile:1

FROM ghcr.io/rocker-org/r-ver:4.5.2

################################################################################
################################################################################
################################################################################

ENV R_LIBS=/usr/local/lib/R/site-library
ENV R_LIBS_SITE=/usr/local/lib/R/site-library
ENV R_LIBS_USER=/usr/local/lib/R/site-library

ENV PYENV_DEFAULT_PYTHON_VERSION="3.12.12"
ENV PYENV_ROOT="/root/.pyenv"
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"

ENV S6_VERSION="v2.1.0.2"
ENV PANDOC_VERSION="default"
ENV QUARTO_VERSION="default"
ENV SWS_ROOT="/project/_public"
ENV SWS_PORT="8080"
ARG SWS_VERSION="2.40.1"

RUN /rocker_scripts/install_s6init.sh

RUN /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_quarto.sh

# Static Web Server (https://static-web-server.net)
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://get.static-web-server.net | sh -s -- --version ${SWS_VERSION} --bin-dir /usr/local/bin

ENV HUGO_VERSION="0.152.2"
ENV MICROMAMBA_VERSION="2.4.0-0"

COPY scripts/install_hugo.sh nd_docker_scripts/install_hugo.sh
RUN nd_docker_scripts/install_hugo.sh

COPY scripts/install_pyenv.sh nd_docker_scripts/install_pyenv.sh
RUN nd_docker_scripts/install_pyenv.sh

COPY scripts/install_extra.sh nd_docker_scripts/install_extra.sh
RUN nd_docker_scripts/install_extra.sh

COPY scripts/setup_r.sh nd_docker_scripts/setup_r.sh
RUN nd_docker_scripts/setup_r.sh

COPY scripts /nd_docker_scripts

# s6 service for static-web-server
COPY services/static-web-server /etc/services.d/static-web-server
RUN chmod +x /etc/services.d/static-web-server/run /etc/services.d/static-web-server/finish

CMD ["/init"]
