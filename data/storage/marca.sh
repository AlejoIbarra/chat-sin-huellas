#!/bin/sh
# Color de marca de Sin Huellas en Chatwoot.
#
# Chatwoot pinta casi todo con variables de color que custom.css redefine, pero su azul de marca (#2781f6, «39 129 246») quedó fijo en
# unas 60 clases del CSS ya compilado: botones principales, enfoques, casillas, enlaces y sus variantes transparentes. Este script lo
# reemplaza por la variable --sh-marca, que custom.css define para el modo claro y el oscuro. El valor entre paréntesis es el esmeralda
# del bufete y se usa donde no carga custom.css (encuesta, centro de ayuda, chat web, administrador).
#
# Corre al construir la imagen (Dockerfile) y al arrancar en desarrollo (docker-compose.yaml); correrlo dos veces no cambia nada.
# No toca el color cuando va dentro del nombre de una clase («.bg-\[\#2781F6\]»): eso rompería la regla completa.
#   sh marca.sh [carpeta=/app/public/vite/assets]
set -e
MARCA='var(--sh-marca, 22 63 48)'
for f in "${1:-/app/public/vite/assets}"/*.css; do
  sed -i -E \
    -e "s/([^\\])#2781f60d/\1rgb(${MARCA} \/ .05)/gI" \
    -e "s/([^\\])#2781f61a/\1rgb(${MARCA} \/ .1)/gI" \
    -e "s/([^\\])#2781f633/\1rgb(${MARCA} \/ .2)/gI" \
    -e "s/([^\\])#2781f680/\1rgb(${MARCA} \/ .5)/gI" \
    -e "s/([^\\])#2781f6cc/\1rgb(${MARCA} \/ .8)/gI" \
    -e "s/([^\\])#2781f6([^0-9a-f])/\1rgb(${MARCA})\2/gI" \
    -e "s/39 129 246/${MARCA}/g" \
    "$f"
done
