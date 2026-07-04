# 🟢 Hermes Agent & 9Router — Automated Railway Deployment

<div align="center">

  <img src="https://img.shields.io/badge/Hermes--Agent-v0.18.0-4CAF50?style=for-the-badge&logo=telegram&logoColor=white" alt="Hermes Version" />
  <img src="https://img.shields.io/badge/9Router-v0.5.18-8BC34A?style=for-the-badge&logo=nextdotjs&logoColor=white" alt="9Router Version" />
  <img src="https://img.shields.io/badge/Railway-Deployed-00E676?style=for-the-badge&logo=railway&logoColor=white" alt="Railway Status" />
  <img src="https://img.shields.io/badge/Cloudflare-Tunnel-2ECC71?style=for-the-badge&logo=cloudflare&logoColor=white" alt="Tunnel Status" />
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="License" />

  <p align="center">
    <b>A fully automated, all-in-one deployment for Hermes Agent and 9Router on Railway, with complete Cloudflare Tunnel and Telegram bot support.</b><br/>
    <b>یک استقرار خودکار و همه‌کاره برای Hermes Agent و 9Router روی پلتفرم Railway با پشتیبانی کامل از کلودفلر و بات تلگرام.</b>
  </p>

  <sub>Built with ❤️ for the Persian AI community • Telegram channel: <a href="https://t.me/iWZedLabs">t.me/iWZedLabs</a></sub>
  <br/>
  <sub>ساخته شده با عشق برای جامعه هوش مصنوعی فارسی • کانال تلگرام ما: <a href="https://t.me/iWZedLabs">t.me/iWZedLabs</a></sub>

</div>

---

## 📑 Table of Contents / فهرست مطالب

