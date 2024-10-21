#!/bin/bash

# Variables
TEMP_DIR="tempdir"
DOCKER_IMAGE="cars-management-container"
CONTAINER_NAME="cars-management-container"
PORT=3000

# Colores
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

# Limpiar imágenes y contenedores antiguos
echo "${YELLOW}Limpiando contenedores antiguos...${RESET}"
docker rm -f $(docker ps -aq --filter "name=$CONTAINER_NAME") 2>/dev/null

echo "${YELLOW}Limpiando imágenes antiguas...${RESET}"
docker rmi -f $(docker images -q $DOCKER_IMAGE) 2>/dev/null

# Crear estructura de directorios
echo "${GREEN}Creando estructura de directorios${RESET}"
mkdir -p $TEMP_DIR/{public,src}
cp -r public/* $TEMP_DIR/public
cp -r src/* $TEMP_DIR/src
cp -r package*.json server.js $TEMP_DIR

# Construyendo Dockerfile
echo "${GREEN}Construyendo Dockerfile${RESET}"
cat <<EOF > $TEMP_DIR/Dockerfile
FROM node:18-alpine
LABEL org.opencontainers.image.authors="RoxsRoss"
RUN apk add --no-cache python3 make g++
WORKDIR /app
COPY package*.json ./ 
RUN npm install 
COPY . .
EXPOSE $PORT
CMD ["npm", "start"]
EOF

# Crear imagen de Docker
echo "${GREEN}Construyendo imagen de Docker${RESET}"
docker build -t $DOCKER_IMAGE $TEMP_DIR

# Correr contenedor de Docker
echo "${GREEN}Corriendo contenedor de Docker${RESET}"
docker run -d -p $PORT:$PORT --name $CONTAINER_NAME $DOCKER_IMAGE

# Mostrar contenedores activos
echo "${YELLOW}Contenedores Activos${RESET}"
docker ps -a

# Mostrar logs
echo "${YELLOW}Logs${RESET}"
docker logs $CONTAINER_NAME

# Proporcionar instrucciones para validar la aplicación
echo "${GREEN}Accede a la aplicación en: http://localhost:$PORT${RESET}"

# Obtener la IP del contenedor
CONTAINER_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)
echo "${GREEN}La IP del contenedor es: $CONTAINER_IP${RESET}"
