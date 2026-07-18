# Desarrollo de una extensión para la facturación electrónica de documentos tributarios del SRI en el ERP Microsoft Dynamics 365 Business Central

---

## Descripción general

Este proyecto consiste en el desarrollo de una **extensión para Microsoft Dynamics 365 Business Central SaaS**, implementada en lenguaje **AL**, cuyo propósito es integrar el ERP con la plataforma de facturación electrónica de **GrupoMAS** mediante servicios **API REST**.

La extensión actúa como una capa de integración entre Business Central y la plataforma externa de GrupoMAS. Business Central genera los documentos tributarios, y la extensión se encarga de validar la configuración, construir la estructura XML requerida, consumir los servicios API REST, registrar la respuesta recibida, consultar el estado de los comprobantes, actualizar el documento y conservar la trazabilidad del proceso.

> **Importante:** La plataforma de GrupoMAS es un sistema externo e independiente. Esta plataforma recibe la información enviada desde Business Central, procesa los documentos electrónicos, gestiona la autorización ante el SRI del Ecuador, administra los comprobantes y realiza el envío del RIDE autorizado por correo electrónico. Estos procesos externos **no forman parte del desarrollo de este proyecto**.

---

## Objetivo

Desarrollar una extensión funcional en Microsoft Dynamics 365 Business Central SaaS que permita gestionar el proceso de facturación electrónica de documentos tributarios del SRI del Ecuador, integrando el ERP con la plataforma externa de facturación electrónica de GrupoMAS mediante servicios API REST, con el fin de mejorar la visibilidad y trazabilidad del proceso directamente desde el entorno del ERP.

---

## Alcance

### Incluido en el proyecto

| Área | Descripción |
|---|---|
| Configuración | Registro de parámetros de conexión con la plataforma GrupoMAS |
| Habilitación | Activación o desactivación de tipos de documentos tributarios |
| Construcción XML | Generación de estructuras XML por tipo de documento |
| Integración API REST | Envío y consulta de documentos mediante servicios REST |
| Registro de respuestas | Almacenamiento de respuestas del servicio externo |
| Estados | Actualización del estado del documento en Business Central |
| Trazabilidad | Registro de trazabilidad del proceso de facturación electrónica |
| Reenvío | Soporte para reenvío o reproceso en escenarios permitidos |
| Descarga XML | Recuperación de información XML cuando corresponda |

### Fuera del alcance

El proyecto **no incluye**:

- Desarrollo de una plataforma propia de facturación electrónica.
- Comunicación directa con el SRI desde Business Central.
- Administración interna de la plataforma GrupoMAS.
- Envío del RIDE (Representación Impresa del Documento Electrónico) desde Business Central.
- Modificación del proceso contable estándar de Business Central.
- Aplicación móvil.
- Migración masiva de documentos históricos.
- Integración con otros proveedores de facturación electrónica.
- Reportes fiscales avanzados.
- Gestión de pagos, gastos o conciliación bancaria.

---

## Funcionalidades principales

- Configurar parámetros de conexión con la plataforma de facturación electrónica de GrupoMAS:
  - URL de envío
  - URL de consulta
  - Token de acceso
  - Identificador de compañía
  - Identificador de contrato
- Activar o desactivar documentos tributarios para facturación electrónica.
- Construir estructuras XML según el tipo de documento tributario.
- Enviar documentos electrónicos mediante API REST.
- Consultar el estado de documentos enviados.
- Registrar respuestas del servicio externo.
- Actualizar el estado del documento dentro de Business Central.
- Registrar información de trazabilidad.
- Permitir reenvío o reproceso en escenarios permitidos.
- Descargar o recuperar información XML cuando corresponda.

---

## Documentos soportados

### Módulo de Ventas

| Documento | Descripción |
|---|---|
| Factura de venta | Comprobante de venta de bienes o servicios |
| Nota de crédito de venta | Documento de ajuste o anulación parcial de una factura |
| Guía de remisión | Documento de sustento de traslado de mercadería |

### Módulo de Compras

| Documento | Descripción |
|---|---|
| Liquidación de compra | Documento para adquisiciones a personas naturales no obligadas a llevar contabilidad |
| Retención de compra | Comprobante de retención en la fuente de impuestos |

---

## Arquitectura de la solución

La arquitectura fue diseñada siguiendo el modelo **C4 (Context, Container, Component, Code)**.

### Nivel 1 — Contexto del sistema

```
┌────────────────────────────────────────┐
│  Business Central + Extensión AL       │
│  (ERP con módulo de integración FE)    │
└──────────────────┬─────────────────────┘
                   │ API REST
                   ▼
┌────────────────────────────────────────┐
│  Plataforma GrupoMAS                   │
│  (Facturación electrónica externa)     │
└───────────┬────────────────────────────┘
            │                   │
            ▼                   ▼
     Servicios SRI       Envío RIDE al
     (Autorización)      cliente/proveedor
```

