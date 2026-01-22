# Comandos Útiles para AppDynamics en WebSphere

Este documento contiene comandos útiles para la administración y troubleshooting del agente de AppDynamics en IBM WebSphere.

## Verificación de Instalación

### Verificar que el agente está cargado
```bash
# Verificar procesos Java con el agente
ps aux | grep javaagent

# Verificar en el proceso de WebSphere
ps -ef | grep was | grep javaagent
```

### Verificar variables de entorno
```bash
# Ver todas las variables de AppDynamics
env | grep APPDYNAMICS

# Ver variables específicas
echo $APPDYNAMICS_AGENT_NODE_NAME
echo $APPDYNAMICS_AGENT_TIER_NAME
echo $APPDYNAMICS_AGENT_APPLICATION_NAME
```

### Verificar archivos de configuración
```bash
# Verificar que existe el archivo de configuración
ls -la /opt/appdynamics/java-agent/conf/controller-info.xml

# Verificar contenido (sin mostrar access key)
grep -v "access-key" /opt/appdynamics/java-agent/conf/controller-info.xml

# Validar XML
xmllint --noout /opt/appdynamics/java-agent/conf/controller-info.xml
```

## Verificación de Conectividad

### Verificar DNS
```bash
# Resolver hostname
nslookup controller.example.com

# O usando getent
getent hosts controller.example.com

# Ver IP resuelta
dig +short controller.example.com
```

### Verificar conectividad de puertos
```bash
# Verificar puerto HTTP (8090)
telnet controller.example.com 8090

# O usando nc (netcat)
nc -zv controller.example.com 8090

# O usando timeout con bash
timeout 5 bash -c "cat < /dev/null > /dev/tcp/controller.example.com/8090" && echo "Conectado" || echo "No conectado"

# Verificar puerto HTTPS (8181)
openssl s_client -connect controller.example.com:8181 -showcerts
```

### Verificar acceso HTTP/HTTPS
```bash
# Verificar endpoint del Controller (HTTP)
curl -v http://controller.example.com:8090/controller/rest/serverstatus

# Verificar endpoint del Controller (HTTPS, sin verificar certificado)
curl -k -v https://controller.example.com:8181/controller/rest/serverstatus

# Verificar con autenticación básica
curl -u usuario:password http://controller.example.com:8090/controller/rest/serverstatus
```

### Verificar rutas de red
```bash
# Traceroute al Controller
traceroute controller.example.com

# O usando mtr
mtr controller.example.com
```

## Monitoreo de Logs

### Ver logs en tiempo real
```bash
# Log principal del agente
tail -f /opt/appdynamics/java-agent/logs/agent.log

# Log con filtrado de errores
tail -f /opt/appdynamics/java-agent/logs/agent.log | grep -i error

# Múltiples logs
tail -f /opt/appdynamics/java-agent/logs/*.log
```

### Buscar en logs
```bash
# Buscar errores
grep -i error /opt/appdynamics/java-agent/logs/agent.log

# Buscar conexiones exitosas
grep -i "connected\|registered" /opt/appdynamics/java-agent/logs/agent.log

# Buscar por fecha
grep "2024-01-15" /opt/appdynamics/java-agent/logs/agent.log

# Buscar últimas 100 líneas con errores
tail -n 100 /opt/appdynamics/java-agent/logs/agent.log | grep -i error
```

### Analizar logs
```bash
# Contar errores
grep -c -i error /opt/appdynamics/java-agent/logs/agent.log

# Ver errores únicos
grep -i error /opt/appdynamics/java-agent/logs/agent.log | sort | uniq

# Ver últimas 50 líneas antes de un error
grep -B 50 -i error /opt/appdynamics/java-agent/logs/agent.log | tail -n 50
```

## Gestión de Certificados SSL

### Obtener certificado del Controller
```bash
# Obtener certificado
openssl s_client -connect controller.example.com:8181 -showcerts </dev/null 2>/dev/null | openssl x509 -outform PEM > controller.crt

# Ver detalles del certificado
openssl x509 -in controller.crt -text -noout
```

### Importar certificado al keystore de Java
```bash
# Importar certificado (Java 8)
keytool -import -alias appdynamics-controller -file controller.crt \
  -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit

# Verificar certificado importado
keytool -list -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit | grep appdynamics

# Para Java 9+ (ruta diferente)
keytool -import -alias appdynamics-controller -file controller.crt \
  -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit
```

## Configuración de Firewall

### Linux - iptables
```bash
# Agregar regla para puerto HTTP
iptables -A OUTPUT -p tcp --dport 8090 -j ACCEPT

# Agregar regla para puerto HTTPS
iptables -A OUTPUT -p tcp --dport 8181 -j ACCEPT

# Ver reglas actuales
iptables -L OUTPUT -n | grep 8090

# Guardar reglas (según distribución)
service iptables save
# O
iptables-save > /etc/iptables/rules.v4
```

### Linux - firewalld
```bash
# Agregar regla para puerto HTTP
firewall-cmd --permanent --add-port=8090/tcp
firewall-cmd --reload

# Agregar regla para puerto HTTPS
firewall-cmd --permanent --add-port=8181/tcp
firewall-cmd --reload

# Ver reglas
firewall-cmd --list-ports
```

