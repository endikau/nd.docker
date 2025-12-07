# syntax=docker/dockerfile:1

FROM ghcr.io/rocker-org/r-ver:4.5.2

ENV S6_VERSION="v2.1.0.2"
ENV SHINY_SERVER_VERSION="latest"

RUN /rocker_scripts/install_shiny_server.sh

EXPOSE 3838
CMD ["/init"]

COPY scripts /nd_docker_scripts