Business Central con la extensión se comunica con la plataforma de facturación electrónica de GrupoMAS. GrupoMAS gestiona la autorización ante el SRI y envía el RIDE autorizado al destinatario correspondiente.

### Nivel 2 — Contenedores

| Contenedor | Descripción |
|---|---|
| Interfaz de usuario de Business Central | Páginas y extensiones de páginas donde el usuario interactúa |
| Extensión AL de facturación electrónica | Lógica de integración desarrollada en este proyecto |
| Persistencia administrada de Business Central | Base de datos gestionada por Microsoft (tablas AL) |
| API REST de GrupoMAS | Servicios de envío y consulta de documentos electrónicos |
| Plataforma web de GrupoMAS | Sistema externo de administración y autorización |
| Servicios externos del SRI | Autorización y validación oficial de comprobantes electrónicos |

### Nivel 3 — Componentes de la extensión

| Componente | Responsabilidad |
|---|---|
| Configuración | Gestión de parámetros de conexión |
| Habilitación de documentos | Control de tipos de documentos habilitados para FE |
| Construcción XML | Generación de estructuras XML por tipo de documento |
| Cliente API REST | Consumo de servicios REST de GrupoMAS |
| Procesador de respuestas | Interpretación y registro de respuestas externas |
| Gestor de estados | Actualización del estado del documento en Business Central |
| Gestor de reenvío | Manejo de reenvío y reprocesos permitidos |
| Gestor de descarga XML | Recuperación de información XML desde el servicio externo |
| Registro de trazabilidad | Almacenamiento de eventos del proceso de FE |
| Extensiones de páginas | Integración visual en páginas estándar de Business Central |

### Nivel 4 — Modelo de entidades principales

| Entidad | Descripción |
|---|---|
| `Configuración FE` | Parámetros de conexión con la plataforma GrupoMAS |
| `Tipo Documento FE` | Tipos de documentos habilitados para facturación electrónica |
| `Transacción Documento FE` | Registro de envíos y respuestas por documento |
| `Log Trazabilidad FE` | Historial de eventos del proceso de facturación electrónica |
| `Documento Origen Business Central` | Referencia al documento estándar de Business Central (venta, compra, etc.) |

---

## Tecnologías utilizadas

| Tecnología | Uso |
|---|---|
| Microsoft Dynamics 365 Business Central SaaS | Plataforma ERP base del proyecto |
| Lenguaje AL | Lenguaje de desarrollo de extensiones para Business Central |
| Visual Studio Code | Entorno de desarrollo (IDE) |
| AL Language Extension | Extensión de VS Code para desarrollo en AL |
| Git | Control de versiones |
| Jira | Gestión de tareas y seguimiento del proyecto |
| API REST | Protocolo de integración con la plataforma GrupoMAS |
| XML | Formato de estructura de documentos tributarios electrónicos |
| Business Central Sandbox | Ambiente de pruebas y validación funcional |
| Modelo C4 | Metodología de diseño arquitectónico |

---

## Estructura del proyecto

La estructura general del repositorio sigue la organización estándar de proyectos AL para Business Central. Puede variar según la organización final del repositorio.

```
Capstone-Rodriguez/
│
├── Codeunits/                  # Lógica de negocio: construcción XML, API REST, estados, trazabilidad
├── Pages/                      # Páginas de configuración, consulta y gestión de FE
├── PageExtensions/             # Extensiones sobre páginas estándar de Business Central
├── Tables/                     # Tablas personalizadas: configuración, tipos, transacciones, logs
├── TableExtensions/            # Extensiones sobre tablas estándar de Business Central
├── Translations/               # Archivos de traducción y localización
│
├── app.json                    # Manifiesto de la extensión (nombre, versión, dependencias)
├── launch.json                 # Configuración del ambiente de publicación (Sandbox)
└── README.md                   # Documentación del proyecto
```

> Los archivos `.al` están organizados por área funcional: configuración, construcción XML, cliente API REST, documentos de ventas, documentos de compras, gestión de estados y trazabilidad.

---

## Configuración requerida

Antes de utilizar la extensión, se deben registrar los siguientes parámetros en la página de **Configuración de Facturación Electrónica** dentro de Business Central:

| Parámetro | Descripción | Ejemplo de referencia |
|---|---|---|
| URL de envío | Endpoint de la API REST para enviar documentos | `https://api.example.com/send` |
| URL de consulta | Endpoint de la API REST para consultar el estado | `https://api.example.com/status` |
| Token de acceso | Credencial de autenticación con la plataforma | `********` |
| Identificador de compañía | Código de la compañía registrada en GrupoMAS | `XXXX` |
| Identificador de contrato | Código del contrato activo en GrupoMAS | `XXXX` |
| Estado del servicio | Indicador de activación del servicio de FE | `Activo / Inactivo` |