### Windows
```powershell
# Agregar regla para puerto HTTP
netsh advfirewall firewall add rule name="AppDynamics Controller HTTP" dir=out action=allow protocol=TCP localport=8090

# Agregar regla para puerto HTTPS
netsh advfirewall firewall add rule name="AppDynamics Controller HTTPS" dir=out action=allow protocol=TCP localport=8181

# Ver reglas
netsh advfirewall firewall show rule name="AppDynamics Controller HTTP"
```

## Gestión de Permisos

### Verificar permisos
```bash
# Ver permisos del directorio del agente
ls -la /opt/appdynamics/java-agent

# Ver permisos de archivos específicos
ls -la /opt/appdynamics/java-agent/javaagent.jar
ls -la /opt/appdynamics/java-agent/conf/controller-info.xml
ls -la /opt/appdynamics/java-agent/logs/
```

### Configurar permisos
```bash
# Configurar permisos de lectura
chmod -R 755 /opt/appdynamics/java-agent

# Configurar permisos de escritura en logs
chmod -R 775 /opt/appdynamics/java-agent/logs

# Cambiar propietario (ajustar usuario según entorno)
chown -R wasadmin:wasgroup /opt/appdynamics/java-agent
```

## Verificación de WebSphere

### Verificar configuración de JVM
```bash
# Ver argumentos JVM (desde la consola administrativa o archivos de configuración)
# En WebSphere, los argumentos están en:
# $WAS_HOME/profiles/[profile]/config/cells/[cell]/nodes/[node]/servers/[server]/server.xml

# Buscar javaagent en configuración
grep -r "javaagent" $WAS_HOME/profiles/*/config/
```

### Ver logs de WebSphere
```bash
# Logs del servidor (ajustar ruta según instalación)
tail -f $WAS_HOME/profiles/[profile]/logs/[server]/SystemOut.log

# Buscar referencias a AppDynamics
grep -i appdynamics $WAS_HOME/profiles/*/logs/*/SystemOut.log
```

## Troubleshooting Avanzado

### Verificar procesos y recursos
```bash
# Ver uso de memoria del proceso Java
ps aux | grep java | grep was

# Ver conexiones de red activas
netstat -an | grep 8090
netstat -an | grep 8181

# Ver conexiones establecidas al Controller
netstat -an | grep ESTABLISHED | grep controller
```

### Verificar variables del sistema Java
```bash
# Ver todas las propiedades del sistema relacionadas con AppDynamics
java -XshowSettings:properties -version 2>&1 | grep appdynamics

# Ver classpath (si está configurado)
echo $CLASSPATH | tr ':' '\n' | grep appdynamics
```

### Generar información de diagnóstico
```bash
# Crear script de diagnóstico
cat > /tmp/appd-diagnostic.sh << 'EOF'
#!/bin/bash
echo "=== Información del Sistema ==="
uname -a
echo ""
echo "=== Versión de Java ==="
java -version
echo ""
echo "=== Variables de Entorno AppDynamics ==="
env | grep APPDYNAMICS
echo ""
echo "=== Configuración del Agente ==="
cat /opt/appdynamics/java-agent/conf/controller-info.xml | grep -v "access-key"
echo ""
echo "=== Últimas 50 líneas del log ==="
tail -n 50 /opt/appdynamics/java-agent/logs/agent.log
EOF

chmod +x /tmp/appd-diagnostic.sh
/tmp/appd-diagnostic.sh > appd-diagnostic-$(date +%Y%m%d-%H%M%S).txt
```

## Comandos de Limpieza

### Limpiar logs antiguos
```bash
# Eliminar logs más antiguos de 30 días
find /opt/appdynamics/java-agent/logs -name "*.log" -mtime +30 -delete

# Comprimir logs antiguos
find /opt/appdynamics/java-agent/logs -name "*.log" -mtime +7 -exec gzip {} \;
```

### Rotar logs manualmente
```bash
# Rotar log actual
mv /opt/appdynamics/java-agent/logs/agent.log /opt/appdynamics/java-agent/logs/agent.log.$(date +%Y%m%d)
touch /opt/appdynamics/java-agent/logs/agent.log
```

## Comandos de Validación

### Validar XML de configuración
```bash
# Validar sintaxis XML
xmllint --noout /opt/appdynamics/java-agent/conf/controller-info.xml

# Validar y formatear
xmllint --format /opt/appdynamics/java-agent/conf/controller-info.xml
```

### Verificar integridad del agente
```bash
# Verificar que javaagent.jar existe y es accesible
test -f /opt/appdynamics/java-agent/javaagent.jar && echo "OK" || echo "FALTA"

# Verificar versión del agente (si está disponible)
unzip -p /opt/appdynamics/java-agent/javaagent.jar META-INF/MANIFEST.MF | grep -i version
```

## Notas

- Ajuste las rutas según su instalación específica
- Reemplace `controller.example.com` con el hostname real de su Controller
- Algunos comandos requieren permisos de administrador
- Los comandos de firewall pueden variar según la distribución de Linux
