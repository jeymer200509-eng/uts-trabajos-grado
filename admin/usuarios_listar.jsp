<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="ADMIN" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Gestión de Usuarios - Admin UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<%-- Obtener parámetros de búsqueda y filtro --%>
<c:set var="filtroRol" value="${not empty param.rol ? param.rol : ''}" />
<c:set var="filtroBuscar" value="${not empty param.buscar ? fn:trim(param.buscar) : ''}" />
<c:set var="buscarPattern" value="%${filtroBuscar}%" />

<%-- Cargar lista de roles para el selector --%>
<sql:query var="rolesQ" dataSource="${conn}">
    SELECT id_rol, nombre_rol FROM roles ORDER BY id_rol ASC
</sql:query>

<%-- Consulta parametrizada de usuarios con filtro dinámico --%>
<sql:query var="usuariosQ" dataSource="${conn}">
    SELECT u.id_usuario, u.codigo, u.documento, u.nombres, u.apellidos, u.correo, 
           u.telefono, u.semestre, u.activo, u.fecha_registro,
           r.id_rol, r.nombre_rol, p.nombre_programa
    FROM usuarios u
    INNER JOIN roles r ON u.id_rol = r.id_rol
    LEFT JOIN programas p ON u.id_programa = p.id_programa
    WHERE (? = '' OR r.nombre_rol = ?)
      AND (? = '' OR u.nombres LIKE ? OR u.apellidos LIKE ? OR u.codigo LIKE ? OR u.documento LIKE ? OR u.correo LIKE ?)
    ORDER BY r.id_rol ASC, u.apellidos ASC
    <sql:param value="${filtroRol}" />
    <sql:param value="${filtroRol}" />
    <sql:param value="${filtroBuscar}" />
    <sql:param value="${buscarPattern}" />
    <sql:param value="${buscarPattern}" />
    <sql:param value="${buscarPattern}" />
    <sql:param value="${buscarPattern}" />
    <sql:param value="${buscarPattern}" />
</sql:query>

