# 🟢 Hermes Agent & 9Router — Automated Railway Deployment

<div align="center">

  <img src="https://img.shields.io/badge/Hermes--Agent-v0.18.0-4CAF50?style=for-the-badge&logo=telegram&logoColor=white" alt="Hermes Version" />
  <img src="https://img.shields.io/badge/9Router-v0.5.18-8BC34A?style=for-the-badge&logo=nextdotjs&logoColor=white" alt="9Router Version" />
  <img src="https://img.shields.io/badge/Railway-Deployed-00E676?style=for-the-badge&logo=railway&logoColor=white" alt="Railway Status" />
  <img src="https://img.shields.io/badge/Cloudflare-Tunnel-2ECC71?style=for-the-badge&logo=cloudflare&logoColor=white" alt="Tunnel Status" />
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="License" />

  <p align="center">
    <b>A fully automated, all-in-one deployment for Hermes Agent and 9Router on Railway, with complete Cloudflare Tunnel and Telegram bot support.</b>
  </p>

  <sub>Built with ❤️ for the Persian AI community • Telegram channel: <a href="https://t.me/iWZedLabs">t.me/iWZedLabs</a></sub>
  <br/>
  <sub>[نسخه فارسی (Persian Version)](README.fa.md)</sub>

</div>

---

## 📑 Table of Contents

- [About the Project](#-about-the-project)
- [Deployment Guide](#-deployment-guide)
- [Dashboard Setup](#️-dashboard-setup)
- [Security & Data Persistence](#-security--data-persistence)
- [Exposed Services](#-exposed-services)
- [Support Channel](#-support-channel)
- [License](#-license)

---

## ⚡ About the Project

This project provides a fully automated, simultaneous deployment of **Hermes Agent** and **9Router** inside a single isolated container on the Railway cloud platform. Connections are established through a secure Cloudflare Tunnel, so the system loads with fully active WebSockets — no dedicated IP address or open ports required.

> [!IMPORTANT]
> Hermes normally requires a dedicated physical server (such as a VPS or an always-on local machine) to run. In this project, we've handled the entire process so it runs **completely free of any physical server**, fully hosted on the Railway cloud platform — no hassle required.

> [!NOTE]
> We've added **9Router** to the project as an AI router proxy. However, given Hermes' extensive built-in capabilities and advanced native tools, **it is strongly recommended to use the Hermes environment itself**, since Hermes already includes all the tools, chats, and memory management you need, without requiring any additional interfaces.

---

## 🚀 Deployment Guide

You can deploy the entire project from your own machine (Windows or macOS/Linux) directly to your Railway account using the ready-made scripts below.

### ✅ Prerequisites

| Prerequisite | Details |
| :--- | :--- |
| **Railway CLI** | Installed on your system (log in with `railway login`) |
| **Cloudflare CLI (`cloudflared`)** | Installed (optional — the script handles it if needed) |

### 🐧 Deploy on Linux / macOS

Open your terminal and run the following one-line command:

```bash
git clone https://github.com/iWZed/hermes-railway.git && cd hermes-railway && bash deploy_railway.sh
```

### 🪟 Deploy on Windows

Open PowerShell **as Administrator** and run the following one-line command:

```powershell
git clone https://github.com/iWZed/hermes-railway.git && cd hermes-railway && Set-ExecutionPolicy Bypass -Scope Process -Force && ./deploy_railway.ps1
```

> [!TIP]
> The script will automatically ask whether you want to use Cloudflare's free domain (`TryCloudflare`) or connect your own custom domain, and it will handle every step for you automatically.

> [!WARNING]
> Free Cloudflare domains (`TryCloudflare`) are temporary and usually expire — and change — after 24 hours or whenever the container restarts. For a permanent, stable connection, it is recommended to use the custom domain option.

---

## 🛠️ Dashboard Setup

Once the server is up and the dashboard link is open, follow the steps below **in this exact order** so your settings are saved correctly and not lost.

### 1️⃣ Connect & Activate the Telegram Bot 🤖

1. Get your Telegram bot token from [@BotFather](https://t.me/BotFather).
2. Get your numeric Telegram user ID from [@userinfobot](https://t.me/userinfobot) (a multi-digit number, e.g. `51482930`).
3. In the Hermes dashboard, click the **`Channels`** tab in the left-hand menu.
4. Click the **Configure** button in the **Telegram** section.
5. Enter your bot token and numeric ID in the corresponding fields.
6. Click **Save** at the bottom of the page.
7. **Important:** Go to the **`System`** tab in the left menu and click **`Restart Gateway`** so the Telegram bot starts up with the new token.

### 2️⃣ Configure API Keys & Models 🔑

1. Click the **`Keys`** tab in the left-hand menu of the dashboard.
2. Paste the API key of your desired provider (e.g. OpenRouter, Gemini, or OpenAI) into the corresponding field and save it.
3. Go to the **`Models`** tab and select your preferred main chat model.
4. With this setup, your keys are stored in the container's persistent config files, so the bot will keep working normally even after the container restarts.

---

## 🔒 Security & Data Persistence

All API keys and Telegram tokens configured through the dashboard are securely stored. Since Railway runs on isolated virtualized infrastructure with enterprise-grade security and stable environments, your data is safe and remains persistent. Additionally, all traffic routed through Cloudflare Tunnels is fully encrypted end-to-end via SSL/TLS, eliminating the need to expose open ports to the internet.

---

## 📂 Exposed Services

| Service | Internal Port | Description |
| :--- | :---: | :--- |
| **Hermes Agent Dashboard** | `9119` | Chat UI, smart agent, and file management |
| **9Router Dashboard & API** | `20128` | LLM proxy & router panel |

---

## 📢 Support Channel

For the latest news, deployment scripts, updates, and Q&A, join our Telegram channel:

👉 **[Zed Labs Telegram Channel — t.me/iWZedLabs](https://t.me/iWZedLabs)**

---

## 📄 License

This project is released under the **MIT License**. You are free to use, modify, and redistribute it, provided the original source is credited.
