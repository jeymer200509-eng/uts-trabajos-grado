<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="EVALUADOR" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Evaluaciones Asignadas - Docente Evaluador UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<%-- Proyectos donde este usuario es el evaluador --%>
<sql:query var="qMisEvaluaciones" dataSource="${conn}">
    SELECT a.*, 
           u.codigo AS cod_est, u.documento AS doc_est, u.nombres AS nom_est, u.apellidos AS ape_est,
           u.correo AS correo_est, u.semestre,
           p.nombre_programa,
           d.nombres AS nom_dir, d.apellidos AS ape_dir,
           (SELECT c.nota FROM calificaciones c WHERE c.id_anteproyecto = a.id_anteproyecto AND c.id_docente = ? ORDER BY c.id_calificacion DESC LIMIT 1) AS mi_nota_eva,
           (SELECT c.nota FROM calificaciones c WHERE c.id_anteproyecto = a.id_anteproyecto AND c.tipo_evaluacion LIKE '%Director%' ORDER BY c.id_calificacion DESC LIMIT 1) AS nota_director
    FROM anteproyectos a
    INNER JOIN usuarios u ON a.id_estudiante = u.id_usuario
    LEFT JOIN programas p ON u.id_programa = p.id_programa
    LEFT JOIN usuarios d ON a.id_director = d.id_usuario
    WHERE a.id_evaluador = ?
    ORDER BY a.fecha_radicacion DESC
    <sql:param value="${sessionScope.id_usuario}" />
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<div class="container-fluid px-lg-4 py-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <div>
            <h2 class="fw-bold mb-1 text-dark">
                <i class="bi bi-clipboard-check-fill text-info me-2"></i>Catálogo de Evaluaciones de Grado Asignadas
            </h2>
            <p class="text-secondary mb-0">Revisión formal, verificación de requisitos y emisión de concepto definitivo de aprobación o rechazo.</p>
        </div>
        <div>
            <span class="badge bg-secondary-subtle text-secondary border px-3 py-2 fs-6">
                Total Evaluaciones: <strong><c:out value="${qMisEvaluaciones.rowCount}" /></strong>
            </span>
        </div>
    </div>

    <div class="card card-uts shadow-sm">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
            <span class="fw-bold text-dark">Anteproyectos y Proyectos por Dictaminar</span>
            <div class="w-25">
                <input type="text" id="filtroEva" class="form-control form-control-sm" placeholder="Buscar estudiante o título..." onkeyup="filtrarTabla('filtroEva', 'tablaEvaluador')">
            </div>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0" id="tablaEvaluador">
                    <thead class="table-light text-secondary">
                        <tr>
                            <th>Estudiante</th>
                            <th>Título del Anteproyecto</th>
                            <th>Director Tutor</th>
                            <th>Documento Digital</th>
                            <th class="text-center">Mi Dictamen / Nota</th>
                            <th>Estado Actual</th>
                            <th class="text-end pe-3">Acción</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${qMisEvaluaciones.rowCount > 0}">
                                <c:forEach var="p" items="${qMisEvaluaciones.rows}">
                                    <tr>
                                        <td>
                                            <div class="fw-bold text-dark"><c:out value="${p.nom_est} ${p.ape_est}" /></div>
                                            <small class="text-muted d-block">Cód: <code><c:out value="${p.cod_est}" /></code></small>
                                            <small class="text-secondary"><c:out value="${p.nombre_programa}" /></small>
                                        </td>
                                        <td>
                                            <div class="fw-semibold text-dark"><c:out value="${p.titulo}" /></div>
                                            <small class="text-muted"><i class="bi bi-tag"></i> <c:out value="${p.linea_investigacion}" /> &bull; v<c:out value="${p.version}" /></small>
                                        </td>
                                        <td>
                                            <div class="small fw-semibold text-primary"><c:out value="${p.nom_dir} ${p.ape_dir}" /></div>
                                            <c:if test="${not empty p.nota_director}">
                                                <small class="text-muted">Nota Director: <strong><fmt:formatNumber value="${p.nota_director}" pattern="0.0" /></strong></small>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:if test="${not empty p.enlace_desprendible}">
                                                <a href="<c:out value='${p.enlace_desprendible}' />" target="_blank" class="btn btn-sm btn-outline-secondary mb-1 d-inline-block" title="Desprendible de Pago">
                                                    <i class="bi bi-receipt me-1"></i> Pago
                                                </a>
                                            </c:if>
                                            <a href="<c:out value='${p.enlace_documento}' />" target="_blank" class="btn btn-sm btn-outline-primary mb-1 d-inline-block">
                                                <i class="bi bi-file-earmark-pdf me-1"></i> Propuesta
                                            </a>
                                            <c:if test="${not empty p.enlace_documento_final}">
                                                <br>
                                                <a href="<c:out value='${p.enlace_documento_final}' />" target="_blank" class="btn btn-sm btn-success d-inline-block">
                                                    <i class="bi bi-file-earmark-check me-1"></i> Informe Final
                                                </a>
                                            </c:if>
                                        </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${not empty p.mi_nota_eva}">
                                                    <span class="badge ${p.mi_nota_eva >= 3.0 ? 'bg-success' : 'bg-danger'} fs-6 px-2 py-1">
                                                        <fmt:formatNumber value="${p.mi_nota_eva}" pattern="0.0" />
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-warning-subtle text-warning border border-warning-subtle">
                                                        Pendiente
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
                                            <a href="${pageContext.request.contextPath}/evaluador/proyecto_revisar.jsp?id=${p.id_anteproyecto}" class="btn btn-sm btn-uts-primary">
                                                <i class="bi bi-clipboard-check me-1"></i> Calificar
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <i class="bi bi-folder-x fs-1 text-secondary opacity-50 d-block mb-2"></i>
                                        No registra anteproyectos asignados para evaluar en este periodo académico.
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