Adicionalmente, se deben habilitar los **tipos de documentos** que serán procesados mediante facturación electrónica desde la página de configuración correspondiente.

> ⚠️ **No deben registrarse valores reales de configuración en el repositorio.** Los tokens, URLs e identificadores deben gestionarse de forma segura y privada.

---

## Instalación y publicación

Los siguientes pasos describen el proceso general para instalar y publicar la extensión en un ambiente **Business Central Sandbox**. Los comandos y configuraciones pueden variar según el ambiente y versión de Business Central.

### Pasos

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/orodriguez-dev/Capstone-Rodriguez.git
   cd Capstone-Rodriguez
   ```

2. **Abrir el proyecto en Visual Studio Code:**
   ```bash
   code .
   ```

3. **Verificar el archivo `app.json`:**
   Revisar que los campos `name`, `publisher`, `version` y `dependencies` sean correctos para el ambiente destino.

4. **Configurar el archivo `launch.json`:**
   Actualizar los campos `environmentName`, `tenant` y `authentication` con los datos del ambiente Sandbox disponible.

   ```json
   {
     "version": "0.2.0",
     "configurations": [
       {
         "type": "al",
         "request": "launch",
         "name": "Sandbox - FE",
         "environmentType": "Sandbox",
         "environmentName": "nombre-del-sandbox",
         "tenant": "id-del-tenant",
         "authentication": "UserPassword"
       }
     ]
   }
   ```

5. **Descargar símbolos de Business Central:**
   En VS Code, ejecutar el comando:
   > `AL: Download Symbols` (atajo: `Ctrl+Shift+P` → buscar "Download Symbols")

6. **Compilar la extensión:**
   > `AL: Build` o presionar `Ctrl+Shift+B`

7. **Publicar en ambiente Sandbox:**
   > `AL: Publish` o presionar `F5`

8. **Validar disponibilidad:**
   - Verificar que las páginas de configuración de Facturación Electrónica estén disponibles en Business Central.
   - Verificar que las acciones de envío y consulta sean accesibles desde los documentos correspondientes.

---

## Flujo funcional

El siguiente diagrama describe el flujo principal del proceso de facturación electrónica gestionado por la extensión:

```
[1] Usuario selecciona o registra un documento tributario en Business Central
        │
        ▼
[2] La extensión valida que exista una configuración activa
        │
        ▼
[3] La extensión verifica que el tipo de documento esté habilitado para FE
        │
        ▼
[4] Se construye la estructura XML requerida por el servicio externo
        │
        ▼
[5] La extensión consume la API REST de GrupoMAS (envío del documento)
        │
        ▼
[6] GrupoMAS procesa el documento, gestiona la autorización y opera con el SRI
    (proceso externo — fuera del alcance del proyecto)
        │
        ▼
[7] La extensión recibe y registra la respuesta del servicio externo
        │
        ▼
[8] El documento en Business Central se actualiza con el estado correspondiente
        │
        ▼
