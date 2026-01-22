# Checklist de Instalación - AppDynamics en IBM WebSphere

Use este checklist para asegurar una implementación completa y exitosa.

## Fase 1: Preparación

### Requisitos Previos
- [ ] IBM WebSphere Application Server instalado y funcionando
- [ ] Java 1.8 (JDK 8) instalado y configurado
- [ ] Acceso de administrador al servidor WebSphere
- [ ] Información del Controller de AppDynamics disponible:
  - [ ] URL del Controller
  - [ ] Puerto (HTTP 8090 o HTTPS 8181)
  - [ ] Account Name
  - [ ] Account Access Key
  - [ ] Nombre de la aplicación
  - [ ] Nombre del tier
  - [ ] Nombre del nodo

### Verificación del Entorno
- [ ] Verificar versión de Java: `java -version` (debe ser 1.8)
- [ ] Verificar versión de WebSphere
- [ ] Verificar espacio en disco disponible (mínimo 500MB para el agente)
- [ ] Verificar permisos de escritura en el sistema de archivos

## Fase 2: Descarga e Instalación

### Descarga del Agente
- [ ] Acceder al portal de AppDynamics
- [ ] Descargar Java Agent compatible con Java 1.8
- [ ] Verificar integridad del archivo descargado

### Instalación del Agente
- [ ] Extraer el archivo ZIP en ubicación permanente (ej: `/opt/appdynamics/java-agent`)
- [ ] Verificar estructura de directorios:
  - [ ] `conf/` existe
  - [ ] `lib/` existe
  - [ ] `javaagent.jar` existe
  - [ ] `ver/` existe
- [ ] Crear directorio de logs: `mkdir -p /opt/appdynamics/java-agent/logs`
- [ ] Configurar permisos:
  - [ ] `chmod -R 755 /opt/appdynamics/java-agent`
  - [ ] `chmod -R 775 /opt/appdynamics/java-agent/logs`
  - [ ] Verificar propietario (debe ser el usuario que ejecuta WebSphere)

## Fase 3: Configuración del Agente

### Configuración de controller-info.xml
- [ ] Copiar `controller-info.xml.example` a `conf/controller-info.xml`
- [ ] Configurar `controller-host`
- [ ] Configurar `controller-port` (8090 o 8181)
- [ ] Configurar `controller-ssl-enabled` (true/false)
- [ ] Configurar `application-name`
- [ ] Configurar `tier-name`
- [ ] Configurar `node-name`
- [ ] Configurar `account-name`
- [ ] Configurar `account-access-key`
- [ ] Configurar `agent-runtime-dir`
- [ ] Configurar `log-dir`
- [ ] Configurar `log-level` (INFO recomendado)
- [ ] Si se usa proxy, configurar:
  - [ ] `http-proxy-host`
  - [ ] `http-proxy-port`
  - [ ] `http-proxy-username` (si aplica)
  - [ ] `http-proxy-password` (si aplica)

## Fase 4: Configuración de Conectividad

### Verificación de Red
- [ ] Verificar resolución DNS del Controller: `nslookup controller.example.com`
- [ ] Verificar conectividad de red: `ping controller.example.com`
- [ ] Verificar puerto HTTP: `telnet controller.example.com 8090` o `curl http://controller.example.com:8090/controller/rest/serverstatus`
- [ ] Si usa HTTPS, verificar puerto: `openssl s_client -connect controller.example.com:8181`

### Configuración de Firewall
- [ ] Identificar firewall utilizado (iptables, firewalld, Windows Firewall, etc.)
- [ ] Agregar regla para puerto HTTP 8090 (saliente)
- [ ] Si usa HTTPS, agregar regla para puerto 8181 (saliente)
- [ ] Verificar que las reglas estén activas
- [ ] Probar conectividad después de configurar firewall

### Configuración de Proxy (si aplica)
- [ ] Identificar si el servidor está detrás de un proxy
- [ ] Obtener información del proxy (host, puerto, credenciales)
- [ ] Configurar proxy en `controller-info.xml` o variables del sistema
- [ ] Verificar conectividad a través del proxy

### Certificados SSL/TLS (si aplica)
- [ ] Determinar si el Controller usa SSL/TLS
- [ ] Obtener certificado del Controller
- [ ] Importar certificado al keystore de Java: `keytool -import ...`
- [ ] O verificar que `controller-ssl-verify-cert` esté configurado correctamente

### Permisos de Archivos
- [ ] Verificar permisos de lectura en `/opt/appdynamics/java-agent`
- [ ] Verificar permisos de escritura en `/opt/appdynamics/java-agent/logs`
- [ ] Verificar que el usuario de WebSphere tenga acceso

