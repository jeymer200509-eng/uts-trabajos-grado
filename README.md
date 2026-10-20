# Sistema de Gestión y Seguimiento de Trabajos de Grado (UTS)
### Unidades Tecnológicas de Santander &bull; Proyecto de Parcial Académico Web

---

## 1. Descripción General del Proyecto
Aplicación web universitaria completa, funcional y lista para ejecutar, diseñada e implementada para la **gestión, radicación, evaluación y trazabilidad del ciclo de vida de los trabajos de grado en las Unidades Tecnológicas de Santander (UTS)**.

El sistema modela el flujo institucional completo:
`Idea seleccionada` $\rightarrow$ `Anteproyecto radicado` $\rightarrow$ `En revisión por director` $\rightarrow$ `Devuelto con observaciones` $\rightarrow$ `Aprobado por director` $\rightarrow$ `En revisión por evaluador` $\rightarrow$ `Aprobado` (o `Rechazado`) $\rightarrow$ `En desarrollo` $\rightarrow$ `Documento final entregado` $\rightarrow$ `Sustentado`.

---

## 2. Cumplimiento Estricto de Restricciones Obligatorias
Este proyecto fue desarrollado bajo especificaciones académicas rigurosas:
1. **Cero archivos `.java`**: No se utilizaron Servlets, Beans, DAOs, Filters ni Listeners en el proyecto.
2. **Cero Scriptlets**: No se emplea `<% %>`, `<%= %>` ni `<%! %>`. Toda la lógica de control, iteración, presentación y acceso a base de datos se implementa con **JSTL 1.2** y **Expression Language (EL: `${}`)**.
3. **Librerías JSTL obligatorias**:
   - `core` (`c:`): `c:if`, `c:choose`, `c:when`, `c:otherwise`, `c:forEach`, `c:set`, `c:remove`, `c:redirect`, `c:out`.
   - `sql` (`sql:`): `sql:setDataSource`, `sql:query`, `sql:update`, `sql:param`.
   - `fmt` (`fmt:`): `fmt:formatDate`, `fmt:formatNumber`, `fmt:requestEncoding`.
   - `fn` (`fn:`): `fn:trim`, `fn:length`, `fn:contains`, `fn:toLowerCase`, `fn:replace`.
4. **Consultas 100% Parametrizadas**: Toda interacción con datos ingresados por usuarios utiliza `<sql:param>` para mitigar vulnerabilidades de Inyección SQL (SQLi).
5. **Seguridad XSS**: Todas las salidas de variables dinámicas utilizan `<c:out>` con escape automático de caracteres HTML/JS.
6. **Cifrado de Contraseñas**: Las contraseñas se almacenan y verifican con hash criptográfico unidireccional `SHA2(?, 256)` directamente en el motor de base de datos MySQL.

---

## 3. Justificación Técnica: Registro de Documentos por Enlace URL (Nube)
En aplicaciones Java tradicionales, la carga física de archivos binarios al servidor requiere cabeceras HTTP `multipart/form-data`, las cuales demandan anotaciones `@MultipartConfig` o clases auxiliares como `Apache Commons FileUpload` con Servlets Java. 

Dado que **el proyecto prohíbe taxativamente la creación de Servlets o cualquier clase `.java`**, y la especificación estándar JSTL no puede procesar corrientes binarias de archivos, se adoptó la decisión arquitectural de **registrar el enlace permanente al documento digital (Google Drive, OneDrive institucional o Dropbox) en campos URL validados**. Esto permite:
- Respetar al 100% la restricción de cero clases Java.
- Aprovechar el almacenamiento en la nube institucional de los estudiantes UTS.
- Garantizar versionamiento de documentos (v1.0, v1.1, etc.) y acceso inmediato para directores y evaluadores sin saturar el almacenamiento del servidor Tomcat.

---

## 4. Estructura del Proyecto

