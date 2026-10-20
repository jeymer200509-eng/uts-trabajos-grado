<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="DIRECTOR" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Panel del Docente Director - UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<%-- Métricas de proyectos asignados al docente director --%>
<sql:query var="qKpiDir" dataSource="${conn}">
    SELECT 
        COUNT(*) AS total_asignados,
        SUM(CASE WHEN a.estado = 'En revisión por director' THEN 1 ELSE 0 END) AS pendientes_revision,
        SUM(CASE WHEN a.estado = 'Devuelto con observaciones' THEN 1 ELSE 0 END) AS devueltos,
        SUM(CASE WHEN a.estado IN ('Aprobado por director', 'En revisión por evaluador', 'Aprobado', 'En desarrollo', 'Documento final entregado', 'Sustentado') THEN 1 ELSE 0 END) AS aprobados,
        SUM(CASE WHEN a.estado = 'Documento final entregado' THEN 1 ELSE 0 END) AS entregas_finales
    FROM anteproyectos a
    WHERE a.id_director = ?
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<c:set var="kpi" value="${qKpiDir.rows[0]}" />

<%-- Proyectos que requieren atención inmediata del director --%>
<sql:query var="qPendientes" dataSource="${conn}">
    SELECT a.id_anteproyecto, a.titulo, a.linea_investigacion, a.version, a.estado, a.fecha_radicacion,
           u.codigo AS cod_est, u.nombres AS nom_est, u.apellidos AS ape_est, u.correo AS correo_est,
           p.nombre_programa
    FROM anteproyectos a
    INNER JOIN usuarios u ON a.id_estudiante = u.id_usuario
    LEFT JOIN programas p ON u.id_programa = p.id_programa
    WHERE a.id_director = ?
      AND a.estado IN ('En revisión por director', 'Documento final entregado')
    ORDER BY a.fecha_actualizacion ASC
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<div class="container-fluid px-lg-4 py-4">
    <!-- Bienvenida al Docente Director -->
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <div>
            <h2 class="fw-bold mb-1 text-dark">
                <i class="bi bi-person-workspace text-primary me-2"></i>Panel de Tutoría de Trabajos de Grado
            </h2>
            <p class="text-secondary mb-0">Bienvenido(a), <strong>Prof. <c:out value="${sessionScope.nombre_completo}" /></strong>. Gestione los anteproyectos de sus estudiantes tutorados.</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/director/proyectos_listar.jsp" class="btn btn-uts-primary shadow-sm">
                <i class="bi bi-folder-check me-1"></i> Ver Todos Mis Proyectos
            </a>
        </div>
    </div>

    <!-- Indicadores KPIs -->
    <div class="row g-3 mb-4">
        <div class="col-sm-6 col-xl-3">
            <div class="kpi-card shadow-sm">
                <div class="kpi-label">Proyectos Asignados</div>
                <div class="d-flex align-items-center justify-content-between mt-2">
                    <div class="kpi-value"><c:out value="${kpi.total_asignados}" /> <small class="fs-6 text-muted">/ 5 máx</small></div>
                    <i class="bi bi-folder2-open fs-1 text-primary opacity-75"></i>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="kpi-card kpi-card-gold shadow-sm">
                <div class="kpi-label">Pendientes por Revisar</div>
                <div class="d-flex align-items-center justify-content-between mt-2">
                    <div class="kpi-value text-warning"><c:out value="${kpi.pendientes_revision}" /></div>
                    <i class="bi bi-hourglass-top fs-1 text-warning opacity-75"></i>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="kpi-card kpi-card-blue shadow-sm">
                <div class="kpi-label">Propuestas Aprobadas</div>
                <div class="d-flex align-items-center justify-content-between mt-2">
                    <div class="kpi-value text-success"><c:out value="${kpi.aprobados}" /></div>
                    <i class="bi bi-patch-check fs-1 text-success opacity-75"></i>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="kpi-card kpi-card-red shadow-sm">
                <div class="kpi-label">Entregas Finales Recibidas</div>
                <div class="d-flex align-items-center justify-content-between mt-2">
                    <div class="kpi-value text-danger"><c:out value="${kpi.entregas_finales}" /></div>
                    <i class="bi bi-file-earmark-check fs-1 text-danger opacity-75"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Tabla de Proyectos que requieren acción inmediata -->
    <div class="card card-uts shadow-sm mb-4">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
            <h5 class="mb-0 fw-bold text-dark">
                <i class="bi bi-bell-fill text-warning me-2"></i>Anteproyectos y Entregas Pendientes de tu Concepto
            </h5>
            <span class="badge bg-warning-subtle text-warning border border-warning-subtle rounded-pill px-3 py-2">
                <c:out value="${qPendientes.rowCount}" /> pendiente(s)
            </span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light text-secondary">
                        <tr>
                            <th>Estudiante</th>
                            <th>Título de la Propuesta</th>
                            <th>Programa</th>
                            <th>Estado Actual</th>
                            <th>Fecha Radicación</th>
                            <th class="text-end pe-3">Acción</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${qPendientes.rowCount > 0}">
                                <c:forEach var="p" items="${qPendientes.rows}">
                                    <tr>
                                        <td>
                                            <div class="fw-bold text-dark"><c:out value="${p.nom_est} ${p.ape_est}" /></div>
                                            <small class="text-muted">Cód: <code><c:out value="${p.cod_est}" /></code></small>
                                            <div class="small text-muted"><c:out value="${p.correo_est}" /></div>
                                        </td>
                                        <td>
                                            <div class="fw-semibold text-dark"><c:out value="${p.titulo}" /></div>
                                            <small class="text-muted"><i class="bi bi-tag"></i> <c:out value="${p.linea_investigacion}" /> &bull; v<c:out value="${p.version}" /></small>
                                        </td>
                                        <td><small><c:out value="${p.nombre_programa}" /></small></td>
                                        <td>
                                            <span class="badge badge-estado badge-estado-${fn:replace(fn:toLowerCase(p.estado), ' ', '-')}">
                                                <c:out value="${p.estado}" />
                                            </span>
                                        </td>
                                        <td><small><fmt:formatDate value="${p.fecha_radicacion}" pattern="dd/MM/yyyy" /></small></td>
                                        <td class="text-end pe-3">
                                            <a href="${pageContext.request.contextPath}/director/proyecto_revisar.jsp?id=${p.id_anteproyecto}" class="btn btn-sm btn-uts-primary shadow-sm">
                                                <i class="bi bi-pencil-fill me-1"></i> Revisar / Calificar
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <i class="bi bi-check2-all fs-1 text-success d-block mb-2"></i>
                                        ¡Excelente! No tienes propuestas pendientes por calificar en este momento.
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
