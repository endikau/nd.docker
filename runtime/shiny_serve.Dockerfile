# syntax=docker/dockerfile:1

FROM ghcr.io/rocker-org/r-ver:4.5.2

################################################################################
################################################################################
################################################################################

ENV R_LIBS=/usr/local/lib/R/site-library
ENV R_LIBS_SITE=/usr/local/lib/R/site-library
ENV R_LIBS_USER=/usr/local/lib/R/site-library
ENV R_PROFILE="/usr/local/lib/R/etc/Rprofile.site"

ENV PYENV_DEFAULT_PYTHON_VERSION="3.12.12"
ENV PYENV_ROOT="/root/.pyenv"
ENV PATH="${PYENV_ROOT}/shims:${PATH}"

ENV S6_VERSION="v2.1.0 SHINY_SERVER_VERSION="latest"

RUN /rocker_scripts/install_shiny_server.sh
COPY configs/shiny-server.conf /etc/shiny-server/shiny-server.conf
EXPOSE 3838
CMD ["/init"]

COPY scripts/install_pyenv.sh nd_docker_scripts/install_pyenv.sh
RUN nd_docker_scripts/install_pyenv.sh

COPY scripts/install_extra.sh nd_docker_scripts/install_extra.sh
RUN nd_docker_scripts/install_extra.sh

COPY scripts /nd_docker_scripts

COPY configs/Rprofile.site /usr/local/lib/R/etc/Rprofile.site