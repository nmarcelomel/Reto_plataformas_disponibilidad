#!/bin/bash
# ============================================================
# NOC Dashboard - Verificacion Competitiva por Fases
# Hackathon Infrastructure Troubleshooting
# ============================================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

PHASE1_PASS=0
PHASE1_TOTAL=3
PHASE2_PASS=0
PHASE2_TOTAL=3
PHASE3_PASS=0
PHASE3_TOTAL=2

echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║       NOC Dashboard - Verificacion Competitiva              ║${NC}"
echo -e "${CYAN}${BOLD}║       Infrastructure Troubleshooting Challenge              ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ==============================================================
# FASE 1: Los contenedores arrancan y el frontend carga
# ==============================================================
echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}${BOLD}  FASE 1: Conectividad Basica (contenedores + frontend)${NC}"
echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check 1.1: Todos los servicios corriendo
echo -e "${BOLD}[1.1] Verificando que los 3 servicios esten corriendo...${NC}"
RUNNING_SERVICES=$(docker compose ps --status running --format "{{.Service}}" 2>/dev/null | sort)
EXPECTED_SERVICES=$(printf "backend\ndb\nproxy")

if [ "$(echo "$RUNNING_SERVICES" | sort)" == "$(echo "$EXPECTED_SERVICES" | sort)" ]; then
    echo -e "      ${GREEN}✓ PASS${NC} - proxy, backend y db estan UP"
    PHASE1_PASS=$((PHASE1_PASS + 1))
else
    echo -e "      ${RED}✗ FAIL${NC} - No todos los servicios estan corriendo"
    MISSING=$(comm -23 <(echo "$EXPECTED_SERVICES" | sort) <(echo "$RUNNING_SERVICES" | sort))
    if [ -n "$MISSING" ]; then
        echo -e "      ${YELLOW}Servicios caidos:${NC} $MISSING"
    fi
    echo -e "      ${YELLOW}TIP${NC}: docker compose ps -a | docker compose logs <servicio>"
fi
echo ""

# Check 1.2: Puerto 80 accesible
echo -e "${BOLD}[1.2] Verificando acceso HTTP en puerto 80...${NC}"
HTTP_FRONTEND=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/ 2>/dev/null)

if [ "$HTTP_FRONTEND" == "200" ]; then
    echo -e "      ${GREEN}✓ PASS${NC} - Frontend accesible en http://localhost"
    PHASE1_PASS=$((PHASE1_PASS + 1))
else
    echo -e "      ${RED}✗ FAIL${NC} - No se puede acceder a http://localhost (HTTP: ${HTTP_FRONTEND:-'sin respuesta'})"
    echo -e "      ${YELLOW}TIP${NC}: Revisa el port mapping del proxy en docker-compose.yml"
fi
echo ""

# Check 1.3: Nginx puede llegar al backend (no 502)
echo -e "${BOLD}[1.3] Verificando que Nginx se comunica con el backend...${NC}"
HTTP_API=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/api/health 2>/dev/null)

if [ "$HTTP_API" != "502" ] && [ "$HTTP_API" != "000" ] && [ -n "$HTTP_API" ]; then
    echo -e "      ${GREEN}✓ PASS${NC} - Nginx se comunica con el backend (HTTP: $HTTP_API)"
    PHASE1_PASS=$((PHASE1_PASS + 1))
else
    echo -e "      ${RED}✗ FAIL${NC} - Nginx NO puede comunicarse con el backend (HTTP: ${HTTP_API:-'sin respuesta'})"
    if [ "$HTTP_API" == "502" ]; then
        echo -e "      ${YELLOW}TIP${NC}: 502 = proxy no alcanza al backend. Revisa redes y puertos en nginx.conf"
    else
        echo -e "      ${YELLOW}TIP${NC}: Sin respuesta. Revisa que el proxy tenga el puerto publicado"
    fi
fi
echo ""