<div class="container-fluid px-lg-4 py-4">
    <!-- Encabezado y botón nuevo -->
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <div>
            <h2 class="fw-bold mb-1 text-dark">
                <i class="bi bi-people-fill text-primary me-2"></i>Directorio General de Usuarios
            </h2>
            <p class="text-secondary mb-0">Administración integral de cuentas de estudiantes, directores, evaluadores y coordinación.</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/admin/usuarios_formulario.jsp" class="btn btn-uts-primary shadow-sm">
                <i class="bi bi-person-plus-fill me-1"></i> Registrar Nuevo Usuario
            </a>
        </div>
    </div>

    <!-- Barra de Filtros y Búsqueda -->
    <div class="card card-uts shadow-sm mb-4">
        <div class="card-body p-3">
            <form action="${pageContext.request.contextPath}/admin/usuarios_listar.jsp" method="GET" class="row g-2 align-items-center">
                <div class="col-md-5">
                    <div class="input-group">
                        <span class="input-group-text bg-light text-secondary border-end-0">
                            <i class="bi bi-search"></i>
                        </span>
                        <input type="text" name="buscar" class="form-control border-start-0" 
                               placeholder="Buscar por código, cédula, nombres o correo..." 
                               value="<c:out value='${filtroBuscar}' />">
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="input-group">
                        <label class="input-group-text bg-light text-secondary" for="selectRol">Rol:</label>
                        <select name="rol" id="selectRol" class="form-select">
                            <option value="">-- Todos los Roles --</option>
                            <c:forEach var="rolItem" items="${rolesQ.rows}">
                                <option value="${rolItem.nombre_rol}" ${filtroRol == rolItem.nombre_rol ? 'selected' : ''}>
                                    <c:out value="${rolItem.nombre_rol}" />
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="col-md-3 d-flex gap-2">
                    <button type="submit" class="btn btn-uts-secondary flex-grow-1">
                        <i class="bi bi-funnel-fill me-1"></i> Filtrar
                    </button>
                    <c:if test="${not empty filtroBuscar or not empty filtroRol}">
                        <a href="${pageContext.request.contextPath}/admin/usuarios_listar.jsp" class="btn btn-outline-secondary" title="Limpiar filtros">
                            <i class="bi bi-x-circle"></i>
                        </a>
                    </c:if>
                </div>
            </form>
        </div>
    </div>

    <!-- Tabla de Usuarios -->
    <div class="card card-uts shadow-sm">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
            <span class="fw-bold text-dark">
                Resultados encontrados: <span class="badge bg-secondary rounded-pill"><c:out value="${usuariosQ.rowCount}" /></span>
            </span>
            <small class="text-muted">Ordenado por Rol y Apellidos</small>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0" id="tablaUsuarios">
                    <thead class="table-light text-secondary">
                        <tr>
                            <th>Código</th>
                            <th>Documento</th>
                            <th>Nombres y Apellidos</th>
                            <th>Correo Institucional</th>
                            <th>Rol</th>
                            <th>Programa / Semestre</th>
                            <th class="text-center">Estado</th>
                            <th class="text-end pe-3">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${usuariosQ.rowCount > 0}">
                                <c:forEach var="u" items="${usuariosQ.rows}">
                                    <tr>
                                        <td><code><c:out value="${u.codigo}" /></code></td>
                                        <td><c:out value="${u.documento}" /></td>
                                        <td>
                                            <div class="fw-semibold text-dark"><c:out value="${u.nombres} ${u.apellidos}" /></div>
                                            <c:if test="${not empty u.telefono}">
                                                <small class="text-muted"><i class="bi bi-telephone"></i> <c:out value="${u.telefono}" /></small>
                                            </c:if>
                                        </td>
                                        <td>
                                            <a href="mailto:${u.correo}" class="text-decoration-none text-secondary">
                                                <c:out value="${u.correo}" />
                                            </a>
                                        </td>
                                        <td>
                                            <span class="badge badge-rol badge-rol-${u.nombre_rol}">
                                                <c:out value="${u.nombre_rol}" />
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty u.nombre_programa}">
                                                    <div><small class="fw-semibold"><c:out value="${u.nombre_programa}" /></small></div>
                                                    <c:if test="${not empty u.semestre}">
                                                        <small class="text-muted">Semestre: <c:out value="${u.semestre}" /></small>
                                                    </c:if>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted fst-italic">Institucional</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${u.activo}">
                                                    <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-2 py-1">
                                                        <i class="bi bi-check-circle-fill me-1"></i>Activo
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill px-2 py-1">
                                                        <i class="bi bi-x-circle-fill me-1"></i>Inactivo
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end pe-3">
                                            <div class="btn-group btn-group-sm">
                                                <a href="${pageContext.request.contextPath}/admin/usuarios_formulario.jsp?id=${u.id_usuario}" class="btn btn-outline-primary" title="Editar datos del usuario">
                                                    <i class="bi bi-pencil-square"></i>
                                                </a>
                                                <button type="button" class="btn btn-outline-warning" data-bs-toggle="modal" data-bs-target="#modalClave${u.id_usuario}" title="Restablecer contraseña">
                                                    <i class="bi bi-key-fill"></i>
                                                </button>
                                                <a href="${pageContext.request.contextPath}/admin/usuarios_eliminar.jsp?id=${u.id_usuario}&accion=toggle" 
                                                   class="btn btn-outline-${u.activo ? 'secondary' : 'success'}" 
                                                   onclick="return confirmarAccion(event, '¿Desea cambiar el estado de acceso de este usuario?');"
                                                   title="${u.activo ? 'Desactivar acceso' : 'Reactivar acceso'}">
                                                    <i class="bi bi-${u.activo ? 'person-dash' : 'person-check'}"></i>
                                                </a>
                                            </div>

                                            <!-- Modal para restablecer contraseña -->
                                            <div class="modal fade" id="modalClave${u.id_usuario}" tabindex="-1" aria-labelledby="modalLabel${u.id_usuario}" aria-hidden="true">
                                                <div class="modal-dialog modal-dialog-centered text-start">
                                                    <div class="modal-content">
                                                        <div class="modal-header bg-light">
                                                            <h6 class="modal-title fw-bold" id="modalLabel${u.id_usuario}">
                                                                <i class="bi bi-key-fill text-warning me-2"></i>Restablecer Contraseña
                                                            </h6>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                                                        </div>
                                                        <form action="${pageContext.request.contextPath}/admin/usuarios_clave.jsp" method="POST">
                                                            <div class="modal-body">
                                                                <input type="hidden" name="id_usuario" value="${u.id_usuario}">
                                                                <p class="small text-muted mb-3">
                                                                    Usuario: <strong><c:out value="${u.nombres} ${u.apellidos}" /></strong> (<c:out value="${u.correo}" />)
                                                                </p>
                                                                <div class="mb-3">
                                                                    <label class="form-label fw-semibold">Nueva Contraseña:</label>
                                                                    <input type="password" name="nueva_clave" class="form-control" required minlength="6" placeholder="Mínimo 6 caracteres">
                                                                </div>
                                                                <div class="alert alert-warning py-2 small mb-0">
                                                                    La contraseña será cifrada en la base de datos con SHA-256.
                                                                </div>
                                                            </div>
                                                            <div class="modal-footer">
                                                                <button type="button" class="btn btn-sm btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                                                <button type="submit" class="btn btn-sm btn-warning fw-semibold">Actualizar Contraseña</button>
                                                            </div>
                                                        </form>
                                                    </div>
                                                </div>
                                            </div>

                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="8" class="text-center py-5 text-muted">
                                        <i class="bi bi-people fs-1 d-block mb-2 text-secondary opacity-50"></i>
                                        No se encontraron usuarios con los criterios de búsqueda seleccionados.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<%@ include file="/includes/footer.jspf" %>
