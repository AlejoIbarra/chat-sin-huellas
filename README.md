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

*(Nota: en `.env` cambia `SECRET_KEY_BASE` (`openssl rand -hex 64`) y `POSTGRES_PASSWORD`. `docker-compose.yaml` solo lee `.env`; `.env.example` es una plantilla y no se carga).*

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

---

## 🤖 Integración con el bot de Sin Huellas

Este Chatwoot es también el del bot de atención (n8n + Gemini). El entorno de pruebas del bot levanta Chatwoot con la misma versión y los mismos archivos de `data/storage`, así que sus pruebas corren sobre esta instalación.

- **Versión fija** (`chatwoot/chatwoot:v4.18.0` en `rails` y `sidekiq`). Las plantillas de `data/storage` reemplazan archivos de esa versión exacta; con `latest`, una actualización de Chatwoot las puede dejar desfasadas sin aviso. Para subir de versión: partir de las plantillas nuevas de Chatwoot, reaplicar los cambios de Sin Huellas y cambiar la versión aquí y en el entorno del bot.
- **`vueapp.html.erb`** es la plantilla original de 4.18.0 más los agregados de Sin Huellas (`custom.css`, cambio de textos y botón «Envío Masivo Express»). La versión anterior había perdido claves de `window.chatwootConfig` que Chatwoot usa: sin `vapidPublicKey` el navegador no se suscribe a las notificaciones push, sin `isMfaEnabled` no aparece la verificación en dos pasos y sin `whatsappConfigurationId`/`whatsappApiVersion` no funciona la conexión de WhatsApp con el botón de Meta.
- **Español en segundo plano.** `DEFAULT_LOCALE=es` solo cambia la interfaz web; sidekiq (correos y mensajes de WhatsApp) sigue en inglés. Por eso `i18n_default.rb` vuelve a copiarse a `config/initializers` (se había perdido al pasar a volúmenes con nombre) y `zz-sinhuellas.es.yml` traduce el botón que abre las listas en WhatsApp («Choose an item» → «Ver opciones»). Los dos se copian en `rails` y en `sidekiq`.
- **`campanas.html`** se copia a `/app/public/` para que el botón «Envío Masivo Express» la encuentre también en una instalación nueva. Habla con n8n (`/webhook/campanas`, en la dirección de `SH_N8N_URL_PUBLICA`) con la sesión de Chatwoot de quien lo usa; las imágenes y videos salen de la carpeta de campañas en Drive.
- **`Dockerfile`:** la misma instalación como imagen. Parte de `chatwoot/chatwoot:v4.18.0` y deja los archivos de `data/storage` en su lugar al construir, con las mismas copias de `docker-compose.yaml`. Es lo que usa el servidor: Easypanel construye desde la rama `integracion-bot`. La web usa el comando por defecto (prepara la base y abre en el 3000) y sidekiq usa `bundle exec sidekiq -C config/sidekiq.yml`. `docker-compose.yaml` sigue igual para quien prefiera montar los archivos.
- **Lo que configura el bot no vive aquí:** el Agent Bot asignado a la bandeja de WhatsApp, las macros, etiquetas, atributos personalizados y vistas los crean los scripts del bot por la API de Chatwoot.
- **Red interna:** si Chatwoot llama al bot por la red de Docker (por ejemplo `http://n8n:5678/...`), hace falta `SAFE_FETCH_ALLOW_PRIVATE_NETWORK=true`, porque Chatwoot 4.18 bloquea los webhooks hacia direcciones privadas.
