#!/bin/bash
#
# Script de verificación de conectividad para AppDynamics
# Este script verifica que todos los requisitos de conectividad estén cumplidos
#

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables de configuración (ajustar según su entorno)
CONTROLLER_HOST="controller.example.com"
CONTROLLER_HTTP_PORT="8090"
CONTROLLER_HTTPS_PORT="8181"
USE_SSL=false

echo "=========================================="
echo "Verificación de Conectividad AppDynamics"
echo "=========================================="
echo ""

# Función para verificar comando
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 está instalado"
        return 0
    else
        echo -e "${RED}✗${NC} $1 NO está instalado"
        return 1
    fi
}

# Función para verificar conectividad de puerto
check_port() {
    host=$1
    port=$2
    protocol=$3
    
    if timeout 5 bash -c "cat < /dev/null > /dev/tcp/$host/$port" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Puerto $port ($protocol) accesible en $host"
        return 0
    else
        echo -e "${RED}✗${NC} Puerto $port ($protocol) NO accesible en $host"
        return 1
    fi
}

# Función para verificar DNS
check_dns() {
    host=$1
    if nslookup $host &> /dev/null || getent hosts $host &> /dev/null; then
        ip=$(getent hosts $host | awk '{print $1}' | head -1)
        echo -e "${GREEN}✓${NC} DNS resuelve $host a $ip"
        return 0
    else
        echo -e "${RED}✗${NC} DNS NO puede resolver $host"
        return 1
    fi
}

# Función para verificar HTTP/HTTPS
check_http() {
    host=$1
    port=$2
    use_ssl=$3
    
    if [ "$use_ssl" = true ]; then
        url="https://$host:$port/controller/rest/serverstatus"
        if curl -k -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$url" | grep -q "200"; then
            echo -e "${GREEN}✓${NC} Controller HTTPS accesible en $host:$port"
            return 0
        else
            echo -e "${RED}✗${NC} Controller HTTPS NO accesible en $host:$port"
            return 1
        fi
    else
        url="http://$host:$port/controller/rest/serverstatus"
        if curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$url" | grep -q "200"; then
            echo -e "${GREEN}✓${NC} Controller HTTP accesible en $host:$port"
            return 0
        else
            echo -e "${RED}✗${NC} Controller HTTP NO accesible en $host:$port"
            return 1
        fi
    fi
}

# Verificar comandos necesarios
echo "1. Verificando herramientas necesarias..."
echo "----------------------------------------"
check_command "curl"
check_command "nslookup" || check_command "getent"
check_command "timeout" || check_command "nc"
echo ""

# Verificar DNS
echo "2. Verificando resolución DNS..."
echo "----------------------------------------"
check_dns "$CONTROLLER_HOST"
echo ""

# Verificar conectividad de puertos
echo "3. Verificando conectividad de puertos..."
echo "----------------------------------------"
if [ "$USE_SSL" = true ]; then
    check_port "$CONTROLLER_HOST" "$CONTROLLER_HTTPS_PORT" "HTTPS"
else
    check_port "$CONTROLLER_HOST" "$CONTROLLER_HTTP_PORT" "HTTP"
fi
echo ""

# Verificar acceso HTTP/HTTPS
echo "4. Verificando acceso al Controller..."
echo "----------------------------------------"
check_http "$CONTROLLER_HOST" "$CONTROLLER_HTTP_PORT" false
if [ "$USE_SSL" = true ]; then
    check_http "$CONTROLLER_HOST" "$CONTROLLER_HTTPS_PORT" true
fi
echo ""

# Verificar firewall local
echo "5. Verificando configuración de firewall..."
echo "----------------------------------------"
if command -v iptables &> /dev/null; then
    if iptables -L OUTPUT -n | grep -q "$CONTROLLER_HTTP_PORT\|$CONTROLLER_HTTPS_PORT"; then
        echo -e "${GREEN}✓${NC} Reglas de firewall encontradas"
    else
        echo -e "${YELLOW}⚠${NC} No se encontraron reglas específicas de firewall (puede estar permitido por defecto)"
    fi
elif command -v firewall-cmd &> /dev/null; then
    if firewall-cmd --list-all | grep -q "$CONTROLLER_HTTP_PORT\|$CONTROLLER_HTTPS_PORT"; then
        echo -e "${GREEN}✓${NC} Reglas de firewall encontradas"
    else
        echo -e "${YELLOW}⚠${NC} No se encontraron reglas específicas de firewall"
    fi
else
    echo -e "${YELLOW}⚠${NC} No se pudo verificar firewall (herramienta no disponible)"
fi
echo ""

# Verificar variables de entorno
echo "6. Verificando variables de entorno..."
echo "----------------------------------------"
if [ -n "$APPDYNAMICS_AGENT_NODE_NAME" ]; then
    echo -e "${GREEN}✓${NC} APPDYNAMICS_AGENT_NODE_NAME: $APPDYNAMICS_AGENT_NODE_NAME"
else
    echo -e "${YELLOW}⚠${NC} APPDYNAMICS_AGENT_NODE_NAME no está configurada"
fi

if [ -n "$APPDYNAMICS_AGENT_TIER_NAME" ]; then
    echo -e "${GREEN}✓${NC} APPDYNAMICS_AGENT_TIER_NAME: $APPDYNAMICS_AGENT_TIER_NAME"
else
    echo -e "${YELLOW}⚠${NC} APPDYNAMICS_AGENT_TIER_NAME no está configurada"
fi

if [ -n "$APPDYNAMICS_AGENT_APPLICATION_NAME" ]; then
    echo -e "${GREEN}✓${NC} APPDYNAMICS_AGENT_APPLICATION_NAME: $APPDYNAMICS_AGENT_APPLICATION_NAME"
else
    echo -e "${YELLOW}⚠${NC} APPDYNAMICS_AGENT_APPLICATION_NAME no está configurada"
fi
echo ""

# Verificar archivo de configuración
echo "7. Verificando archivo de configuración..."
echo "----------------------------------------"
CONFIG_FILE="/opt/appdynamics/java-agent/conf/controller-info.xml"
if [ -f "$CONFIG_FILE" ]; then
    echo -e "${GREEN}✓${NC} Archivo de configuración encontrado: $CONFIG_FILE"
    
    # Verificar elementos clave
    if grep -q "<controller-host>" "$CONFIG_FILE"; then
        echo -e "${GREEN}✓${NC} controller-host configurado"
    else
        echo -e "${RED}✗${NC} controller-host NO configurado"
    fi
    
    if grep -q "<application-name>" "$CONFIG_FILE"; then
        echo -e "${GREEN}✓${NC} application-name configurado"
    else
        echo -e "${RED}✗${NC} application-name NO configurado"
    fi
    
    if grep -q "<account-access-key>" "$CONFIG_FILE"; then
        echo -e "${GREEN}✓${NC} account-access-key configurado"
    else
        echo -e "${RED}✗${NC} account-access-key NO configurado"
    fi
else
    echo -e "${RED}✗${NC} Archivo de configuración NO encontrado: $CONFIG_FILE"
fi
echo ""

# Resumen
echo "=========================================="
echo "Resumen de Verificación"
echo "=========================================="
echo ""
echo "Para usar este script con su configuración:"
echo "1. Edite las variables al inicio del script"
echo "2. Ejecute: bash verify-connectivity.sh"
echo ""
echo "Si todas las verificaciones pasan, el agente debería poder"
echo "conectarse al Controller de AppDynamics."
echo ""
