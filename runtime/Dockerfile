# syntax=docker/dockerfile:1.7

ARG R_VERSION=4.6.0
ARG NODE_VERSION=24.17.0

FROM node:${NODE_VERSION}-bookworm-slim AS node
FROM rocker/r-ver:${R_VERSION} AS runtime

ARG PYTHON_VERSION=3.12.12
ARG PYENV_RELEASE=v2.7.2
ARG S6_VERSION=v2.1.0.2

ENV LANG=C.UTF-8 \
    PYENV_ROOT=/opt/pyenv \
    PYENV_DEFAULT_PYTHON_VERSION=${PYTHON_VERSION} \
    PYENV_RELEASE=${PYENV_RELEASE} \
    PATH=/opt/pyenv/shims:/opt/pyenv/bin:${PATH} \
    R_PROFILE_SITE=/usr/local/lib/R/etc/Rprofile.site \
    RENV_CONFIG_CACHE_SYMLINKS=FALSE \
    S6_VERSION=${S6_VERSION}

COPY scripts/install_extra.sh /opt/nd-docker/scripts/install_extra.sh
COPY scripts/install_hugo.sh /opt/nd-docker/scripts/install_hugo.sh
COPY scripts/install_pyenv.sh /opt/nd-docker/scripts/install_pyenv.sh
COPY scripts/install_static_web_server.sh /opt/nd-docker/scripts/install_static_web_server.sh

COPY --from=node /usr/local/ /usr/local/

RUN chmod +x /opt/nd-docker/scripts/*.sh \
 && /rocker_scripts/install_s6init.sh \
 && /opt/nd-docker/scripts/install_extra.sh

RUN /opt/nd-docker/scripts/install_pyenv.sh

RUN R --version \
 && python --version \
 && pyenv --version \
 && node --version \
 && npm --version

COPY configs/Rprofile.site /usr/local/lib/R/etc/Rprofile.site

CMD ["/init"]


FROM runtime AS shiny

ARG PANDOC_VERSION=3.10
ARG SHINY_SERVER_VERSION=1.5.24.1035
ARG NCPUS=4

ENV NCPUS=${NCPUS} \
    PANDOC_VERSION=${PANDOC_VERSION} \
    SHINY_SERVER_VERSION=${SHINY_SERVER_VERSION}

RUN /rocker_scripts/install_shiny_server.sh "${SHINY_SERVER_VERSION}" \
 && rm -rf /srv/shiny-server/*

COPY configs/shiny-server.conf /etc/shiny-server/shiny-server.conf

EXPOSE 3838

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD curl -fsS http://127.0.0.1:3838/ >/dev/null || exit 1

CMD ["/init"]


FROM runtime AS static

ARG SWS_VERSION=2.43.0
ARG SWS_SHA256_AMD64=da3c4e599d6bb2bf6d3aebb2a97c7ebdae842896cadafec97792b96a595bf5aa
ARG SWS_SHA256_ARM64=6aeca9e23580a187c043daef9c6bf8c12b80bb8d75ed84a23beead2cd193a20d

ENV SWS_PORT=8080 \
    SWS_ROOT=/project/_public \
    SWS_SHA256_AMD64=${SWS_SHA256_AMD64} \
    SWS_SHA256_ARM64=${SWS_SHA256_ARM64} \
    SWS_VERSION=${SWS_VERSION}

RUN /opt/nd-docker/scripts/install_static_web_server.sh

COPY services/static-web-server /etc/services.d/static-web-server
RUN chmod +x \
    /etc/services.d/static-web-server/run \
    /etc/services.d/static-web-server/finish

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -fsS "http://127.0.0.1:${SWS_PORT}/" >/dev/null || exit 1

CMD ["/init"]
