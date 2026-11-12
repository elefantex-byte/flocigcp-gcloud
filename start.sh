#!/usr/bin/env bash
set -e

# Limpiar barra diagonal final si existe
FLOCI_CLEAN="${FLOCI_URL%/}"

if [ -z "$FLOCI_CLEAN" ]; then
  echo "ERROR: Falta configurar la variable de entorno FLOCI_URL en Render."
  exit 1
fi

# Exportar configuración de gcloud hacia floci-gcp
cat <<EOF > /etc/profile.d/floci-gcp.sh
export CLOUDSDK_CORE_PROJECT="proyecto-practica"
export CLOUDSDK_CORE_DISABLE_PROMPTS=1
export CLOUDSDK_AUTH_ACCESS_TOKEN="token-local-practica"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_STORAGE="${FLOCI_CLEAN}/storage/v1/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_PUBSUB="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_FIRESTORE="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_SECRETMANAGER="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_CLOUDTASKS="${FLOCI_CLEAN}/"
EOF

source /etc/profile.d/floci-gcp.sh

# Mensaje de bienvenida al abrir la terminal
cat <<'EOF' > /root/.bashrc
source /etc/profile.d/floci-gcp.sh
clear
echo "=========================================================="
echo "  LABORATORIO GOOGLE CLOUD CLI + FLOCI-GCP LISTO"
echo "  Conectado a: $FLOCI_URL"
echo "=========================================================="
echo ""
echo "Comandos de prueba rápidos:"
echo "  1. Crear bucket:   gcloud storage buckets create gs://mi-primer-bucket"
echo "  2. Listar buckets: gcloud storage ls"
echo "  3. Crear tópico:   gcloud pubsub topics create pedidos"
echo "  4. Crear secreto:  echo -n '12345' | gcloud secrets create api-pass --data-file=-"
echo ""
echo "NOTA: Si floci-gcp estaba dormido, el primer comando tardará ~40s en despertar."
echo ""
EOF

# Iniciar terminal web con contraseña en el puerto asignado por Render
USER_AUTH="${TERMINAL_USER:-admin}:${TERMINAL_PASS:-practica123}"
exec ttyd -W -p "${PORT:-10000}" -c "$USER_AUTH" bash