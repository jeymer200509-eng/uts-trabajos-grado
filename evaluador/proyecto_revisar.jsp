<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="EVALUADOR" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="idProyecto" value="${param.id}" />

<c:if test="${empty idProyecto}">
    <c:set var="mensaje_error" value="Proyecto no especificado." scope="session" />
    <c:redirect url="/evaluador/proyectos_listar.jsp" />
</c:if>

<%-- Consultar proyecto verificando asignación a este evaluador --%>
<sql:query var="qProy" dataSource="${conn}">
    SELECT a.*, 
           u.codigo AS cod_est, u.documento AS doc_est, u.nombres AS nom_est, u.apellidos AS ape_est,
           u.correo AS correo_est, u.telefono AS tel_est, u.semestre,
           p.nombre_programa, p.nivel,
           d.nombres AS nom_dir, d.apellidos AS ape_dir, d.correo AS correo_dir
    FROM anteproyectos a
    INNER JOIN usuarios u ON a.id_estudiante = u.id_usuario
    LEFT JOIN programas p ON u.id_programa = p.id_programa
    LEFT JOIN usuarios d ON a.id_director = d.id_usuario
    WHERE a.id_anteproyecto = ? AND a.id_evaluador = ?
    <sql:param value="${idProyecto}" />
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<c:if test="${qProy.rowCount == 0}">
    <c:set var="mensaje_error" value="El proyecto no existe o usted no está asignado como jurado evaluador." scope="session" />
    <c:redirect url="/evaluador/proyectos_listar.jsp" />
</c:if>

<c:set var="p" value="${qProy.rows[0]}" />

<%-- Consultar historial de calificaciones previas (incluyendo la del director) --%>
<sql:query var="qHistNotas" dataSource="${conn}">
    SELECT c.*, u.nombres AS nom_doc, u.apellidos AS ape_doc, r.nombre_rol
    FROM calificaciones c
    INNER JOIN usuarios u ON c.id_docente = u.id_usuario
    INNER JOIN roles r ON u.id_rol = r.id_rol
    WHERE c.id_anteproyecto = ?
    ORDER BY c.fecha_calificacion DESC
    <sql:param value="${idProyecto}" />
</sql:query>