# Resultado Fase 1
echo -e "${BOLD}  Fase 1: ${PHASE1_PASS}/${PHASE1_TOTAL} checks${NC}"
if [ $PHASE1_PASS -eq $PHASE1_TOTAL ]; then
    echo -e "  ${GREEN}${BOLD}★ FASE 1 COMPLETADA${NC}"
else
    echo -e "  ${RED}✗ Fase 1 incompleta — resuelve estos errores antes de avanzar${NC}"
    echo ""
    echo -e "${BOLD}RESULTADO FINAL: Fase 1 no superada (${PHASE1_PASS}/${PHASE1_TOTAL})${NC}"
    echo ""
    exit 1
fi
echo ""

# ==============================================================
# FASE 2: La base de datos conecta y el health responde OK
# ==============================================================
echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}${BOLD}  FASE 2: Base de Datos (conexion + datos)${NC}"
echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check 2.1: /api/health devuelve 200
echo -e "${BOLD}[2.1] Verificando que /api/health devuelve HTTP 200...${NC}"
HTTP_CODE=$(curl -s -o /tmp/health_response.json -w "%{http_code}" http://localhost/api/health 2>/dev/null)

if [ "$HTTP_CODE" == "200" ]; then
    echo -e "      ${GREEN}✓ PASS${NC} - Health endpoint responde 200 OK"
    PHASE2_PASS=$((PHASE2_PASS + 1))
else
    echo -e "      ${RED}✗ FAIL${NC} - Health endpoint responde HTTP ${HTTP_CODE}"
    if [ "$HTTP_CODE" == "503" ]; then
        ERROR_MSG=$(cat /tmp/health_response.json 2>/dev/null | grep -o '"error":"[^"]*"' | cut -d'"' -f4)
        echo -e "      ${YELLOW}TIP${NC}: 503 = backend no puede conectar a la BD."
        echo -e "      ${YELLOW}     ${NC} Revisa: credenciales, variables de entorno, init SQL"
        if [ -n "$ERROR_MSG" ]; then
            echo -e "      ${YELLOW}Error:${NC} $ERROR_MSG"
        fi
    fi
fi
echo ""

# Check 2.2: Database status es "connected"
echo -e "${BOLD}[2.2] Verificando conexion activa a PostgreSQL...${NC}"
if [ -f /tmp/health_response.json ] && [ "$HTTP_CODE" == "200" ]; then
    DB_CONNECTED=$(cat /tmp/health_response.json | grep -o '"status":"connected"')
    if [ -n "$DB_CONNECTED" ]; then
        echo -e "      ${GREEN}✓ PASS${NC} - Base de datos conectada"
        PHASE2_PASS=$((PHASE2_PASS + 1))
    else
        echo -e "      ${RED}✗ FAIL${NC} - Base de datos no conectada"
        echo -e "      ${YELLOW}TIP${NC}: Revisa las variables de entorno del backend y como config.js las lee"
    fi
else
    echo -e "      ${RED}✗ FAIL${NC} - No se pudo verificar (check 2.1 fallo)"
fi
echo ""

# Check 2.3: La tabla services existe y tiene datos
echo -e "${BOLD}[2.3] Verificando que las tablas de monitoreo existen con datos...${NC}"
if [ -f /tmp/health_response.json ] && [ "$HTTP_CODE" == "200" ]; then
    HEALTHY_COUNT=$(cat /tmp/health_response.json | grep -o '"healthyServices":[0-9]*' | cut -d':' -f2)
    if [ -n "$HEALTHY_COUNT" ] && [ "$HEALTHY_COUNT" -gt 0 ] 2>/dev/null; then
        echo -e "      ${GREEN}✓ PASS${NC} - Tabla services operacional ($HEALTHY_COUNT servicios healthy)"
        PHASE2_PASS=$((PHASE2_PASS + 1))
    else
        echo -e "      ${RED}✗ FAIL${NC} - La tabla 'services' no existe o no tiene datos"
        echo -e "      ${YELLOW}TIP${NC}: Revisa el archivo init.sql — puede tener errores de sintaxis"
        echo -e "      ${YELLOW}     ${NC} Ejecuta: docker compose logs db | grep -i error"
    fi
else
    echo -e "      ${RED}✗ FAIL${NC} - No se pudo verificar (checks anteriores fallaron)"
fi
echo ""

# Resultado Fase 2
echo -e "${BOLD}  Fase 2: ${PHASE2_PASS}/${PHASE2_TOTAL} checks${NC}"
if [ $PHASE2_PASS -eq $PHASE2_TOTAL ]; then
    echo -e "  ${GREEN}${BOLD}★ FASE 2 COMPLETADA${NC}"
else
    echo -e "  ${RED}✗ Fase 2 incompleta — resuelve estos errores antes de avanzar${NC}"
    echo ""
    TOTAL_PASS=$((PHASE1_PASS + PHASE2_PASS))
    TOTAL=$((PHASE1_TOTAL + PHASE2_TOTAL))
    echo -e "${BOLD}RESULTADO FINAL: Fase 2 no superada (${TOTAL_PASS}/${TOTAL} checks totales)${NC}"
    echo ""
    exit 1
fi
echo ""

# ==============================================================
# FASE 3: El sistema es estable (sin OOM, uptime > 30s)
# ==============================================================
echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}${BOLD}  FASE 3: Estabilidad (sin reinicios, uptime sostenido)${NC}"
echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check 3.1: Backend uptime > 30 segundos
echo -e "${BOLD}[3.1] Verificando estabilidad del backend (uptime > 30s)...${NC}"
UPTIME=$(cat /tmp/health_response.json 2>/dev/null | grep -o '"uptime":[0-9.]*' | head -1 | cut -d':' -f2)
if [ -n "$UPTIME" ]; then
    UPTIME_INT=${UPTIME%.*}
    if [ "$UPTIME_INT" -ge 30 ] 2>/dev/null; then
        echo -e "      ${GREEN}✓ PASS${NC} - Backend estable (uptime: ${UPTIME_INT}s)"
        PHASE3_PASS=$((PHASE3_PASS + 1))
    else
        echo -e "      ${RED}✗ FAIL${NC} - Backend inestable (uptime: ${UPTIME_INT}s, necesita >30s)"
        echo -e "      ${YELLOW}TIP${NC}: Si se reinicia constantemente, revisa limites de memoria"
        echo -e "      ${YELLOW}     ${NC} Ejecuta: docker stats --no-stream"
        echo -e "      ${YELLOW}     ${NC} Busca: docker compose logs backend | grep -i 'oom\|kill\|memory'"
    fi
