<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="rolRequerido" value="ADMIN" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Panel de Administración - UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<%-- Consultas de métricas para el Dashboard del Administrador --%>
<sql:query var="cntUsuarios" dataSource="${conn}">
    SELECT 
        COUNT(*) AS total,
        SUM(CASE WHEN r.nombre_rol = 'ESTUDIANTE' THEN 1 ELSE 0 END) AS total_estudiantes,
        SUM(CASE WHEN r.nombre_rol = 'DIRECTOR' THEN 1 ELSE 0 END) AS total_directores,
        SUM(CASE WHEN r.nombre_rol = 'EVALUADOR' THEN 1 ELSE 0 END) AS total_evaluadores,
        SUM(CASE WHEN r.nombre_rol = 'COORDINACION' THEN 1 ELSE 0 END) AS total_coordinacion
    FROM usuarios u
    INNER JOIN roles r ON u.id_rol = r.id_rol
    WHERE u.activo = 1
</sql:query>

<sql:query var="cntProyectos" dataSource="${conn}">
    SELECT COUNT(*) AS total_proyectos FROM anteproyectos
</sql:query>

<sql:query var="ultimosUsuarios" dataSource="${conn}">
    SELECT u.id_usuario, u.codigo, u.documento, u.nombres, u.apellidos, u.correo, u.activo,
           r.nombre_rol, p.nombre_programa
    FROM usuarios u
    INNER JOIN roles r ON u.id_rol = r.id_rol
    LEFT JOIN programas p ON u.id_programa = p.id_programa
    ORDER BY u.id_usuario DESC
    LIMIT 6
</sql:query>

<div class="container-fluid px-lg-4 py-4">
    <!-- Encabezado de bienvenida -->
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <div>
            <h2 class="fw-bold mb-1 text-dark">
                <i class="bi bi-shield-lock-fill text-danger me-2"></i>Panel de Administración General
            </h2>
            <p class="text-secondary mb-0">Gestión de identidades, usuarios institucionales y supervisión global del sistema.</p>
        </div>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/admin/usuarios_formulario.jsp" class="btn btn-uts-primary shadow-sm">
                <i class="bi bi-person-plus-fill me-1"></i> Registrar Nuevo Usuario
            </a>
            <a href="${pageContext.request.contextPath}/admin/usuarios_listar.jsp" class="btn btn-outline-secondary shadow-sm">
                <i class="bi bi-people-fill me-1"></i> Directorio Completo
            </a>
        </div>
    </div>

    <!-- Tarjetas de Indicadores (KPIs) -->
    <c:set var="kpi" value="${cntUsuarios.rows[0]}" />
    <div class="row g-3 mb-4">
        <div class="col-sm-6 col-xl-3">
            <div class="kpi-card shadow-sm">
                <div class="kpi-label">Estudiantes Activos</div>
                <div class="d-flex align-items-center justify-content-between mt-2">
                    <div class="kpi-value"><c:out value="${kpi.total_estudiantes}" /></div>
                    <i class="bi bi-mortarboard fs-1 text-success opacity-75"></i>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="kpi-card kpi-card-blue shadow-sm">
                <div class="kpi-label">Docentes Directores</div>
                <div class="d-flex align-items-center justify-content-between mt-2">
                    <div class="kpi-value"><c:out value="${kpi.total_directores}" /></div>
                    <i class="bi bi-person-badge fs-1 text-primary opacity-75"></i>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="kpi-card kpi-card-gold shadow-sm">
                <div class="kpi-label">Docentes Evaluadores</div>
                <div class="d-flex align-items-center justify-content-between mt-2">
                    <div class="kpi-value"><c:out value="${kpi.total_evaluadores}" /></div>
                    <i class="bi bi-clipboard-check fs-1 text-warning opacity-75"></i>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="kpi-card kpi-card-red shadow-sm">
                <div class="kpi-label">Total Proyectos Registrados</div>
                <div class="d-flex align-items-center justify-content-between mt-2">
                    <div class="kpi-value"><c:out value="${cntProyectos.rows[0].total_proyectos}" /></div>
                    <i class="bi bi-journal-text fs-1 text-danger opacity-75"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Tabla de Últimos Usuarios Registrados -->
    <div class="row">
        <div class="col-12">
            <div class="card card-uts shadow-sm">
                <div class="card-header d-flex justify-content-between align-items-center py-3">
                    <h5 class="mb-0 fw-bold text-dark">
                        <i class="bi bi-clock-history text-secondary me-2"></i>Últimos Usuarios Registrados
                    </h5>
                    <a href="${pageContext.request.contextPath}/admin/usuarios_listar.jsp" class="btn btn-sm btn-outline-primary">
                        Ver todos los usuarios &rarr;
                    </a>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Código</th>
                                    <th>Documento</th>
                                    <th>Nombres y Apellidos</th>
                                    <th>Correo Institucional</th>
                                    <th>Rol</th>
                                    <th>Programa</th>
                                    <th>Estado</th>
                                    <th class="text-end pe-3">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="u" items="${ultimosUsuarios.rows}">
                                    <tr>
                                        <td><code><c:out value="${u.codigo}" /></code></td>
                                        <td><c:out value="${u.documento}" /></td>
                                        <td class="fw-semibold"><c:out value="${u.nombres} ${u.apellidos}" /></td>
                                        <td><c:out value="${u.correo}" /></td>
                                        <td>
                                            <span class="badge badge-rol badge-rol-${u.nombre_rol}">
                                                <c:out value="${u.nombre_rol}" />
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty u.nombre_programa}">
                                                    <small><c:out value="${u.nombre_programa}" /></small>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted fst-italic">N/A</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${u.activo}">
                                                    <span class="badge bg-success-subtle text-success border border-success-subtle">Activo</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-danger-subtle text-danger border border-danger-subtle">Inactivo</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end pe-3">
                                            <a href="${pageContext.request.contextPath}/admin/usuarios_formulario.jsp?id=${u.id_usuario}" class="btn btn-sm btn-outline-primary" title="Editar">
                                                <i class="bi bi-pencil-square"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="/includes/footer.jspf" %>
