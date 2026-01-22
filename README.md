# Manual de Instrumentación de AppDynamics en IBM WebSphere

## Tabla de Contenidos
1. [Requisitos Previos](#requisitos-previos)
2. [Descarga e Instalación del Agente](#descarga-e-instalación-del-agente)
3. [Configuración del Agente](#configuración-del-agente)
4. [Configuración en IBM WebSphere](#configuración-en-ibm-websphere)
5. [Permisos de Conectividad](#permisos-de-conectividad)
6. [Configuración del Controller](#configuración-del-controller)
7. [Verificación de la Instrumentación](#verificación-de-la-instrumentación)
8. [Troubleshooting](#troubleshooting)
9. [Referencias](#referencias)

---

## Requisitos Previos

### Software Requerido
- **IBM WebSphere Application Server** (versión 8.5 o superior)
- **Java 1.8** (JDK 8)
- **AppDynamics Java Agent** (versión compatible con Java 1.8)
- **AppDynamics Controller** accesible desde el servidor WebSphere

### Permisos del Sistema
- Acceso de administrador al servidor WebSphere
- Permisos de lectura/escritura en el sistema de archivos
- Permisos para modificar archivos de configuración de WebSphere

### Información Necesaria
Antes de comenzar, asegúrese de tener:
- URL del Controller de AppDynamics:
  - **On-Premise:** `http://controller.example.com:8090` o `https://controller.example.com:8181`
  - **SaaS:** `https://saas.appdynamics.com` (puerto 443 por defecto)
- Nombre de la aplicación en AppDynamics
- Nombre del tier
- Nombre del nodo
- Credenciales de acceso al Controller (si aplica)

---

## Descarga e Instalación del Agente

### 1. Descargar el Agente Java de AppDynamics

1. Acceda al portal de AppDynamics
2. Navegue a **Download** > **Agents** > **Java Agent**
3. Descargue la versión compatible con Java 1.8

**Nota:** Normalmente el agente se descarga en una máquina local y luego se copia al servidor donde se va a usar.

### 2. Transferir el Agente al Servidor

Si descargó el agente en una máquina local, transfiéralo al servidor WebSphere usando uno de los siguientes métodos:

#### Opción A: Usando SCP (recomendado)

```bash
# Desde su máquina local, copie el archivo ZIP al servidor
scp appdynamics-java-agent-*.zip usuario@servidor-websphere:/tmp/

# O si prefiere copiar el agente ya extraído
scp -r appdynamics-java-agent usuario@servidor-websphere:/opt/appdynamics/
```

#### Opción B: Usando SFTP

```bash
# Conectar al servidor
sftp usuario@servidor-websphere

# Dentro de SFTP, subir el archivo
put appdynamics-java-agent-*.zip /tmp/
exit
```

#### Opción C: Usando herramientas gráficas

- **WinSCP** (Windows)
- **FileZilla** (Multiplataforma)
- **Cyberduck** (Mac/Windows)

#### Opción D: Montar directorio compartido

Si tiene acceso a un directorio compartido (NFS, SMB, etc.), puede copiar el archivo directamente.

#### Opción E: Usando rsync (recomendado para directorios grandes)

```bash
# Sincronizar directorio del agente (más eficiente que scp para directorios)
rsync -avz --progress appdynamics-java-agent/ usuario@servidor-websphere:/opt/appdynamics/java-agent/
```

**Nota:** Después de transferir, verifique que el archivo llegó correctamente:
```bash
# Verificar que el archivo existe en el servidor
ssh usuario@servidor-websphere "ls -lh /tmp/appdynamics-java-agent-*.zip"

# Verificar integridad (comparar checksums)
# En máquina local:
md5sum appdynamics-java-agent-*.zip
# En servidor:
ssh usuario@servidor-websphere "md5sum /tmp/appdynamics-java-agent-*.zip"
```

### 3. Extraer el Agente en el Servidor

Una vez que el archivo esté en el servidor, extraiga el archivo ZIP en una ubicación permanente:

```bash
# Conectarse al servidor (si no está ya conectado)
ssh usuario@servidor-websphere

# Crear directorio de destino
sudo mkdir -p /opt/appdynamics

# Extraer el archivo ZIP
cd /tmp
unzip appdynamics-java-agent-*.zip -d /opt/appdynamics/

# Renombrar el directorio extraído (ajustar según el nombre del archivo)
sudo mv /opt/appdynamics/appdynamics-java-agent-* /opt/appdynamics/java-agent

# O si ya extrajo localmente y copió el directorio, verificar que esté en:
# /opt/appdynamics/java-agent

# Configurar permisos (ajustar usuario según su entorno)
# El usuario que ejecuta WebSphere debe tener acceso de lectura
sudo chown -R wasadmin:wasgroup /opt/appdynamics/java-agent
sudo chmod -R 755 /opt/appdynamics/java-agent

# Crear directorio de logs con permisos de escritura
sudo mkdir -p /opt/appdynamics/java-agent/logs
sudo chown -R wasadmin:wasgroup /opt/appdynamics/java-agent/logs
sudo chmod -R 775 /opt/appdynamics/java-agent/logs
```

**Ubicación recomendada:** `/opt/appdynamics/java-agent`

**Importante:** Asegúrese de que el usuario que ejecuta WebSphere tenga permisos de lectura en el directorio del agente y permisos de escritura en el directorio de logs.

### 4. Verificar la Estructura de Directorios

Después de la extracción, debería tener la siguiente estructura:
```
/opt/appdynamics/java-agent/
├── conf/
│   ├── controller-info.xml
│   └── logging/
├── lib/
├── ver/
└── javaagent.jar
```

---

## Configuración del Agente

### 1. Configurar controller-info.xml

Edite el archivo `conf/controller-info.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<controller-info>
    <!-- Controller Configuration -->
    <!-- On-Premise: controller.example.com | SaaS: saas.appdynamics.com -->
    <controller-host>controller.example.com</controller-host>
    <!-- On-Premise: 8090 (HTTP) o 8181 (HTTPS) | SaaS: 443 (HTTPS) -->
    <controller-port>8090</controller-port>
    <!-- On-Premise: false para HTTP, true para HTTPS | SaaS: siempre true -->
    <controller-ssl-enabled>false</controller-ssl-enabled>
    
    <!-- Application Configuration -->
    <application-name>MiAplicacion</application-name>
    <tier-name>WebSphere-Tier</tier-name>
    <node-name>WebSphere-Node-1</node-name>
    
    <!-- Account Configuration -->
    <account-name>customer1</account-name>
    <account-access-key>tu-access-key-aqui</account-access-key>
    
    <!-- Agent Configuration -->
    <agent-runtime-dir>/opt/appdynamics/java-agent</agent-runtime-dir>
    <sim-enabled>true</sim-enabled>
    
    <!-- Logging Configuration -->
    <log-dir>/opt/appdynamics/java-agent/logs</log-dir>
    <log-level>INFO</log-level>
</controller-info>
```

**Nota:** Reemplace los valores con la información de su entorno.

**Importante sobre Precedencia:** Los valores en este archivo pueden ser sobrescritos por variables de entorno o propiedades del sistema Java. Esto es útil cuando se usa el mismo agente en múltiples servidores. Vea la sección [Precedencia de Configuración](#importante-precedencia-de-configuración) para más detalles.

### 2. Configurar Propiedades del Sistema (Opcional)

Si necesita configuración adicional, cree o edite `conf/system.properties`:

```properties
# Configuración de red
appdynamics.http.proxyHost=
appdynamics.http.proxyPort=
appdynamics.http.proxyUser=
appdynamics.http.proxyPassword=

# Configuración de SSL
appdynamics.ssl.enabled=false
appdynamics.ssl.verify=false

# Configuración de instrumentación
appdynamics.instrumentation.enabled=true
appdynamics.instrumentation.methods=
```

---

## Configuración en IBM WebSphere

### Importante: Precedencia de Configuración

**Las variables de entorno y propiedades del sistema tienen precedencia sobre el archivo `controller-info.xml`.**

Esto permite usar el mismo agente de AppDynamics en múltiples servidores, cambiando solo las variables de entorno para cada servidor. El orden de precedencia es:

1. **Variables de entorno del sistema** (más alta prioridad)
2. **Propiedades del sistema Java** (`-Dappdynamics.*`)
3. **Archivo `controller-info.xml`** (menor prioridad)

#### Variables de Entorno que Sobrescriben controller-info.xml

Las siguientes variables de entorno pueden sobrescribir valores en `controller-info.xml`:

| Variable de Entorno | Sobrescribe en controller-info.xml | Uso Recomendado |
|---------------------|-----------------------------------|-----------------|
| `APPDYNAMICS_AGENT_NODE_NAME` | `<node-name>` | **Recomendado** - Identificar servidor único |
| `APPDYNAMICS_AGENT_TIER_NAME` | `<tier-name>` | **Recomendado** - Agrupar servidores similares |
| `APPDYNAMICS_AGENT_APPLICATION_NAME` | `<application-name>` | Opcional - Si todos los servidores usan la misma app |
| `APPDYNAMICS_CONTROLLER_HOST_NAME` | `<controller-host>` | Opcional - Si todos usan el mismo controller |
| `APPDYNAMICS_CONTROLLER_PORT` | `<controller-port>` | Opcional - Si todos usan el mismo puerto |
| `APPDYNAMICS_CONTROLLER_SSL_ENABLED` | `<controller-ssl-enabled>` | Opcional - Si todos usan el mismo protocolo |
| `APPDYNAMICS_AGENT_ACCOUNT_NAME` | `<account-name>` | Opcional - Si todos usan la misma cuenta |
| `APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY` | `<account-access-key>` | Opcional - Generalmente se deja en controller-info.xml |

#### Ventaja: Un Solo Agente para Múltiples Servidores

**Escenario:** Tiene 5 servidores WebSphere y quiere instrumentarlos todos con AppDynamics.

**Solución:**
1. Copie el mismo agente (con `controller-info.xml` configurado) a todos los servidores
2. Configure solo las variables de entorno específicas en cada servidor:
   - `APPDYNAMICS_AGENT_NODE_NAME` (único por servidor)
   - `APPDYNAMICS_AGENT_TIER_NAME` (puede ser el mismo para servidores similares)

**Ejemplo práctico:**

Servidor 1 (Producción):
```bash
APPDYNAMICS_AGENT_NODE_NAME=WebSphere-Prod-01
APPDYNAMICS_AGENT_TIER_NAME=WebSphere-Production
APPDYNAMICS_AGENT_APPLICATION_NAME=MiAplicacion
```

Servidor 2 (Producción):
```bash
APPDYNAMICS_AGENT_NODE_NAME=WebSphere-Prod-02
APPDYNAMICS_AGENT_TIER_NAME=WebSphere-Production
APPDYNAMICS_AGENT_APPLICATION_NAME=MiAplicacion
```

Servidor 3 (Desarrollo):
```bash
APPDYNAMICS_AGENT_NODE_NAME=WebSphere-Dev-01
APPDYNAMICS_AGENT_TIER_NAME=WebSphere-Development
APPDYNAMICS_AGENT_APPLICATION_NAME=MiAplicacion-Dev
```

Todos usan el mismo `controller-info.xml` base, pero cada uno se identifica correctamente mediante las variables de entorno.

### Opción 1: Configuración mediante Variables de Entorno (Recomendado)

#### Paso 1: Configurar Variables de Entorno en WebSphere

1. Acceda a la consola administrativa de WebSphere
2. Navegue a: **Servidores** > **Application Servers** > **[nombre-del-servidor]**
3. En la sección **Java and Process Management**, haga clic en **Process Definition**
4. Haga clic en **Environment Entries**
5. Agregue las siguientes variables (estas sobrescribirán los valores en `controller-info.xml`):

| Nombre | Valor | Descripción |
|--------|-------|-------------|
| `APPDYNAMICS_AGENT_NODE_NAME` | `WebSphere-Node-1` | **Recomendado** - Nombre único del nodo (cambiar por servidor) |
| `APPDYNAMICS_AGENT_TIER_NAME` | `WebSphere-Tier` | **Recomendado** - Nombre del tier (puede ser igual para servidores similares) |
| `APPDYNAMICS_AGENT_APPLICATION_NAME` | `MiAplicacion` | Opcional - Solo si difiere del valor en controller-info.xml |

**Nota:** Si no configura estas variables, se usarán los valores del archivo `controller-info.xml`. Configurarlas permite usar el mismo agente en múltiples servidores cambiando solo estas variables.

#### Paso 2: Configurar JVM Arguments

1. En la misma sección, haga clic en **Java Virtual Machine**
2. En el campo **Generic JVM arguments**, agregue:

```bash
-javaagent:/opt/appdynamics/java-agent/javaagent.jar
# Las siguientes propiedades sobrescriben controller-info.xml
# Solo configure las que necesite cambiar por servidor
-Dappdynamics.agent.applicationName=MiAplicacion
-Dappdynamics.agent.tierName=WebSphere-Tier
-Dappdynamics.agent.nodeName=WebSphere-Node-1
# Configuración del Controller (generalmente se deja en controller-info.xml)
-Dappdynamics.controller.hostName=controller.example.com
-Dappdynamics.controller.port=8090  # On-Premise: 8090 o 8181 | SaaS: 443
-Dappdynamics.controller.ssl.enabled=false
-Dappdynamics.agent.accountName=customer1
-Dappdynamics.agent.accountAccessKey=tu-access-key-aqui
# Configuración de rutas (generalmente se deja en controller-info.xml)
-Dappdynamics.agent.runtimeDir=/opt/appdynamics/java-agent
-Dappdynamics.agent.logging.dir=/opt/appdynamics/java-agent/logs
-Dappdynamics.agent.logging.level=INFO
```

**Nota:** Las propiedades del sistema (`-Dappdynamics.*`) también sobrescriben `controller-info.xml`. Para usar el mismo agente en múltiples servidores, configure solo las propiedades que varían por servidor (principalmente `nodeName` y `tierName`).

### Opción 2: Configuración mediante Script de Inicio

#### Crear Script de Inicio Personalizado

1. Cree un script en: `/opt/appdynamics/scripts/startAppD.sh`

```bash
#!/bin/bash
# Script de inicio para AppDynamics en WebSphere
# Este script permite usar el mismo agente en múltiples servidores
# cambiando solo las variables de entorno

# Variables que sobrescriben controller-info.xml
# IMPORTANTE: Cambiar estos valores por servidor
export APPDYNAMICS_AGENT_NODE_NAME="WebSphere-Node-1"  # Cambiar por servidor
export APPDYNAMICS_AGENT_TIER_NAME="WebSphere-Tier"    # Puede ser igual para servidores similares
export APPDYNAMICS_AGENT_APPLICATION_NAME="MiAplicacion" # Opcional si es diferente

# Agregar el agente al classpath
export JAVA_OPTS="$JAVA_OPTS -javaagent:/opt/appdynamics/java-agent/javaagent.jar"
```

2. Haga el script ejecutable:
```bash
chmod +x /opt/appdynamics/scripts/startAppD.sh
```

3. Configure WebSphere para ejecutar este script antes del inicio del servidor.

**Ventaja:** Puede copiar el mismo script a todos los servidores y solo cambiar las variables `APPDYNAMICS_AGENT_NODE_NAME` y `APPDYNAMICS_AGENT_TIER_NAME` en cada uno.

### Opción 3: Configuración mediante Archivo de Propiedades del Sistema

1. Cree un archivo `appdynamics.properties` en `/opt/appdynamics/java-agent/conf/`
2. Configure las propiedades necesarias
3. Referencie el archivo en los JVM arguments:

```bash
-Dappdynamics.config.file=/opt/appdynamics/java-agent/conf/appdynamics.properties
```

---

## Permisos de Conectividad

### Requisitos de Red

El agente de AppDynamics necesita conectividad de red desde el servidor WebSphere hacia el Controller. Asegúrese de que se cumplan los siguientes requisitos:

### 1. Puertos Requeridos

**Importante:** Los puertos requeridos dependen del tipo de instalación de AppDynamics:

#### AppDynamics On-Premise
| Puerto | Protocolo | Dirección | Descripción |
|--------|-----------|-----------|-------------|
| **8090** (HTTP) | TCP | Saliente | Comunicación con el Controller On-Premise (HTTP) |
| **8181** (HTTPS) | TCP | Saliente | Comunicación con el Controller On-Premise (HTTPS) |

#### AppDynamics SaaS (Cloud)
| Puerto | Protocolo | Dirección | Descripción |
|--------|-----------|-----------|-------------|
| **443** (HTTPS) | TCP | Saliente | Comunicación con el Controller SaaS (siempre HTTPS) |

**Nota:** Para AppDynamics SaaS, el puerto 443 es el único puerto necesario ya que todas las comunicaciones se realizan a través de HTTPS.

### 2. Configuración de Firewall

#### Reglas de Firewall Salientes

Configure las reglas de firewall para permitir tráfico saliente según su tipo de instalación:

**Para AppDynamics On-Premise:**
```bash
# Ejemplo para iptables (Linux)
iptables -A OUTPUT -p tcp --dport 8090 -j ACCEPT  # HTTP
iptables -A OUTPUT -p tcp --dport 8181 -j ACCEPT  # HTTPS

# Ejemplo para Windows Firewall
netsh advfirewall firewall add rule name="AppDynamics Controller HTTP" dir=out action=allow protocol=TCP localport=8090
netsh advfirewall firewall add rule name="AppDynamics Controller HTTPS" dir=out action=allow protocol=TCP localport=8181
```

**Para AppDynamics SaaS:**
```bash
# Ejemplo para iptables (Linux)
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT  # HTTPS (SaaS siempre usa 443)

# Ejemplo para Windows Firewall
netsh advfirewall firewall add rule name="AppDynamics Controller SaaS" dir=out action=allow protocol=TCP localport=443
```

#### Verificación de Conectividad

Antes de iniciar el agente, verifique la conectividad según su tipo de instalación:

**Para AppDynamics On-Premise:**
```bash
# Verificar conectividad HTTP (puerto 8090)
telnet controller.example.com 8090

# O usando curl
curl -v http://controller.example.com:8090/controller/rest/serverstatus

# Verificar conectividad HTTPS (puerto 8181)
openssl s_client -connect controller.example.com:8181
```

**Para AppDynamics SaaS:**
```bash
# Verificar conectividad HTTPS (puerto 443)
telnet saas.appdynamics.com 443

# O usando curl
curl -v https://saas.appdynamics.com/controller/rest/serverstatus

# Verificar conectividad SSL
openssl s_client -connect saas.appdynamics.com:443
```

### 3. Configuración de Proxy

Si el servidor WebSphere está detrás de un proxy, configure las propiedades del proxy:

#### En controller-info.xml:
```xml
<http-proxy-host>proxy.example.com</http-proxy-host>
<http-proxy-port>8080</http-proxy-port>
<http-proxy-username>usuario-proxy</http-proxy-username>
<http-proxy-password>password-proxy</http-proxy-password>
```

#### O mediante variables del sistema:
```bash
-Dappdynamics.http.proxyHost=proxy.example.com
-Dappdynamics.http.proxyPort=8080
-Dappdynamics.http.proxyUser=usuario-proxy
-Dappdynamics.http.proxyPassword=password-proxy
```

### 4. Certificados SSL/TLS

Si el Controller usa HTTPS, puede ser necesario:

#### Importar Certificados en el Keystore de Java

```bash
# Obtener el certificado del Controller
openssl s_client -connect controller.example.com:8181 -showcerts </dev/null 2>/dev/null | openssl x509 -outform PEM > controller.crt

# Importar al keystore de Java
keytool -import -alias appdynamics-controller -file controller.crt -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit
```

#### O deshabilitar verificación SSL (solo para desarrollo/testing):

```xml
<controller-ssl-enabled>true</controller-ssl-enabled>
<controller-ssl-verify-cert>false</controller-ssl-verify-cert>
```

### 5. Resolución DNS

Asegúrese de que el nombre del Controller sea resuelto correctamente:

```bash
# Verificar resolución DNS
nslookup controller.example.com
ping controller.example.com
```

Si es necesario, agregue una entrada en `/etc/hosts`:

```
192.168.1.100    controller.example.com
```

### 6. Permisos de Archivos y Directorios

Asegúrese de que el usuario que ejecuta WebSphere tenga permisos adecuados:

```bash
# Permisos de lectura en el directorio del agente
chmod -R 755 /opt/appdynamics/java-agent

# Permisos de escritura en el directorio de logs
chmod -R 775 /opt/appdynamics/java-agent/logs
chown -R wasadmin:wasgroup /opt/appdynamics/java-agent/logs
```

---

## Configuración del Controller

### 1. Verificar Acceso al Controller

1. Acceda a la consola del Controller:
   - **On-Premise:** `http://controller.example.com:8090/controller` o `https://controller.example.com:8181/controller`
   - **SaaS:** `https://saas.appdynamics.com/controller`
2. Verifique que puede iniciar sesión con las credenciales configuradas
3. Confirme que la aplicación, tier y nodo están configurados correctamente

### 2. Configurar Aplicación en el Controller

Si la aplicación no existe, créela en el Controller:

1. Navegue a **Configuration** > **App Agents**
2. Haga clic en **Create Application**
3. Ingrese el nombre de la aplicación (debe coincidir con `application-name` en `controller-info.xml`)
4. Configure el tier y nodo según corresponda

### 3. Verificar Account Access Key

1. En el Controller, navegue a **Settings** > **License**
2. Verifique el **Account Name** y **Access Key**
3. Asegúrese de que coincidan con la configuración del agente

---

## Verificación de la Instrumentación

### 1. Verificar Logs del Agente

Revise los logs del agente para confirmar la conexión exitosa:

```bash
# Ver logs en tiempo real
tail -f /opt/appdynamics/java-agent/logs/agent.log

# Buscar errores
grep -i error /opt/appdynamics/java-agent/logs/agent.log

# Buscar mensajes de conexión exitosa
grep -i "connected\|registered" /opt/appdynamics/java-agent/logs/agent.log
```

### 2. Verificar en la Consola de WebSphere

1. Acceda a la consola administrativa de WebSphere
2. Navegue a **Troubleshooting** > **Logs and Trace**
3. Revise los logs del servidor para mensajes relacionados con AppDynamics

### 4. Verificar en el Controller

1. Acceda al Controller de AppDynamics
2. Navegue a **Dashboards** > **Application Dashboard**
3. Seleccione su aplicación
4. Verifique que aparezca el nodo y tier configurados
5. Confirme que se están recibiendo métricas

### 5. Verificar Instrumentación de Aplicaciones

1. Ejecute transacciones en su aplicación
2. En el Controller, verifique que aparezcan en:
   - **Flow Maps**
   - **Transaction Snapshots**
   - **Business Transactions**

---

## Troubleshooting

### Problema: El agente no se conecta al Controller

**Síntomas:**
- Logs muestran errores de conexión
- No aparece el nodo en el Controller

**Soluciones:**
1. Verificar conectividad de red:
   ```bash
   # On-Premise
   telnet controller.example.com 8090
   # SaaS
   telnet saas.appdynamics.com 443
   ```

2. Verificar configuración en `controller-info.xml`:
   - Host y puerto correctos
   - Account name y access key válidos

3. Verificar firewall y reglas de red

4. Revisar logs detallados:
   ```bash
   tail -f /opt/appdynamics/java-agent/logs/agent.log
   ```

### Problema: El agente se inicia pero no instrumenta la aplicación

**Síntomas:**
- El agente se conecta pero no aparecen métricas

**Soluciones:**
1. Verificar que el `javaagent.jar` esté correctamente referenciado en los JVM arguments

2. Verificar permisos de archivos:
   ```bash
   ls -la /opt/appdynamics/java-agent/javaagent.jar
   ```

3. Verificar que la aplicación esté siendo ejecutada por el JVM configurado

4. Revisar configuración de instrumentación en `controller-info.xml`

### Problema: Errores de SSL/TLS

**Síntomas:**
- Errores de certificado SSL
- Conexión rechazada cuando SSL está habilitado

**Soluciones:**
1. Importar certificados al keystore de Java (ver sección de Certificados SSL/TLS)

2. O deshabilitar verificación SSL (solo para desarrollo):
   ```xml
   <controller-ssl-verify-cert>false</controller-ssl-verify-cert>
   ```

### Problema: El agente causa problemas de rendimiento

**Síntomas:**
- Aplicación más lenta después de instrumentar
- Alto uso de CPU o memoria

**Soluciones:**
1. Ajustar nivel de logging a WARN o ERROR:
   ```xml
   <log-level>WARN</log-level>
   ```

2. Deshabilitar instrumentación de métodos específicos si no son necesarios

3. Revisar configuración de sampling en el Controller

### Problema: Permisos de archivos

**Síntomas:**
- Errores de acceso denegado en logs
- El agente no puede escribir logs

**Soluciones:**
1. Verificar permisos:
   ```bash
   chmod -R 755 /opt/appdynamics/java-agent
   chmod -R 775 /opt/appdynamics/java-agent/logs
   ```

2. Verificar propietario:
   ```bash
   chown -R wasadmin:wasgroup /opt/appdynamics/java-agent
   ```

### Comandos Útiles para Diagnóstico

```bash
# Verificar que el proceso Java tiene el agente cargado
ps aux | grep javaagent

# Verificar variables de entorno
env | grep APPDYNAMICS

# Verificar conectividad
   # On-Premise
   netstat -an | grep 8090
   netstat -an | grep 8181
   # SaaS
   netstat -an | grep 443

# Verificar logs del sistema
journalctl -u websphere -f  # En sistemas con systemd
```

---

## Mejores Prácticas

### Uso del Mismo Agente en Múltiples Servidores

**Escenario común:** Tiene varios servidores WebSphere y quiere instrumentarlos todos con AppDynamics.

**Solución recomendada:**

1. **Configure `controller-info.xml` con valores comunes:**
   - Controller host y puerto
   - Account name y access key
   - Application name (si todos usan la misma)
   - Configuración de logging
   - Configuración de SSL

2. **Use variables de entorno para valores específicos por servidor:**
   - `APPDYNAMICS_AGENT_NODE_NAME` - **Siempre configurar** (único por servidor)
   - `APPDYNAMICS_AGENT_TIER_NAME` - **Recomendado** (puede agrupar servidores similares)
   - `APPDYNAMICS_AGENT_APPLICATION_NAME` - Solo si difiere entre servidores

3. **Ventajas de este enfoque:**
   - Un solo agente para copiar a todos los servidores
   - Fácil mantenimiento (actualizar controller-info.xml una vez)
   - Identificación clara de cada servidor mediante node-name
   - Agrupación lógica mediante tier-name

**Ejemplo de implementación:**

```bash
# Servidor 1 - Producción
APPDYNAMICS_AGENT_NODE_NAME=WebSphere-Prod-01
APPDYNAMICS_AGENT_TIER_NAME=WebSphere-Production

# Servidor 2 - Producción
APPDYNAMICS_AGENT_NODE_NAME=WebSphere-Prod-02
APPDYNAMICS_AGENT_TIER_NAME=WebSphere-Production

# Servidor 3 - Desarrollo
APPDYNAMICS_AGENT_NODE_NAME=WebSphere-Dev-01
APPDYNAMICS_AGENT_TIER_NAME=WebSphere-Development
```

Todos usan el mismo `controller-info.xml`, pero se identifican correctamente en AppDynamics.

### Convenciones de Nomenclatura

- **Node Name:** Use un formato descriptivo que incluya:
  - Ambiente (Prod, Dev, QA)
  - Tipo de servidor (WebSphere, JBoss, etc.)
  - Número o identificador único
  - Ejemplo: `WebSphere-Prod-01`, `WebSphere-Dev-02`

- **Tier Name:** Agrupe servidores lógicos:
  - Por ambiente: `WebSphere-Production`, `WebSphere-Development`
  - Por función: `WebSphere-Frontend`, `WebSphere-Backend`
  - Por aplicación: `MiApp-WebSphere`

- **Application Name:** Mantenga consistencia:
  - Use el mismo nombre en todos los servidores de la misma aplicación
  - Diferencie solo si realmente son aplicaciones diferentes

### Mantenimiento

- **Actualizaciones del agente:** Actualice `controller-info.xml` una vez y redistribuya
- **Cambios de configuración:** Modifique variables de entorno en WebSphere sin tocar el agente
- **Documentación:** Mantenga un registro de qué variables están configuradas en cada servidor

---

## Referencias

### Documentación Oficial
- [AppDynamics Java Agent Documentation](https://docs.appdynamics.com/)
- [IBM WebSphere Application Server Documentation](https://www.ibm.com/docs/en/was-nd)

### Archivos de Configuración Importantes
- `/opt/appdynamics/java-agent/conf/controller-info.xml` - Configuración principal
- `/opt/appdynamics/java-agent/conf/logging/log4j.xml` - Configuración de logging
- `/opt/appdynamics/java-agent/conf/system.properties` - Propiedades del sistema

### Logs Importantes
- `/opt/appdynamics/java-agent/logs/agent.log` - Log principal del agente
- `/opt/appdynamics/java-agent/logs/ver/*.log` - Logs de verificación
- Logs de WebSphere (ubicación según instalación)

### Contacto y Soporte
- Soporte de AppDynamics: [support.appdynamics.com](https://support.appdynamics.com)
- Comunidad de AppDynamics: [community.appdynamics.com](https://community.appdynamics.com)

---

## Checklist de Implementación

Use este checklist para asegurar una implementación completa:

- [ ] Agente Java de AppDynamics descargado e instalado
- [ ] `controller-info.xml` configurado correctamente
- [ ] Variables de entorno configuradas en WebSphere (si aplica)
- [ ] JVM arguments agregados en WebSphere
- [ ] Conectividad de red verificada:
  - [ ] On-Premise: puertos 8090 (HTTP) o 8181 (HTTPS)
  - [ ] SaaS: puerto 443 (HTTPS)
- [ ] Firewall configurado para permitir tráfico saliente
- [ ] Proxy configurado (si aplica)
- [ ] Certificados SSL importados (si aplica)
- [ ] Permisos de archivos y directorios configurados
- [ ] Logs del agente verificados
- [ ] Nodo visible en el Controller de AppDynamics
- [ ] Métricas recibidas en el Controller
- [ ] Transacciones instrumentadas correctamente

---

**Última actualización:** $(date)
**Versión del Manual:** 1.0
