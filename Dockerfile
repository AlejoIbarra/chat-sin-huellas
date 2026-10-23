# Chatwoot de Sin Huellas: la imagen oficial con la apariencia y los ajustes de data/storage ya puestos en su lugar.
# Hace lo mismo que docker-compose.yaml al arrancar, pero dentro de la imagen, para construirla desde Git (Easypanel, rama main).
# La misma imagen sirve para la web y para sidekiq:
#   web:     (comando por defecto) prepara o actualiza la base y abre en el puerto 3000
#   sidekiq: bundle exec sidekiq -C config/sidekiq.yml
FROM chatwoot/chatwoot:v4.18.0

COPY data/storage/ /app/custom_storage/

RUN set -e; \
    mkdir -p /app/public/brand-assets /app/public/packs/brand-assets /app/app/javascript/dashboard/assets/images /app/app/javascript/widget/assets/images; \
    cp /app/custom_storage/sinhuellas_logo.svg /app/public/brand-assets/logo.svg; \
    cp /app/custom_storage/sinhuellas_logo.svg /app/public/brand-assets/logo_dark.svg; \
    cp /app/custom_storage/sinhuellas_logo.svg /app/public/brand-assets/logo_thumbnail.svg; \
    cp /app/custom_storage/sinhuellas_logo.svg /app/public/packs/brand-assets/logo.svg; \
    cp /app/custom_storage/sinhuellas_logo.svg /app/public/packs/brand-assets/logo_dark.svg; \
    cp /app/custom_storage/sinhuellas_logo.svg /app/public/packs/brand-assets/logo_thumbnail.svg; \
    cp /app/custom_storage/sinhuellas_logo.svg /app/app/javascript/dashboard/assets/images/bubble-logo.svg; \
    cp /app/custom_storage/sinhuellas_logo.svg /app/app/javascript/widget/assets/images/logo.svg; \
    cp /app/custom_storage/sinhuellas_logo.png /app/public/brand-assets/logo.png; \
    cp /app/custom_storage/portada-formulario.jpg /app/public/brand-assets/portada-formulario.jpg; \
    cp /app/custom_storage/sinhuellas_logo.png /app/public/brand-assets/logo_dark.png; \
    cp /app/custom_storage/sinhuellas_logo.png /app/public/brand-assets/logo_thumbnail.png; \
    cp /app/custom_storage/sinhuellas_logo.png /app/public/favicon.ico; \
    cp /app/custom_storage/sinhuellas_logo.png /app/public/favicon-16x16.png; \
    cp /app/custom_storage/sinhuellas_logo.png /app/public/favicon-32x32.png; \
    cp /app/custom_storage/sinhuellas_logo.png /app/public/favicon-96x96.png; \
    cp /app/custom_storage/sinhuellas_logo.png /app/public/favicon-512x512.png; \
    cp /app/custom_storage/sinhuellas_logo.png /app/public/apple-icon.png; \
    cp /app/custom_storage/sinhuellas_logo.png /app/public/apple-touch-icon.png; \
    for f in /app/public/android-icon-*.png /app/public/apple-icon-*.png /app/public/ms-icon-*.png; do \
      [ -f "$f" ] && cp /app/custom_storage/sinhuellas_logo.png "$f" || true; \
    done; \
    cp /app/custom_storage/custom.css /app/public/custom.css; \
    cp /app/custom_storage/vueapp.html.erb /app/app/views/layouts/vueapp.html.erb; \
    mkdir -p /app/app/controllers/concerns; \
    cp /app/custom_storage/instagram_concern.rb /app/app/controllers/concerns/instagram_concern.rb; \
    mkdir -p /app/app/views/super_admin/application /app/app/views/super_admin/devise/sessions /app/app/views/super_admin/instance_statuses /app/app/controllers/super_admin; \
    cp /app/custom_storage/_navigation.html.erb /app/app/views/super_admin/application/_navigation.html.erb; \
    cp /app/custom_storage/instance_status_show.html.erb /app/app/views/super_admin/instance_statuses/show.html.erb; \
    cp /app/custom_storage/sessions_new.html.erb /app/app/views/super_admin/devise/sessions/new.html.erb; \
    cp /app/custom_storage/campanas.html /app/public/campanas.html; \
    cp /app/custom_storage/zz-sinhuellas.es.yml /app/config/locales/zz-sinhuellas.es.yml; \
    cp /app/custom_storage/i18n_default.rb /app/config/initializers/i18n_default.rb; \
    cp -r /app/custom_storage/privacy /app/public/; \
    cp -r /app/custom_storage/terms /app/public/; \
    cp /app/custom_storage/privacy.html /app/public/; \
    cp /app/custom_storage/tiktokVCWaYAGPTtL07smB08Kwl56OCrCHqgnS.txt /app/public/

# Color de marca: Chatwoot dejó fijo su azul en el CSS compilado; marca.sh lo cambia por la variable --sh-marca que define custom.css
RUN sh /app/custom_storage/marca.sh

# Espera a Postgres y borra el server.pid que pudo quedar de un apagón (como en docker-compose.yaml)
ENTRYPOINT ["docker/entrypoints/rails.sh"]
CMD ["sh", "-c", "bundle exec rails db:chatwoot_prepare && exec bundle exec rails s -p 3000 -b 0.0.0.0"]