<c:set var="pageTitle" value="Dictamen de Evaluación - Evaluador UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<div class="container-fluid px-lg-4 py-4">
    <!-- Encabezado -->
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <div>
            <span class="badge badge-estado badge-estado-${fn:replace(fn:toLowerCase(p.estado), ' ', '-')} fs-6 mb-2">
                <c:out value="${p.estado}" />
            </span>
            <h2 class="fw-bold mb-1 text-dark"><c:out value="${p.titulo}" /></h2>
            <p class="text-secondary mb-0">Evaluación y emisión de veredicto institucional &bull; Estudiante: <strong><c:out value="${p.nom_est} ${p.ape_est}" /></strong></p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/evaluador/proyectos_listar.jsp" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left"></i> Volver a Mis Evaluaciones
            </a>
        </div>
    </div>

    <div class="row g-4">
        <!-- Columna Izquierda: Información del Estudiante y Documento -->
        <div class="col-lg-7">
            <!-- Ficha del Estudiante y Director -->
            <div class="card card-uts shadow-sm mb-4 border-start border-4 border-start-info">
                <div class="card-header bg-white py-3">
                    <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-person-badge-fill text-info me-2"></i>Información Institucional</h6>
                </div>
                <div class="card-body p-3">
                    <div class="row g-3">
                        <div class="col-sm-6">
                            <small class="text-muted d-block">Estudiante:</small>
                            <span class="fw-bold text-dark"><c:out value="${p.nom_est} ${p.ape_est}" /></span>
                            <div class="small text-muted">Cód: <code><c:out value="${p.cod_est}" /></code> &bull; CC: <c:out value="${p.doc_est}" /></div>
                            <div class="small text-secondary"><c:out value="${p.nombre_programa}" /> (<c:out value="${p.semestre}" />° Semestre)</div>
                        </div>
                        <div class="col-sm-6 border-start-sm ps-sm-3">
                            <small class="text-muted d-block">Docente Director Tutor:</small>
                            <span class="fw-bold text-primary"><c:out value="${p.nom_dir} ${p.ape_dir}" /></span>
                            <div class="small text-muted"><i class="bi bi-envelope"></i> <c:out value="${p.correo_dir}" /></div>
                            <span class="badge bg-success-subtle text-success border border-success-subtle mt-1">Aprobado previamente por Director</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Contenido del Proyecto -->
            <div class="card card-uts shadow-sm mb-4">
                <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                    <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-file-earmark-text text-success me-2"></i>Propuesta de Grado (v<c:out value="${p.version}" />)</h6>
                    <span class="badge bg-light text-secondary border"><i class="bi bi-tag"></i> <c:out value="${p.linea_investigacion}" /></span>
                </div>
                <div class="card-body p-4">
                    <div class="mb-3">
                        <h6 class="fw-bold text-secondary mb-1">Planteamiento del Problema:</h6>
                        <p class="text-muted small"><c:out value="${p.planteamiento_problema}" /></p>
                    </div>

                    <div class="mb-3">
                        <h6 class="fw-bold text-secondary mb-1">Objetivo General:</h6>
                        <p class="text-muted small"><c:out value="${p.objetivo_general}" /></p>
                    </div>

                    <div class="mb-3">
                        <h6 class="fw-bold text-secondary mb-1">Objetivos Específicos:</h6>
                        <p class="text-muted small" style="white-space: pre-line;"><c:out value="${p.objetivos_especificos}" /></p>
                    </div>

                    <div class="mb-3">
                        <h6 class="fw-bold text-secondary mb-1">Resumen del Proyecto:</h6>
                        <p class="text-muted small"><c:out value="${p.resumen}" /></p>
                    </div>

                    <!-- Enlace directo al documento digital en Drive -->
                    <div class="p-3 bg-light rounded-3 d-flex flex-wrap justify-content-between align-items-center gap-2">
                        <div>
                            <div class="fw-bold text-dark"><i class="bi bi-cloud-arrow-down-fill text-primary me-2"></i>Documento del Anteproyecto:</div>
                            <small class="text-muted text-break"><c:out value="${p.enlace_documento}" /></small>
                        </div>
                        <a href="<c:out value='${p.enlace_documento}' />" target="_blank" class="btn btn-outline-primary">
                            <i class="bi bi-box-arrow-up-right me-1"></i> Abrir en Nube
                        </a>
                    </div>

                    <c:if test="${not empty p.enlace_documento_final}">
                        <div class="p-3 bg-success-subtle border border-success-subtle rounded-3 d-flex flex-wrap justify-content-between align-items-center gap-2 mt-3">
                            <div>
                                <div class="fw-bold text-success"><i class="bi bi-file-earmark-check-fill me-2"></i>Monografía / Entrega Final Radicada:</div>
                                <small class="text-muted text-break"><c:out value="${p.enlace_documento_final}" /></small>
                                <c:if test="${not empty p.resumen_documento_final}">
                                    <div class="small text-muted mt-2"><strong>Resultados:</strong> <c:out value="${p.resumen_documento_final}" /></div>
                                </c:if>
                            </div>
                            <a href="<c:out value='${p.enlace_documento_final}' />" target="_blank" class="btn btn-success">
                                <i class="bi bi-box-arrow-up-right me-1"></i> Abrir Monografía
                            </a>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>

        <!-- Columna Derecha: Formulario de Evaluación y Concepto -->
        <div class="col-lg-5">
            <div class="card card-uts shadow-sm mb-4">
                <div class="card-header card-header-uts py-3">
                    <h5 class="mb-0 fw-bold"><i class="bi bi-award-fill me-2"></i>Dictamen del Jurado Evaluador</h5>
                </div>
                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/evaluador/proyecto_calificar.jsp" method="POST">
                        <input type="hidden" name="id_anteproyecto" value="${p.id_anteproyecto}">
                        <input type="hidden" name="estado_actual" value="${p.estado}">

                        <div class="mb-3">
                            <label for="tipo_evaluacion" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Tipo de Evaluación:
                            </label>
                            <select name="tipo_evaluacion" id="tipo_evaluacion" class="form-select" required>
                                <option value="Anteproyecto - Evaluador" ${p.estado != 'Documento final entregado' ? 'selected' : ''}>
                                    Evaluación de Anteproyecto de Grado
                                </option>
                                <c:if test="${not empty p.enlace_documento_final or p.estado == 'Documento final entregado'}">
                                    <option value="Documento Final - Evaluador" selected>
                                        Evaluación de Documento Final / Monografía
                                    </option>
                                </c:if>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label for="nota" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Calificación (Escala 0.0 a 5.0):
                            </label>
                            <div class="input-group input-group-lg">
                                <span class="input-group-text bg-light fw-bold">Nota</span>
                                <input type="number" step="0.1" min="0.0" max="5.0" class="form-control" 
                                       id="nota" name="nota" required placeholder="ej. 4.5" oninput="validarNotaInput(this)">
                            </div>
                            <div class="form-text">Nota aprobatoria mínima: <strong>3.0</strong> en la escala de las UTS.</div>
                        </div>

                        <div class="mb-3">
                            <label for="estado_decision" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Veredicto de Evaluación:
                            </label>
                            <select name="estado_decision" id="estado_decision" class="form-select form-select-lg" required>
                                <option value="Aprobado">Aprobado (Autorizar avance a fase de desarrollo)</option>
                                <option value="Rechazado">Rechazado (No cumple lineamientos institucionales)</option>
                            </select>
                            <div class="form-text">Al aprobar, se notificará automáticamente al estudiante y a la Coordinación.</div>
                        </div>

                        <div class="mb-4">
                            <label for="observaciones" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Concepto Técnico y Observaciones:
                            </label>
                            <textarea class="form-control" id="observaciones" name="observaciones" rows="5" required 
                                      placeholder="Consigne los argumentos técnicos del dictamen evaluativo, pertinencia metodológica y recomendaciones..."></textarea>
                        </div>

                        <button type="submit" class="btn btn-uts-primary btn-lg w-100 shadow-sm" onclick="return confirmarAccion(event, '¿Confirma la emisión del veredicto definitivo de evaluación para este proyecto?');">
                            <i class="bi bi-check-circle-fill me-1"></i> Asentar Dictamen de Evaluación
                        </button>
                    </form>
                </div>
            </div>

            <!-- Conceptos previos del Director -->
            <div class="card card-uts shadow-sm">
                <div class="card-header bg-white py-3">
                    <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-clock-history me-2"></i>Evaluaciones Previas Registradas</h6>
                </div>
                <div class="card-body p-3">
                    <c:choose>
                        <c:when test="${qHistNotas.rowCount > 0}">
                            <c:forEach var="hn" items="${qHistNotas.rows}">
                                <div class="border-bottom pb-2 mb-2">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <span class="fw-bold small text-dark"><c:out value="${hn.tipo_evaluacion}" /></span>
                                        <span class="badge ${hn.nota >= 3.0 ? 'bg-success' : 'bg-danger'}">
                                            <fmt:formatNumber value="${hn.nota}" pattern="0.0" />
                                        </span>
                                    </div>
                                    <div class="small text-muted mt-1"><c:out value="${hn.observaciones}" /></div>
                                    <div class="text-end text-secondary" style="font-size: 0.75rem;">
                                        Por: <c:out value="${hn.nom_doc} ${hn.ape_doc}" /> (<c:out value="${hn.nombre_rol}" />) &bull; 
                                        <fmt:formatDate value="${hn.fecha_calificacion}" pattern="dd/MM/yyyy HH:mm" />
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-3 text-muted small">
                                No registra evaluaciones previas.
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="/includes/footer.jspf" %>
