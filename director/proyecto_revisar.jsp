<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="DIRECTOR" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="idProyecto" value="${param.id}" />

<c:if test="${empty idProyecto}">
    <c:set var="mensaje_error" value="Proyecto no especificado." scope="session" />
    <c:redirect url="/director/proyectos_listar.jsp" />
</c:if>

<%-- Consultar proyecto verificando asignación a este director --%>
<sql:query var="qProy" dataSource="${conn}">
    SELECT a.*, 
           u.codigo AS cod_est, u.documento AS doc_est, u.nombres AS nom_est, u.apellidos AS ape_est,
           u.correo AS correo_est, u.telefono AS tel_est, u.semestre,
           p.nombre_programa, p.nivel,
           e.nombres AS nom_eva, e.apellidos AS ape_eva
    FROM anteproyectos a
    INNER JOIN usuarios u ON a.id_estudiante = u.id_usuario
    LEFT JOIN programas p ON u.id_programa = p.id_programa
    LEFT JOIN usuarios e ON a.id_evaluador = e.id_usuario
    WHERE a.id_anteproyecto = ? AND a.id_director = ?
    <sql:param value="${idProyecto}" />
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<c:if test="${qProy.rowCount == 0}">
    <c:set var="mensaje_error" value="El proyecto no existe o usted no está asignado como director tutor." scope="session" />
    <c:redirect url="/director/proyectos_listar.jsp" />
</c:if>

<c:set var="p" value="${qProy.rows[0]}" />
<c:set var="esFaseInforme" value="${not empty p.enlace_documento_final or p.estado == 'Documento final entregado'}" />

<%-- Consultar evaluadores activos para remitir al Comité Evaluador --%>
<sql:query var="qEvaluadores" dataSource="${conn}">
    SELECT u.id_usuario, u.nombres, u.apellidos, u.correo
    FROM usuarios u
    INNER JOIN roles r ON u.id_rol = r.id_rol AND r.nombre_rol = 'EVALUADOR'
    WHERE u.activo = 1
    ORDER BY u.nombres ASC
</sql:query>

<%-- Consultar historial de calificaciones previas --%>
<sql:query var="qHistNotas" dataSource="${conn}">
    SELECT c.*, u.nombres AS nom_doc, u.apellidos AS ape_doc, r.nombre_rol
    FROM calificaciones c
    INNER JOIN usuarios u ON c.id_docente = u.id_usuario
    INNER JOIN roles r ON u.id_rol = r.id_rol
    WHERE c.id_anteproyecto = ?
    ORDER BY c.fecha_calificacion DESC
    <sql:param value="${idProyecto}" />
</sql:query>