## Fase 5: Configuración en WebSphere

### Opción A: Variables de Entorno y JVM Arguments
- [ ] Acceder a la consola administrativa de WebSphere
- [ ] Navegar a: Servidores > Application Servers > [nombre-del-servidor]
- [ ] Ir a: Java and Process Management > Process Definition > Environment Entries
- [ ] Agregar variable `APPDYNAMICS_AGENT_NODE_NAME`
- [ ] Agregar variable `APPDYNAMICS_AGENT_TIER_NAME`
- [ ] Agregar variable `APPDYNAMICS_AGENT_APPLICATION_NAME`
- [ ] Ir a: Java and Process Management > Java Virtual Machine
- [ ] Agregar JVM argument: `-javaagent:/opt/appdynamics/java-agent/javaagent.jar`
- [ ] Agregar JVM arguments adicionales según necesidad
- [ ] Guardar configuración

### Opción B: Script de Inicio (alternativa)
- [ ] Crear script de inicio personalizado
- [ ] Configurar variables de entorno en el script
- [ ] Hacer el script ejecutable: `chmod +x script.sh`
- [ ] Configurar WebSphere para ejecutar el script

## Fase 6: Verificación

### Verificación Pre-Inicio
- [ ] Ejecutar script de verificación: `bash verify-connectivity.sh`
- [ ] Revisar que todas las verificaciones pasen
- [ ] Verificar que `controller-info.xml` esté correctamente formateado (XML válido)

### Inicio del Servidor
- [ ] Detener el servidor WebSphere (si está corriendo)
- [ ] Iniciar el servidor WebSphere
- [ ] Verificar que el servidor inicie sin errores relacionados con AppDynamics

### Verificación Post-Inicio
- [ ] Revisar logs del agente: `tail -f /opt/appdynamics/java-agent/logs/agent.log`
- [ ] Buscar mensajes de conexión exitosa en los logs
- [ ] Verificar que no haya errores críticos en los logs
- [ ] Revisar logs de WebSphere para mensajes relacionados con AppDynamics

### Verificación en el Controller
- [ ] Acceder al Controller de AppDynamics
- [ ] Navegar a: Dashboards > Application Dashboard
- [ ] Seleccionar la aplicación configurada
- [ ] Verificar que el nodo aparezca en la lista de nodos
- [ ] Verificar que el tier aparezca correctamente
- [ ] Verificar que se estén recibiendo métricas básicas

### Verificación de Instrumentación
- [ ] Ejecutar transacciones en la aplicación
- [ ] Verificar que aparezcan en Flow Maps del Controller
- [ ] Verificar que aparezcan Transaction Snapshots
- [ ] Verificar que aparezcan Business Transactions
- [ ] Verificar métricas de rendimiento (CPU, memoria, etc.)

## Fase 7: Optimización y Ajustes

### Ajustes de Rendimiento
- [ ] Revisar nivel de logging (ajustar a WARN o ERROR si es necesario)
- [ ] Configurar sampling si hay muchas transacciones
- [ ] Revisar uso de CPU y memoria del agente

### Configuración Avanzada
- [ ] Configurar instrumentación personalizada si es necesario
- [ ] Configurar exclusiones de métodos si es necesario
- [ ] Ajustar timeouts si hay problemas de conectividad intermitente

## Fase 8: Documentación y Cierre

### Documentación
- [ ] Documentar configuración específica del entorno
- [ ] Documentar valores de configuración utilizados
- [ ] Documentar cualquier ajuste o workaround aplicado
- [ ] Actualizar este checklist con notas específicas

### Handoff
- [ ] Entregar documentación al equipo de operaciones
- [ ] Proporcionar acceso a logs y configuración
- [ ] Capacitar al equipo en monitoreo básico
- [ ] Establecer procedimientos de troubleshooting

## Notas Adicionales

### Problemas Comunes y Soluciones
- [ ] Si el agente no se conecta: verificar firewall y conectividad
- [ ] Si no aparecen métricas: verificar que la aplicación esté siendo instrumentada
- [ ] Si hay errores de SSL: verificar certificados
- [ ] Si hay problemas de rendimiento: ajustar nivel de logging

### Contactos de Soporte
- [ ] Documentar contacto de soporte de AppDynamics
- [ ] Documentar contacto de soporte interno
- [ ] Documentar procedimientos de escalamiento

---

**Fecha de Instalación:** _______________
**Instalado por:** _______________
**Revisado por:** _______________
**Estado Final:** ☐ Exitoso  ☐ Parcial  ☐ Fallido

**Comentarios:**
_________________________________________________
_________________________________________________
_________________________________________________
