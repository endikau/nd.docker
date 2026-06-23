# nd.docker runtimes

One multi-target Dockerfile provides the shared runtime and the two service
variants:

- `runtime`: R 4.6.0, pyenv 2.7.2, Python 3.12.12, Node 24.17.0/npm,
  `libnode-dev`, s6, and shared system libraries.
- `shiny`: `runtime` plus Shiny Server and its s6 service.
- `static`: `runtime` plus static-web-server and its s6 service.

Build all local targets:

```bash
docker compose build
```

Published images use the versioned tag `4.6.0-py3.12.12-v2` as well as
`latest`. Application Dockerfiles should use the versioned tag.

Quarto, Pandoc, and Hugo are build-only dependencies in `nd.site`. Node is
part of the shared runtime because both projects use it and R package `V8`
can link against the system `libnode`.
