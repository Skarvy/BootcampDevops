#!/bin/bash

# Variables
LOG_FILE="ci_cd_automation.log"
DOCKER_IMAGE_NAME="cars-management-container"
DOCKER_IMAGE_VERSION=""
REPO_NAME=""
BRANCH_NAME=""
AUTHOR=""
EMAIL=""
PORT=3000
DOCKER_REGISTRY=""

# Colores para la salida en consola
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

# Función para escribir en el log
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Verificar herramientas necesarias
for tool in git docker jq; do
  if ! command -v $tool &> /dev/null; then
    log "${RED}Error: $tool no está instalado. Por favor, instálalo antes de continuar.${RESET}"
    exit 1
  fi
done

log "${GREEN}Todas las herramientas necesarias están instaladas.${RESET}"

# Obtener versión actual del proyecto (package.json)
if [ -f package.json ]; then
  DOCKER_IMAGE_VERSION=$(jq -r .version package.json)
elif [ -f CHANGELOG.md ]; then
  DOCKER_IMAGE_VERSION=$(grep -E '^\d+\.\d+\.\d+' CHANGELOG.md | head -n 1)
else
  log "${RED}Error: No se pudo obtener la versión del proyecto. Asegúrate de tener package.json o CHANGELOG.md.${RESET}"
  exit 1
fi

log "${GREEN}Versión del proyecto: $DOCKER_IMAGE_VERSION${RESET}"

# Obtener el nombre del repositorio y la rama actual
REPO_NAME=$(basename `git rev-parse --show-toplevel`)
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
log "${GREEN}Repositorio: $REPO_NAME, Rama: $BRANCH_NAME${RESET}"

# Obtener información del último commit
AUTHOR=$(git log -1 --pretty=format:'%an')
EMAIL=$(git log -1 --pretty=format:'%ae')
log "${GREEN}Último commit - Autor: $AUTHOR, Email: $EMAIL${RESET}"

# Construir nombre de la imagen Docker
DOCKER_IMAGE_NAME="$DOCKER_REGISTRY/$REPO_NAME:$DOCKER_IMAGE_VERSION"
log "${GREEN}Nombre de la imagen Docker: $DOCKER_IMAGE_NAME${RESET}"

# Construcción de la imagen Docker
log "${YELLOW}Construyendo la imagen Docker...${RESET}"
docker build -t "$DOCKER_IMAGE_NAME" .

# Etiquetar la imagen como "latest"
docker tag "$DOCKER_IMAGE_NAME" "$DOCKER_REGISTRY/$REPO_NAME:latest"
log "${GREEN}Imagen Docker etiquetada como 'latest'.${RESET}"

# Simulación de despliegue
log "${YELLOW}Simulando despliegue de la aplicación...${RESET}"
docker run -d -p "$PORT:$PORT" "$DOCKER_IMAGE_NAME"
log "${GREEN}Aplicación desplegada en el puerto $PORT.${RESET}"

# Salida final
log "${GREEN}El script se ejecutó con éxito.${RESET}"
