<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="EVALUADOR" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Panel del Docente Evaluador - UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<%-- Métricas de evaluaciones asignadas al evaluador --%>
<sql:query var="qKpiEva" dataSource="${conn}">
    SELECT 
        COUNT(*) AS total_asignados,
        SUM(CASE WHEN a.estado = 'En revisión por evaluador' THEN 1 ELSE 0 END) AS pendientes_evaluar,
        SUM(CASE WHEN a.estado IN ('Aprobado', 'En desarrollo', 'Documento final entregado', 'Sustentado') THEN 1 ELSE 0 END) AS aprobados,
        SUM(CASE WHEN a.estado = 'Rechazado' THEN 1 ELSE 0 END) AS rechazados
    FROM anteproyectos a
    WHERE a.id_evaluador = ?
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<c:set var="kpi" value="${qKpiEva.rows[0]}" />

<%-- Proyectos que esperan calificación de este evaluador --%>
<sql:query var="qPendientesEva" dataSource="${conn}">
    SELECT a.id_anteproyecto, a.titulo, a.linea_investigacion, a.version, a.estado, a.fecha_radicacion,
           u.codigo AS cod_est, u.nombres AS nom_est, u.apellidos AS ape_est, u.correo AS correo_est,
           p.nombre_programa,
           d.nombres AS nom_dir, d.apellidos AS ape_dir
    FROM anteproyectos a
    INNER JOIN usuarios u ON a.id_estudiante = u.id_usuario
    LEFT JOIN programas p ON u.id_programa = p.id_programa
    LEFT JOIN usuarios d ON a.id_director = d.id_usuario
    WHERE a.id_evaluador = ?
      AND a.estado = 'En revisión por evaluador'
    ORDER BY a.fecha_actualizacion ASC
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<div class="container-fluid px-lg-4 py-4">
    <!-- Encabezado -->
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <div>
            <h2 class="fw-bold mb-1 text-dark">
                <i class="bi bi-clipboard-check-fill text-info me-2"></i>Panel de Evaluación y Jurado de Grado
            </h2>
            <p class="text-secondary mb-0">Bienvenido(a), <strong>Prof. <c:out value="${sessionScope.nombre_completo}" /></strong>. Dictamen técnico de anteproyectos aprobados por directores.</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/evaluador/proyectos_listar.jsp" class="btn btn-uts-primary shadow-sm">
                <i class="bi bi-card-checklist me-1"></i> Ver Todas Mis Evaluaciones
            </a>
        </div>
    </div>

    <!-- Indicadores KPIs -->
    <div class="row g-3 mb-4">
        <div class="col-sm-6 col-xl-3">
            <div class="kpi-card shadow-sm">
                <div class="kpi-label">Proyectos Asignados</div>
                <div class="d-flex align-items-center justify-content-between mt-2">
                    <div class="kpi-value"><c:out value="${kpi.total_asignados}" /></div>
                    <i class="bi bi-folder-check fs-1 text-secondary opacity-75"></i>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="kpi-card kpi-card-gold shadow-sm">
                <div class="kpi-label">Pendientes por Dictaminar</div>
                <div class="d-flex align-items-center justify-content-between mt-2">
                    <div class="kpi-value text-warning"><c:out value="${kpi.pendientes_evaluar}" /></div>
                    <i class="bi bi-hourglass-top fs-1 text-warning opacity-75"></i>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="kpi-card kpi-card-blue shadow-sm">
                <div class="kpi-label">Conceptos Favorables</div>
                <div class="d-flex align-items-center justify-content-between mt-2">
                    <div class="kpi-value text-success"><c:out value="${kpi.aprobados}" /></div>
                    <i class="bi bi-check-circle-fill fs-1 text-success opacity-75"></i>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="kpi-card kpi-card-red shadow-sm">
                <div class="kpi-label">Propuestas Rechazadas</div>
                <div class="d-flex align-items-center justify-content-between mt-2">
                    <div class="kpi-value text-danger"><c:out value="${kpi.rechazados}" /></div>
                    <i class="bi bi-x-circle-fill fs-1 text-danger opacity-75"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Proyectos en espera de dictamen del evaluador -->
    <div class="card card-uts shadow-sm">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
            <h5 class="mb-0 fw-bold text-dark">
                <i class="bi bi-inbox-fill text-primary me-2"></i>Anteproyectos Aprobados por Director en Espera de Evaluación
            </h5>
            <span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill px-3 py-2">
                <c:out value="${qPendientesEva.rowCount}" /> por dictaminar
            </span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light text-secondary">
                        <tr>
                            <th>Estudiante</th>
                            <th>Título del Anteproyecto</th>
                            <th>Director Tutor</th>
                            <th>Programa</th>
                            <th>Estado</th>
                            <th class="text-end pe-3">Acción</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${qPendientesEva.rowCount > 0}">
                                <c:forEach var="p" items="${qPendientesEva.rows}">
                                    <tr>
                                        <td>
                                            <div class="fw-bold text-dark"><c:out value="${p.nom_est} ${p.ape_est}" /></div>
                                            <small class="text-muted">Cód: <code><c:out value="${p.cod_est}" /></code></small>
                                        </td>
                                        <td>
                                            <div class="fw-semibold text-dark"><c:out value="${p.titulo}" /></div>
                                            <small class="text-muted"><i class="bi bi-tag"></i> <c:out value="${p.linea_investigacion}" /> &bull; v<c:out value="${p.version}" /></small>
                                        </td>
                                        <td>
                                            <small class="text-primary fw-semibold"><c:out value="${p.nom_dir} ${p.ape_dir}" /></small>
                                        </td>
                                        <td><small><c:out value="${p.nombre_programa}" /></small></td>
                                        <td>
                                            <span class="badge badge-estado badge-estado-en-revision-por-evaluador">
                                                En revisión por evaluador
                                            </span>
                                        </td>
                                        <td class="text-end pe-3">
                                            <a href="${pageContext.request.contextPath}/evaluador/proyecto_revisar.jsp?id=${p.id_anteproyecto}" class="btn btn-sm btn-uts-primary shadow-sm">
                                                <i class="bi bi-clipboard2-check me-1"></i> Calificar / Dictaminar
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <i class="bi bi-clipboard2-check fs-1 text-success d-block mb-2"></i>
                                        No tienes anteproyectos pendientes de dictamen en este momento.
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
