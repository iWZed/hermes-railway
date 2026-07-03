# 1. Build 9router Next.js app
FROM node:20-alpine AS builder
WORKDIR /app/9router
RUN apk add --no-cache git build-base python3
RUN git clone https://github.com/decolua/9router.git .
RUN npm install
RUN npm run build

# 2. Final stage
FROM node:20-alpine
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache curl jq bash psmisc ca-certificates python3 py3-pip git build-base python3-dev

# Clone and build hermes-agent from source to include ui-tui workspace
RUN git clone https://github.com/nousresearch/hermes-agent.git /app/hermes-agent && \
    cd /app/hermes-agent/ui-tui && \
    npm install --silent --no-fund --no-audit --progress=false

# Setup virtual environment and install hermes-agent in editable mode
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir -e /app/hermes-agent

# Expose ports: 9119 (Hermes Agent Dashboard), 20128 (9Router Dashboard/API)
EXPOSE 9119 20128

# Download cloudflared
RUN curl -L -s https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# Copy built 9router files
COPY --from=builder /app/9router /app/9router

# Copy scripts
COPY entrypoint.sh /entrypoint.sh
COPY welcome.sh /app/welcome.sh
RUN chmod +x /entrypoint.sh /app/welcome.sh

ENTRYPOINT ["/entrypoint.sh"]
