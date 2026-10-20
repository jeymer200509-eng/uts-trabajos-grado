<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="COORDINACION" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Informes Estadísticos - Coordinación UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<%-- 1. Consulta GROUP BY para informe por Estado --%>
<sql:query var="qPorEstado" dataSource="${conn}">
    SELECT a.estado, COUNT(*) AS cantidad
    FROM anteproyectos a
    GROUP BY a.estado
    ORDER BY cantidad DESC
</sql:query>

<%-- 2. Consulta GROUP BY para informe por Director --%>
<sql:query var="qPorDirector" dataSource="${conn}">
    SELECT d.id_usuario, d.codigo, d.nombres, d.apellidos, d.correo,
           COUNT(a.id_anteproyecto) AS total_dirigidos,
           SUM(CASE WHEN a.estado = 'En revisión por director' THEN 1 ELSE 0 END) AS en_revision,
           SUM(CASE WHEN a.estado IN ('Aprobado por director', 'En revisión por evaluador', 'Aprobado', 'En desarrollo', 'Documento final entregado', 'Sustentado') THEN 1 ELSE 0 END) AS aprobados,
           SUM(CASE WHEN a.estado = 'Devuelto con observaciones' THEN 1 ELSE 0 END) AS devueltos,
           AVG(c.nota) AS promedio_notas
    FROM usuarios d
    INNER JOIN roles r ON d.id_rol = r.id_rol AND r.nombre_rol = 'DIRECTOR'
    LEFT JOIN anteproyectos a ON d.id_usuario = a.id_director
    LEFT JOIN calificaciones c ON a.id_anteproyecto = c.id_anteproyecto AND c.id_docente = d.id_usuario
    WHERE d.activo = 1
    GROUP BY d.id_usuario, d.codigo, d.nombres, d.apellidos, d.correo
    ORDER BY total_dirigidos DESC, d.apellidos ASC
</sql:query>

<%-- 3. Consulta GROUP BY para informe por Evaluador --%>
<sql:query var="qPorEvaluador" dataSource="${conn}">
    SELECT e.id_usuario, e.codigo, e.nombres, e.apellidos, e.correo,
           COUNT(a.id_anteproyecto) AS total_asignados,
           SUM(CASE WHEN a.estado = 'En revisión por evaluador' THEN 1 ELSE 0 END) AS pendientes_evaluar,
           SUM(CASE WHEN a.estado IN ('Aprobado', 'En desarrollo', 'Documento final entregado', 'Sustentado') THEN 1 ELSE 0 END) AS aprobados,
           SUM(CASE WHEN a.estado = 'Rechazado' THEN 1 ELSE 0 END) AS rechazados,
           AVG(c.nota) AS promedio_notas
    FROM usuarios e
    INNER JOIN roles r ON e.id_rol = r.id_rol AND r.nombre_rol = 'EVALUADOR'
    LEFT JOIN anteproyectos a ON e.id_usuario = a.id_evaluador
    LEFT JOIN calificaciones c ON a.id_anteproyecto = c.id_anteproyecto AND c.id_docente = e.id_usuario
    WHERE e.activo = 1
    GROUP BY e.id_usuario, e.codigo, e.nombres, e.apellidos, e.correo
    ORDER BY total_asignados DESC, e.apellidos ASC
</sql:query>

<%-- 4. Consulta detallada para informe por Estudiante --%>
<sql:query var="qPorEstudiante" dataSource="${conn}">
    SELECT u.codigo AS cod_est, u.nombres AS nom_est, u.apellidos AS ape_est, u.semestre,
           p.nombre_programa,
           a.titulo, a.estado, a.version, a.fecha_radicacion,
           d.nombres AS nom_dir, d.apellidos AS ape_dir,
           ev.nombres AS nom_eva, ev.apellidos AS ape_eva,
           (SELECT MAX(c.nota) FROM calificaciones c WHERE c.id_anteproyecto = a.id_anteproyecto) AS ultima_nota
    FROM usuarios u
    INNER JOIN roles r ON u.id_rol = r.id_rol AND r.nombre_rol = 'ESTUDIANTE'
    LEFT JOIN programas p ON u.id_programa = p.id_programa
    LEFT JOIN anteproyectos a ON u.id_usuario = a.id_estudiante
    LEFT JOIN usuarios d ON a.id_director = d.id_usuario
    LEFT JOIN usuarios ev ON a.id_evaluador = ev.id_usuario
    WHERE u.activo = 1
    ORDER BY p.nombre_programa ASC, u.apellidos ASC
</sql:query>

