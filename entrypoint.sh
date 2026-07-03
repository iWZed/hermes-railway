#!/bin/bash

# Enable strict mode
set -e

# Make sure log files exist
touch /tmp/hermes.log /tmp/9router.log /tmp/cf_hermes.log /tmp/cf_9r.log /tmp/cf.log

# Patch loopback IP security check and CORS limits inside container
echo "[*] Patching Hermes Agent WebSocket security gates and CORS..."
python3 -c "
import glob
paths = (
    glob.glob('/opt/venv/lib/python*/site-packages/hermes_cli/web_server.py') +
    glob.glob('/app/hermes-agent/hermes_cli/web_server.py')
)
if paths:
    path = paths[0]
    with open(path, 'r') as f:
        content = f.read()
    
    # 1. Patch CORSMiddleware to allow all origins
    old_cors_variants = [
        'allow_origin_regex=r\"^https?://(localhost|127\\\\.0\\\\.0\\\\.1)(:\\\\d+)?$\",',
        'allow_origin_regex=r\"^https?://(localhost|127\\.0\\.0\\.1)(:\\d+)?$\",',
        'allow_origin_regex=r\'^https?://(localhost|127\\\\.0\\\\.0\\\\.1)(:\\\\d+)?$\',',
        'allow_origin_regex=r\'^https?://(localhost|127\\.0\\.0\\.1)(:\\d+)?$\','
    ]
    for var in old_cors_variants:
        if var in content:
            content = content.replace(var, 'allow_origins=[\"*\"],')
            print('[*] Patched CORSMiddleware')
            break
            
    # 2. Patch _is_accepted_host to always accept hosts
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if 'def _is_accepted_host' in line:
            lines.insert(i + 1, '    return True')
            print('[*] Patched _is_accepted_host')
            break
            
    with open(path, 'w') as f:
        f.write('\n'.join(lines))
"

# 1. Start Hermes Agent Dashboard
echo "[*] Starting Hermes Agent Dashboard on port 9119..."
/opt/venv/bin/hermes dashboard --port 9119 --host 127.0.0.1 &

# 2. Start 9Router Next.js server
echo "[*] Starting 9Router on port 20128..."
cd /app/9router
PORT=20128 HOSTNAME=0.0.0.0 npm run start &

# 3. Configure and Start Cloudflare Tunnel
TUNNEL_MODE=${TUNNEL_MODE:-1}

if [ "$TUNNEL_MODE" = "1" ]; then
    echo "[*] Starting TryCloudflare Tunnel for Hermes Agent..."
    cloudflared tunnel --url http://127.0.0.1:9119 > /tmp/cf_hermes.log 2>&1 &
    
    echo "[*] Starting TryCloudflare Tunnel for 9Router..."
    cloudflared tunnel --url http://127.0.0.1:20128 > /tmp/cf_9r.log 2>&1 &
    
elif [ "$TUNNEL_MODE" = "2" ]; then
    if [ -n "$CF_TUNNEL_TOKEN" ]; then
        echo "[*] Starting Personal Tunnel via Token..."
        cloudflared tunnel --no-autoupdate run --token "$CF_TUNNEL_TOKEN" > /tmp/cf.log 2>&1 &
    elif [ -n "$CF_TUNNEL_ID" ] && [ -n "$CF_TUNNEL_CREDENTIALS" ] && [ -n "$CF_DOMAIN_HERMES" ] && [ -n "$CF_DOMAIN_9R" ]; then
        echo "[*] Configuring Personal Tunnel with dual domains..."
        CF_CONFIG_DIR="/root/.cloudflared"
        mkdir -p "$CF_CONFIG_DIR"
        echo "$CF_TUNNEL_CREDENTIALS" > "$CF_CONFIG_DIR/$CF_TUNNEL_ID.json"
        
        cat > "$CF_CONFIG_DIR/conf.yml" << CF
tunnel: $CF_TUNNEL_ID
credentials-file: $CF_CONFIG_DIR/$CF_TUNNEL_ID.json
ingress:
  - hostname: $CF_DOMAIN_HERMES
    service: http://127.0.0.1:9119
  - hostname: $CF_DOMAIN_9R
    service: http://127.0.0.1:20128
  - service: http_status:404
CF
        echo "[*] Starting Personal Tunnel via config file..."
        cloudflared tunnel --config "$CF_CONFIG_DIR/conf.yml" run > /tmp/cf.log 2>&1 &
    else
        echo "[!] Error: Missing Personal Tunnel variables."
        exit 1
    fi
fi

# Run welcome monitoring script
/app/welcome.sh
