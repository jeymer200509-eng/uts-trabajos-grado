<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="rolRequerido" value="COORDINACION" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Panel de Coordinación - Trabajos de Grado UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<%-- Métricas de Trabajos de Grado para Coordinación --%>
<sql:query var="qKpis" dataSource="${conn}">
    SELECT 
        COUNT(*) AS total_proyectos,
        SUM(CASE WHEN estado = 'Anteproyecto radicado' THEN 1 ELSE 0 END) AS pendientes_asignacion,
        SUM(CASE WHEN estado = 'En revisión por director' THEN 1 ELSE 0 END) AS en_revision_director,
        SUM(CASE WHEN estado = 'En revisión por evaluador' THEN 1 ELSE 0 END) AS en_revision_evaluador,
        SUM(CASE WHEN estado IN ('Aprobado', 'En desarrollo') THEN 1 ELSE 0 END) AS en_desarrollo,
        SUM(CASE WHEN estado = 'Documento final entregado' THEN 1 ELSE 0 END) AS entrega_final,
        SUM(CASE WHEN estado = 'Sustentado' THEN 1 ELSE 0 END) AS sustentados
    FROM anteproyectos
</sql:query>

<sql:query var="qIdeasKpi" dataSource="${conn}">
    SELECT 
        COUNT(*) AS total_ideas,
        SUM(CASE WHEN estado = 'Disponible' THEN 1 ELSE 0 END) AS ideas_disponibles,
        SUM(CASE WHEN estado = 'Asignada' THEN 1 ELSE 0 END) AS ideas_asignadas
    FROM ideas
</sql:query>

<sql:query var="qProyectosRecientes" dataSource="${conn}">
    SELECT a.id_anteproyecto, a.titulo, a.estado, a.version, a.fecha_radicacion,
           u.codigo AS codigo_estudiante, u.nombres AS nom_est, u.apellidos AS ape_est,
           d.nombres AS nom_dir, d.apellidos AS ape_dir
    FROM anteproyectos a
    INNER JOIN usuarios u ON a.id_estudiante = u.id_usuario
    LEFT JOIN usuarios d ON a.id_director = d.id_usuario
    ORDER BY a.fecha_actualizacion DESC
    LIMIT 6
</sql:query>

