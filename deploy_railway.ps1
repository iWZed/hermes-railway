# Enable console colors
$global:DefaultParameterValues['Out-Default:Transcript'] = $null

function Print-Header {
    Clear-Host
    Write-Host "🤖 HERMES AGENT & 9ROUTER RAILWAY DEPLOYER | t.me/iWZedLabs" -ForegroundColor Cyan
    Write-Host "────────────────────────────────────────────────────────────" -ForegroundColor Cyan
}

Print-Header

# 1. PREREQUISITE CHECKS
Write-Host "❯ Checking dependencies..." -ForegroundColor Yellow

# Check Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "✖ Error: git is not installed." -ForegroundColor Red
    Exit 1
}
& git init 2>&1 >$null

# Check Railway CLI
if (-not (Get-Command railway -ErrorAction SilentlyContinue)) {
    # Check common local install paths
    $railwayLocalPath = Join-Path $env:USERPROFILE ".railway\bin\railway.exe"
    if (Test-Path $railwayLocalPath) {
        $env:PATH += ";$env:USERPROFILE\.railway\bin"
    } else {
        Write-Host "❯ Railway CLI not found. Attempting automatic installation..." -ForegroundColor Yellow
        if (Get-Command npm -ErrorAction SilentlyContinue) {
            Write-Host "[*] Installing via npm..." -ForegroundColor Yellow
            & npm install -g @railway/cli
        } else {
            Write-Host "[*] Installing via standalone PowerShell script..." -ForegroundColor Yellow
            Invoke-Expression (Invoke-RestMethod https://railway.com/install.ps1)
            $env:PATH += ";$env:USERPROFILE\.railway\bin"
        }
        
        if (-not (Get-Command railway -ErrorAction SilentlyContinue)) {
            Write-Host "✖ Error: Railway CLI could not be installed automatically." -ForegroundColor Red
            Write-Host "❯ Please install it manually: npm i -g @railway/cli" -ForegroundColor Yellow
            Exit 1
        }
    }
}

# Check cloudflared
$cloudflaredBin = "cloudflared"
if (-not (Get-Command cloudflared -ErrorAction SilentlyContinue)) {
    $localBinPath = Join-Path $env:USERPROFILE ".local\bin"
    $cloudflaredPath = Join-Path $localBinPath "cloudflared.exe"
    if (Test-Path $cloudflaredPath) {
        $cloudflaredBin = $cloudflaredPath
    } else {
        Write-Host "❯ cloudflared not found. Downloading locally..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Force -Path $localBinPath | Out-Null
        Invoke-WebRequest -Uri "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe" -OutFile $cloudflaredPath
        $cloudflaredBin = $cloudflaredPath
    }
}

Write-Host "✔ All dependencies satisfied." -ForegroundColor Green
Write-Host ""

# 2. RAILWAY LOGIN CHECK
Write-Host "❯ Verifying Railway authentication..." -ForegroundColor Yellow
$isLoggedIn = $false
$null = & railway status 2>&1
if ($LASTEXITCODE -eq 0) {
    $isLoggedIn = $true
}

if ($isLoggedIn) {
    $rwUserJson = & railway whoami --json 2>$null | ConvertFrom-Json
    if ($rwUserJson -and $rwUserJson.email) {
        $rwUser = $rwUserJson.email
        Write-Host "✔ Detected active Railway account: $rwUser" -ForegroundColor Green
        $rwAccOpt = Read-Host "  👉 Do you want to use this account? [Y/n]"
        if ($rwAccOpt -match "^[nN]") {
            Write-Host "[*] Logging out from current Railway account..." -ForegroundColor Yellow
            & railway logout
            $isLoggedIn = $false
        }
    } else {
        Write-Host "✔ Authenticated with Railway." -ForegroundColor Green
    }
}

if (-not $isLoggedIn) {
    Write-Host "[*] Not logged into Railway. Opening login..." -ForegroundColor Yellow
    & railway login
}

# 3. CHOOSE RAILWAY PROJECT
Write-Host ""
Write-Host "❯ Railway Project Setup:" -ForegroundColor Cyan
Write-Host "  [1] Create a new Railway project" -ForegroundColor Green
Write-Host "  [2] Link to an existing Railway project" -ForegroundColor Yellow

while ($true) {
    $projChoice = Read-Host "  👉 Choice [1-2]"
    if ($projChoice -eq "1" -or $projChoice -eq "۱") {
        & railway init
        & railway add --service zed-hermes 2>&1 >$null
        break
    } elseif ($projChoice -eq "2" -or $projChoice -eq "۲") {
        & railway link
        & railway add --service zed-hermes 2>&1 >$null
        break
    } else {
        Write-Host "✖ Invalid choice. Please enter 1 or 2." -ForegroundColor Red
    }
}

# 4. CONFIGURE TUNNEL MODE
while ($true) {
    Print-Header
    Write-Host ""
    Write-Host "❯ Select Cloudflare Tunnel Mode:" -ForegroundColor Cyan
    Write-Host "  [1] Free Cloudflare Tunnel (TryCloudflare - Temporary)" -ForegroundColor Green
    Write-Host "  [2] Personal Tunnel (Custom Domain - Persistent)" -ForegroundColor Yellow
    
    $cfMode = Read-Host "  👉 Choice [1-2]"
    
    if ($cfMode -eq "1" -or $cfMode -eq "۱") {
        Write-Host "❯ Configuring TryCloudflare..." -ForegroundColor Yellow
        & railway variable set TUNNEL_MODE=1 --service zed-hermes 2>&1 >$null
        $cfDomainHermes = $null
        $cfDomain9r = $null
        break
    } elseif ($cfMode -eq "2" -or $cfMode -eq "۲") {
        while ($true) {
            Print-Header
            Write-Host ""
            Write-Host "❯ Personal Tunnel Authentication:" -ForegroundColor Cyan
            Write-Host "  [1] Automate Setup (Login & Create Tunnel locally)" -ForegroundColor Green
            Write-Host "  [2] Manual Setup (Enter Tunnel Token & Domain manually)" -ForegroundColor Yellow
            
            $cfAuthChoice = Read-Host "  👉 Choice [1-2]"
            
            if ($cfAuthChoice -eq "1" -or $cfAuthChoice -eq "۱") {
                $certPath = Join-Path $env:USERPROFILE ".cloudflared\cert.pem"
                if (-not (Test-Path $certPath)) {
                    Write-Host "[*] Cloudflare authentication required. Please follow the login prompt:" -ForegroundColor Yellow
                    Start-Process $cloudflaredBin -ArgumentList "tunnel login" -NoNewWindow -Wait
                }
                
                # Function block to resolve Zone Name
                $resolveZone = {
                    $global:zoneName = $null
                    if (Test-Path $certPath) {
                        try {
                            $tokenContent = (Get-Content -Path $certPath | Where-Object { $_ -notmatch "ARGO TUNNEL TOKEN" }) -join ""
                            $decodedBytes = [System.Convert]::FromBase64String($tokenContent)
                            $decodedJson = [System.Text.Encoding]::UTF8.GetString($decodedBytes) | ConvertFrom-Json
                            $zoneId = $decodedJson.zoneID
                            $apiToken = $decodedJson.apiToken
                            
                            if ($zoneId -and $apiToken) {
                                Write-Host "❯ Querying Cloudflare account domains..." -ForegroundColor Yellow
                                $headers = @{
                                    "Authorization" = "Bearer $apiToken"
                                    "Content-Type" = "application/json"
                                }
                                $response = Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/$zoneId" -Headers $headers -TimeoutSec 10
                                if ($response -and $response.result -and $response.result.name) {
                                    $global:zoneName = $response.result.name
                                    Write-Host "✔ Detected: $global:zoneName" -ForegroundColor Green
                                }
                            }
                        } catch {
                            Write-Host "✖ Failed to query Cloudflare API" -ForegroundColor Red
                        }
                    }
                }
                
                & $resolveZone

                # Check for previously configured domain
                $prevHermes = $null
                $prev9r = $null
                $localDomainFile = ".\.cf_domain"
                if (Test-Path $localDomainFile) {
                    $domainLines = Get-Content -Path $localDomainFile
                    foreach ($line in $domainLines) {
                        if ($line -match "hermes_domain:\s*(.*)") { $prevHermes = $Matches[1].Trim() }
                        if ($line -match "9r_domain:\s*(.*)") { $prev9r = $Matches[1].Trim() }
                    }
                }
                if (-not $prevHermes) {
                    $prevVarsJson = & railway variable list --service zed-hermes --json 2>$null | ConvertFrom-Json
                    if ($prevVarsJson) {
                        if ($prevVarsJson.CF_DOMAIN_HERMES) { $prevHermes = $prevVarsJson.CF_DOMAIN_HERMES }
                        if ($prevVarsJson.CF_DOMAIN_9R) { $prev9r = $prevVarsJson.CF_DOMAIN_9R }
                    }
                }
                
                $cfDomainHermes = $null
                $cfDomain9r = $null
                $reusePrev = $false
                if ($prevHermes -and $prev9r) {
                    Write-Host "❯ Detected previously configured subdomains: Hermes: $prevHermes, 9Router: $prev9r" -ForegroundColor Yellow
                    $reuseOpt = Read-Host "  👉 Do you want to reuse these subdomains? [Y/n]"
                    if ($reuseOpt -notmatch "^[nN]") {
                        $reusePrev = $true
                    }
                }
                
                if ($reusePrev) {
                    $cfDomainHermes = $prevHermes
                    $cfDomain9r = $prev9r
                } else {
                    # Confirm if they want to use the currently detected domain
                    $useDetected = $false
                    if ($global:zoneName) {
                        Write-Host "❯ Detected domain on your Cloudflare account: $global:zoneName" -ForegroundColor Yellow
                        $useDetectedOpt = Read-Host "  👉 Do you want to use this domain? [Y/n]"
                        if ($useDetectedOpt -notmatch "^[nN]") {
                            $useDetected = $true
                        }
                    }

                    if (-not $useDetected) {
                        Write-Host "[*] Re-authenticating with Cloudflare to choose a different domain..." -ForegroundColor Yellow
                        if (Test-Path $certPath) {
                            Remove-Item -Path $certPath -Force
                        }
                        Start-Process $cloudflaredBin -ArgumentList "tunnel login" -NoNewWindow -Wait
                        & $resolveZone
                        
                        # Fallback to manual entry if API query failed
                        if (-not $global:zoneName) {
                            Write-Host ""
                            Write-Host ">>> Enter your Cloudflare Root Domain (e.g. koshix.com) <<<" -ForegroundColor Cyan
                            $global:zoneName = (Read-Host " Domain").Trim()
                            if (-not $global:zoneName) {
                                Write-Host "[!] Domain cannot be empty." -ForegroundColor Red
                                Exit 1
                            }
                        }
                    }
                    
                    $cfDomainHermes = "hermes.$global:zoneName"
                    $cfDomain9r = "9r.$global:zoneName"
                    Write-Host "✔ Subdomains automatically set to:" -ForegroundColor Green
                    Write-Host "  - Hermes Agent: $cfDomainHermes" -ForegroundColor Cyan
                    Write-Host "  - 9Router:      $cfDomain9r" -ForegroundColor Cyan
                }
                
                # Save domains locally for next time
                "hermes_domain: $cfDomainHermes" | Out-File -FilePath $localDomainFile -Encoding utf8
                "9r_domain: $cfDomain9r" | Out-File -FilePath $localDomainFile -Append -Encoding utf8
                
                $tName = "zed-hermes-" + (Get-Date -UFormat %s)
                Write-Host "[*] Creating Tunnel ($tName)..." -ForegroundColor Yellow
                Start-Process $cloudflaredBin -ArgumentList "tunnel create $tName" -NoNewWindow -Wait
                
                $tList = & $cloudflaredBin tunnel list
                $tId = $null
                foreach ($line in $tList) {
                    if ($line -match $tName) {
                        $tId = ($line -split "\s+")[0]
                        break
                    }
                }
                
                if (-not $tId) {
                    Write-Host "[!] Failed to retrieve Tunnel ID." -ForegroundColor Red
                    Exit 1
                }
                
                Write-Host "[*] Routing DNS for $cfDomainHermes..." -ForegroundColor Yellow
                Start-Process $cloudflaredBin -ArgumentList "tunnel route dns -f $tId $cfDomainHermes" -NoNewWindow -Wait
                
                Write-Host "[*] Routing DNS for $cfDomain9r..." -ForegroundColor Yellow
                Start-Process $cloudflaredBin -ArgumentList "tunnel route dns -f $tId $cfDomain9r" -NoNewWindow -Wait
                
                $credPath = Join-Path $env:USERPROFILE ".cloudflared\$tId.json"
                if (-not (Test-Path $credPath)) {
                    Write-Host "[!] Credentials file not found at $credPath" -ForegroundColor Red
                    Exit 1
                }
                $cfCredContent = Get-Content -Raw -Path $credPath
                
                Write-Host "❯ Uploading Cloudflare Tunnel configuration to Railway..." -ForegroundColor Yellow
                & railway variable set TUNNEL_MODE=2 CF_TUNNEL_ID="$tId" CF_TUNNEL_CREDENTIALS="$cfCredContent" CF_DOMAIN_HERMES="$cfDomainHermes" CF_DOMAIN_9R="$cfDomain9r" --service zed-hermes 2>&1 >$null
                break
                
            } elseif ($cfAuthChoice -eq "2" -or $cfAuthChoice -eq "۲") {
                $cfToken = (Read-Host "  👉 Enter your Cloudflare Tunnel Token").Trim()
                $cfDomainHermes = (Read-Host "  👉 Enter your Hermes Domain (e.g., hermes.yourdomain.com)").Trim()
                $cfDomain9r = (Read-Host "  👉 Enter your 9Router Domain (e.g., 9r.yourdomain.com)").Trim()
                
                if ($cfToken -and $cfDomainHermes -and $cfDomain9r) {
                    Write-Host "❯ Setting Personal Tunnel variables on Railway..." -ForegroundColor Yellow
                    & railway variable set TUNNEL_MODE=2 CF_TUNNEL_TOKEN="$cfToken" CF_DOMAIN_HERMES="$cfDomainHermes" CF_DOMAIN_9R="$cfDomain9r" --service zed-hermes 2>&1 >$null
                    
                    # Save domains locally
                    "hermes_domain: $cfDomainHermes" | Out-File -FilePath $localDomainFile -Encoding utf8
                    "9r_domain: $cfDomain9r" | Out-File -FilePath $localDomainFile -Append -Encoding utf8
                    break
                } else {
                    Write-Host "✖ Inputs cannot be empty." -ForegroundColor Red
                }
            } else {
                Write-Host "✖ Invalid choice. Please enter 1 or 2." -ForegroundColor Red
            }
        }
        break
    } else {
        Write-Host "✖ Invalid choice. Please enter 1 or 2." -ForegroundColor Red
    }
}

# 5. START DEPLOYMENT
$maxDeployRetries = 3
$deployRetry = 1
$deploySuccess = $false

Write-Host ""
Write-Host "❯ Compiling and deploying container to Railway (this may take a moment)..." -ForegroundColor Yellow

while ($deployRetry -le $maxDeployRetries) {
    & railway up --service zed-hermes --ci --detach
    if ($LASTEXITCODE -eq 0) {
        $deploySuccess = $true
        break
    } else {
        Write-Host "✖ Attempt $deployRetry failed." -ForegroundColor Red
        if ($deployRetry -lt $maxDeployRetries) {
            Write-Host "❯ Retrying deployment in 5 seconds (attempt $($deployRetry + 1)/$maxDeployRetries)..." -ForegroundColor Yellow
            Start-Sleep -Seconds 5
        }
    }
    $deployRetry++
}

if (-not $deploySuccess) {
    Write-Host "✖ Error: Code upload to Railway failed." -ForegroundColor Red
    Exit 1
} else {
    Write-Host "✔ Code uploaded successfully! Starting build on Railway..." -ForegroundColor Green
}

# 6. MONITOR BUILD & GET URLS
Write-Host "❯ Monitoring Railway build status..." -ForegroundColor Yellow

$elapsed = 0
$status = "CHECKING"
$domainHermes = $null
$domain9r = $null
$buildFailed = $false

while ($elapsed -lt 600) {
    if ($elapsed % 5 -eq 0) {
        $statusVars = & railway deployment list --json --limit 1 --service zed-hermes 2>$null | ConvertFrom-Json
        if ($statusVars) {
            $status = $statusVars[0].status
        }
    }
    
    $minutes = [Math]::Floor($elapsed / 60)
    $seconds = $elapsed % 60
    $timeStr = "{0:02}:{1:02}" -f $minutes, $seconds
    
    # Carriage return and clear line behavior in PowerShell
    [Console]::Write("`r" + " " * 80 + "`r")
    Write-Host -NoNewline "❯ [$timeStr] Build Status: $status..." -ForegroundColor Yellow
    
    if ($status -eq "FAILED" -or $status -eq "CRASHED") {
        $buildFailed = $true
        break
    } elseif ($status -eq "SUCCESS" -or $status -eq "REMOVED" -or $status -eq "INITIALIZING") {
        $logs = & railway logs --service zed-hermes 2>$null
        
        if ($cfMode -eq "1" -or $cfMode -eq "۱") {
            for ($i=0; $i -lt $logs.Count; $i++) {
                if ($logs[$i] -match "HERMES AGENT") {
                    if ($logs[$i+1] -match '([a-zA-Z0-9.-]+\.trycloudflare\.com)') {
                        $domainHermes = $Matches[1]
                    }
                }
                if ($logs[$i] -match "9ROUTER") {
                    if ($logs[$i+1] -match '([a-zA-Z0-9.-]+\.trycloudflare\.com)') {
                        $domain9r = $Matches[1]
                    }
                }
            }
            if ($domainHermes -and $domain9r) {
                break
            }
        } else {
            $domainHermes = $cfDomainHermes
            $domain9r = $cfDomain9r
            break
        }
    }
    
    Start-Sleep -Seconds 1
    $elapsed++
}
Write-Host ""

if ($buildFailed) {
    Write-Host "✖ Error: Railway build/deployment FAILED." -ForegroundColor Red
    Write-Host "❯ Please check the build logs on your Railway dashboard or run:" -ForegroundColor Yellow
    Write-Host "  railway logs --service zed-hermes" -ForegroundColor Cyan
    Write-Host ""
    Exit 1
}

# 7. DISPLAY FINAL OUTPUT BANNERS
Clear-Host
Write-Host "🤖 HERMES AGENT & 9ROUTER RAILWAY DEPLOYER (WINDOWS)" -ForegroundColor Cyan
Write-Host "────────────────────────────────────────────────────────────" -ForegroundColor Cyan
Write-Host ""
Write-Host "🎉 SUCCESS! Hermes Agent & 9Router are running on Railway." -ForegroundColor Green
Write-Host ""

if (($cfMode -eq "1" -or $cfMode -eq "۱") -and (-not $domainHermes -or -not $domain9r)) {
    Write-Host "✖ Could not automatically fetch TryCloudflare URLs from logs." -ForegroundColor Red
    Write-Host "❯ Please check the service logs manually to copy the links:" -ForegroundColor Yellow
    Write-Host "    railway logs --service zed-hermes" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "🤖 HERMES AGENT DASHBOARD:" -ForegroundColor White
    Write-Host "   URL:  https://$domainHermes" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🌐 9ROUTER (API & DASHBOARD):" -ForegroundColor White
    Write-Host "   URL:  https://$domain9r" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "❯ The services run 24/7 in the background on Railway." -ForegroundColor Yellow
Write-Host "❯ Join our Telegram channel: https://t.me/iWZedLabs" -ForegroundColor Cyan
