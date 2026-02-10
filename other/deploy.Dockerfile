FROM ghcr.io/linuxserver-labs/webhook:latest

# Install packages
RUN apk add --no-cache \
      bash \
      git \
      openssh-client \
      docker-cli \
      docker-cli-compose \
      python3 \
      py3-pip
      
# Create a venv and install PyYAML there
RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir --upgrade pip \
    && /opt/venv/bin/pip install --no-cache-dir pyyaml

# Defaults baked into the image
COPY other/defaults/ /defaults/

# Deploy scripts invoked by webhook
COPY other/scripts/deploy.sh /usr/local/bin/deploy.sh
COPY other/scripts/deploy.py /usr/local/bin/deploy.py
RUN chmod +x /usr/local/bin/deploy.sh /usr/local/bin/deploy.py

# Startup bootstrap: copy defaults into /config if missing
COPY other/cont-init.d/ /etc/cont-init.d/
RUN chmod +x /etc/cont-init.d/*