[9] El usuario puede consultar el estado y revisar la trazabilidad desde Business Central
```

---

## Pruebas

Las pruebas se realizaron en ambiente **Business Central Sandbox**, enfocadas en el escenario correcto de autorización.

| ID | Caso de prueba | Descripción |
|---|---|---|
| CP-01 | Configuración de parámetros | Registro y validación de parámetros de conexión |
| CP-02 | Activación de documentos electrónicos | Habilitación de tipos de documentos para FE |
| CP-03 | Envío de factura de venta mediante API REST | Envío del documento y recepción de respuesta |
| CP-04 | Validación por tipo de documento | Verificación de habilitación según tipo de documento |
| CP-05 | Consulta del estado de autorización | Consulta del estado de un documento enviado |
| CP-06 | Revisión de trazabilidad | Verificación del registro de eventos del proceso |
| CP-07 | Validación de acceso a parámetros de configuración | Control de acceso a la configuración de FE |
| CP-08 | Publicación y ejecución en Sandbox | Compilación, publicación y ejecución en el ambiente de pruebas |

> **Nota:** Las pruebas se enfocaron principalmente en el escenario correcto de autorización. Los escenarios de documentos no autorizados, errores tributarios específicos, caídas de servicio y reprocesos complejos quedan recomendados como trabajo futuro.

---

## Resultados

Los resultados obtenidos con el desarrollo de la extensión son:

- ✅ Extensión funcional desplegada en Business Central SaaS.
- ✅ Integración mediante servicios API REST con la plataforma externa de GrupoMAS.
- ✅ Construcción de estructuras XML para documentos tributarios de ventas y compras.
- ✅ Validación de documentos de ventas (factura, nota de crédito, guía de remisión) y de compras (liquidación, retención).
- ✅ Registro de respuesta del servicio externo y actualización del estado del documento.
- ✅ Mejora de visibilidad del proceso de facturación electrónica directamente desde el ERP.
- ✅ Registro de trazabilidad del proceso por documento.
- ✅ Compatibilidad con el modelo SaaS de Business Central, respetando las restricciones de la plataforma.
- ✅ Organización modular del código AL por componente funcional.

---

## Restricciones

| Restricción | Descripción |
|---|---|
| Plataforma SaaS | Business Central SaaS no permite acceso directo al servidor ni al sistema operativo. El desarrollo debe realizarse exclusivamente mediante extensiones AL. |
| Autorización externa | La autorización final de los comprobantes depende de la plataforma externa de GrupoMAS y de los servicios del SRI. |
| Tiempos de respuesta | El tiempo de respuesta del proceso puede verse afectado por la disponibilidad de servicios externos. |
| Credenciales | Los tokens y credenciales de conexión no deben exponerse en el repositorio. |
| Evidencias | Las capturas y evidencias del proyecto deben anonimizar datos sensibles (RUC, valores económicos, información de clientes o proveedores). |

---

## Seguridad e implicaciones éticas

El manejo de información tributaria implica responsabilidades en materia de seguridad y privacidad de datos. Se deben observar las siguientes consideraciones:

- **Protección de datos tributarios:** La información de clientes, proveedores y comprobantes debe tratarse con confidencialidad y no exponerse públicamente.
- **Confidencialidad de credenciales:** Los tokens de acceso, URLs de conexión e identificadores técnicos son credenciales sensibles. No deben subirse al repositorio bajo ninguna circunstancia.
- **Anonimización de evidencias:** Las capturas de pantalla y evidencias incluidas en la documentación deben anonimizar RUC, razones sociales, valores económicos y cualquier dato identificable.
- **Uso responsable de la trazabilidad:** Los registros de trazabilidad contienen información sobre transacciones tributarias y deben ser accesibles únicamente por usuarios autorizados.
- **No exponer datos reales:** No deben incluirse en el repositorio datos reales de clientes, proveedores, RUC, valores económicos, claves de acceso ni información sensible del entorno productivo.

---

## Advertencia de seguridad

> ⛔ **ADVERTENCIA:** Está estrictamente prohibido subir al repositorio (público o privado) cualquier tipo de información sensible, incluyendo:
>
> - Tokens de acceso o credenciales de autenticación.
> - URLs reales de endpoints de producción o pruebas internas.
> - RUC, razones sociales o datos de identificación de clientes o proveedores.
> - Valores económicos, montos o información tributaria real.
> - Capturas de pantalla con información no anonimizada.
> - Claves de acceso, contraseñas o datos de configuración de ambientes productivos.
>
> En caso de haber subido información sensible por error, se debe revocar inmediatamente la credencial expuesta, limpiar el historial del repositorio y notificar a los responsables del proyecto.

---

## Trabajo futuro

Se recomienda considerar las siguientes mejoras y extensiones del proyecto para trabajos posteriores:

- [ ] Ampliar la cobertura de pruebas con documentos no autorizados y rechazados por el SRI.
- [ ] Implementar manejo de errores tributarios específicos devueltos por GrupoMAS.
- [ ] Mejorar el manejo de caídas de servicio y estrategias de reintento.
- [ ] Automatizar pruebas funcionales y de regresión.
- [ ] Incorporar integración continua y entrega continua (CI/CD) mediante **GitHub Actions**, **Azure DevOps** o **AL-Go for GitHub**.
- [ ] Mejorar los reportes de trazabilidad con filtros avanzados y exportación.
- [ ] Agregar validaciones adicionales por tipo de documento tributario.
- [ ] Fortalecer el manejo de respuestas excepcionales y estados intermedios.
- [ ] Evaluar compatibilidad con futuras versiones de Business Central.

---

## Autor

| Campo | Detalle |
|---|---|
| **Nombre** | Oscar A. Rodríguez C. |
| **Carrera** | Ingeniería de Software |
| **Institución** | Universidad de las Américas — UDLA |
| **Proyecto** | Capstone |

---

## Licencia y uso académico

Este proyecto fue desarrollado como trabajo de titulación (Capstone) en el marco de la carrera de **Ingeniería de Software** de la **Universidad de las Américas (UDLA)**. Su uso está restringido al ámbito académico e investigativo.

Queda prohibida la reproducción total o parcial del código, la documentación o los materiales del proyecto con fines comerciales sin la autorización expresa del autor y de la institución académica correspondiente.

---

*Proyecto Capstone — Universidad de las Américas (UDLA) — Ingeniería de Software*