<c:set var="pageTitle" value="Revisión de Proyecto y Envío al Comité - Director UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<div class="container-fluid px-lg-4 py-4">
    <!-- Encabezado -->
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <div>
            <span class="badge bg-primary rounded-pill px-3 py-2 me-2">
                <c:out value="${esFaseInforme ? 'FASE 5: Revisión de Informe del Proyecto' : 'FASE 3: Revisión de Propuesta'}" />
            </span>
            <span class="badge badge-estado badge-estado-${fn:replace(fn:toLowerCase(p.estado), ' ', '-')} fs-6 mb-2">
                <c:out value="${p.estado}" />
            </span>
            <h2 class="fw-bold mb-1 text-dark"><c:out value="${p.titulo}" /></h2>
            <p class="text-secondary mb-0">Revisión del Director y remisión al Comité Evaluador &bull; Estudiante: <strong><c:out value="${p.nom_est} ${p.ape_est}" /></strong></p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/director/proyectos_listar.jsp" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left"></i> Volver a Mis Proyectos
            </a>
        </div>
    </div>

    <div class="row g-4">
        <!-- Columna Izquierda: Información del Estudiante y Documentos por Fase -->
        <div class="col-lg-7">
            <!-- Ficha del Estudiante -->
            <div class="card card-uts shadow-sm mb-4 border-start border-4 border-start-primary">
                <div class="card-header bg-white py-3">
                    <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-person-circle text-primary me-2"></i>Datos del Estudiante</h6>
                </div>
                <div class="card-body p-3">
                    <div class="row g-2">
                        <div class="col-sm-6">
                            <small class="text-muted d-block">Nombres y Apellidos:</small>
                            <span class="fw-bold text-dark"><c:out value="${p.nom_est} ${p.ape_est}" /></span>
                        </div>
                        <div class="col-sm-3">
                            <small class="text-muted d-block">Código:</small>
                            <code><c:out value="${p.cod_est}" /></code>
                        </div>
                        <div class="col-sm-3">
                            <small class="text-muted d-block">Documento:</small>
                            <span><c:out value="${p.doc_est}" /></span>
                        </div>
                        <div class="col-sm-6">
                            <small class="text-muted d-block">Programa Académico:</small>
                            <span class="small fw-semibold"><c:out value="${p.nombre_programa}" /></span>
                        </div>
                        <div class="col-sm-3">
                            <small class="text-muted d-block">Semestre:</small>
                            <span><c:out value="${p.semestre}" />° Semestre</span>
                        </div>
                        <div class="col-sm-3">
                            <small class="text-muted d-block">Correo:</small>
                            <a href="mailto:${p.correo_est}" class="small text-decoration-none"><c:out value="${p.correo_est}" /></a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Contenido del Proyecto y Documentos Subidos -->
            <div class="card card-uts shadow-sm mb-4">
                <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                    <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-file-earmark-text text-success me-2"></i>Detalle de la Propuesta e Informe (v<c:out value="${p.version}" />)</h6>
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

                    <hr class="my-3">
                    <h6 class="fw-bold text-dark mb-2"><i class="bi bi-folder2-open text-primary me-1"></i>Documentos Digitales para Revisar:</h6>

                    <!-- Fase 1: Desprendible de Pago -->
                    <c:if test="${not empty p.enlace_desprendible}">
                        <div class="p-3 bg-light rounded-3 d-flex flex-wrap justify-content-between align-items-center gap-2 mb-2 border">
                            <div>
                                <div class="fw-bold text-dark"><i class="bi bi-receipt text-success me-2"></i>Fase 1: Desprendible de Pago del Estudiante:</div>
                                <small class="text-muted text-break"><c:out value="${p.enlace_desprendible}" /></small>
                            </div>
                            <a href="<c:out value='${p.enlace_desprendible}' />" target="_blank" class="btn btn-sm btn-outline-success">
                                <i class="bi bi-box-arrow-up-right me-1"></i> Ver Desprendible
                            </a>
                        </div>
                    </c:if>

                    <!-- Fase 2: Documento de la Propuesta -->
                    <div class="p-3 bg-light rounded-3 d-flex flex-wrap justify-content-between align-items-center gap-2 mb-2 border">
                        <div>
                            <div class="fw-bold text-dark"><i class="bi bi-cloud-arrow-down-fill text-primary me-2"></i>Fase 2: Propuesta de Grado Enviada por Estudiante:</div>
                            <small class="text-muted text-break"><c:out value="${p.enlace_documento}" /></small>
                        </div>
                        <a href="<c:out value='${p.enlace_documento}' />" target="_blank" class="btn btn-sm btn-outline-primary">
                            <i class="bi bi-box-arrow-up-right me-1"></i> Abrir Propuesta
                        </a>
                    </div>

                    <!-- Fase 4: Informe del Proyecto -->
                    <c:if test="${not empty p.enlace_documento_final}">
                        <div class="p-3 bg-success-subtle border border-success-subtle rounded-3 d-flex flex-wrap justify-content-between align-items-center gap-2 mt-2">
                            <div>
                                <div class="fw-bold text-success"><i class="bi bi-file-earmark-check-fill me-2"></i>Fase 4: Informe Final del Proyecto Subido por Estudiante:</div>
                                <small class="text-muted text-break"><c:out value="${p.enlace_documento_final}" /></small>
                                <c:if test="${not empty p.resumen_documento_final}">
                                    <div class="small text-muted mt-2"><strong>Resumen del Informe:</strong> <c:out value="${p.resumen_documento_final}" /></div>
                                </c:if>
                            </div>
                            <a href="<c:out value='${p.enlace_documento_final}' />" target="_blank" class="btn btn-sm btn-success">
                                <i class="bi bi-box-arrow-up-right me-1"></i> Abrir Informe del Proyecto
                            </a>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>

        <!-- Columna Derecha: Formulario de Revisión y Envío al Comité Evaluador -->
        <div class="col-lg-5">
            <div class="card card-uts shadow-sm mb-4">
                <div class="card-header card-header-uts py-3">
                    <h5 class="mb-0 fw-bold">
                        <i class="bi bi-send-check-fill me-2"></i>
                        <c:out value="${esFaseInforme ? 'Fase 5: Revisar Informe y Enviar al Comité Evaluador' : 'Fase 3: Revisar Propuesta y Enviar al Comité Evaluador'}" />
                    </h5>
                </div>
                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/director/proyecto_calificar.jsp" method="POST">
                        <input type="hidden" name="id_anteproyecto" value="${p.id_anteproyecto}">
                        <input type="hidden" name="estado_actual" value="${p.estado}">

                        <div class="mb-3">
                            <label for="tipo_evaluacion" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Etapa a Revisar:
                            </label>
                            <select name="tipo_evaluacion" id="tipo_evaluacion" class="form-select" required>
                                <option value="Anteproyecto - Director" ${!esFaseInforme ? 'selected' : ''}>
                                    Fase 3: Revisión de Propuesta y Envío al Comité Evaluador
                                </option>
                                <c:if test="${esFaseInforme}">
                                    <option value="Documento Final - Director" selected>
                                        Fase 5: Revisión de Informe del Proyecto y Envío al Comité Evaluador
                                    </option>
                                </c:if>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label for="id_evaluador" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Comité Evaluador (Docente Evaluador Destino):
                            </label>
                            <select name="id_evaluador" id="id_evaluador" class="form-select" required>
                                <option value="">-- Seleccione Docente del Comité Evaluador --</option>
                                <c:forEach var="eva" items="${qEvaluadores.rows}">
                                    <option value="${eva.id_usuario}" ${p.id_evaluador == eva.id_usuario ? 'selected' : ''}>
                                        Prof. <c:out value="${eva.nombres} ${eva.apellidos}" /> (<c:out value="${eva.correo}" />)
                                    </option>
                                </c:forEach>
                            </select>
                            <div class="form-text">Si aprueba el documento, se remitirá automáticamente a este miembro del Comité Evaluador.</div>
                        </div>

                        <div class="mb-3 p-3 bg-light rounded-3 border">
                            <label for="enlace_documento_director" class="form-label fw-semibold text-dark">
                                <i class="bi bi-cloud-arrow-up-fill text-primary me-1"></i>Subir Archivo de Revisión / Aval del Director (Link PDF Drive/Nube):
                            </label>
                            <input type="url" class="form-control" id="enlace_documento_director" name="enlace_documento_director"
                                   value="<c:out value='${esFaseInforme ? p.enlace_informe_director : p.enlace_aval_director}' />"
                                   placeholder="https://drive.google.com/file/d/... (Carta de aval o documento revisado)"
                                   oninput="validarUrlDocumento(this)">
                            <div class="form-text">Adjunte el enlace al documento de aval o revisión para el Comité Evaluador.</div>
                        </div>

                        <div class="mb-3">
                            <label for="nota" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Calificación del Director (Escala 0.0 a 5.0):
                            </label>
                            <div class="input-group input-group-lg">
                                <span class="input-group-text bg-light fw-bold">Nota</span>
                                <input type="number" step="0.1" min="0.0" max="5.0" class="form-control" 
                                       id="nota" name="nota" required placeholder="ej. 4.2" oninput="validarNotaInput(this)">
                            </div>
                            <div class="form-text">Nota mínima aprobatoria: <strong>3.0</strong> según reglamento institucional UTS.</div>
                        </div>

                        <div class="mb-3">
                            <label for="estado_decision" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Decisión del Director:
                            </label>
                            <select name="estado_decision" id="estado_decision" class="form-select form-select-lg" required>
                                <option value="Aprobado">Aprobar y Enviar al Comité Evaluador</option>
                                <option value="Devuelto">Devolver con Observaciones (Requiere corrección del estudiante)</option>
                            </select>
                        </div>

                        <div class="mb-4">
                            <label for="observaciones" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Observaciones y Retroalimentación:
                            </label>
                            <textarea class="form-control" id="observaciones" name="observaciones" rows="4" required 
                                      placeholder="Escriba aquí los comentarios detallados para el Comité Evaluador o los aspectos a corregir por el estudiante..."></textarea>
                        </div>

                        <button type="submit" class="btn btn-uts-primary btn-lg w-100 shadow-sm" onclick="return confirmarAccion(event, '¿Confirma el registro de su revisión y decisión?');">
                            <i class="bi bi-send-check-fill me-1"></i> Guardar Revisión y Procesar Envío
                        </button>
                    </form>
                </div>
            </div>

            <!-- Historial de calificaciones previas del proyecto -->
            <div class="card card-uts shadow-sm">
                <div class="card-header bg-white py-3">
                    <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-clock-history me-2"></i>Calificaciones Previas del Proyecto</h6>
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
                                        Por: <c:out value="${hn.nom_doc} ${hn.ape_doc}" /> &bull; <fmt:formatDate value="${hn.fecha_calificacion}" pattern="dd/MM/yyyy HH:mm" />
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-3 text-muted small">
                                No registra calificaciones previas.
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="/includes/footer.jspf" %>
