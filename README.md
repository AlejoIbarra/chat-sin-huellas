# 🚀 SinHuellas Chat - Plataforma de Mensajería Omnicanal

Plataforma de mensajería y atención omnicanal basada en Chatwoot con personalización ejecutiva **SinHuellas Chat**, soporte nativo en español (`:es`), campañas de WhatsApp activadas y despliegue rápido con **Docker Compose**.

---

## 📋 Requisitos Previos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (macOS, Windows o Linux)
- [Git](https://git-scm.com/)

---

## ⚡ Guía de Instalación Rápida

### 1. Clonar el repositorio
```bash
git clone https://github.com/AlejoIbarra/chat-sin-huellas.git
cd chat-sin-huellas
```

### 2. Crear el archivo de entorno
```bash
cp .env.example .env
```

*(Nota: El archivo `.env.example` ya viene preconfigurado con valores por defecto funcionales para desarrollo local).*

### 3. Levantar los servicios con Docker
```bash
docker compose up -d
```

### 4. Ingresar a la aplicación
Abre tu navegador e ingresa a:
👉 **[http://localhost:3000/app/login](http://localhost:3000/app/login)**

---

## 👨‍💻 Crear el Usuario Administrador Inicial

Si es tu primera vez iniciando la plataforma y necesitas un superadministrador, ejecuta:

```bash
docker compose exec rails bundle exec rails runner "
  account = Account.create!(name: 'SinHuellas Chat')
  user = User.create!(
    name: 'Administrador',
    email: 'admin@sinhuellas.co',
    password: 'Password123!',
    password_confirmation: 'Password123!',
    role: 'administrator'
  )
  AccountUser.create!(account: account, user: user, role: 'administrator')
  account.enable_features('whatsapp_campaign', 'automations', 'campaigns')
  account.save!
  puts '✅ Administrador creado con éxito: admin@sinhuellas.co / Password123!'
"
```

---

## 🛠️ Comandos de Administración Útiles

| Acción | Comando |
| :--- | :--- |
| **Ver estado de los servicios** | `docker compose ps` |
| **Ver logs del servidor en vivo** | `docker compose logs -f rails` |
| **Reiniciar la aplicación** | `docker compose restart rails sidekiq` |
| **Detener los servicios** | `docker compose down` |

---

## 🎨 Características Incluidas

- 🟢 **Tema Exclusivo SinHuellas**: Estilo visual luxury en Verde Esmeralda (`#163f30`), Dorado Cálido (`#d7a944`) y Blanco Puro (`#ffffff`).
- 🌙 **Soporte Completo Modo Claro / Modo Oscuro**: Ajustes de contraste perfecto y lectura sin deslumbramiento.
- 💬 **WhatsApp Cloud API & Campañas**: Bandera de funciones activada para envío de mensajes masivos y gestión de canales de WhatsApp.
- 🌎 **Español por Defecto (`:es`)**: Interfaz e inicializadores traducidos completamente al español.
- ⚡ **Infraestructura Completa en Contenedores**:
  - **Rails Web Server** (`Chatwoot Engine`)
  - **Sidekiq Worker** (Procesamiento de tareas en segundo plano)
  - **PostgreSQL 15** (Con extensión `pgvector`)
  - **Redis 7** (Gestión de caché y colas)
