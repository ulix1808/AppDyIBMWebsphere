# Índice de Documentación - AppDynamics en IBM WebSphere

Este repositorio contiene la documentación completa para la instrumentación del agente Java de AppDynamics en IBM WebSphere con Java 1.8.

## Estructura del Repositorio

```
AppDyIBMWebsphere/
├── README.md                      # Manual principal completo
├── INSTALLATION_CHECKLIST.md      # Checklist paso a paso para instalación
├── COMANDOS_UTILES.md             # Comandos útiles para administración
├── INDEX.md                       # Este archivo (índice de documentación)
├── controller-info.xml.example    # Archivo de ejemplo de configuración
├── verify-connectivity.sh         # Script de verificación de conectividad
└── .gitignore                     # Archivos a ignorar en Git
```

## Guía de Uso Rápido

### Para Instalación Nueva
1. Comience con **[README.md](README.md)** - Lea la sección de Requisitos Previos
2. Siga **[INSTALLATION_CHECKLIST.md](INSTALLATION_CHECKLIST.md)** - Marque cada paso
3. Use **[controller-info.xml.example](controller-info.xml.example)** - Como plantilla para configuración
4. Ejecute **[verify-connectivity.sh](verify-connectivity.sh)** - Antes de iniciar el servidor

### Para Troubleshooting
1. Consulte la sección **Troubleshooting** en **[README.md](README.md)**
2. Use **[COMANDOS_UTILES.md](COMANDOS_UTILES.md)** - Para comandos de diagnóstico
3. Ejecute **[verify-connectivity.sh](verify-connectivity.sh)** - Para verificar conectividad

### Para Referencia Rápida
- **[COMANDOS_UTILES.md](COMANDOS_UTILES.md)** - Comandos más utilizados
- **[controller-info.xml.example](controller-info.xml.example)** - Referencia de configuración

## Documentos Principales

### README.md
El manual completo que incluye:
- Requisitos previos
- Instrucciones de instalación paso a paso
- Configuración del agente
- Configuración en WebSphere
- **Permisos de conectividad** (sección detallada)
- Verificación
- Troubleshooting
- Referencias

### INSTALLATION_CHECKLIST.md
Checklist detallado con:
- Fases de instalación
- Items verificables
- Espacios para notas
- Sección de problemas comunes

### COMANDOS_UTILES.md
Colección de comandos para:
- Verificación de instalación
- Verificación de conectividad
- Monitoreo de logs
- Gestión de certificados SSL
- Configuración de firewall
- Troubleshooting avanzado

### controller-info.xml.example
Archivo de ejemplo con:
- Todas las opciones de configuración
- Comentarios explicativos
- Valores de ejemplo
- Configuraciones opcionales documentadas

### verify-connectivity.sh
Script automatizado que verifica:
- Herramientas necesarias instaladas
- Resolución DNS
- Conectividad de puertos
- Acceso HTTP/HTTPS al Controller
- Configuración de firewall
- Variables de entorno
- Archivo de configuración

## Flujo de Trabajo Recomendado

### 1. Preparación
```
1. Leer README.md (sección Requisitos Previos)
2. Revisar INSTALLATION_CHECKLIST.md (Fase 1)
3. Recopilar información necesaria
```

### 2. Instalación
```
1. Seguir README.md (sección Descarga e Instalación)
2. Usar controller-info.xml.example como plantilla
3. Seguir INSTALLATION_CHECKLIST.md (Fases 2-5)
```

### 3. Verificación
```
1. Ejecutar verify-connectivity.sh
2. Seguir README.md (sección Verificación)
3. Completar INSTALLATION_CHECKLIST.md (Fase 6)
```

### 4. Operación
```
1. Usar COMANDOS_UTILES.md para monitoreo diario
2. Consultar README.md (sección Troubleshooting) si hay problemas
```

## Secciones Clave por Tema

### Conectividad y Red
- **README.md**: Sección "Permisos de Conectividad" (detallada)
- **COMANDOS_UTILES.md**: Sección "Verificación de Conectividad"
- **verify-connectivity.sh**: Script automatizado

### Configuración
- **README.md**: Sección "Configuración del Agente" y "Configuración en IBM WebSphere"
- **controller-info.xml.example**: Archivo de ejemplo completo
- **INSTALLATION_CHECKLIST.md**: Fases 3 y 5

### Troubleshooting
- **README.md**: Sección "Troubleshooting" (problemas comunes)
- **COMANDOS_UTILES.md**: Sección "Troubleshooting Avanzado"
- **INSTALLATION_CHECKLIST.md**: Sección "Problemas Comunes y Soluciones"

### Verificación
- **README.md**: Sección "Verificación de la Instrumentación"
- **verify-connectivity.sh**: Script de verificación
- **INSTALLATION_CHECKLIST.md**: Fase 6

## Notas Importantes

### Seguridad
- **NO** suba archivos con información sensible a Git
- Use `.gitignore` para excluir `controller-info.xml` real
- Use `controller-info.xml.example` como plantilla
- Proteja las credenciales y access keys

### Personalización
- Ajuste las rutas según su instalación
- Modifique los valores de ejemplo según su entorno
- Adapte los scripts según su distribución de Linux

### Mantenimiento
- Actualice la documentación cuando cambie la configuración
- Revise los logs regularmente
- Mantenga los certificados SSL actualizados

## Contribuciones

Si encuentra errores o tiene mejoras:
1. Revise la documentación existente
2. Proponga cambios específicos
3. Actualice los archivos relevantes
4. Mantenga el formato y estilo consistente

## Soporte

Para problemas o preguntas:
1. Consulte la sección Troubleshooting en README.md
2. Revise los logs usando comandos en COMANDOS_UTILES.md
3. Ejecute verify-connectivity.sh para diagnóstico
4. Consulte la documentación oficial de AppDynamics

---

**Última actualización:** Ver fecha en README.md
**Versión:** 1.0
