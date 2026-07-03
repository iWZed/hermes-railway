# 🟢 Hermes Agent & 9Router on Railway

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

> [!NOTE]
> ما **9Router** را به عنوان پروکسی روتر هوش مصنوعی به پروژه اضافه کرده‌ایم؛ اما با توجه به قابلیت‌های بسیار گسترده و ابزارهای پیشرفته بومی هرمس، **شدیداً توصیه می‌شود از خود محیط هرمس استفاده کنید**، زیرا هرمس به طور کامل تمام ابزارها، چت‌ها، و مدیریت حافظه را در خود دارد و نیازی به رابط‌های اضافه نخواهید داشت.

---

## 🛠️ راهنمای راه‌اندازی و مراحل مهم (Setup Guide)

> [!IMPORTANT]  
> برای جلوگیری از پریدن تنظیمات و کلیدهای API، **مراحل را دقیقاً به ترتیب زیر انجام دهید**:

### مرحله اول: اتصال ربات تلگرام (Telegram Connection)
ابتدا کانال‌های ارتباطی خود را متصل کنید تا ارتباطات پایه برقرار شوند:
1. توکن ربات تلگرام خود را از [@BotFather](https://t.me/BotFather) دریافت کنید.
2. آیدی عددی تلگرام خود را از [@userinfobot](https://t.me/userinfobot) دریافت کنید.
3. در داشبورد هرمس وارد تب **`Channels`** شده و توکن و آیدی عددی خود را در بخش **Telegram** وارد و ذخیره کنید.

### مرحله دوم: تنظیم کلیدهای API و مدل‌ها (API Keys & Models)
پس از فعال شدن بات تلگرام، به تنظیمات مدل‌ها بروید:
1. در داشبورد وارد بخش **`Keys`** یا **`Config`** شوید.
2. کلید API ارائه‌دهنده خود (مانند OpenRouter، Gemini یا Anthropic) را وارد و ثبت کنید.
3. مدل مورد نظر خود را ست کنید. این روش باعث می‌شود تنظیمات به درستی در فایل‌های کانفیگ ثبت شده و در آینده با ری‌استارت شدن کانتینر یا بروزرسانی‌ها اطلاعات شما پاک نشوند.

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
