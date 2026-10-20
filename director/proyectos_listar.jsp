<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="DIRECTOR" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Anteproyectos Asignados - Docente Director UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<%-- Consultar todos los proyectos tutorados por este director --%>
<sql:query var="qMisProyectos" dataSource="${conn}">
    SELECT a.*, 
           u.codigo AS cod_est, u.documento AS doc_est, u.nombres AS nom_est, u.apellidos AS ape_est,
           u.correo AS correo_est, u.telefono AS tel_est, u.semestre,
           p.nombre_programa,
           e.nombres AS nom_eva, e.apellidos AS ape_eva,
           (SELECT c.nota FROM calificaciones c WHERE c.id_anteproyecto = a.id_anteproyecto AND c.id_docente = ? ORDER BY c.id_calificacion DESC LIMIT 1) AS mi_ultima_nota
    FROM anteproyectos a
    INNER JOIN usuarios u ON a.id_estudiante = u.id_usuario
    LEFT JOIN programas p ON u.id_programa = p.id_programa
    LEFT JOIN usuarios e ON a.id_evaluador = e.id_usuario
    WHERE a.id_director = ?
    ORDER BY a.fecha_radicacion DESC
    <sql:param value="${sessionScope.id_usuario}" />
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<div class="container-fluid px-lg-4 py-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <div>
            <h2 class="fw-bold mb-1 text-dark">
                <i class="bi bi-folder-check text-primary me-2"></i>Mis Anteproyectos Asignados
            </h2>
            <p class="text-secondary mb-0">Catálogo de estudiantes bajo su tutoría institucional, revisión de avances y evaluación de propuestas.</p>
        </div>
        <div>
            <span class="badge bg-secondary-subtle text-secondary border px-3 py-2 fs-6">
                Total Asignados: <strong><c:out value="${qMisProyectos.rowCount}" /></strong> / 5 permitidos
            </span>
        </div>
    </div>

    <div class="card card-uts shadow-sm">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
            <span class="fw-bold text-dark">Estudiantes y Trabajos de Grado</span>
            <div class="w-25">
                <input type="text" id="filtroDir" class="form-control form-control-sm" placeholder="Buscar estudiante o título..." onkeyup="filtrarTabla('filtroDir', 'tablaDirector')">
            </div>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0" id="tablaDirector">
                    <thead class="table-light text-secondary">
                        <tr>
                            <th>Información del Estudiante</th>
                            <th>Título del Trabajo de Grado</th>
                            <th>Documento Digital</th>
                            <th class="text-center">Mi Última Nota</th>
                            <th>Estado del Proyecto</th>
                            <th class="text-end pe-3">Acción</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${qMisProyectos.rowCount > 0}">
                                <c:forEach var="p" items="${qMisProyectos.rows}">
                                    <tr>
                                        <td>
                                            <div class="fw-bold text-dark"><c:out value="${p.nom_est} ${p.ape_est}" /></div>
                                            <small class="text-muted d-block">
                                                Cód: <code><c:out value="${p.cod_est}" /></code> &bull; CC: <c:out value="${p.doc_est}" />
                                            </small>
                                            <small class="text-secondary d-block">
                                                <c:out value="${p.nombre_programa}" /> (Semestre <c:out value="${p.semestre}" />°)
                                            </small>
                                            <small class="text-muted"><i class="bi bi-envelope"></i> <c:out value="${p.correo_est}" /></small>
                                        </td>
                                        <td>
                                            <div class="fw-semibold text-dark"><c:out value="${p.titulo}" /></div>
                                            <small class="text-muted">
                                                <i class="bi bi-tag"></i> Línea: <c:out value="${p.linea_investigacion}" /> &bull; v<c:out value="${p.version}" />
                                            </small>
                                            <c:if test="${not empty p.nom_eva}">
                                                <div class="small text-secondary mt-1">
                                                    Evaluador: <strong><c:out value="${p.nom_eva} ${p.ape_eva}" /></strong>
                                                </div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:if test="${not empty p.enlace_desprendible}">
                                                <a href="<c:out value='${p.enlace_desprendible}' />" target="_blank" class="btn btn-sm btn-outline-secondary mb-1 d-inline-block" title="Desprendible de Pago">
                                                    <i class="bi bi-receipt me-1"></i> Pago
                                                </a>
                                            </c:if>
                                            <c:if test="${not empty p.enlace_documento and p.enlace_documento != 'PENDIENTE'}">
                                                <a href="<c:out value='${p.enlace_documento}' />" target="_blank" class="btn btn-sm btn-outline-primary mb-1 d-inline-block">
                                                    <i class="bi bi-file-earmark-pdf me-1"></i> Propuesta
                                                </a>
                                            </c:if>
                                            <c:if test="${not empty p.enlace_documento_final}">
                                                <br>
                                                <a href="<c:out value='${p.enlace_documento_final}' />" target="_blank" class="btn btn-sm btn-success d-inline-block">
                                                    <i class="bi bi-file-earmark-check me-1"></i> Informe Final
                                                </a>
                                            </c:if>
                                        </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${not empty p.mi_ultima_nota}">
                                                    <span class="badge ${p.mi_ultima_nota >= 3.0 ? 'bg-success' : 'bg-danger'} fs-6 px-2 py-1">
                                                        <fmt:formatNumber value="${p.mi_ultima_nota}" pattern="0.0" />
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted small fst-italic">Pendiente</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="badge badge-estado badge-estado-${fn:replace(fn:toLowerCase(p.estado), ' ', '-')}">
                                                <c:out value="${p.estado}" />
                                            </span>
                                        </td>
                                        <td class="text-end pe-3">
                                            <a href="${pageContext.request.contextPath}/director/proyecto_revisar.jsp?id=${p.id_anteproyecto}" class="btn btn-sm btn-uts-primary">
                                                <i class="bi bi-clipboard2-check-fill me-1"></i> Evaluar
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <i class="bi bi-folder-x fs-1 text-secondary opacity-50 d-block mb-2"></i>
                                        Aún no tiene anteproyectos asignados por la Coordinación de Grado.
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
