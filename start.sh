#!/usr/bin/env bash
set -e

FLOCI_CLEAN="${FLOCI_URL%/}"

if [ -z "$FLOCI_CLEAN" ]; then
  echo "ERROR: Falta configurar la variable de entorno FLOCI_URL en Render."
  exit 1
fi

# 1. Configurar todos los endpoints soportados por floci-gcp para gcloud CLI
cat <<EOF > /etc/profile.d/floci-gcp.sh
export FLOCI_CLEAN="${FLOCI_CLEAN}"
export CLOUDSDK_CORE_PROJECT="\${CLOUDSDK_CORE_PROJECT:-${PROJECT_ID:-allen-practica}}"
export CLOUDSDK_CORE_DISABLE_PROMPTS=1
export CLOUDSDK_AUTH_ACCESS_TOKEN="token-local-practica"

# Almacenamiento y Bases de Datos
export CLOUDSDK_API_ENDPOINT_OVERRIDES_STORAGE="${FLOCI_CLEAN}/storage/v1/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_FIRESTORE="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_DATASTORE="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_BIGQUERY="${FLOCI_CLEAN}/"

# Mensajeria, Tareas y Eventos
export CLOUDSDK_API_ENDPOINT_OVERRIDES_PUBSUB="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_CLOUDTASKS="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_CLOUDSCHEDULER="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_EVENTARC="${FLOCI_CLEAN}/"

# Identidad, Seguridad y Criptografia
export CLOUDSDK_API_ENDPOINT_OVERRIDES_IAM="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_IAMCREDENTIALS="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_STS="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_SECRETMANAGER="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_CLOUDKMS="${FLOCI_CLEAN}/"

# Observabilidad y Administracion
export CLOUDSDK_API_ENDPOINT_OVERRIDES_LOGGING="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_MONITORING="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_CLOUDRESOURCEMANAGER="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_SERVICEUSAGE="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_CLOUDBILLING="${FLOCI_CLEAN}/"

# Servicios con soporte Mock en Render (sin Docker anidado)
export CLOUDSDK_API_ENDPOINT_OVERRIDES_RUN="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_SQL="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_FUNCTIONS="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_COMPUTE="${FLOCI_CLEAN}/"
EOF

source /etc/profile.d/floci-gcp.sh

# 2. Configurar entorno visual Google Cloud Shell y utilidades en .bashrc
cat <<'EOF' > /root/.bashrc
source /etc/profile.d/floci-gcp.sh

# Colores oficiales Google Material Dark
GREEN='\[\033[01;32m\]'
BLUE='\[\033[01;34m\]'
YELLOW='\[\033[01;33m\]'
RESET='\[\033[00m\]'

USER_DISPLAY="${TERMINAL_USER:-admin}"
export PS1="${GREEN}${USER_DISPLAY}@cloudshell${RESET}:${BLUE}\w${RESET} ${YELLOW}(\${CLOUDSDK_CORE_PROJECT})${RESET}\$ "

alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Funcion util para cambiar proyecto rapidamente (ej: set-project mi-nuevo-id)
set-project() {
  if [ -z "$1" ]; then
    echo "Uso: set-project <project-id-en-minusculas>"
    return 1
  fi
  export CLOUDSDK_CORE_PROJECT="$1"
  gcloud config set project "$1" >/dev/null 2>&1 || true
  echo "Proyecto activo cambiado a: $CLOUDSDK_CORE_PROJECT"
}

# Funcion rapida de diagnostico de floci-gcp
check-floci() {
  echo "Verificando conexion con $FLOCI_CLEAN ..."
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 60 "${FLOCI_CLEAN}/storage/v1/b?project=${CLOUDSDK_CORE_PROJECT}")
  if [ "$HTTP_CODE" = "200" ]; then
    echo -e "\033[1;32m[OK] floci-gcp esta despierto y respondiendo (HTTP 200).\033[0m"
  else
    echo -e "\033[1;33m[AVISO] Respuesta HTTP: $HTTP_CODE (si estaba dormido, intenta de nuevo en unos segundos).\033[0m"
  fi
}

clear
echo -e "\033[1;37mWelcome to Cloud Shell! Type \"help\" to get started.\033[0m"
echo -e "Your Cloud Platform project in this session is set to \033[1;33m${CLOUDSDK_CORE_PROJECT}\033[0m."
echo -e "Use \033[1;36m“set-project [PROJECT_ID]”\033[0m to switch projects or \033[1;36m“check-floci”\033[0m to test connection."
echo ""
echo -e "\033[0;90m[Emulador: ${FLOCI_CLEAN} | 20+ servicios GCP enlazados]\033[0m"
echo ""
EOF

# 3. Iniciar terminal web ttyd con fuente consola nitida y tema Cloud Shell
USER_AUTH="${TERMINAL_USER:-admin}:${TERMINAL_PASS:-practica123}"

exec ttyd -W \
  -p "${PORT:-10000}" \
  -c "$USER_AUTH" \
  -t titleFixed="Cloud Shell" \
  -t fontSize=15 \
  -t fontFamily="Cascadia Code, Consolas, Liberation Mono, Menlo, monospace" \
  -t cursorStyle="block" \
  -t 'theme={"background":"#101820","foreground":"#E8EAED","cursor":"#8AB4F8","selectionBackground":"#3C4043","black":"#202124","red":"#F28B82","green":"#81C995","yellow":"#FDD663","blue":"#8AB4F8","magenta":"#C58AF9","cyan":"#78D9EC","white":"#E8EAED","brightBlack":"#5F6368","brightRed":"#F28B82","brightGreen":"#81C995","brightYellow":"#FDD663","brightBlue":"#8AB4F8","brightMagenta":"#C58AF9","brightCyan":"#78D9EC","brightWhite":"#FFFFFF"}' \
  bash
