<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="COORDINACION" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Asignación de Directores y Evaluadores - UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<%-- Consulta de Directores disponibles con conteo de carga activa --%>
<sql:query var="qDirectores" dataSource="${conn}">
    SELECT u.id_usuario, u.nombres, u.apellidos, u.codigo,
           COUNT(a.id_anteproyecto) AS proyectos_activos
    FROM usuarios u
    INNER JOIN roles r ON u.id_rol = r.id_rol AND r.nombre_rol = 'DIRECTOR'
    LEFT JOIN anteproyectos a ON u.id_usuario = a.id_director 
         AND a.estado NOT IN ('Rechazado', 'Sustentado')
    WHERE u.activo = 1
    GROUP BY u.id_usuario, u.nombres, u.apellidos, u.codigo
    ORDER BY u.nombres ASC
</sql:query>

<%-- Consulta de Evaluadores disponibles con conteo de carga activa --%>
<sql:query var="qEvaluadores" dataSource="${conn}">
    SELECT u.id_usuario, u.nombres, u.apellidos, u.codigo,
           COUNT(a.id_anteproyecto) AS evaluaciones_activas
    FROM usuarios u
    INNER JOIN roles r ON u.id_rol = r.id_rol AND r.nombre_rol = 'EVALUADOR'
    LEFT JOIN anteproyectos a ON u.id_usuario = a.id_evaluador 
         AND a.estado NOT IN ('Rechazado', 'Sustentado')
    WHERE u.activo = 1
    GROUP BY u.id_usuario, u.nombres, u.apellidos, u.codigo
    ORDER BY u.nombres ASC
</sql:query>

<%-- Consulta de Anteproyectos --%>
<sql:query var="qAnteproyectos" dataSource="${conn}">
    SELECT a.id_anteproyecto, a.titulo, a.linea_investigacion, a.version, a.estado,
           a.fecha_radicacion, a.enlace_documento,
           a.id_director, a.id_evaluador,
           u.id_usuario AS id_est, u.codigo AS cod_est, u.nombres AS nom_est, u.apellidos AS ape_est,
           p.nombre_programa,
           d.nombres AS nom_dir, d.apellidos AS ape_dir,
           e.nombres AS nom_eva, e.apellidos AS ape_eva
    FROM anteproyectos a
    INNER JOIN usuarios u ON a.id_estudiante = u.id_usuario
    LEFT JOIN programas p ON u.id_programa = p.id_programa
    LEFT JOIN usuarios d ON a.id_director = d.id_usuario
    LEFT JOIN usuarios e ON a.id_evaluador = e.id_usuario
    ORDER BY a.fecha_radicacion DESC
</sql:query>