```
c:\xampp\tomcat\webapps\ParcialSegundoCorte/
├── index.jsp                           # Enrutador inteligente según sesión y rol
├── login.jsp                           # Formulario de inicio de sesión con branding UTS
├── login_procesar.jsp                  # Autenticación parametrizada con SHA2(?, 256)
├── logout.jsp                          # Cierre de sesión y limpieza de atributos con c:remove
├── includes/
│   ├── conexion.jspf                   # Fuente de datos centralizada con <sql:setDataSource>
│   ├── seguridad.jspf                  # Validación declarativa de sesión y roles permitidos
│   ├── header.jspf                     # Cabecera HTML5, CDN Bootstrap 5.3 y Bootstrap Icons
│   ├── navbar.jspf                     # Menú superior dinámico por rol y render de mensajes flash
│   └── footer.jspf                     # Pie de página institucional y carga de JavaScript
├── admin/
│   ├── index.jsp                       # Dashboard del Administrador con KPIs del sistema
│   ├── usuarios_listar.jsp             # Directorio de usuarios con buscador y filtro por rol
│   ├── usuarios_formulario.jsp         # Formulario adaptable según el tipo de rol
│   ├── usuarios_guardar.jsp            # Procesador INSERT/UPDATE con validación de duplicados
│   ├── usuarios_eliminar.jsp           # Alternador de estado activo/inactivo de cuentas
│   └── usuarios_clave.jsp              # Restablecimiento de contraseña con SHA2
├── coordinacion/
│   ├── index.jsp                       # Dashboard con métricas globales del proceso de grado
│   ├── ideas_listar.jsp                # CRUD del Banco de Ideas institucionales
│   ├── ideas_formulario.jsp            # Creación y edición de propuestas de investigación
│   ├── ideas_guardar.jsp               # Procesador de ideas con validación de cupos
│   ├── ideas_eliminar.jsp              # Eliminación con verificación de integridad
│   ├── asignacion_listar.jsp           # Asignación de directores y evaluadores
│   ├── asignacion_guardar.jsp          # Regla: máximo 5 proyectos activos por director
│   ├── buscador_estudiante.jsp         # Búsqueda por código/nombre + línea de tiempo completa
│   ├── informes.jsp                    # Reportes con GROUP BY (estados, directores, jurados)
│   ├── calendario_gestionar.jsp        # CRUD del cronograma académico
│   ├── calendario_guardar.jsp          # Guardado y eliminación de hitos
│   ├── formatos_gestionar.jsp          # CRUD de formatos y guías SIG UTS (F-DC)
│   └── formatos_guardar.jsp            # Publicación de formatos oficiales
├── estudiante/
│   ├── index.jsp                       # Dashboard del Estudiante con tarjeta de proyecto y próximos pasos
│   ├── banco_ideas.jsp                 # Catálogo de ideas disponibles para seleccionar
│   ├── idea_seleccionar.jsp            # Postulación e inicio de anteproyecto (Idea seleccionada)
│   ├── anteproyecto_ver.jsp            # Vista completa con tutores asignados y calificaciones
│   ├── anteproyecto_formulario.jsp     # Radicación o edición de anteproyecto con enlace en nube
│   ├── anteproyecto_guardar.jsp        # Procesador de radicación con validación de unicidad
│   ├── anteproyecto_eliminar.jsp       # Anulación permitida solo en etapa inicial
│   ├── informe_calificaciones.jsp      # Informe de notas 0.0 - 5.0 y observaciones docentes
│   ├── entrega_final.jsp               # Formulario de radicación del documento final / monografía
│   └── entrega_final_guardar.jsp       # Cambio de estado a 'Documento final entregado'
├── director/
│   ├── index.jsp                       # Dashboard con contador de revisiones pendientes
│   ├── proyectos_listar.jsp            # Listado de estudiantes tutorados con datos académicos
│   ├── proyecto_revisar.jsp            # Revisión de anteproyecto o entrega final
│   └── proyecto_calificar.jsp          # Calificación (0.0-5.0), concepto (Aprobar/Devolver)
├── evaluador/
│   ├── index.jsp                       # Dashboard con proyectos por dictaminar
│   ├── proyectos_listar.jsp            # Listado de anteproyectos aprobados por director
│   ├── proyecto_revisar.jsp            # Evaluación técnica con revisión de nota del director
│   └── proyecto_calificar.jsp          # Dictamen (Aprobar/Rechazar) y notificación visual
├── comun/
│   ├── calendario.jsp                  # Consulta general del calendario de grado
│   └── formatos.jsp                    # Consulta y descarga de formatos institucionales F-DC
├── css/
│   └── estilos.css                     # Paleta institucional UTS (#006633 y #003366) y badges
├── js/
│   └── validaciones.js                 # Confirmaciones, filtros dinámicos de tablas y validaciones
├── WEB-INF/
│   ├── web.xml                         # Configuración del contenedor Servlet 4.0
│   └── lib/
│       ├── taglibs-standard-impl-1.2.5.jar
│       ├── taglibs-standard-spec-1.2.5.jar
│       └── mysql-connector-j-8.3.0.jar
├── sql/
│   └── schema.sql                      # Base de datos, tablas, constraints y datos de prueba
└── README.md                           # Documentación completa y guía de sustentación
```

