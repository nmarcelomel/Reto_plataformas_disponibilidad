# 🏢 NOC Dashboard — Infrastructure Troubleshooting Challenge

## Contexto

Tu equipo de infraestructura acaba de recibir un deployment de emergencia del **NOC Dashboard** (Network Operations Center). Este sistema monitorea la salud de servicios críticos y debe estar operacional para el próximo turno de operaciones.

El problema: **el deployment fue hecho por un ingeniero junior a las 3AM y nada funciona correctamente**.

Tu misión: hacer que el sistema pase las **3 fases de verificación** lo más rápido posible.

---

## 🎯 Formato Competitivo

| Fase | Objetivo | Tiempo sugerido |
|------|----------|----------------|
| **Fase 1** | Los contenedores arrancan y el frontend carga | 15 min |
| **Fase 2** | La base de datos conecta y el health responde | 15 min |
| **Fase 3** | El sistema es estable (sin reinicios) | 15 min |

**Reglas:**
- Puedes usar IA como copiloto (Kiro, Copilot, ChatGPT)
- El timer empieza cuando ejecutas `docker compose up --build -d`
- Gana quien obtenga el **Hash de Victoria** primero
- Si nadie lo logra en 45 min, gana quien tenga más fases completadas

---

## 🏗️ Arquitectura

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│   Browser   │──:80──│  Nginx      │──────▶│  Backend    │
│  (Frontend) │       │  (Proxy)    │       │  (Node.js)  │
└─────────────┘       └─────────────┘       └──────┬──────┘
                                                    │
                                             ┌──────▼──────┐
                                             │ PostgreSQL  │
                                             │   (DB)      │
                                             └─────────────┘
```

**Servicios:**
- `proxy` — Nginx sirviendo frontend + reverse proxy al backend (puerto 80)
- `backend` — API Node.js con endpoint `/api/health` (puerto interno 8080)
- `db` — PostgreSQL 16 con tablas de monitoreo

---

## 🚀 Instrucciones

### 1. Levantar los servicios

```bash
docker compose up --build -d
```

### 2. Verificar tu progreso

```bash
./verificar_reto.sh
```

El script verifica fase por fase. **No puedes avanzar a la siguiente fase hasta completar la anterior.**

### 3. Diagnosticar

```bash
# Ver estado de los contenedores
docker compose ps -a

# Ver logs de cada servicio
docker compose logs proxy
docker compose logs backend
docker compose logs db

# Ver uso de recursos
docker stats --no-stream

# Entrar a un contenedor
docker compose exec backend sh
docker compose exec db psql -U nocadmin -d noc_dashboard
```

### 4. Aplicar correcciones y reconstruir

```bash
docker compose down -v
docker compose up --build -d
```

> ⚠️ **Usa `-v` para borrar volúmenes si cambias el init SQL o la configuración de la base de datos.**

### 5. Verificar la solución

```bash
./verificar_reto.sh
```

---

## 📁 Estructura del Proyecto

```
Reto_plataformas_disponibilidad/
├── docker-compose.yml          # Orquestación de servicios
├── docker-compose.override.yml # Overrides para desarrollo
├── Dockerfile.frontend         # Build del frontend (Nginx)
├── nginx/
│   └── nginx.conf              # Configuración del reverse proxy
├── backend/
│   ├── Dockerfile              # Build del backend
│   ├── entrypoint.sh           # Script de inicialización del servicio
│   ├── package.json            # Dependencias Node.js
│   ├── app.js                  # API del backend
│   └── config.js               # Carga de configuración
├── database/
│   ├── Dockerfile              # Build custom de PostgreSQL
│   ├── pg-setup.sh             # Configuración de auth y schemas
│   └── init.sql                # Script de inicialización de la BD
├── frontend/
│   └── index.html              # Dashboard UI
├── verificar_reto.sh           # Script de verificación por fases
└── README.md                   # Este archivo
```

---

## 🛠️ Comandos Útiles

| Comando | Descripción |
|---------|-------------|
| `docker compose ps -a` | Ver estado de todos los servicios |
| `docker compose logs <service>` | Ver logs de un servicio |
| `docker compose logs -f backend` | Logs en tiempo real |
| `docker compose exec backend sh` | Shell dentro del backend |
| `docker compose exec db psql -U nocadmin -d noc_dashboard` | Conectar a PostgreSQL |
| `docker network ls` | Listar redes de Docker |
| `docker network inspect <network>` | Ver detalles de una red |
| `docker stats --no-stream` | Ver uso de CPU/memoria |
| `docker compose down -v` | Tirar todo incluyendo volúmenes |

---

## ⏱️ Tiempo Límite: 45 minutos

El reto está diseñado en cascada — cada error puede ocultar el siguiente. Los errores están distribuidos en múltiples capas:

- **Algunos errores son visibles leyendo archivos**
- **Otros solo se manifiestan en runtime** (logs, estado del contenedor)
- **Otros aparecen después de que los anteriores están resueltos**

No todos los archivos que se ven "correctos" lo son cuando el sistema corre.

---

## 💡 Filosofía

> "En producción, los problemas más peligrosos no son los que se ven en el código — son los que solo aparecen cuando el sistema está corriendo bajo condiciones específicas."

¡Buena suerte, SRE! 🫡
