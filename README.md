# 🟢 استقرار خودکار Hermes Agent & 9Router روی Railway

<div align="center">

  <img src="https://img.shields.io/badge/Hermes--Agent-v0.18.0-4CAF50?style=for-the-badge&logo=telegram&logoColor=white" alt="Hermes Version" />
  <img src="https://img.shields.io/badge/9Router-v0.5.18-8BC34A?style=for-the-badge&logo=nextdotjs&logoColor=white" alt="9Router Version" />
  <img src="https://img.shields.io/badge/Railway-Deployed-00E676?style=for-the-badge&logo=railway&logoColor=white" alt="Railway Status" />
  <img src="https://img.shields.io/badge/Cloudflare-Tunnel-2ECC71?style=for-the-badge&logo=cloudflare&logoColor=white" alt="Tunnel Status" />

  <p align="center">
    <b>یک استقرار خودکار و همه‌کاره برای Hermes Agent و 9Router روی پلتفرم Railway با پشتیبانی کامل از کلودفلر و بات تلگرام.</b>
  </p>

  <sub>ساخته شده با عشق برای جامعه هوش مصنوعی فارسی • کانال تلگرام ما: <a href="https://t.me/iWZedLabs">t.me/iWZedLabs</a></sub>

</div>

---

## ⚡ درباره پروژه (About the Project)

این پروژه برای پیاده‌سازی همزمان و خودکار **Hermes Agent** و **9Router** در یک کانتینر مجزا روی سرورهای ابری Railway طراحی شده است. اتصالات از طریق تونل امن کلودفلر (Cloudflare Tunnels) برقرار می‌شوند تا بدون هیچ‌گونه نیاز به آی‌پی اختصاصی یا پورت‌های باز، سیستم به صورت کاملاً امن با وب‌سوکت‌های فعال لود شود.

> [!IMPORTANT]
> هرمس به طور عادی برای اجرا به یک سرور فیزیکی مجزا (مانند VPS یا سیستم لوکال روشن) نیاز دارد؛ اما ما در این پروژه کل فرآیند را به صورت کاملاً **بدون نیاز به سرور فیزیکی، کاملاً رایگان و به سبک «پشم‌ریزون»** روی پلتفرم ابری Railway برای شما اوکی کرده‌ایم تا بدون دردسر بالا بیاید!

> [!NOTE]
> ما **9Router** را به عنوان پروکسی روتر هوش مصنوعی به پروژه اضافه کرده‌ایم؛ اما با توجه به قابلیت‌های بسیار گسترده و ابزارهای پیشرفته بومی هرمس، **شدیداً توصیه می‌شود از خود محیط هرمس استفاده کنید**، زیرا هرمس به طور کامل تمام ابزارها، چت‌ها، و مدیریت حافظه را در خود دارد و نیازی به رابط‌های اضافه نخواهید داشت.

---

## 🚀 راهنمای استقرار (Deployment Guide)

شما می‌توانید کل پروژه را از سیستم خود (ویندوز یا مک/لینوکس) با استفاده از اسکریپت‌های آماده مستقیماً روی اکانت Railway خود مستقر کنید:

### پیش‌نیازها:
1. نصب بودن **Railway CLI** روی سیستم خود (و ورود به اکانت با دستور `railway login`).
2. نصب بودن ابزار **Cloudflare CLI (cloudflared)** (اختیاری، اسکریپت در صورت نیاز آن را هندل می‌کند).

### استقرار در لینوکس و مک (Linux / macOS):
ترمینال را باز کرده و دستور یک‌خطی زیر را اجرا کنید:
```bash
git clone https://github.com/iWZed/hermes-railway.git && cd hermes-railway && bash deploy_railway.sh
```

### استقرار در ویندوز (Windows):
پاورشل (PowerShell) را به صورت Administrator باز کرده و دستور یک‌خطی زیر را اجرا کنید:
```powershell
git clone https://github.com/iWZed/hermes-railway.git && cd hermes-railway && Set-ExecutionPolicy Bypass -Scope Process -Force && ./deploy_railway.ps1
```

> [!TIP]
> اسکریپت به صورت خودکار از شما می‌پرسد که آیا می‌خواهید از دامنه رایگان کلودفلر (`TryCloudflare`) استفاده کنید یا مایلید دامنه اختصاصی خودتان را متصل کنید و تمام مراحل را به صورت خودکار انجام می‌دهد.

---

## 🛠️ راهنمای پیکربندی دقیق در داشبورد هرمس (Dashboard Setup)

پس از بالا آمدن موفقیت‌آمیز سرور و باز کردن لینک داشبورد، مراحل زیر را **دقیقاً به ترتیب** انجام دهید تا تنظیمات شما ذخیره شده و از بین نروند:

### گام اول: اتصال و فعال‌سازی ربات تلگرام 🤖
1. ابتدا توکن ربات تلگرام خود را از [@BotFather](https://t.me/BotFather) دریافت کنید.
2. شناسه عددی تلگرام خود را از [@userinfobot](https://t.me/userinfobot) بگیرید (یک عدد چند رقمی مانند `51482930`).
3. در داشبورد هرمس، از منوی سمت چپ روی تب **`Channels`** کلیک کنید.
4. روی دکمه **Configure** در بخش **Telegram** کلیک کنید.
5. توکن ربات و شناسه عددی خود را در کادرهای مشخص شده وارد کنید.
6. دکمه **Save** را در پایین صفحه بزنید.
7. **مهم**: از منوی سمت چپ به تب **`System`** رفته و روی دکمه **`Restart Gateway`** کلیک کنید تا ربات تلگرام با توکن جدید استارت بخورد.

### گام دوم: تنظیم کلیدهای API و مدل‌ها 🔑
1. از منوی سمت چپ داشبورد روی تب **`Keys`** کلیک کنید.
2. کلید API پرووایدر مورد نظر خود (مانند OpenRouter، Gemini یا OpenAI) را در کادر مربوطه پیست کرده و ذخیره کنید.
3. سپس به تب **`Models`** رفته و مدل اصلی مورد نظر خود را برای چت انتخاب کنید.
4. با این ترتیب، کلیدها در فایل‌های کانفیگ دائم کانتینر ذخیره شده و پس از ری‌استارت شدن کانتینر، ربات بدون مشکل به کار خود ادامه خواهد داد.

---

## 📂 پورت‌ها و دسترسی به پنل‌ها (Exposed Services)

| سرویس (Service) | پورت داخلی (Internal Port) | توضیحات (Description) |
| :--- | :---: | :--- |
| **Hermes Agent Dashboard** | `9119` | رابط کاربری چت، ایجنت هوشمند و مدیریت فایل‌ها |
| **9Router Dashboard & API** | `20128` | پنل پروکسی و روتر مدل‌های زبانی |

---

## 📢 کانال پشتیبانی (Support Channel)
برای دریافت آخرین اخبار، کدهای استقرار، به‌روزرسانی‌های جدید و پرسش و پاسخ، به کانال تلگرام ما ملحق شوید:
👉 **[کانال تلگرام آزمایشگاه Zed Labs (t.me/iWZedLabs)](https://t.me/iWZedLabs)**