- [About the Project / درباره پروژه](#-about-the-project--درباره-پروژه)
- [Deployment Guide / راهنمای استقرار](#-deployment-guide--راهنمای-استقرار)
- [Dashboard Setup / راهنمای پیکربندی داشبورد](#️-dashboard-setup--راهنمای-پیکربندی-داشبورد)
- [Exposed Services / پورت‌ها و دسترسی به پنل‌ها](#-exposed-services--پورتها-و-دسترسی-به-پنلها)
- [Support Channel / کانال پشتیبانی](#-support-channel--کانال-پشتیبانی)
- [License / لایسنس](#-license--لایسنس)

---

## ⚡ About the Project / درباره پروژه

**EN:** This project provides a fully automated, simultaneous deployment of **Hermes Agent** and **9Router** inside a single isolated container on the Railway cloud platform. Connections are established through a secure Cloudflare Tunnel, so the system loads with fully active WebSockets — no dedicated IP address or open ports required.

**FA:** این پروژه برای پیاده‌سازی همزمان و خودکار **Hermes Agent** و **9Router** در یک کانتینر مجزا روی سرورهای ابری Railway طراحی شده است. اتصالات از طریق تونل امن کلودفلر (Cloudflare Tunnels) برقرار می‌شوند تا بدون هیچ‌گونه نیاز به آی‌پی اختصاصی یا پورت‌های باز، سیستم به صورت کاملاً امن با وب‌سوکت‌های فعال لود شود.

> [!IMPORTANT]
> **EN:** Hermes normally requires a dedicated physical server (such as a VPS or an always-on local machine) to run. In this project, we've handled the entire process so it runs **completely free of any physical server**, fully hosted on the Railway cloud platform — no hassle required.
>
> **FA:** هرمس به طور عادی برای اجرا به یک سرور فیزیکی مجزا (مانند VPS یا سیستم لوکال روشن) نیاز دارد؛ اما ما در این پروژه کل فرآیند را به صورت کاملاً **بدون نیاز به سرور فیزیکی و کاملاً رایگان** روی پلتفرم ابری Railway برای شما اوکی کرده‌ایم تا بدون دردسر بالا بیاید!

> [!NOTE]
> **EN:** We've added **9Router** to the project as an AI router proxy. However, given Hermes' extensive built-in capabilities and advanced native tools, **it is strongly recommended to use the Hermes environment itself**, since Hermes already includes all the tools, chats, and memory management you need, without requiring any additional interfaces.
>
> **FA:** ما **9Router** را به عنوان پروکسی روتر هوش مصنوعی به پروژه اضافه کرده‌ایم؛ اما با توجه به قابلیت‌های بسیار گسترده و ابزارهای پیشرفته بومی هرمس، **شدیداً توصیه می‌شود از خود محیط هرمس استفاده کنید**، زیرا هرمس به طور کامل تمام ابزارها، چت‌ها، و مدیریت حافظه را در خود دارد و نیازی به رابط‌های اضافه نخواهید داشت.

---

## 🚀 Deployment Guide / راهنمای استقرار

**EN:** You can deploy the entire project from your own machine (Windows or macOS/Linux) directly to your Railway account using the ready-made scripts below.

**FA:** شما می‌توانید کل پروژه را از سیستم خود (ویندوز یا مک/لینوکس) با استفاده از اسکریپت‌های آماده مستقیماً روی اکانت Railway خود مستقر کنید.

### ✅ Prerequisites / پیش‌نیازها

| EN | FA |
| :--- | :--- |
| **Railway CLI** installed on your system (log in with `railway login`) | نصب بودن **Railway CLI** روی سیستم خود (و ورود به اکانت با دستور `railway login`) |
| **Cloudflare CLI (`cloudflared`)** installed (optional — the script handles it if needed) | نصب بودن ابزار **Cloudflare CLI (cloudflared)** (اختیاری، اسکریپت در صورت نیاز آن را هندل می‌کند) |

### 🐧 Deploy on Linux / macOS

**EN:** Open your terminal and run the following one-line command:

**FA:** ترمینال را باز کرده و دستور یک‌خطی زیر را اجرا کنید:

```bash
git clone https://github.com/iWZed/hermes-railway.git && cd hermes-railway && bash deploy_railway.sh
```

### 🪟 Deploy on Windows

**EN:** Open PowerShell **as Administrator** and run the following one-line command:

**FA:** پاورشل (PowerShell) را به صورت Administrator باز کرده و دستور یک‌خطی زیر را اجرا کنید:

```powershell
git clone https://github.com/iWZed/hermes-railway.git && cd hermes-railway && Set-ExecutionPolicy Bypass -Scope Process -Force && ./deploy_railway.ps1
```

> [!TIP]
> **EN:** The script will automatically ask whether you want to use Cloudflare's free domain (`TryCloudflare`) or connect your own custom domain, and it will handle every step for you automatically.
>
> **FA:** اسکریپت به صورت خودکار از شما می‌پرسد که آیا می‌خواهید از دامنه رایگان کلودفلر (`TryCloudflare`) استفاده کنید یا مایلید دامنه اختصاصی خودتان را متصل کنید و تمام مراحل را به صورت خودکار انجام می‌دهد.

> [!WARNING]
> **EN:** Free Cloudflare domains (`TryCloudflare`) are temporary and usually expire — and change — after 24 hours or whenever the container restarts. For a permanent, stable connection, it is recommended to use the custom domain option.
>
> **FA:** توجه داشته باشید که دامنه‌های رایگان کلودفلر (`TryCloudflare`) موقتی هستند و معمولاً بعد از ۲۴ ساعت یا در صورت ری‌استارت شدن کانتینر منقضی شده و تغییر خواهند کرد. برای داشتن یک اتصال دائمی و ثابت، توصیه می‌شود از گزینه دامنه اختصاصی استفاده کنید.

---

## 🛠️ Dashboard Setup / راهنمای پیکربندی داشبورد

**EN:** Once the server is up and the dashboard link is open, follow the steps below **in this exact order** so your settings are saved correctly and not lost.

**FA:** پس از بالا آمدن موفقیت‌آمیز سرور و باز کردن لینک داشبورد، مراحل زیر را **دقیقاً به ترتیب** انجام دهید تا تنظیمات شما ذخیره شده و از بین نروند.

### 1️⃣ Connect & Activate the Telegram Bot / اتصال و فعال‌سازی ربات تلگرام 🤖

**EN:**
1. Get your Telegram bot token from [@BotFather](https://t.me/BotFather).
2. Get your numeric Telegram user ID from [@userinfobot](https://t.me/userinfobot) (a multi-digit number, e.g. `51482930`).
3. In the Hermes dashboard, click the **`Channels`** tab in the left-hand menu.
4. Click the **Configure** button in the **Telegram** section.
5. Enter your bot token and numeric ID in the corresponding fields.
6. Click **Save** at the bottom of the page.
7. **Important:** Go to the **`System`** tab in the left menu and click **`Restart Gateway`** so the Telegram bot starts up with the new token.

**FA:**
1. ابتدا توکن ربات تلگرام خود را از [@BotFather](https://t.me/BotFather) دریافت کنید.
2. شناسه عددی تلگرام خود را از [@userinfobot](https://t.me/userinfobot) بگیرید (یک عدد چند رقمی مانند `51482930`).
3. در داشبورد هرمس، از منوی سمت چپ روی تب **`Channels`** کلیک کنید.
4. روی دکمه **Configure** در بخش **Telegram** کلیک کنید.
5. توکن ربات و شناسه عددی خود را در کادرهای مشخص شده وارد کنید.
6. دکمه **Save** را در پایین صفحه بزنید.
7. **مهم**: از منوی سمت چپ به تب **`System`** رفته و روی دکمه **`Restart Gateway`** کلیک کنید تا ربات تلگرام با توکن جدید استارت بخورد.

### 2️⃣ Configure API Keys & Models / تنظیم کلیدهای API و مدل‌ها 🔑

**EN:**
1. Click the **`Keys`** tab in the left-hand menu of the dashboard.
2. Paste the API key of your desired provider (e.g. OpenRouter, Gemini, or OpenAI) into the corresponding field and save it.
3. Go to the **`Models`** tab and select your preferred main chat model.
4. With this setup, your keys are stored in the container's persistent config files, so the bot will keep working normally even after the container restarts.

**FA:**
1. از منوی سمت چپ داشبورد روی تب **`Keys`** کلیک کنید.
2. کلید API پرووایدر مورد نظر خود (مانند OpenRouter، Gemini یا OpenAI) را در کادر مربوطه پیست کرده و ذخیره کنید.
3. سپس به تب **`Models`** رفته و مدل اصلی مورد نظر خود را برای چت انتخاب کنید.
4. با این ترتیب، کلیدها در فایل‌های کانفیگ دائم کانتینر ذخیره شده و پس از ری‌استارت شدن کانتینر، ربات بدون مشکل به کار خود ادامه خواهد داد.

---

## 🔒 Security & Data Persistence / امنیت و پایداری داده‌ها

### 🛡️ Security / امنیت
* **EN:** All API keys and Telegram tokens configured through the dashboard are stored locally within the container. Since Railway runs on isolated virtualized infrastructure with enterprise-grade security, your keys are not exposed to the public. Additionally, all traffic routed through Cloudflare Tunnels is fully encrypted end-to-end via SSL/TLS, eliminating the need to expose open ports to the internet.
* **FA:** تمام کلیدهای API و توکن‌های تلگرام تنظیم شده در داشبورد به صورت محلی درون کانتینر ذخیره می‌شوند. از آنجا که پلتفرم Railway روی زیرساخت‌های ایزوله و امن ابری اجرا می‌شود، کلیدهای شما در معرض دسترسی عموم قرار ندارند. علاوه بر این، تمامی ترافیک عبوری از طریق تونل کلودفلر به صورت سرتاسری (End-to-End) با پروتکل SSL/TLS رمزنگاری می‌شود و نیازی به باز کردن پورت‌های ناامن روی اینترنت نیست.

### 💾 Data Persistence on Railway / پایداری داده‌ها در ریل‌وی
* **EN:** By default, Railway containers are ephemeral. To ensure your Telegram configuration and API keys are permanently saved across redeployments and automatic restarts, it is highly recommended to mount a **Railway Volume** to the service:
  1. Go to your service settings in the Railway Dashboard.
  2. Under the **Volumes** tab, click **Add Volume**.
  3. Set the mount path to `/root` (where Hermes stores its configuration database under `/root/.hermes` or `/root/.config`).
* **FA:** به طور پیش‌فرض، کانتینرهای Railway موقتی هستند. برای اطمینان از اینکه تنظیمات بات تلگرام و کلیدهای هوش مصنوعی شما در زمان بالا و پایین شدن کانتینر یا دیپلوی‌های مجدد پاک نمی‌شوند، شدیداً توصیه می‌شود یک **Railway Volume** به سرویس خود متصل کنید:
  1. در داشبورد Railway به بخش تنظیمات (Settings) سرویس خود بروید.
  2. در تب **Volumes** روی دکمه **Add Volume** کلیک کنید.
  3. مسیر اتصال (Mount Path) را روی `/root` تنظیم کنید (جایی که فایل‌های کانفیگ هرمس در مسیر `/root/.hermes` یا `/root/.config` ذخیره می‌شوند).

---

## 📂 Exposed Services / پورت‌ها و دسترسی به پنل‌ها
| Service / سرویس | Internal Port / پورت داخلی | Description / توضیحات |
| :--- | :---: | :--- |
| **Hermes Agent Dashboard** | `9119` | EN: Chat UI, smart agent, and file management <br/> FA: رابط کاربری چت، ایجنت هوشمند و مدیریت فایل‌ها |
| **9Router Dashboard & API** | `20128` | EN: LLM proxy & router panel <br/> FA: پنل پروکسی و روتر مدل‌های زبانی |

---

## 📢 Support Channel / کانال پشتیبانی

**EN:** For the latest news, deployment scripts, updates, and Q&A, join our Telegram channel:

**FA:** برای دریافت آخرین اخبار، کدهای استقرار، به‌روزرسانی‌های جدید و پرسش و پاسخ، به کانال تلگرام ما ملحق شوید:

👉 **[Zed Labs Telegram Channel — t.me/iWZedLabs](https://t.me/iWZedLabs)**

---

## 📄 License / لایسنس

**EN:** This project is released under the **MIT License**. You are free to use, modify, and redistribute it, provided the original source is credited.

**FA:** این پروژه تحت لایسنس **MIT** منتشر شده است. استفاده، ویرایش و بازنشر آن با ذکر نام منبع آزاد است.
