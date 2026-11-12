#!/usr/bin/env bash
set -e

FLOCI_CLEAN="${FLOCI_URL%/}"

if [ -z "$FLOCI_CLEAN" ]; then
  echo "ERROR: Falta configurar la variable de entorno FLOCI_URL en Render."
  exit 1
fi

# 1. Variables de entorno para gcloud CLI apuntando a floci-gcp
cat <<EOF > /etc/profile.d/floci-gcp.sh
export CLOUDSDK_CORE_PROJECT="${PROJECT_ID:-proyecto-practica}"
export CLOUDSDK_CORE_DISABLE_PROMPTS=1
export CLOUDSDK_AUTH_ACCESS_TOKEN="token-local-practica"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_STORAGE="${FLOCI_CLEAN}/storage/v1/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_PUBSUB="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_FIRESTORE="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_SECRETMANAGER="${FLOCI_CLEAN}/"
export CLOUDSDK_API_ENDPOINT_OVERRIDES_CLOUDTASKS="${FLOCI_CLEAN}/"
EOF

source /etc/profile.d/floci-gcp.sh

# 2. Apariencia de Google Cloud Shell (Prompt, colores y banner)
cat <<'EOF' > /root/.bashrc
source /etc/profile.d/floci-gcp.sh

# Colores ANSI estilo Google
GREEN='\[\033[01;32m\]'
BLUE='\[\033[01;34m\]'
YELLOW='\[\033[01;33m\]'
CYAN='\[\033[01;36m\]'
RESET='\[\033[00m\]'

# Prompt oficial: usuario@cloudshell:~ (proyecto-practica)$
USER_DISPLAY="${TERMINAL_USER:-student}"
export PS1="${GREEN}${USER_DISPLAY}@cloudshell${RESET}:${BLUE}\w${RESET} ${YELLOW}(\${CLOUDSDK_CORE_PROJECT})${RESET}\$ "

# Colores en comandos comunes (ls, grep)
alias ls='ls --color=auto'
alias grep='grep --color=auto'

clear
echo -e "\033[1;37mWelcome to Cloud Shell! Type \"help\" to get started.\033[0m"
echo -e "Your Cloud Platform project in this session is set to \033[1;33m${CLOUDSDK_CORE_PROJECT}\033[0m."
echo -e "Use \033[1;36m“gcloud config set project [PROJECT_ID]”\033[0m to change to a different project."
echo ""
echo -e "\033[0;90m[Emulador conectado: ${FLOCI_URL}]\033[0m"
echo ""
EOF

# 3. Iniciar ttyd con paleta de colores oficial de Google Cloud Shell
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