---

## 5. Requisitos y Dependencias

### Servidor y Base de Datos
- **XAMPP para Windows** (con módulos Apache y MySQL activos).
- **Apache Tomcat 9.0.x** (compatible con el espacio de nombres `javax.servlet`).
- **MySQL 5.7+ o MariaDB 10.4+** en el puerto por defecto `3306`.
- **JDK / JRE 8 o superior**.

### Librerías JAR en `WEB-INF/lib/`
El proyecto ya cuenta con las librerías ubicadas en `WEB-INF/lib/`:
1. `taglibs-standard-impl-1.2.5.jar` (Implementación de JSTL 1.2 por Apache Tomcat)
2. `taglibs-standard-spec-1.2.5.jar` (Especificación API de JSTL 1.2)
3. `mysql-connector-j-8.3.0.jar` (Driver JDBC oficial de MySQL)

*Enlaces de descarga oficial si se requiere reinstalación:*
- **JSTL 1.2**: [Apache Tomcat Taglibs Downloads](https://tomcat.apache.org/taglibs/standard/) o Maven Central (`org.apache.taglibs:taglibs-standard-impl:1.2.5` y `taglibs-standard-spec:1.2.5`).
- **MySQL Connector/J**: [MySQL Downloads Connector/J](https://dev.mysql.com/downloads/connector/j/) o Maven Central (`com.mysql:mysql-connector-j:8.3.0`).

---

## 6. Pasos para Correr y Desplegar el Proyecto

### Paso 1: Iniciar MySQL en XAMPP
1. Abra el **Panel de Control de XAMPP**.
2. Presione el botón **Start** en el módulo **MySQL** (verifique que esté en verde en el puerto 3306).

### Paso 2: Importar la Base de Datos
1. Ingrese a [phpMyAdmin](http://localhost/phpmyadmin) o abra una consola de comandos en `c:\xampp\mysql\bin`.
2. Ejecute el script `schema.sql`:
   ```bash
   c:\xampp\mysql\bin\mysql.exe -u root -p < c:\xampp\tomcat\webapps\ParcialSegundoCorte\sql\schema.sql
   ```
   *(Si el usuario root no tiene contraseña en XAMPP, simplemente presione Enter).*
3. Se creará automáticamente la base de datos `uts_trabajos_grado` con todas las tablas, restricciones y datos de prueba.

### Paso 3: Iniciar Apache Tomcat
1. En el **Panel de Control de XAMPP**, presione **Start** en el módulo **Tomcat**, o ejecute:
   ```bash
   c:\xampp\tomcat\bin\startup.bat
   ```
2. Dado que el proyecto reside en `c:\xampp\tomcat\webapps\ParcialSegundoCorte`, Tomcat lo desplegará de inmediato bajo el context path `/ParcialSegundoCorte`.

### Paso 4: Acceder a la Aplicación
Abra cualquier navegador web e ingrese a:
👉 **`http://localhost:8080/ParcialSegundoCorte/`**

---

## 7. Usuarios y Credenciales de Prueba

Todas las contraseñas están almacenadas con hash seguro `SHA-256`. Para facilidad de evaluación durante el parcial, se cuenta con cuentas de prueba listas:

| Rol Institucional | Nombre Completo | Correo / Usuario | Código | Contraseña |
| :--- | :--- | :--- | :--- | :--- |
| **Administrador** | Super Administrador | `admin@uts.edu.co` | `ADM001` | `admin123` |
| **Coordinación** | Héctor González Parra | `coordinacion@uts.edu.co` | `CRD001` | `coord123` |
| **Director 1** | Carlos Eduardo Pérez | `director1@uts.edu.co` | `DIR001` | `docente123` |
| **Director 2** | María Jimena Gómez | `director2@uts.edu.co` | `DIR002` | `docente123` |
| **Evaluador 1** | Juan Camilo Rodríguez | `evaluador1@uts.edu.co` | `EVA001` | `eval123` |
| **Evaluador 2** | Laura Marcela Mendoza | `evaluador2@uts.edu.co` | `EVA002` | `eval123` |
| **Estudiante 1** | Andrés Felipe Torres | `estudiante1@uts.edu.co` | `1098765432` | `est123` |
| **Estudiante 2** | Valentina Castro | `estudiante2@uts.edu.co` | `1098765433` | `est123` |
| **Estudiante 3** | Camilo Andrés Silva | `estudiante3@uts.edu.co` | `1098765434` | `est123` |
| **Estudiante 4** | Daniela Sofía Ramírez | `estudiante4@uts.edu.co` | `1098765435` | `est123` |

---

## 8. Checklist de Pruebas Manuales del Software (Casos de Éxito y Fallo)

### Módulo Autenticación y Seguridad
- [x] **CP-01 (Éxito)**: Login con correo institucional (`admin@uts.edu.co`) y contraseña correcta $\rightarrow$ Accede a su dashboard.
- [x] **CP-02 (Éxito)**: Login alternativo con código numérico (`1098765432`) $\rightarrow$ Accede como estudiante.
- [x] **CP-03 (Fallo)**: Login con contraseña incorrecta $\rightarrow$ Alerta flash de error "Credenciales inválidas" sin revelar estructura.
- [x] **CP-04 (Fallo)**: Intentar acceder directamente por URL a `/admin/index.jsp` sin sesión activa $\rightarrow$ Redirección forzosa a `/login.jsp`.
- [x] **CP-05 (Fallo)**: Estudiante intentando acceder a `/coordinacion/ideas_listar.jsp` $\rightarrow$ Bloqueado y redirigido a `/index.jsp` por `seguridad.jspf`.

### Módulo Administrador ("CREA USUARIOS")
- [x] **CP-06 (Éxito)**: Registrar nuevo docente evaluador con código `EVA003` $\rightarrow$ Creado correctamente con clave encriptada SHA-256.
- [x] **CP-07 (Fallo)**: Intentar registrar un usuario con un correo o código ya existente $\rightarrow$ Mensaje flash de duplicado.
- [x] **CP-08 (Éxito)**: Filtrar directorio de usuarios por rol "ESTUDIANTE" $\rightarrow$ Lista únicamente alumnos.
- [x] **CP-09 (Éxito)**: Restablecer contraseña de un usuario mediante el modal $\rightarrow$ Se actualiza el hash `SHA2(?, 256)`.
- [x] **CP-10 (Éxito)**: Alternar estado de activación (Activar/Desactivar) $\rightarrow$ Usuario inactivo no puede iniciar sesión.

### Módulo Coordinación
- [x] **CP-11 (Éxito)**: Publicar una nueva idea en el Banco de Proyectos con 2 cupos $\rightarrow$ Visible para los estudiantes.
- [x] **CP-12 (Éxito)**: Asignar Director y Evaluador a un anteproyecto radicado $\rightarrow$ Estado avanza a "En revisión por director".
- [x] **CP-13 (Fallo)**: Intentar asignar un director que ya tiene 5 proyectos activos $\rightarrow$ Validación bloquea la asignación por exceso de carga.
- [x] **CP-14 (Éxito)**: Buscar estudiante por código `1098765433` $\rightarrow$ Despliega ficha técnica completa y línea de tiempo histórica de estados.
- [x] **CP-15 (Éxito)**: Consultar informe con `GROUP BY` de directores $\rightarrow$ Muestra totales por estado y promedios.

### Módulo Estudiante
- [x] **CP-16 (Éxito)**: Estudiante sin proyecto selecciona idea del banco $\rightarrow$ Pasa a estado "Idea seleccionada" y reserva cupo.
- [x] **CP-17 (Fallo)**: Estudiante con proyecto activo intenta seleccionar otra idea $\rightarrow$ Alerta de restricción institucional UTS (máx. 1 proyecto).
- [x] **CP-18 (Éxito)**: Radicar propuesta con URL de Google Drive $\rightarrow$ Proyecto queda en "Anteproyecto radicado".
- [x] **CP-19 (Éxito)**: Consultar informe de calificaciones $\rightarrow$ Muestra desglose de notas 0.0 - 5.0 y observaciones docentes.
- [x] **CP-20 (Éxito)**: Radicar entrega final del documento (monografía) $\rightarrow$ Estado avanza a "Documento final entregado".

### Módulo Director
- [x] **CP-21 (Éxito)**: Director ingresa y visualiza estudiantes asignados con su información académica.
- [x] **CP-22 (Éxito)**: Calificar anteproyecto con nota 4.2 y concepto "Aprobado" $\rightarrow$ Estado avanza a "En revisión por evaluador".
- [x] **CP-23 (Éxito)**: Calificar anteproyecto con concepto "Devuelto con observaciones" $\rightarrow$ Estado pasa a "Devuelto con observaciones" y estudiante puede editar.

### Módulo Evaluador
- [x] **CP-24 (Éxito)**: Evaluador visualiza únicamente proyectos aprobados por el director tutor.
- [x] **CP-25 (Éxito)**: Calificar con nota 4.5 y concepto "Aprobado" $\rightarrow$ Proyecto pasa a "En desarrollo" y genera notificación de aprobación.
- [x] **CP-26 (Éxito)**: Calificar con concepto "Rechazado" $\rightarrow$ Estado pasa a "Rechazado".

---

## 9. Arquitectura Interna y Pautas para Sustentación Oral

1. **¿Dónde reside la conexión a base de datos?**
   - En `/includes/conexion.jspf`. Utiliza `<sql:setDataSource>` almacenado en `scope="application"`, evitando reabrir fuentes de datos en cada petición y optimizando el pool de conexiones.
2. **¿Cómo se previene SQL Injection sin DAOs Java?**
   - El estándar JSTL provee la etiqueta `<sql:param value="${...}" />`, la cual sustituye los signos de interrogación `?` mediante un `PreparedStatement` nativo de JDBC, neutralizando cualquier intento de inyección.
3. **¿Cómo se implementa la seguridad y autorización sin Servlets/Filters?**
   - En `/includes/seguridad.jspf`. Cada vista declara `<c:set var="rolRequerido" value="DIRECTOR" />` y luego incluye el archivo. Si la sesión no existe o el rol no coincide (`fn:contains`), JSTL ejecuta `<c:redirect url="/login.jsp" />`.
4. **¿Cómo funcionan los mensajes Flash?**
   - La acción de procesamiento guarda el mensaje en `sessionScope` (ej. `mensaje_exito`). El fragmento reutilizable `navbar.jspf` lo lee con `<c:if>`, lo muestra en un banner Bootstrap y lo purga inmediatamente con `<c:remove>`.