<div class="container-fluid px-lg-4 py-4">
    <!-- Encabezado de bienvenida -->
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <div>
            <h2 class="fw-bold mb-1 text-dark">
                <i class="bi bi-briefcase-fill text-purple me-2" style="color: #6f42c1;"></i>Panel de Coordinación de Grado
            </h2>
            <p class="text-secondary mb-0">Gestión de banco de ideas, asignación tutorial de jurados y seguimiento académico.</p>
        </div>
        <div class="d-flex flex-wrap gap-2">
            <a href="${pageContext.request.contextPath}/coordinacion/pagos_listar.jsp" class="btn btn-success shadow-sm">
                <i class="bi bi-receipt-cutoff me-1"></i> Validar Desprendibles de Pago
            </a>
            <a href="${pageContext.request.contextPath}/coordinacion/ideas_formulario.jsp" class="btn btn-uts-primary shadow-sm">
                <i class="bi bi-lightbulb-fill me-1"></i> Publicar Idea
            </a>
            <a href="${pageContext.request.contextPath}/coordinacion/asignacion_listar.jsp" class="btn btn-uts-secondary shadow-sm">
                <i class="bi bi-person-check-fill me-1"></i> Asignar Directores
            </a>
            <a href="${pageContext.request.contextPath}/coordinacion/buscador_estudiante.jsp" class="btn btn-outline-dark shadow-sm">
                <i class="bi bi-search me-1"></i> Buscar Estudiante
            </a>
        </div>
    </div>

    <!-- Indicadores Estadísticos -->
    <c:set var="kpi" value="${qKpis.rows[0]}" />
    <c:set var="kpiIdea" value="${qIdeasKpi.rows[0]}" />
    <div class="row g-3 mb-4">
        <div class="col-sm-6 col-xl-3">
            <div class="kpi-card shadow-sm">
                <div class="kpi-label">Ideas Disponibles</div>
                <div class="d-flex align-items-center justify-content-between mt-2">
                    <div class="kpi-value"><c:out value="${kpiIdea.ideas_disponibles}" /></div>
                    <i class="bi bi-lightbulb fs-1 text-success opacity-75"></i>
                </div>
                <small class="text-muted"><c:out value="${kpiIdea.total_ideas}" /> ideas en total</small>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="kpi-card kpi-card-blue shadow-sm">
                <div class="kpi-label">Pendientes de Asignación</div>
                <div class="d-flex align-items-center justify-content-between mt-2">
                    <div class="kpi-value text-primary"><c:out value="${kpi.pendientes_asignacion}" /></div>
                    <i class="bi bi-person-plus fs-1 text-primary opacity-75"></i>
                </div>
                <small class="text-muted">Requieren director o evaluador</small>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="kpi-card kpi-card-gold shadow-sm">
                <div class="kpi-label">En Revisión Activa</div>
                <div class="d-flex align-items-center justify-content-between mt-2">
                    <div class="kpi-value text-warning"><c:out value="${kpi.en_revision_director + kpi.en_revision_evaluador}" /></div>
                    <i class="bi bi-hourglass-split fs-1 text-warning opacity-75"></i>
                </div>
                <small class="text-muted">Docentes directores y evaluadores</small>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="kpi-card kpi-card-red shadow-sm">
                <div class="kpi-label">Proyectos en Desarrollo</div>
                <div class="d-flex align-items-center justify-content-between mt-2">
                    <div class="kpi-value text-success"><c:out value="${kpi.en_desarrollo}" /></div>
                    <i class="bi bi-check2-circle fs-1 text-success opacity-75"></i>
                </div>
                <small class="text-muted"><c:out value="${kpi.sustentados}" /> sustentados exitosamente</small>
            </div>
        </div>
    </div>

    <!-- Accesos Rápidos y Proyectos Recientes -->
    <div class="row g-4">
        <div class="col-lg-8">
            <div class="card card-uts shadow-sm">
                <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 fw-bold text-dark">
                        <i class="bi bi-clock-history text-primary me-2"></i>Actividad Reciente en Trabajos de Grado
                    </h5>
                    <a href="${pageContext.request.contextPath}/coordinacion/informes.jsp" class="btn btn-sm btn-outline-secondary">
                        Ver Informes Globales &rarr;
                    </a>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Estudiante</th>
                                    <th>Título del Proyecto</th>
                                    <th>Director</th>
                                    <th>Estado</th>
                                    <th class="text-end pe-3">Acción</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="p" items="${qProyectosRecientes.rows}">
                                    <tr>
                                        <td>
                                            <div class="fw-semibold text-dark"><c:out value="${p.nom_est} ${p.ape_est}" /></div>
                                            <small class="text-muted">Cód: <c:out value="${p.codigo_estudiante}" /></small>
                                        </td>
                                        <td>
                                            <span class="text-truncate d-inline-block" style="max-width: 260px;" title="<c:out value='${p.titulo}' />">
                                                <c:out value="${p.titulo}" />
                                            </span>
                                            <div><span class="badge bg-light text-secondary border">v<c:out value="${p.version}" /></span></div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty p.nom_dir}">
                                                    <small class="fw-semibold text-secondary"><c:out value="${p.nom_dir} ${p.ape_dir}" /></small>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-warning-subtle text-warning border border-warning-subtle">Sin asignar</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="badge badge-estado badge-estado-${fn:replace(fn:toLowerCase(p.estado), ' ', '-')}">
                                                <c:out value="${p.estado}" />
                                            </span>
                                        </td>
                                        <td class="text-end pe-3">
                                            <a href="${pageContext.request.contextPath}/coordinacion/buscador_estudiante.jsp?codigo=${p.codigo_estudiante}" class="btn btn-sm btn-outline-primary" title="Ver Historial Completo">
                                                <i class="bi bi-eye"></i>
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

        <div class="col-lg-4">
            <div class="card card-uts shadow-sm mb-4">
                <div class="card-header card-header-uts py-3">
                    <h6 class="mb-0 fw-bold"><i class="bi bi-tools me-2"></i>Herramientas de Coordinación</h6>
                </div>
                <div class="list-group list-group-flush">
                    <a href="${pageContext.request.contextPath}/coordinacion/pagos_listar.jsp" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center py-3">
                        <div>
                            <div class="fw-bold"><i class="bi bi-receipt-cutoff text-success me-2"></i>Validar Desprendibles de Pago</div>
                            <small class="text-muted">Aceptar o rechazar comprobantes PDF (Fase 1)</small>
                        </div>
                        <i class="bi bi-chevron-right text-muted"></i>
                    </a>
                    <a href="${pageContext.request.contextPath}/coordinacion/ideas_listar.jsp" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center py-3">
                        <div>
                            <div class="fw-bold"><i class="bi bi-lightbulb-fill text-warning me-2"></i>Banco de Ideas</div>
                            <small class="text-muted">Crear, publicar y gestionar cupos</small>
                        </div>
                        <i class="bi bi-chevron-right text-muted"></i>
                    </a>
                    <a href="${pageContext.request.contextPath}/coordinacion/asignacion_listar.jsp" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center py-3">
                        <div>
                            <div class="fw-bold"><i class="bi bi-person-check-fill text-primary me-2"></i>Asignar Directores y Evaluadores</div>
                            <small class="text-muted">Control de carga máx. 5 proyectos</small>
                        </div>
                        <i class="bi bi-chevron-right text-muted"></i>
                    </a>
                    <a href="${pageContext.request.contextPath}/coordinacion/buscador_estudiante.jsp" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center py-3">
                        <div>
                            <div class="fw-bold"><i class="bi bi-search text-success me-2"></i>Buscador con Línea de Tiempo</div>
                            <small class="text-muted">Historial completo por estudiante</small>
                        </div>
                        <i class="bi bi-chevron-right text-muted"></i>
                    </a>
                    <a href="${pageContext.request.contextPath}/coordinacion/informes.jsp" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center py-3">
                        <div>
                            <div class="fw-bold"><i class="bi bi-bar-chart-fill text-info me-2"></i>Informes Consolidados</div>
                            <small class="text-muted">Por estudiante, director y evaluador</small>
                        </div>
                        <i class="bi bi-chevron-right text-muted"></i>
                    </a>
                    <a href="${pageContext.request.contextPath}/coordinacion/calendario_gestionar.jsp" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center py-3">
                        <div>
                            <div class="fw-bold"><i class="bi bi-calendar-event text-danger me-2"></i>Calendario Académico</div>
                            <small class="text-muted">Programar fechas y sustentaciones</small>
                        </div>
                        <i class="bi bi-chevron-right text-muted"></i>
                    </a>
                    <a href="${pageContext.request.contextPath}/coordinacion/formatos_gestionar.jsp" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center py-3">
                        <div>
                            <div class="fw-bold"><i class="bi bi-folder-fill text-secondary me-2"></i>Formatos y Guías UTS</div>
                            <small class="text-muted">Administrar enlaces de descarga</small>
                        </div>
                        <i class="bi bi-chevron-right text-muted"></i>
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="/includes/footer.jspf" %>
