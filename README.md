# Sistema de Inventario Tecnológico · Clínica Veterinaria Pata Verde

Proyecto final de **Servidores II** (Universidad de Sonora, Ingeniería en Sistemas de Información) · **Equipo 7**.

Sistema web para registrar y consultar los equipos tecnológicos de una clínica veterinaria ficticia: equipos de diagnóstico por imagen, autoclaves, computadoras, impresoras, red y cámaras de seguridad. Los datos de ejemplo son ficticios.

## Arquitectura

| Servicio | Imagen | Puerto | Función |
|---|---|---|---|
| nginx | `nginx:1.28-alpine` | 80 publicado | Proxy inverso: recibe las peticiones del navegador y las envía a la app |
| app | `unisonsrv2eq726/inventario-app:1.0` | 5000 interno | Aplicación Flask servida con Gunicorn |
| db | `mysql:8.4` | 3306 interno | Base de datos `inventario`, inicializada con `db/init.sql` |

Los tres servicios se comunican por la red interna `red_interna`. Los datos de MySQL se guardan en el volumen `datos_mysql`. Solo el puerto 80 queda expuesto al anfitrión.

## Requisitos

- Servidor Linux (probado en Ubuntu Server) con 4 GB de RAM o más.
- Docker Engine, Docker Compose y Git.

## Recrear el sistema desde cero

1. Clonar el repositorio:

   ```bash
   git clone https://github.com/equipo7-servidores/inventario.git
   cd inventario
   ```

2. Crear el archivo `.env` a partir de la plantilla y cambiar las contraseñas (sin `$`, `#` ni espacios):

   ```bash
   cp .env.example .env
   nano .env
   ```

3. Levantar los servicios y esperar a que `db` aparezca como `healthy` (la primera vez tarda unos minutos):

   ```bash
   docker compose up -d
   docker compose ps
   ```

4. (Opcional) Restaurar un respaldo de la base de datos:

   ```bash
   docker compose exec -T db sh -c 'mysql -u root -p"$MYSQL_ROOT_PASSWORD"' < inventario_AAAA-MM-DD_HHMM.sql
   ```

5. Verificar el sistema:

   ```bash
   curl http://localhost/salud
   ```

   Debe responder `"estado":"ok"`. Desde el navegador, entrar a `http://IP-del-servidor`.

## Respaldo

```bash
./respaldo.sh
```

Genera `~/respaldos/inventario_AAAA-MM-DD_HHMM.sql` fuera del proyecto. Los respaldos contienen datos de la organización y **no** se suben al repositorio.

## Validación automática

El `Jenkinsfile` define el pipeline `validar-inventario`: comprueba los archivos del proyecto, que `.env` no esté publicado, la estructura de `compose.yaml`, el historial de Git y que el sistema responda en `http://nginx/salud`. Jenkins se ejecuta en un contenedor unido a la red del sistema:

```bash
docker run -d --name jenkins -p 8080:8080 -v jenkins_home:/var/jenkins_home \
  --network inventario_red_interna jenkins/jenkins:lts
```

## Seguridad

- `.env` está en `.gitignore`; el repositorio solo contiene `.env.example` (y `.env.ejemplo`, que valida el pipeline) sin contraseñas reales.
- La base de datos no publica su puerto; solo `nginx` expone el puerto 80.
- La aplicación usa el usuario `app_inventario`, con permisos solo sobre la base `inventario`.