else
    echo -e "      ${RED}✗ FAIL${NC} - No se pudo extraer uptime"
fi
echo ""

# Check 3.2: Segundo health check 5s despues sigue respondiendo 200
echo -e "${BOLD}[3.2] Verificando consistencia (segundo check en 5s)...${NC}"
echo -e "      ${CYAN}Esperando 5 segundos...${NC}"
sleep 5
HTTP_CODE2=$(curl -s -o /tmp/health_response2.json -w "%{http_code}" http://localhost/api/health 2>/dev/null)

if [ "$HTTP_CODE2" == "200" ]; then
    UPTIME2=$(cat /tmp/health_response2.json 2>/dev/null | grep -o '"uptime":[0-9.]*' | head -1 | cut -d':' -f2)
    UPTIME2_INT=${UPTIME2%.*}
    if [ -n "$UPTIME2_INT" ] && [ "$UPTIME2_INT" -ge 35 ] 2>/dev/null; then
        echo -e "      ${GREEN}✓ PASS${NC} - Backend sigue estable despues de 5s (uptime: ${UPTIME2_INT}s)"
        PHASE3_PASS=$((PHASE3_PASS + 1))
    else
        echo -e "      ${RED}✗ FAIL${NC} - Backend se reinicio entre checks (uptime: ${UPTIME2_INT:-0}s)"
        echo -e "      ${YELLOW}TIP${NC}: El backend consume mas memoria de la permitida"
        echo -e "      ${YELLOW}     ${NC} Revisa: docker stats y los archivos de configuracion"
    fi
else
    echo -e "      ${RED}✗ FAIL${NC} - Segundo check fallo (HTTP: ${HTTP_CODE2:-'sin respuesta'})"
    echo -e "      ${YELLOW}TIP${NC}: El contenedor probablemente fue reiniciado por OOM killer"
fi
echo ""

# Resultado Fase 3
echo -e "${BOLD}  Fase 3: ${PHASE3_PASS}/${PHASE3_TOTAL} checks${NC}"
if [ $PHASE3_PASS -eq $PHASE3_TOTAL ]; then
    echo -e "  ${GREEN}${BOLD}★ FASE 3 COMPLETADA${NC}"
else
    echo -e "  ${RED}✗ Fase 3 incompleta${NC}"
    echo ""
    TOTAL_PASS=$((PHASE1_PASS + PHASE2_PASS + PHASE3_PASS))
    TOTAL=$((PHASE1_TOTAL + PHASE2_TOTAL + PHASE3_TOTAL))
    echo -e "${BOLD}RESULTADO FINAL: Fase 3 no superada (${TOTAL_PASS}/${TOTAL} checks totales)${NC}"
    echo ""
    exit 1
fi
echo ""

# ==============================================================
# VICTORIA
# ==============================================================
TOTAL_PASS=$((PHASE1_PASS + PHASE2_PASS + PHASE3_PASS))
TOTAL=$((PHASE1_TOTAL + PHASE2_TOTAL + PHASE3_TOTAL))

echo -e "${GREEN}${BOLD}"
echo "  ██████╗ ███████╗████████╗ ██████╗     ███████╗██╗   ██╗██████╗ ███████╗██████╗  █████╗ ██████╗  ██████╗ ██╗"
echo "  ██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗    ██╔════╝██║   ██║██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔═══██╗██║"
echo "  ██████╔╝█████╗     ██║   ██║   ██║    ███████╗██║   ██║██████╔╝█████╗  ██████╔╝███████║██║  ██║██║   ██║██║"
echo "  ██╔══██╗██╔══╝     ██║   ██║   ██║    ╚════██║██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗██╔══██║██║  ██║██║   ██║╚═╝"
echo "  ██║  ██║███████╗   ██║   ╚██████╔╝    ███████║╚██████╔╝██║     ███████╗██║  ██║██║  ██║██████╔╝╚██████╔╝██╗"
echo "  ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝     ╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═╝"
echo -e "${NC}"
echo ""
echo -e "${GREEN}${BOLD}  ╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}  ║                                                               ║${NC}"
echo -e "${GREEN}${BOLD}  ║   🏆 HASH DE VICTORIA: NOC-KIRO-$(date +%H%M)-${TOTAL_PASS}${TOTAL}                    ║${NC}"
echo -e "${GREEN}${BOLD}  ║                                                               ║${NC}"
echo -e "${GREEN}${BOLD}  ║   Todas las fases completadas: ${TOTAL_PASS}/${TOTAL} checks              ║${NC}"
echo -e "${GREEN}${BOLD}  ║                                                               ║${NC}"
echo -e "${GREEN}${BOLD}  ║   Fase 1: Conectividad    ✓ (${PHASE1_PASS}/${PHASE1_TOTAL})                       ║${NC}"
echo -e "${GREEN}${BOLD}  ║   Fase 2: Base de Datos   ✓ (${PHASE2_PASS}/${PHASE2_TOTAL})                       ║${NC}"
echo -e "${GREEN}${BOLD}  ║   Fase 3: Estabilidad     ✓ (${PHASE3_PASS}/${PHASE3_TOTAL})                       ║${NC}"
echo -e "${GREEN}${BOLD}  ║                                                               ║${NC}"
echo -e "${GREEN}${BOLD}  ╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Cleanup
rm -f /tmp/health_response.json /tmp/health_response2.json
