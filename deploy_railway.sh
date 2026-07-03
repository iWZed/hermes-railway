#!/bin/bash

# Define Colors
R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
B='\033[0;34m'
C='\033[0;36m'
W='\033[1;37m'
N='\033[0m'

print_header() {
    clear
    echo -e "${C}🤖 HERMES AGENT & 9ROUTER RAILWAY DEPLOYER | t.me/iWZedLabs${N}"
    echo -e "${C}────────────────────────────────────────────────────────────${N}"
}

resolve_zone_name() {
    ZONE_NAME=""
    if [ -f "$HOME/.cloudflared/cert.pem" ]; then
        TOKEN_CONTENT=$(grep -v "ARGO TUNNEL TOKEN" "$HOME/.cloudflared/cert.pem" | tr -d "\n\r ")
        DECODED_JSON=$(echo "$TOKEN_CONTENT" | base64 -d 2>/dev/null)
        ZONE_ID=$(echo "$DECODED_JSON" | jq -r ".zoneID // empty")
        API_TOKEN=$(echo "$DECODED_JSON" | jq -r ".apiToken // empty")
        if [ -n "$ZONE_ID" ] && [ -n "$API_TOKEN" ]; then
            echo -ne "${Y}❯ Querying Cloudflare account domains...${N}"
            ZONE_NAME=$(curl -s --max-time 10 -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID" \
                 -H "Authorization: Bearer $API_TOKEN" \
                 -H "Content-Type: application/json" | jq -r ".result.name // empty")
            if [ -n "$ZONE_NAME" ]; then
                echo -e " ${G}Detected: $ZONE_NAME${N}"
            else
                echo -e " ${R}Failed${N}"
            fi
        fi
    fi
}

print_header

# 1. PREREQUISITE CHECKS
echo -e "${Y}❯ Checking dependencies...${N}"

# Check git
if ! command -v git &> /dev/null; then
    echo -e "${R}✖ Error: git is not installed.${N}"
    exit 1
fi
git init >/dev/null 2>&1 || true

# Check Railway CLI
if ! command -v railway &> /dev/null; then
    # Add common binary paths to search
    export PATH="$PATH:$HOME/.railway/bin:$HOME/.local/bin"
    if ! command -v railway &> /dev/null; then
        echo -e "${Y}❯ Railway CLI not found. Attempting automatic installation...${N}"
        if command -v npm &> /dev/null; then
            echo -e "${Y}[*] Installing via npm...${N}"
            npm install -g @railway/cli || npm install --prefix "$HOME/.local" @railway/cli
            export PATH="$PATH:$HOME/.local/bin"
        else
            echo -e "${Y}[*] Installing via standalone curl script...${N}"
            curl -fsSL https://railway.com/install.sh | sh || true
            export PATH="$PATH:$HOME/.railway/bin"
        fi
        
        if ! command -v railway &> /dev/null; then
            echo -e "${R}✖ Error: Railway CLI could not be installed automatically.${N}"
            echo -e "${Y}❯ Please install it manually: npm i -g @railway/cli or curl -fsSL https://railway.com/install.sh | sh${N}"
            exit 1
        fi
    fi
fi

# Check cloudflared
CLOUDFLARED_BIN=""
if command -v cloudflared &> /dev/null; then
    CLOUDFLARED_BIN="cloudflared"
else
    if [ -f "$HOME/.local/bin/cloudflared" ]; then
        CLOUDFLARED_BIN="$HOME/.local/bin/cloudflared"
    else
        echo -e "${Y}❯ cloudflared not found. Downloading locally...${N}"
        mkdir -p "$HOME/.local/bin"
        curl -L -s https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o "$HOME/.local/bin/cloudflared"
        chmod +x "$HOME/.local/bin/cloudflared"
        CLOUDFLARED_BIN="$HOME/.local/bin/cloudflared"
    fi
fi

# Check jq
if ! command -v jq &> /dev/null; then
    echo -e "${R}✖ Error: jq is required but not installed.${N}"
    exit 1
fi

echo -e "${G}✔ All dependencies satisfied.${N}\n"

# 2. RAILWAY LOGIN CHECK
echo -e "${Y}❯ Verifying Railway authentication...${N}"
IS_LOGGED_IN=false
if railway status &>/dev/null; then
    IS_LOGGED_IN=true
fi

if [ "$IS_LOGGED_IN" = true ]; then
    RW_USER=$(railway whoami --json 2>/dev/null | jq -r ".email // empty")
    if [ -n "$RW_USER" ]; then
        echo -e "${G}✔ Detected active Railway account: ${W}$RW_USER${N}"
        read -p "  👉 Do you want to use this account? [Y/n]: " rw_acc_opt
        if [[ "$rw_acc_opt" =~ ^[nN] ]]; then
            echo -e "${Y}[*] Logging out from current Railway account...${N}"
            railway logout
            IS_LOGGED_IN=false
        fi
    else
        echo -e "${G}✔ Authenticated with Railway.${N}"
    fi
fi

if [ "$IS_LOGGED_IN" = false ]; then
    echo -e "${Y}[*] Not logged into Railway. Opening login...${N}"
    railway login
fi

# 3. CHOOSE RAILWAY PROJECT
echo -e "\n${C}❯ Railway Project Setup:${N}"
echo -e "  ${G}[1]${N} Create a new Railway project"
echo -e "  ${Y}[2]${N} Link to an existing Railway project"

while true; do
    read -p "  👉 Choice [1-2]: " proj_choice_raw
    proj_choice=$(echo "$proj_choice_raw" | tr '۰۱۲۳۴۵۶۷۸۹٠١٢٣٤٥٦٧٨٩' '01234567890123456789')
    
    if [ "$proj_choice" = "1" ]; then
        railway init
        railway add --service zed-hermes >/dev/null 2>&1 || true
        break
    elif [ "$proj_choice" = "2" ]; then
        railway link
        railway add --service zed-hermes >/dev/null 2>&1 || true
        break
    else
        echo -e "${R}✖ Invalid choice. Please enter 1 or 2.${N}"
    fi
done

# 4. CONFIGURE TUNNEL MODE
while true; do
    print_header
    echo -e "\n${C}❯ Select Cloudflare Tunnel Mode:${N}"
    echo -e "  ${G}[1]${N} Free Cloudflare Tunnel (TryCloudflare - Temporary)"
    echo -e "  ${Y}[2]${N} Personal Tunnel (Custom Domain - Persistent)"
    
    read -p "  👉 Choice [1-2]: " cf_mode_raw
    cf_mode=$(echo "$cf_mode_raw" | tr '۰۱۲۳۴۵۶۷۸۹٠١٢٣٤٥٦٧٨٩' '01234567890123456789')
    
    if [ "$cf_mode" = "1" ]; then
        echo -e "${Y}❯ Configuring TryCloudflare...${N}"
        railway variable set TUNNEL_MODE=1 --service zed-hermes >/dev/null 2>&1 || true
        cf_domain_hermes=""
        cf_domain_9r=""
        break
    elif [ "$cf_mode" = "2" ]; then
        while true; do
            print_header
            echo -e "\n${C}❯ Personal Tunnel Authentication:${N}"
            echo -e "  ${G}[1]${N} Automate Setup (Login & Create Tunnel locally)"
            echo -e "  ${Y}[2]${N} Manual Setup (Enter Tunnel Token & Domain manually)"
            
            read -p "  👉 Choice [1-2]: " cf_auth_choice_raw
            cf_auth_choice=$(echo "$cf_auth_choice_raw" | tr '۰۱۲۳۴۵۶۷۸۹٠١٢٣٤٥٦٧٨٩' '01234567890123456789')
            
            if [ "$cf_auth_choice" = "1" ]; then
                if [ ! -f "$HOME/.cloudflared/cert.pem" ]; then
                    echo -e "${Y}[*] Cloudflare authentication required. Please follow the login prompt:${N}"
                    $CLOUDFLARED_BIN tunnel login
                fi
                resolve_zone_name

                # Check for previously configured domain
                PREV_HERMES=""
                PREV_9R=""
                if [ -f "./.cf_domain" ]; then
                    PREV_HERMES=$(grep -E '^hermes_domain:' ./.cf_domain | cut -d' ' -f2 || true)
                    PREV_9R=$(grep -E '^9r_domain:' ./.cf_domain | cut -d' ' -f2 || true)
                fi
                if [ -z "$PREV_HERMES" ]; then
                    PREV_HERMES=$(railway variable list --service zed-hermes --json 2>/dev/null | jq -r ".CF_DOMAIN_HERMES // empty")
                    PREV_9R=$(railway variable list --service zed-hermes --json 2>/dev/null | jq -r ".CF_DOMAIN_9R // empty")
                fi
                
                cf_domain_hermes=""
                cf_domain_9r=""
                REUSE_PREV=false
                if [ -n "$PREV_HERMES" ] && [ -n "$PREV_9R" ]; then
                    echo -e "${Y}❯ Detected previously configured subdomains: Hermes: ${W}$PREV_HERMES${Y}, 9Router: ${W}$PREV_9R${N}"
                    read -p "  👉 Do you want to reuse these subdomains? [Y/n]: " reuse_opt
                    if [[ ! "$reuse_opt" =~ ^[nN] ]]; then
                        REUSE_PREV=true
                    fi
                fi

                if [ "$REUSE_PREV" = true ]; then
                    cf_domain_hermes="$PREV_HERMES"
                    cf_domain_9r="$PREV_9R"
                else
                    # Confirm if they want to use the currently detected domain
                    USE_DETECTED=false
                    if [ -n "$ZONE_NAME" ]; then
                        echo -e "${Y}❯ Detected domain on your Cloudflare account: ${W}$ZONE_NAME${N}"
                        read -p "  👉 Do you want to use this domain? [Y/n]: " use_detected_opt
                        if [[ ! "$use_detected_opt" =~ ^[nN] ]]; then
                            USE_DETECTED=true
                        fi
                    fi

                    if [ "$USE_DETECTED" = false ]; then
                        echo -e "${Y}[*] Re-authenticating with Cloudflare to choose a different domain...${N}"
                        rm -f "$HOME/.cloudflared/cert.pem"
                        $CLOUDFLARED_BIN tunnel login
                        resolve_zone_name
                        
                        # Fallback to manual entry if API query failed
                        if [ -z "$ZONE_NAME" ]; then
                            echo -e "\n${C}>>> Enter your Cloudflare Root Domain (e.g. koshix.com) <<<${N}"
                            read -p " Domain: " ZONE_NAME
                            ZONE_NAME=$(echo "$ZONE_NAME" | xargs)
                            if [ -z "$ZONE_NAME" ]; then
                                echo -e "${R}[!] Domain cannot be empty.${N}"
                                exit 1
                            fi
                        fi
                    fi

                    cf_domain_hermes="hermes.$ZONE_NAME"
                    cf_domain_9r="9r.$ZONE_NAME"
                    echo -e "${G}✔ Subdomains automatically set to:${N}"
                    echo -e "  - Hermes Agent: ${C}$cf_domain_hermes${N}"
                    echo -e "  - 9Router:      ${C}$cf_domain_9r${N}"
                fi
                
                # Save domains locally for next time
                echo "hermes_domain: $cf_domain_hermes" > ./.cf_domain
                echo "9r_domain: $cf_domain_9r" >> ./.cf_domain
                
                TNAME="zed-hermes-$(date +%s)"
                echo -e "${Y}[*] Creating Tunnel (${TNAME})...${N}"
                $CLOUDFLARED_BIN tunnel create "$TNAME"
                
                TID=$($CLOUDFLARED_BIN tunnel list | grep "$TNAME" | awk '{print $1}' | head -n1)
                if [ -z "$TID" ]; then
                    echo -e "${R}[!] Failed to retrieve Tunnel ID.${N}"
                    exit 1
                fi
                
                echo -e "${Y}[*] Routing DNS for ${cf_domain_hermes}...${N}"
                $CLOUDFLARED_BIN tunnel route dns -f "$TID" "$cf_domain_hermes"
                
                echo -e "${Y}[*] Routing DNS for ${cf_domain_9r}...${N}"
                $CLOUDFLARED_BIN tunnel route dns -f "$TID" "$cf_domain_9r"
                
                CRED_FILE="$HOME/.cloudflared/$TID.json"
                if [ ! -f "$CRED_FILE" ]; then
                    echo -e "${R}[!] Credentials file not found at $CRED_FILE${N}"
                    exit 1
                fi
                CF_CRED_CONTENT=$(cat "$CRED_FILE")
                
                echo -e "${Y}❯ Uploading Cloudflare Tunnel configuration to Railway...${N}"
                railway variable set TUNNEL_MODE=2 CF_TUNNEL_ID="$TID" CF_TUNNEL_CREDENTIALS="$CF_CRED_CONTENT" CF_DOMAIN_HERMES="$cf_domain_hermes" CF_DOMAIN_9R="$cf_domain_9r" --service zed-hermes >/dev/null 2>&1 || true
                break 2
                
            elif [ "$cf_auth_choice" = "2" ]; then
                read -p "  👉 Enter your Cloudflare Tunnel Token: " cf_token
                read -p "  👉 Enter your Hermes Domain (e.g., hermes.yourdomain.com): " cf_domain_hermes
                read -p "  👉 Enter your 9Router Domain (e.g., 9r.yourdomain.com): " cf_domain_9r
                cf_token=$(echo "$cf_token" | xargs)
                cf_domain_hermes=$(echo "$cf_domain_hermes" | xargs)
                cf_domain_9r=$(echo "$cf_domain_9r" | xargs)
                if [ -n "$cf_token" ] && [ -n "$cf_domain_hermes" ] && [ -n "$cf_domain_9r" ]; then
                    echo -e "${Y}❯ Setting Personal Tunnel variables on Railway...${N}"
                    railway variable set TUNNEL_MODE=2 CF_TUNNEL_TOKEN="$cf_token" CF_DOMAIN_HERMES="$cf_domain_hermes" CF_DOMAIN_9R="$cf_domain_9r" --service zed-hermes >/dev/null 2>&1 || true
                    
                    # Save domains locally
                    echo "hermes_domain: $cf_domain_hermes" > ./.cf_domain
                    echo "9r_domain: $cf_domain_9r" >> ./.cf_domain
                    break 2
                else
                    echo -e "${R}✖ Inputs cannot be empty.${N}"
                fi
            else
                echo -e "${R}✖ Invalid choice. Please enter 1 or 2.${N}"
            fi
        done
    else
        echo -e "${R}✖ Invalid choice. Please enter 1 or 2.${N}"
    fi
done

# 5. START DEPLOYMENT
max_deploy_retries=3
deploy_retry=1
deploy_success=false

echo -e "\n${Y}❯ Compiling and deploying container to Railway (this may take a moment)...${N}"

while [ $deploy_retry -le $max_deploy_retries ]; do
    railway up --service zed-hermes --ci --detach
    if [ $? -eq 0 ]; then
        deploy_success=true
        break
    else
        echo -e "${R}✖ Attempt $deploy_retry failed.${N}"
        if [ $deploy_retry -lt $max_deploy_retries ]; then
            echo -e "${Y}❯ Retrying deployment in 5 seconds (attempt $((deploy_retry+1))/$max_deploy_retries)...${N}"
            sleep 5
        fi
    fi
    deploy_retry=$((deploy_retry+1))
done

if [ "$deploy_success" = false ]; then
    echo -e "${R}✖ Error: Code upload to Railway failed.${N}"
    exit 1
else
    echo -e "${G}✔ Code uploaded successfully! Starting build on Railway...${N}"
fi

# 6. MONITOR BUILD & GET URLS
echo -e "${Y}❯ Monitoring Railway build status...${N}"

elapsed=0
STATUS="CHECKING"
domain_hermes=""
domain_9r=""
build_failed=false

while [ $elapsed -lt 600 ]; do
    # Every 5 seconds, fetch status of the latest deployment
    if [ $((elapsed % 5)) -eq 0 ]; then
        NEW_STATUS=$(railway deployment list --json --limit 1 --service zed-hermes 2>/dev/null | jq -r ".[0].status // empty")
        if [ -n "$NEW_STATUS" ]; then
            STATUS="$NEW_STATUS"
        fi
    fi
    
    # Calculate minutes and seconds
    min=$((elapsed / 60))
    sec=$((elapsed % 60))
    
    # Clear line and print live progress
    echo -ne "\r\033[K${Y}❯ [$(printf "%02d:%02d" $min $sec)] Build Status: ${W}${STATUS}${N}..."
    
    # Verify build status
    if [ "$STATUS" = "FAILED" ] || [ "$STATUS" = "CRASHED" ]; then
        build_failed=true
        break
    elif [ "$STATUS" = "SUCCESS" ] || [ "$STATUS" = "REMOVED" ] || [ "$STATUS" = "INITIALIZING" ]; then
        # Fetch logs only when initialized or successful
        LOGS=$(railway logs --service zed-hermes 2>/dev/null || true)
        
        if [ "$cf_mode" = "1" ]; then
            domain_hermes=$(echo "$LOGS" | grep -A1 "HERMES AGENT" | grep -oE "[a-zA-Z0-9.-]+\.trycloudflare\.com" | head -n1 || true)
            domain_9r=$(echo "$LOGS" | grep -A1 "9ROUTER" | grep -oE "[a-zA-Z0-9.-]+\.trycloudflare\.com" | head -n1 || true)
            if [ -n "$domain_hermes" ] && [ -n "$domain_9r" ]; then
                break
            fi
        else
            domain_hermes=$cf_domain_hermes
            domain_9r=$cf_domain_9r
            break
        fi
    fi
    
    sleep 1
    elapsed=$((elapsed+1))
done
echo ""

if [ "$build_failed" = true ]; then
    echo -e "${R}✖ Error: Railway build/deployment FAILED.${N}"
    echo -e "${Y}❯ Please check the build logs on your Railway dashboard or run:${N}"
    echo -e "  ${C}railway logs --service zed-hermes${N}\n"
    exit 1
fi

# 7. DISPLAY FINAL OUTPUT BANNERS
print_header
echo -e "\n🎉 ${G}SUCCESS! Hermes Agent & 9Router are running on Railway.${N}\n"

if [ "$cf_mode" = "1" ] && { [ -z "$domain_hermes" ] || [ -z "$domain_9r" ]; }; then
    echo -e "${R}✖ Could not automatically fetch TryCloudflare URLs from logs.${N}"
    echo -e "${Y}❯ Please check the service logs manually to copy the links:${N}"
    echo -e "    ${C}railway logs --service zed-hermes${N}\n"
else
    echo -e "${W}🤖 HERMES AGENT DASHBOARD:${N}"
    echo -e "   URL:  ${C}https://$domain_hermes${N}\n"
    
    echo -e "${W}🌐 9ROUTER (API & DASHBOARD):${N}"
    echo -e "   URL:  ${C}https://$domain_9r${N}\n"
fi

echo -e "${Y}❯ The services run 24/7 in the background on Railway.${N}"
echo -e "${Y}❯ Join our Telegram channel: ${C}https://t.me/iWZedLabs${N}\n"
