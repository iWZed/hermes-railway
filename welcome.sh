#!/bin/bash

# Define colors
R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
B='\033[0;34m'
C='\033[0;36m'
W='\033[1;37m'
N='\033[0m'

echo -e "\n${C}⚡ HERMES AGENT & 9ROUTER SERVICE MONITOR | t.me/iWZedLabs${N}"
echo -e "${C}────────────────────────────────────────────────────────────${N}"

# Wait for Hermes Agent and 9Router to start locally
echo -e "${Y}❯ Waiting for Hermes Agent and 9Router to start locally...${N}"
sleep 5

TUNNEL_MODE=${TUNNEL_MODE:-1}
domain_hermes=""
domain_9r=""

if [ "$TUNNEL_MODE" = "1" ]; then
    echo -e "${Y}❯ Retrieving TryCloudflare tunnel links...${N}"
    
    # Retry loop to scrape domains from log files
    retries=0
    while [ $retries -lt 30 ]; do
        if [ -z "$domain_hermes" ]; then
            domain_hermes=$(grep -oE '[a-zA-Z0-9.-]+\.trycloudflare\.com' /tmp/cf_hermes.log | head -n1 || true)
        fi
        if [ -z "$domain_9r" ]; then
            domain_9r=$(grep -oE '[a-zA-Z0-9.-]+\.trycloudflare\.com' /tmp/cf_9r.log | head -n1 || true)
        fi
        
        if [ -n "$domain_hermes" ] && [ -n "$domain_9r" ]; then
            break
        fi
        sleep 1
        retries=$((retries+1))
    done
else
    domain_hermes=$CF_DOMAIN_HERMES
    domain_9r=$CF_DOMAIN_9R
fi

# Print Final Banner
echo -e "\n🎉 ${G}SUCCESS! Services are live on Cloudflare Tunnels:${N}\n"

if [ -n "$domain_hermes" ]; then
    echo -e "${W}🤖 HERMES AGENT DASHBOARD:${N}"
    echo -e "   URL:  ${C}https://$domain_hermes${N}\n"
else
    echo -e "${R}✖ Failed to retrieve Hermes Agent tunnel URL.${N}"
fi

if [ -n "$domain_9r" ]; then
    echo -e "${W}🌐 9ROUTER (API & DASHBOARD):${N}"
    echo -e "   URL:  ${C}https://$domain_9r${N}\n"
else
    echo -e "${R}✖ Failed to retrieve 9Router tunnel URL.${N}"
fi

echo -e "${Y}❯ The services run 24/7 in the background on Railway.${N}"
echo -e "${Y}❯ Join our Telegram channel: ${C}https://t.me/iWZedLabs${N}\n"

# Keep container alive
exec tail -f /dev/null
