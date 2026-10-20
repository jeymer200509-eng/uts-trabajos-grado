<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="ESTUDIANTE" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Mi Anteproyecto de Grado - UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<sql:query var="qProy" dataSource="${conn}">
    SELECT a.*, 
           d.nombres AS nom_dir, d.apellidos AS ape_dir, d.correo AS correo_dir, d.telefono AS tel_dir,
           e.nombres AS nom_eva, e.apellidos AS ape_eva, e.correo AS correo_eva, e.telefono AS tel_eva
    FROM anteproyectos a
    LEFT JOIN usuarios d ON a.id_director = d.id_usuario
    LEFT JOIN usuarios e ON a.id_evaluador = e.id_usuario
    WHERE a.id_estudiante = ?
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<div class="container px-lg-4 py-4">
    <c:choose>
        <c:when test="${qProy.rowCount == 0}">
            <div class="card card-uts shadow-sm py-5 text-center">
                <div class="card-body">
                    <i class="bi bi-journal-x display-3 text-secondary opacity-50 mb-3 d-block"></i>
                    <h4 class="fw-bold">No tienes ningún anteproyecto registrado</h4>
                    <p class="text-secondary col-md-6 mx-auto mb-4">
                        Aún no has radicado tu propuesta ni seleccionado una idea del banco institucional.
                    </p>
                    <a href="${pageContext.request.contextPath}/estudiante/banco_ideas.jsp" class="btn btn-uts-primary me-2">
                        <i class="bi bi-lightbulb-fill me-1"></i> Banco de Ideas
                    </a>
                    <a href="${pageContext.request.contextPath}/estudiante/anteproyecto_formulario.jsp" class="btn btn-outline-secondary">
                        <i class="bi bi-pencil-square me-1"></i> Radicar Propuesta Libre
                    </a>
                </div>
            </div>
        </c:when>

        <c:otherwise>
            <c:set var="proy" value="${qProy.rows[0]}" />
            
            <%-- Consultar calificaciones asociadas --%>
            <sql:query var="qNotas" dataSource="${conn}">
                SELECT c.*, u.nombres AS nom_doc, u.apellidos AS ape_doc, r.nombre_rol
                FROM calificaciones c
                INNER JOIN usuarios u ON c.id_docente = u.id_usuario
                INNER JOIN roles r ON u.id_rol = r.id_rol
                WHERE c.id_anteproyecto = ?
                ORDER BY c.fecha_calificacion DESC
                <sql:param value="${proy.id_anteproyecto}" />
            </sql:query>

            <!-- Encabezado con estado y acciones -->
            <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
                <div>
                    <span class="badge badge-estado badge-estado-${fn:replace(fn:toLowerCase(proy.estado), ' ', '-')} fs-6 mb-2">
                        <c:out value="${proy.estado}" />
                    </span>
                    <h2 class="fw-bold text-dark mb-1"><c:out value="${proy.titulo}" /></h2>
                    <p class="text-secondary mb-0">
                        Línea: <strong><c:out value="${proy.linea_investigacion}" /></strong> &bull; Versión: v<c:out value="${proy.version}" /> &bull;
                        Radicado: <fmt:formatDate value="${proy.fecha_radicacion}" pattern="dd/MM/yyyy" />
                    </p>
                </div>
                <div class="d-flex gap-2">
                    <c:if test="${proy.estado == 'Idea seleccionada' or proy.estado == 'Anteproyecto radicado' or proy.estado == 'Devuelto con observaciones'}">
                        <a href="${pageContext.request.contextPath}/estudiante/anteproyecto_formulario.jsp" class="btn btn-uts-primary shadow-sm">
                            <i class="bi bi-pencil-square me-1"></i> Editar Documento / Datos
                        </a>
                    </c:if>

                    <c:if test="${proy.estado == 'Idea seleccionada' or proy.estado == 'Anteproyecto radicado'}">
                        <a href="${pageContext.request.contextPath}/estudiante/anteproyecto_eliminar.jsp?id=${proy.id_anteproyecto}" 
                           class="btn btn-outline-danger shadow-sm"
                           onclick="return confirmarAccion(event, '¿Está seguro de anular y eliminar este registro de anteproyecto? Solo se permite en estado inicial.');">
                            <i class="bi bi-trash me-1"></i> Eliminar
                        </a>
                    </c:if>
                </div>
            </div>

            <!-- Si fue devuelto con observaciones, mostrar alerta prominente -->
            <c:if test="${proy.estado == 'Devuelto con observaciones'}">
                <div class="alert alert-danger shadow-sm d-flex align-items-center mb-4">
                    <i class="bi bi-exclamation-octagon-fill fs-2 text-danger me-3"></i>
                    <div>
                        <h6 class="fw-bold mb-1">El anteproyecto fue devuelto para corrección por el docente director</h6>
                        <div class="small">
                            Por favor revisa las observaciones emitidas en la sección de calificaciones abajo, realiza los ajustes en tu documento en Google Drive y actualiza el formulario.
                        </div>
                    </div>
                </div>
            </c:if>

            <div class="row g-4">
                <!-- Columna Principal: Contenido del Anteproyecto -->
                <div class="col-lg-8">
                    <div class="card card-uts shadow-sm mb-4">
                        <div class="card-header bg-white py-3">
                            <h5 class="mb-0 fw-bold text-dark"><i class="bi bi-file-text-fill text-success me-2"></i>Contenido de la Propuesta</h5>
                        </div>
                        <div class="card-body p-4">
                            <div class="mb-4">
                                <h6 class="fw-bold text-secondary">Planteamiento del Problema:</h6>
                                <p class="text-muted"><c:out value="${proy.planteamiento_problema}" /></p>
                            </div>

                            <c:if test="${not empty proy.justificacion}">
                                <div class="mb-4">
                                    <h6 class="fw-bold text-secondary">Justificación:</h6>
                                    <p class="text-muted"><c:out value="${proy.justificacion}" /></p>
                                </div>
                            </c:if>

                            <div class="mb-4">
                                <h6 class="fw-bold text-secondary">Objetivo General:</h6>
                                <p class="text-muted"><c:out value="${proy.objetivo_general}" /></p>
                            </div>

                            <div class="mb-4">
                                <h6 class="fw-bold text-secondary">Objetivos Específicos:</h6>
                                <p class="text-muted" style="white-space: pre-line;"><c:out value="${proy.objetivos_especificos}" /></p>
                            </div>

                            <div class="mb-4">
                                <h6 class="fw-bold text-secondary">Resumen Ejecutivo:</h6>
                                <p class="text-muted"><c:out value="${proy.resumen}" /></p>
                            </div>

                            <!-- Acceso a los documentos cargados por Fases -->
                            <h6 class="fw-bold text-secondary mb-2">Documentos Digitales en Nube por Fase:</h6>
                            <div class="d-flex flex-column gap-2">
                                <c:if test="${not empty proy.enlace_desprendible}">
                                    <div class="p-3 bg-light rounded-3 d-flex flex-wrap justify-content-between align-items-center gap-2 border">
                                        <div>
                                            <div class="fw-bold text-dark"><i class="bi bi-receipt text-success me-1"></i> Fase 1 - Desprendible de Pago:</div>
                                            <small class="text-muted text-break"><c:out value="${proy.enlace_desprendible}" /></small>
                                        </div>
                                        <a href="<c:out value='${proy.enlace_desprendible}' />" target="_blank" class="btn btn-sm btn-outline-success">
                                            <i class="bi bi-box-arrow-up-right me-1"></i> Ver Desprendible
                                        </a>
                                    </div>
                                </c:if>

                                <c:if test="${not empty proy.enlace_documento and proy.enlace_documento != 'PENDIENTE'}">
                                    <div class="p-3 bg-light rounded-3 d-flex flex-wrap justify-content-between align-items-center gap-2 border">
                                        <div>
                                            <div class="fw-bold text-dark"><i class="bi bi-file-earmark-pdf-fill text-danger me-1"></i> Fase 2 - Propuesta Enviada al Director:</div>
                                            <small class="text-muted text-break"><c:out value="${proy.enlace_documento}" /></small>
                                        </div>
                                        <a href="<c:out value='${proy.enlace_documento}' />" target="_blank" class="btn btn-sm btn-outline-primary">
                                            <i class="bi bi-box-arrow-up-right me-1"></i> Abrir Propuesta
                                        </a>
                                    </div>
                                </c:if>

                                <c:if test="${not empty proy.enlace_aval_director}">
                                    <div class="p-3 bg-light rounded-3 d-flex flex-wrap justify-content-between align-items-center gap-2 border">
                                        <div>
                                            <div class="fw-bold text-primary"><i class="bi bi-file-earmark-check-fill me-1"></i> Fase 3 - Revisión / Aval de Propuesta por Director:</div>
                                            <small class="text-muted text-break"><c:out value="${proy.enlace_aval_director}" /></small>
                                        </div>
                                        <a href="<c:out value='${proy.enlace_aval_director}' />" target="_blank" class="btn btn-sm btn-outline-primary">
                                            <i class="bi bi-box-arrow-up-right me-1"></i> Ver Aval Director
                                        </a>
                                    </div>
                                </c:if>

                                <c:if test="${not empty proy.enlace_documento_final}">
                                    <div class="p-3 bg-success-subtle border border-success-subtle rounded-3 d-flex flex-wrap justify-content-between align-items-center gap-2">
                                        <div>
                                            <div class="fw-bold text-success"><i class="bi bi-file-earmark-check-fill me-1"></i> Fase 4 - Informe del Proyecto Enviado al Director:</div>
                                            <small class="text-muted text-break"><c:out value="${proy.enlace_documento_final}" /></small>
                                        </div>
                                        <a href="<c:out value='${proy.enlace_documento_final}' />" target="_blank" class="btn btn-sm btn-success">
                                            <i class="bi bi-box-arrow-up-right me-1"></i> Ver Informe del Proyecto
                                        </a>
                                    </div>
                                </c:if>

                                <c:if test="${not empty proy.enlace_informe_director}">
                                    <div class="p-3 bg-light rounded-3 d-flex flex-wrap justify-content-between align-items-center gap-2 border">
                                        <div>
                                            <div class="fw-bold text-primary"><i class="bi bi-send-check-fill me-1"></i> Fase 5 - Informe Avalado por Director para Comité:</div>
                                            <small class="text-muted text-break"><c:out value="${proy.enlace_informe_director}" /></small>
                                        </div>
                                        <a href="<c:out value='${proy.enlace_informe_director}' />" target="_blank" class="btn btn-sm btn-outline-primary">
                                            <i class="bi bi-box-arrow-up-right me-1"></i> Ver Aval de Informe
                                        </a>
                                    </div>
                                </c:if>

                                <c:if test="${not empty proy.enlace_acta_final}">
                                    <div class="p-3 bg-warning-subtle border border-warning rounded-3 d-flex flex-wrap justify-content-between align-items-center gap-2">
                                        <div>
                                            <div class="fw-bold text-dark"><i class="bi bi-trophy-fill text-warning me-1"></i> Fase 6 - Acta / Dictamen Final del Comité Evaluador:</div>
                                            <small class="text-muted text-break"><c:out value="${proy.enlace_acta_final}" /></small>
                                        </div>
                                        <a href="<c:out value='${proy.enlace_acta_final}' />" target="_blank" class="btn btn-sm btn-dark">
                                            <i class="bi bi-box-arrow-up-right me-1"></i> Ver Acta Final
                                        </a>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Columna Lateral: Tutores y Calificaciones -->
                <div class="col-lg-4">
                    <!-- Ficha Tutores -->
                    <div class="card card-uts shadow-sm mb-4">
                        <div class="card-header bg-white py-3">
                            <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-people-fill text-primary me-2"></i>Docentes Asignados</h6>
                        </div>
                        <div class="card-body p-3">
                            <div class="p-3 bg-light rounded-3 mb-3 border">
                                <div class="small text-secondary fw-semibold">DOCENTE DIRECTOR:</div>
                                <c:choose>
                                    <c:when test="${not empty proy.nom_dir}">
                                        <div class="fw-bold text-dark mt-1"><c:out value="${proy.nom_dir} ${proy.ape_dir}" /></div>
                                        <div class="small text-muted"><i class="bi bi-envelope"></i> <c:out value="${proy.correo_dir}" /></div>
                                        <c:if test="${not empty proy.tel_dir}">
                                            <div class="small text-muted"><i class="bi bi-telephone"></i> <c:out value="${proy.tel_dir}" /></div>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-warning-subtle text-warning border border-warning-subtle mt-1">Sin Director asignado</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="p-3 bg-light rounded-3 border">
                                <div class="small text-secondary fw-semibold">DOCENTE EVALUADOR:</div>
                                <c:choose>
                                    <c:when test="${not empty proy.nom_eva}">
                                        <div class="fw-bold text-dark mt-1"><c:out value="${proy.nom_eva} ${proy.ape_eva}" /></div>
                                        <div class="small text-muted"><i class="bi bi-envelope"></i> <c:out value="${proy.correo_eva}" /></div>
                                        <c:if test="${not empty proy.tel_eva}">
                                            <div class="small text-muted"><i class="bi bi-telephone"></i> <c:out value="${proy.tel_eva}" /></div>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle mt-1">Sin Evaluador asignado</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <!-- Calificaciones Recibidas -->
                    <div class="card card-uts shadow-sm">
                        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                            <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-award-fill text-warning me-2"></i>Calificaciones</h6>
                            <a href="${pageContext.request.contextPath}/estudiante/informe_calificaciones.jsp" class="small text-decoration-none">Ver Informe</a>
                        </div>
                        <div class="card-body p-3">
                            <c:choose>
                                <c:when test="${qNotas.rowCount > 0}">
                                    <c:forEach var="n" items="${qNotas.rows}">
                                        <div class="border-bottom pb-2 mb-2">
                                            <div class="d-flex justify-content-between align-items-center">
                                                <span class="fw-bold text-dark small"><c:out value="${n.tipo_evaluacion}" /></span>
                                                <span class="badge ${n.nota >= 3.0 ? 'bg-success' : 'bg-danger'} fs-6">
                                                    <fmt:formatNumber value="${n.nota}" pattern="0.0" />
                                                </span>
                                            </div>
                                            <p class="small text-muted mt-1 mb-1"><c:out value="${n.observaciones}" /></p>
                                            <small class="text-secondary" style="font-size: 0.75rem;">
                                                <c:out value="${n.nom_doc} ${n.ape_doc}" /> &bull; <fmt:formatDate value="${n.fecha_calificacion}" pattern="dd/MM/yyyy" />
                                            </small>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-3 text-muted small">
                                        No se registran calificaciones aún.
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<%@ include file="/includes/footer.jspf" %>