<div class="container-fluid px-lg-4 py-4">
    <!-- Encabezado -->
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <div>
            <h2 class="fw-bold mb-1 text-dark">
                <i class="bi bi-bar-chart-fill text-primary me-2"></i>Informes Consolidados de Trabajos de Grado
            </h2>
            <p class="text-secondary mb-0">Métricas analíticas agrupadas por Estado, Directores de Proyecto, Evaluadores y Estudiantes.</p>
        </div>
        <div>
            <button onclick="window.print();" class="btn btn-outline-secondary shadow-sm">
                <i class="bi bi-printer-fill me-1"></i> Imprimir Reporte
            </button>
        </div>
    </div>

    <!-- Pestañas de Navegación de Informes -->
    <ul class="nav nav-pills mb-4" id="pills-tab" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active fw-semibold" id="pills-estados-tab" data-bs-toggle="pill" data-bs-target="#pills-estados" type="button" role="tab">
                <i class="bi bi-pie-chart-fill me-1"></i> Por Estados
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link fw-semibold" id="pills-directores-tab" data-bs-toggle="pill" data-bs-target="#pills-directores" type="button" role="tab">
                <i class="bi bi-person-badge-fill me-1"></i> Por Docente Director
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link fw-semibold" id="pills-evaluadores-tab" data-bs-toggle="pill" data-bs-target="#pills-evaluadores" type="button" role="tab">
                <i class="bi bi-clipboard-check-fill me-1"></i> Por Docente Evaluador
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link fw-semibold" id="pills-estudiantes-tab" data-bs-toggle="pill" data-bs-target="#pills-estudiantes" type="button" role="tab">
                <i class="bi bi-mortarboard-fill me-1"></i> Por Estudiante
            </button>
        </li>
    </ul>

    <div class="tab-content" id="pills-tabContent">
        <!-- 1. Pestaña: Por Estados -->
        <div class="tab-pane fade show active" id="pills-estados" role="tabpanel">
            <div class="card card-uts shadow-sm">
                <div class="card-header bg-white py-3">
                    <h5 class="mb-0 fw-bold text-dark"><i class="bi bi-pie-chart text-success me-2"></i>Distribución de Proyectos por Estado del Ciclo de Vida</h5>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Estado del Proyecto</th>
                                    <th class="text-center">Cantidad de Proyectos</th>
                                    <th>Representación Visual</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="estRow" items="${qPorEstado.rows}">
                                    <tr>
                                        <td>
                                            <span class="badge badge-estado badge-estado-${fn:replace(fn:toLowerCase(estRow.estado), ' ', '-')} fs-6">
                                                <c:out value="${estRow.estado}" />
                                            </span>
                                        </td>
                                        <td class="text-center fw-bold fs-5">
                                            <c:out value="${estRow.cantidad}" />
                                        </td>
                                        <td class="w-50">
                                            <div class="progress" style="height: 14px;">
                                                <div class="progress-bar bg-success" role="progressbar" style="width: ${estRow.cantidad * 25}%"></div>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- 2. Pestaña: Por Director -->
        <div class="tab-pane fade" id="pills-directores" role="tabpanel">
            <div class="card card-uts shadow-sm">
                <div class="card-header bg-white py-3">
                    <h5 class="mb-0 fw-bold text-dark"><i class="bi bi-person-badge text-primary me-2"></i>Carga Académica y Desempeño por Docente Director</h5>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light text-secondary">
                                <tr>
                                    <th>Docente Director</th>
                                    <th>Código / Correo</th>
                                    <th class="text-center">Total Dirigidos</th>
                                    <th class="text-center">En Revisión</th>
                                    <th class="text-center">Aprobados</th>
                                    <th class="text-center">Devueltos</th>
                                    <th class="text-center">Promedio Calificaciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="dir" items="${qPorDirector.rows}">
                                    <tr>
                                        <td class="fw-bold text-dark"><c:out value="${dir.nombres} ${dir.apellidos}" /></td>
                                        <td>
                                            <code><c:out value="${dir.codigo}" /></code>
                                            <div class="small text-muted"><c:out value="${dir.correo}" /></div>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge ${dir.total_dirigidos >= 5 ? 'bg-danger' : 'bg-primary'} rounded-pill px-3 py-2 fs-6">
                                                <c:out value="${dir.total_dirigidos}" /> / 5
                                            </span>
                                        </td>
                                        <td class="text-center text-warning fw-semibold"><c:out value="${dir.en_revision}" /></td>
                                        <td class="text-center text-success fw-semibold"><c:out value="${dir.aprobados}" /></td>
                                        <td class="text-center text-danger fw-semibold"><c:out value="${dir.devueltos}" /></td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${not empty dir.promedio_notas}">
                                                    <span class="badge ${dir.promedio_notas >= 3.0 ? 'bg-success' : 'bg-danger'}">
                                                        <fmt:formatNumber value="${dir.promedio_notas}" pattern="0.0" />
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted small">Sin notas</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- 3. Pestaña: Por Evaluador -->
        <div class="tab-pane fade" id="pills-evaluadores" role="tabpanel">
            <div class="card card-uts shadow-sm">
                <div class="card-header bg-white py-3">
                    <h5 class="mb-0 fw-bold text-dark"><i class="bi bi-clipboard-check text-info me-2"></i>Evaluaciones Asignadas y Conceptos Emitidos</h5>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light text-secondary">
                                <tr>
                                    <th>Docente Evaluador</th>
                                    <th>Código / Correo</th>
                                    <th class="text-center">Total Asignados</th>
                                    <th class="text-center">Pendientes de Calificar</th>
                                    <th class="text-center">Concepto Favorable</th>
                                    <th class="text-center">Rechazados</th>
                                    <th class="text-center">Promedio Notas</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="eva" items="${qPorEvaluador.rows}">
                                    <tr>
                                        <td class="fw-bold text-dark"><c:out value="${eva.nombres} ${eva.apellidos}" /></td>
                                        <td>
                                            <code><c:out value="${eva.codigo}" /></code>
                                            <div class="small text-muted"><c:out value="${eva.correo}" /></div>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge bg-secondary rounded-pill px-3 py-2 fs-6">
                                                <c:out value="${eva.total_asignados}" />
                                            </span>
                                        </td>
                                        <td class="text-center text-warning fw-semibold"><c:out value="${eva.pendientes_evaluar}" /></td>
                                        <td class="text-center text-success fw-semibold"><c:out value="${eva.aprobados}" /></td>
                                        <td class="text-center text-danger fw-semibold"><c:out value="${eva.rechazados}" /></td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${not empty eva.promedio_notas}">
                                                    <span class="badge ${eva.promedio_notas >= 3.0 ? 'bg-success' : 'bg-danger'}">
                                                        <fmt:formatNumber value="${eva.promedio_notas}" pattern="0.0" />
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted small">Sin notas</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- 4. Pestaña: Por Estudiante -->
        <div class="tab-pane fade" id="pills-estudiantes" role="tabpanel">
            <div class="card card-uts shadow-sm">
                <div class="card-header bg-white py-3">
                    <h5 class="mb-0 fw-bold text-dark"><i class="bi bi-mortarboard text-success me-2"></i>Seguimiento Individual de Estudiantes de Grado</h5>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light text-secondary">
                                <tr>
                                    <th>Estudiante</th>
                                    <th>Programa</th>
                                    <th>Título de Proyecto</th>
                                    <th>Director</th>
                                    <th>Evaluador</th>
                                    <th>Estado</th>
                                    <th class="text-center">Última Nota</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="e" items="${qPorEstudiante.rows}">
                                    <tr>
                                        <td>
                                            <div class="fw-bold text-dark"><c:out value="${e.nom_est} ${e.ape_est}" /></div>
                                            <small class="text-muted">Cód: <code><c:out value="${e.cod_est}" /></code> &bull; Sem: <c:out value="${e.semestre}" />°</small>
                                        </td>
                                        <td><small><c:out value="${e.nombre_programa}" /></small></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty e.titulo}">
                                                    <span class="text-truncate d-inline-block fw-semibold" style="max-width: 240px;" title="<c:out value='${e.titulo}' />">
                                                        <c:out value="${e.titulo}" />
                                                    </span>
                                                    <div><small class="text-muted">v<c:out value="${e.version}" /></small></div>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary-subtle text-secondary border">Sin proyecto radicado</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty e.nom_dir}">
                                                    <small class="text-primary fw-semibold"><c:out value="${e.nom_dir} ${e.ape_dir}" /></small>
                                                </c:when>
                                                <c:otherwise><span class="text-muted small">N/A</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty e.nom_eva}">
                                                    <small class="text-secondary fw-semibold"><c:out value="${e.nom_eva} ${e.ape_eva}" /></small>
                                                </c:when>
                                                <c:otherwise><span class="text-muted small">N/A</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty e.estado}">
                                                    <span class="badge badge-estado badge-estado-${fn:replace(fn:toLowerCase(e.estado), ' ', '-')}">
                                                        <c:out value="${e.estado}" />
                                                    </span>
                                                </c:when>
                                                <c:otherwise>-</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${not empty e.ultima_nota}">
                                                    <span class="badge ${e.ultima_nota >= 3.0 ? 'bg-success' : 'bg-danger'} fs-6">
                                                        <fmt:formatNumber value="${e.ultima_nota}" pattern="0.0" />
                                                    </span>
                                                </c:when>
                                                <c:otherwise><span class="text-muted small">-</span></c:otherwise>
                                            </c:choose>
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