<div class="container-fluid px-lg-4 py-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <div>
            <h2 class="fw-bold mb-1 text-dark">
                <i class="bi bi-person-check-fill text-primary me-2"></i>Asignación de Director y Evaluador
            </h2>
            <p class="text-secondary mb-0">Designación de tutores y jurados evaluadores con validación de límite de 5 proyectos por director.</p>
        </div>
        <div class="d-flex gap-2">
            <span class="badge bg-info-subtle text-info-emphasis border border-info-subtle px-3 py-2 fs-6">
                <i class="bi bi-shield-check me-1"></i> Regla UTS: Máx. 5 proyectos por Director
            </span>
        </div>
    </div>

    <!-- Tabla de Proyectos para Asignación -->
    <div class="card card-uts shadow-sm">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
            <span class="fw-bold text-dark">
                Total de Anteproyectos en el Sistema: <span class="badge bg-secondary rounded-pill"><c:out value="${qAnteproyectos.rowCount}" /></span>
            </span>
            <div class="w-25">
                <input type="text" id="filtroRapidoAsig" class="form-control form-control-sm" placeholder="Filtrar en pantalla..." onkeyup="filtrarTabla('filtroRapidoAsig', 'tablaAsignaciones')">
            </div>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0" id="tablaAsignaciones">
                    <thead class="table-light text-secondary">
                        <tr>
                            <th>Estudiante</th>
                            <th>Título del Anteproyecto</th>
                            <th>Director Designado</th>
                            <th>Evaluador Designado</th>
                            <th>Estado Actual</th>
                            <th class="text-end pe-3">Acción</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${qAnteproyectos.rowCount > 0}">
                                <c:forEach var="p" items="${qAnteproyectos.rows}">
                                    <tr>
                                        <td>
                                            <div class="fw-semibold text-dark"><c:out value="${p.nom_est} ${p.ape_est}" /></div>
                                            <small class="text-muted">Cód: <c:out value="${p.cod_est}" /></small>
                                            <c:if test="${not empty p.nombre_programa}">
                                                <div class="small text-secondary"><c:out value="${p.nombre_programa}" /></div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <div class="fw-semibold text-dark"><c:out value="${p.titulo}" /></div>
                                            <small class="text-muted"><i class="bi bi-tag"></i> <c:out value="${p.linea_investigacion}" /> &bull; v<c:out value="${p.version}" /></small>
                                            <c:if test="${not empty p.enlace_documento}">
                                                <div>
                                                    <a href="<c:out value='${p.enlace_documento}' />" target="_blank" class="small text-primary text-decoration-none">
                                                        <i class="bi bi-link-45deg"></i> Ver Documento
                                                    </a>
                                                </div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty p.nom_dir}">
                                                    <div class="fw-semibold text-primary">
                                                        <i class="bi bi-person-badge me-1"></i><c:out value="${p.nom_dir} ${p.ape_dir}" />
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-warning-subtle text-warning border border-warning-subtle">
                                                        <i class="bi bi-exclamation-circle me-1"></i>Sin Director
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty p.nom_eva}">
                                                    <div class="fw-semibold text-secondary">
                                                        <i class="bi bi-clipboard-check me-1"></i><c:out value="${p.nom_eva} ${p.ape_eva}" />
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle">
                                                        Sin Evaluador
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="badge badge-estado badge-estado-${fn:replace(fn:toLowerCase(p.estado), ' ', '-')}">
                                                <c:out value="${p.estado}" />
                                            </span>
                                        </td>
                                        <td class="text-end pe-3">
                                            <button type="button" class="btn btn-sm btn-uts-primary" data-bs-toggle="modal" data-bs-target="#modalAsignar${p.id_anteproyecto}">
                                                <i class="bi bi-pencil-fill me-1"></i> Asignar
                                            </button>

                                            <!-- Modal de Asignación de Director y Evaluador -->
                                            <div class="modal fade" id="modalAsignar${p.id_anteproyecto}" tabindex="-1" aria-labelledby="modalLabel${p.id_anteproyecto}" aria-hidden="true">
                                                <div class="modal-dialog modal-dialog-centered text-start">
                                                    <div class="modal-content">
                                                        <div class="modal-header card-header-uts text-white">
                                                            <h6 class="modal-title fw-bold" id="modalLabel${p.id_anteproyecto}">
                                                                <i class="bi bi-person-check-fill me-2"></i>Asignar Tutores a Proyecto
                                                            </h6>
                                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                                                        </div>
                                                        <form action="${pageContext.request.contextPath}/coordinacion/asignacion_guardar.jsp" method="POST">
                                                            <div class="modal-body">
                                                                <input type="hidden" name="id_anteproyecto" value="${p.id_anteproyecto}">
                                                                <input type="hidden" name="estado_actual" value="${p.estado}">

                                                                <div class="mb-3 bg-light p-2 rounded">
                                                                    <div class="small text-muted">Estudiante:</div>
                                                                    <div class="fw-bold"><c:out value="${p.nom_est} ${p.ape_est}" /> (Cód: <c:out value="${p.cod_est}" />)</div>
                                                                    <div class="small text-muted mt-1">Proyecto:</div>
                                                                    <div class="small fw-semibold text-dark"><c:out value="${p.titulo}" /></div>
                                                                </div>

                                                                <!-- Selector Director -->
                                                                <div class="mb-3">
                                                                    <label class="form-label fw-semibold">
                                                                        <i class="bi bi-person-badge text-primary me-1"></i>Docente Director (Tutor):
                                                                    </label>
                                                                    <select name="id_director" class="form-select">
                                                                        <option value="">-- Sin Director Asignado --</option>
                                                                        <c:forEach var="dir" items="${qDirectores.rows}">
                                                                            <c:set var="esMismoDir" value="${p.id_director == dir.id_usuario}" />
                                                                            <c:set var="cupoLleno" value="${dir.proyectos_activos >= 5 and !esMismoDir}" />
                                                                            <option value="${dir.id_usuario}" 
                                                                                    ${esMismoDir ? 'selected' : ''} 
                                                                                    ${cupoLleno ? 'disabled' : ''}>
                                                                                <c:out value="${dir.nombres} ${dir.apellidos}" /> 
                                                                                (<c:out value="${dir.proyectos_activos}" /> / 5 activos)
                                                                                <c:if test="${cupoLleno}"> - [CUPO MÁXIMO ALCANZADO]</c:if>
                                                                            </option>
                                                                        </c:forEach>
                                                                    </select>
                                                                    <div class="form-text">Límite institucional de 5 proyectos activos por director.</div>
                                                                </div>

                                                                <!-- Selector Evaluador -->
                                                                <div class="mb-3">
                                                                    <label class="form-label fw-semibold">
                                                                        <i class="bi bi-clipboard-check text-success me-1"></i>Docente Evaluador (Jurado):
                                                                    </label>
                                                                    <select name="id_evaluador" class="form-select">
                                                                        <option value="">-- Sin Evaluador Asignado --</option>
                                                                        <c:forEach var="eva" items="${qEvaluadores.rows}">
                                                                            <option value="${eva.id_usuario}" ${p.id_evaluador == eva.id_usuario ? 'selected' : ''}>
                                                                                <c:out value="${eva.nombres} ${eva.apellidos}" /> (<c:out value="${eva.evaluaciones_activas}" /> asignados)
                                                                            </option>
                                                                        </c:forEach>
                                                                    </select>
                                                                </div>

                                                                <!-- Observación para historial -->
                                                                <div class="mb-3">
                                                                    <label class="form-label fw-semibold">Observación de Coordinación:</label>
                                                                    <textarea name="observacion" class="form-control" rows="2" placeholder="Motivo de la asignación o resolución institucional..."></textarea>
                                                                </div>
                                                            </div>
                                                            <div class="modal-footer">
                                                                <button type="button" class="btn btn-sm btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                                                <button type="submit" class="btn btn-sm btn-uts-primary fw-semibold">Guardar Asignación</button>
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
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        No hay anteproyectos radicados actualmente en el sistema.
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
