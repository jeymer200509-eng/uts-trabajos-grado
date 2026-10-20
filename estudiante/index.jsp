<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="ESTUDIANTE" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Portal del Estudiante por Fases - Trabajos de Grado UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<%-- Consultar anteproyecto del estudiante logueado con notas y promedio --%>
<sql:query var="qMiProyecto" dataSource="${conn}">
    SELECT a.*, 
           d.nombres AS nom_dir, d.apellidos AS ape_dir, d.correo AS correo_dir,
           e.nombres AS nom_eva, e.apellidos AS ape_eva, e.correo AS correo_eva,
           (SELECT COUNT(*) FROM calificaciones c WHERE c.id_anteproyecto = a.id_anteproyecto) AS total_calificaciones,
           (SELECT AVG(c.nota) FROM calificaciones c WHERE c.id_anteproyecto = a.id_anteproyecto) AS promedio_notas,
           (SELECT c.nota FROM calificaciones c WHERE c.id_anteproyecto = a.id_anteproyecto AND c.tipo_evaluacion = 'Documento Final - Evaluador' ORDER BY c.id_calificacion DESC LIMIT 1) AS nota_final_eva
    FROM anteproyectos a
    LEFT JOIN usuarios d ON a.id_director = d.id_usuario
    LEFT JOIN usuarios e ON a.id_evaluador = e.id_usuario
    WHERE a.id_estudiante = ?
    LIMIT 1
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<c:set var="tieneProyecto" value="${qMiProyecto.rowCount > 0}" />
<c:if test="${tieneProyecto}">
    <c:set var="proy" value="${qMiProyecto.rows[0]}" />
</c:if>

<%-- Lógica de desbloqueo progresivo de las 6 Fases --%>
<c:set var="tieneDesprendible" value="${tieneProyecto and not empty proy.enlace_desprendible}" />
<c:set var="f1Completa" value="${tieneDesprendible and proy.estado_pago == 'Aprobado'}" />
<c:set var="f2Desbloqueada" value="${f1Completa}" />
<c:set var="f2Completa" value="${f1Completa and not empty proy.enlace_documento and proy.enlace_documento != 'PENDIENTE' and proy.enlace_documento != 'https://drive.google.com/' and proy.estado != 'Idea seleccionada' and !(proy.estado == 'Devuelto con observaciones' and empty proy.enlace_documento_final)}" />
<c:set var="f3Desbloqueada" value="${f2Completa}" />
<c:set var="f3Completa" value="${tieneProyecto and (proy.estado == 'Aprobado' or proy.estado == 'En desarrollo' or proy.estado == 'Documento final entregado' or (proy.estado == 'En revisión por evaluador' and not empty proy.enlace_documento_final) or (proy.estado == 'Devuelto con observaciones' and not empty proy.enlace_documento_final) or proy.estado == 'Sustentado')}" />
<c:set var="f4Desbloqueada" value="${f3Completa}" />
<c:set var="f4Completa" value="${f3Completa and not empty proy.enlace_documento_final and proy.estado != 'En desarrollo' and proy.estado != 'Aprobado' and !(proy.estado == 'Devuelto con observaciones' and not empty proy.enlace_documento_final)}" />
<c:set var="f5Desbloqueada" value="${f4Completa}" />
<c:set var="f5Completa" value="${f4Completa and ((proy.estado == 'En revisión por evaluador' and not empty proy.enlace_documento_final) or proy.estado == 'Sustentado')}" />
<c:set var="f6Desbloqueada" value="${f5Completa}" />
<c:set var="f6Completa" value="${tieneProyecto and proy.estado == 'Sustentado'}" />

<div class="container px-lg-4 py-4">
    <!-- Saludo institucional -->
    <div class="card card-uts shadow-sm mb-4 border-start border-4 border-start-success">
        <div class="card-body p-4">
            <div class="row align-items-center gy-3">
                <div class="col-md-8">
                    <span class="badge badge-rol badge-rol-ESTUDIANTE mb-2">Estudiante de Grado</span>
                    <h3 class="fw-bold mb-1 text-dark">
                        ¡Hola, <c:out value="${sessionScope.nombres}" />!
                    </h3>
                    <p class="text-secondary mb-0">
                        Código: <code><c:out value="${sessionScope.codigo}" /></code> &bull; 
                        Programa: <strong><c:out value="${sessionScope.nombre_programa}" /></strong>
                    </p>
                </div>
                <div class="col-md-4 text-md-end d-flex flex-wrap justify-content-md-end gap-2">
                    <c:if test="${tieneProyecto}">
                        <a href="${pageContext.request.contextPath}/estudiante/anteproyecto_ver.jsp" class="btn btn-uts-primary shadow-sm">
                            <i class="bi bi-journal-check me-1"></i> Ver Detalle Completo
                        </a>
                        <a href="${pageContext.request.contextPath}/estudiante/informe_calificaciones.jsp" class="btn btn-outline-secondary shadow-sm">
                            <i class="bi bi-award-fill me-1"></i> Notas (<c:out value="${proy.total_calificaciones}" />)
                        </a>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <!-- Alerta si fue devuelto con observaciones -->
    <c:if test="${tieneProyecto and proy.estado == 'Devuelto con observaciones'}">
        <div class="alert alert-danger shadow-sm d-flex align-items-center p-3 mb-4 rounded-3" role="alert">
            <i class="bi bi-exclamation-octagon-fill fs-2 me-3 text-danger"></i>
            <div>
                <h5 class="alert-heading fw-bold mb-1">Documento devuelto con observaciones para corrección</h5>
                <p class="mb-0 small">
                    El Director o el Comité Evaluador ha devuelto tu documento para que realices ajustes. Revisa las observaciones en 
                    <a href="${pageContext.request.contextPath}/estudiante/informe_calificaciones.jsp" class="fw-bold text-danger">Calificaciones</a> 
                    y vuelve a subir el enlace corregido en la fase correspondiente abajo.
                </p>
            </div>
        </div>
    </c:if>

    <!-- =================================================================== -->
    <!-- RUTA DE LAS 6 FASES PROGRESIVAS DEL TRABAJO DE GRADO                 -->
    <!-- =================================================================== -->
    <div class="mb-4">
        <h4 class="fw-bold text-dark mb-1">
            <i class="bi bi-diagram-3-fill text-success me-2"></i>Ruta de Fases de tu Trabajo de Grado
        </h4>
        <p class="text-secondary small mb-3">
            Cada fase se desbloquea automáticamente al completar la fase anterior. Recuerda adjuntar el enlace a tu documento en PDF (Drive o nube) en cada etapa correspondiente.
        </p>

        <div class="row g-4">
            <!-- =============================================================== -->
            <!-- FASE 1: SUBIR DESPRENDIBLE DE PAGO (VALIDADO POR COORDINACIÓN)  -->
            <!-- =============================================================== -->
            <div class="col-12">
                <div class="card card-uts shadow-sm border-start border-4 ${f1Completa ? 'border-start-success' : (tieneDesprendible and proy.estado_pago == 'Rechazado' ? 'border-start-danger' : 'border-start-primary')}">
                    <div class="card-header bg-white py-3 d-flex flex-wrap justify-content-between align-items-center gap-2">
                        <div class="d-flex align-items-center gap-2">
                            <span class="badge ${f1Completa ? 'bg-success' : (tieneDesprendible and proy.estado_pago == 'Rechazado' ? 'bg-danger' : 'bg-primary')} rounded-pill px-3 py-2">FASE 1</span>
                            <h5 class="mb-0 fw-bold text-dark">Subir Desprendible de Pago (Revisión por Coordinación)</h5>
                        </div>
                        <c:choose>
                            <c:when test="${f1Completa}">
                                <span class="badge bg-success-subtle text-success border border-success-subtle px-3 py-2">
                                    <i class="bi bi-check-circle-fill me-1"></i>Aceptado por Coordinación (Fase 2 Desbloqueada)
                                </span>
                            </c:when>
                            <c:when test="${tieneDesprendible and proy.estado_pago == 'En revisión'}">
                                <span class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle px-3 py-2">
                                    <i class="bi bi-hourglass-split me-1"></i>En Revisión por Coordinación
                                </span>
                            </c:when>
                            <c:when test="${tieneDesprendible and proy.estado_pago == 'Rechazado'}">
                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-3 py-2">
                                    <i class="bi bi-x-circle-fill me-1"></i>Rechazado por Coordinación (Subir nuevamente)
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-3 py-2">
                                    <i class="bi bi-unlock-fill me-1"></i>Fase Inicial Activa
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="card-body p-4">
                        <p class="text-secondary small mb-3">
                            Sube el enlace a tu <strong>desprendible de pago en formato PDF</strong> alojado en Google Drive o nube. Una vez subido, <strong>Coordinación</strong> revisará el PDF y lo aceptará o rechazará. Al ser aceptado, se desbloqueará la Fase 2.
                        </p>

                        <c:if test="${tieneDesprendible and proy.estado_pago == 'En revisión'}">
                            <div class="alert alert-warning py-2 small d-flex align-items-center mb-3">
                                <i class="bi bi-clock-history fs-5 me-2"></i>
                                <div>
                                    <strong>Comprobante en revisión:</strong> Ya subiste tu desprendible de pago. El Coordinador revisará el PDF y, una vez lo acepte, se habilitará el envío de tu propuesta al Director.
                                </div>
                            </div>
                        </c:if>

                        <c:if test="${tieneDesprendible and proy.estado_pago == 'Rechazado'}">
                            <div class="alert alert-danger py-2 small d-flex align-items-center mb-3">
                                <i class="bi bi-exclamation-triangle-fill fs-5 me-2"></i>
                                <div>
                                    <strong>Desprendible rechazado por Coordinación:</strong> 
                                    <c:out value="${not empty proy.observacion_pago ? proy.observacion_pago : 'El comprobante PDF no es válido o no es legible. Por favor sube un enlace corregido.'}" />
                                </div>
                            </div>
                        </c:if>

                        <c:if test="${f1Completa and not empty proy.observacion_pago}">
                            <div class="alert alert-success py-2 small d-flex align-items-center mb-3">
                                <i class="bi bi-check-circle-fill fs-5 me-2"></i>
                                <div>
                                    <strong>Observación de Coordinación:</strong> <c:out value="${proy.observacion_pago}" />
                                </div>
                            </div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/estudiante/desprendible_guardar.jsp" method="POST" class="row g-2 align-items-center">
                            <div class="col-md-9">
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-file-earmark-pdf-fill text-danger"></i></span>
                                    <input type="url" name="enlace_desprendible" class="form-control" required
                                           value="<c:out value='${tieneDesprendible ? proy.enlace_desprendible : \"\"}' />"
                                           placeholder="https://drive.google.com/file/d/... (Enlace al PDF del desprendible de pago)"
                                           oninput="validarUrlDocumento(this)">
                                </div>
                            </div>
                            <div class="col-md-3 d-flex gap-2">
                                <button type="submit" class="btn ${f1Completa ? 'btn-outline-success' : 'btn-uts-primary'} w-100 fw-semibold">
                                    <i class="bi bi-cloud-arrow-up-fill me-1"></i> <c:out value="${tieneDesprendible ? 'Actualizar Comprobante' : 'Subir Desprendible'}" />
                                </button>
                                <c:if test="${tieneDesprendible}">
                                    <a href="<c:out value='${proy.enlace_desprendible}' />" target="_blank" class="btn btn-outline-primary" title="Abrir Desprendible">
                                        <i class="bi bi-box-arrow-up-right"></i>
                                    </a>
                                </c:if>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- =============================================================== -->
            <!-- FASE 2: ENVIAR PROPUESTA AL DIRECTOR                            -->
            <!-- =============================================================== -->
            <div class="col-12">
                <div class="card card-uts shadow-sm border-start border-4 ${f2Completa ? 'border-start-success' : (f2Desbloqueada ? 'border-start-primary' : '')}" style="${!f2Desbloqueada ? 'opacity: 0.72;' : ''}">
                    <div class="card-header bg-white py-3 d-flex flex-wrap justify-content-between align-items-center gap-2">
                        <div class="d-flex align-items-center gap-2">
                            <span class="badge ${f2Completa ? 'bg-success' : (f2Desbloqueada ? 'bg-primary' : 'bg-secondary')} rounded-pill px-3 py-2">FASE 2</span>
                            <h5 class="mb-0 fw-bold text-dark">Enviar la Propuesta de Grado al Director</h5>
                        </div>
                        <c:choose>
                            <c:when test="${f2Completa}">
                                <span class="badge bg-success-subtle text-success border border-success-subtle px-3 py-2">
                                    <i class="bi bi-check-circle-fill me-1"></i>Completada (Propuesta enviada al Director)
                                </span>
                            </c:when>
                            <c:when test="${f2Desbloqueada}">
                                <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-3 py-2">
                                    <i class="bi bi-unlock-fill me-1"></i>Habilitada para Envío
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-secondary-subtle text-secondary border px-3 py-2">
                                    <i class="bi bi-lock-fill me-1"></i>Bloqueada (Requiere Fase 1)
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="card-body p-4">
                        <c:choose>
                            <c:when test="${!f2Desbloqueada}">
                                <div class="text-muted small">
                                    <i class="bi bi-lock-fill me-1"></i> Esta sección se habilitará automáticamente una vez subas el desprendible de pago en la <strong>Fase 1</strong>.
                                </div>
                            </c:when>
                            <c:otherwise>
                                <p class="text-secondary small mb-3">
                                    Registra los datos de tu propuesta (o selecciona una idea del Banco de Ideas), elige a tu Docente Director y sube el <strong>enlace al PDF de tu propuesta en Drive/Nube</strong>.
                                </p>
                                <c:if test="${f2Completa}">
                                    <div class="p-3 bg-light rounded-3 mb-3 border d-flex flex-wrap justify-content-between align-items-center gap-2">
                                        <div>
                                            <div class="fw-bold text-dark"><c:out value="${proy.titulo}" /></div>
                                            <small class="text-muted">Director asignado: <strong><c:out value="${not empty proy.nom_dir ? proy.nom_dir.concat(' ').concat(proy.ape_dir) : 'Pendiente'}" /></strong> &bull; Archivo: <c:out value="${proy.enlace_documento}" /></small>
                                        </div>
                                        <a href="<c:out value='${proy.enlace_documento}' />" target="_blank" class="btn btn-sm btn-outline-primary">
                                            <i class="bi bi-file-earmark-pdf me-1"></i> Ver Propuesta Enviada
                                        </a>
                                    </div>
                                </c:if>
                                <c:if test="${!f2Completa or proy.estado == 'Idea seleccionada' or proy.estado == 'Anteproyecto radicado' or (proy.estado == 'Devuelto con observaciones' and empty proy.enlace_documento_final)}">
                                    <div class="d-flex flex-wrap gap-2">
                                        <a href="${pageContext.request.contextPath}/estudiante/anteproyecto_formulario.jsp" class="btn btn-uts-primary shadow-sm">
                                            <i class="bi bi-send-check-fill me-1"></i> Diligenciar y Enviar Propuesta al Director
                                        </a>
                                        <a href="${pageContext.request.contextPath}/estudiante/banco_ideas.jsp" class="btn btn-outline-secondary">
                                            <i class="bi bi-lightbulb me-1"></i> Explorar Banco de Ideas
                                        </a>
                                    </div>
                                </c:if>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- =============================================================== -->
            <!-- FASE 3: DIRECTOR REVISA PROPUESTA Y ENVÍA AL COMITÉ EVALUADOR   -->
            <!-- =============================================================== -->
            <div class="col-12">
                <div class="card card-uts shadow-sm border-start border-4 ${f3Completa ? 'border-start-success' : (f3Desbloqueada ? 'border-start-warning' : '')}" style="${!f3Desbloqueada ? 'opacity: 0.72;' : ''}">
                    <div class="card-header bg-white py-3 d-flex flex-wrap justify-content-between align-items-center gap-2">
                        <div class="d-flex align-items-center gap-2">
                            <span class="badge ${f3Completa ? 'bg-success' : (f3Desbloqueada ? 'bg-warning text-dark' : 'bg-secondary')} rounded-pill px-3 py-2">FASE 3</span>
                            <h5 class="mb-0 fw-bold text-dark">Revisión de la Propuesta por el Director y Envío al Comité Evaluador</h5>
                        </div>
                        <c:choose>
                            <c:when test="${f3Completa}">
                                <span class="badge bg-success-subtle text-success border border-success-subtle px-3 py-2">
                                    <i class="bi bi-check-circle-fill me-1"></i>Propuesta Aprobada (Fase 4 Desbloqueada)
                                </span>
                            </c:when>
                            <c:when test="${f3Desbloqueada}">
                                <span class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle px-3 py-2">
                                    <i class="bi bi-hourglass-split me-1"></i>En Proceso (<c:out value="${proy.estado}" />)
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-secondary-subtle text-secondary border px-3 py-2">
                                    <i class="bi bi-lock-fill me-1"></i>Bloqueada (Requiere Fase 2)
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="card-body p-4">
                        <c:choose>
                            <c:when test="${!f3Desbloqueada}">
                                <div class="text-muted small">
                                    <i class="bi bi-lock-fill me-1"></i> Esta fase se desbloquea cuando envíes tu propuesta al Director en la <strong>Fase 2</strong>.
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <div class="p-3 bg-light rounded-3 border h-100">
                                            <div class="fw-bold text-dark mb-1"><i class="bi bi-person-workspace text-primary me-1"></i>1. Revisión del Director:</div>
                                            <p class="small text-secondary mb-2">
                                                Director: <strong><c:out value="${not empty proy.nom_dir ? proy.nom_dir.concat(' ').concat(proy.ape_dir) : 'Por asignar'}" /></strong>
                                            </p>
                                            <c:if test="${not empty proy.enlace_aval_director}">
                                                <a href="<c:out value='${proy.enlace_aval_director}' />" target="_blank" class="btn btn-sm btn-outline-primary">
                                                    <i class="bi bi-file-earmark-check me-1"></i> Ver Documento/Aval del Director
                                                </a>
                                            </c:if>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="p-3 bg-light rounded-3 border h-100">
                                            <div class="fw-bold text-dark mb-1"><i class="bi bi-people-fill text-info me-1"></i>2. Dictamen del Comité Evaluador:</div>
                                            <p class="small text-secondary mb-2">
                                                Evaluador: <strong><c:out value="${not empty proy.nom_eva ? proy.nom_eva.concat(' ').concat(proy.ape_eva) : 'Se asigna al enviar al Comité'}" /></strong>
                                            </p>
                                            <span class="badge ${f3Completa ? 'bg-success' : 'bg-secondary'}">
                                                <c:out value="${f3Completa ? 'Concepto Favorable - Propuesta Aprobada' : proy.estado}" />
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- =============================================================== -->
            <!-- FASE 4: SUBIR EL INFORME DEL PROYECTO AL DIRECTOR               -->
            <!-- =============================================================== -->
            <div class="col-12">
                <div class="card card-uts shadow-sm border-start border-4 ${f4Completa ? 'border-start-success' : (f4Desbloqueada ? 'border-start-primary' : '')}" style="${!f4Desbloqueada ? 'opacity: 0.72;' : ''}">
                    <div class="card-header bg-white py-3 d-flex flex-wrap justify-content-between align-items-center gap-2">
                        <div class="d-flex align-items-center gap-2">
                            <span class="badge ${f4Completa ? 'bg-success' : (f4Desbloqueada ? 'bg-primary' : 'bg-secondary')} rounded-pill px-3 py-2">FASE 4</span>
                            <h5 class="mb-0 fw-bold text-dark">Subir el Informe del Proyecto al Director</h5>
                        </div>
                        <c:choose>
                            <c:when test="${f4Completa}">
                                <span class="badge bg-success-subtle text-success border border-success-subtle px-3 py-2">
                                    <i class="bi bi-check-circle-fill me-1"></i>Completada (Informe enviado al Director)
                                </span>
                            </c:when>
                            <c:when test="${f4Desbloqueada}">
                                <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-3 py-2">
                                    <i class="bi bi-unlock-fill me-1"></i>Desbloqueada para Subir Informe
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-secondary-subtle text-secondary border px-3 py-2">
                                    <i class="bi bi-lock-fill me-1"></i>Bloqueada (Requiere aprobación en Fase 3)
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="card-body p-4">
                        <c:choose>
                            <c:when test="${!f4Desbloqueada}">
                                <div class="text-muted small">
                                    <i class="bi bi-lock-fill me-1"></i> Esta fase se desbloquea una vez el Director y el Comité Evaluador aprueben tu propuesta en la <strong>Fase 3</strong>.
                                </div>
                            </c:when>
                            <c:otherwise>
                                <p class="text-secondary small mb-3">
                                    Sube el enlace al <strong>PDF del Informe del Proyecto (Monografía / Entrega Final)</strong> en Google Drive o nube para que tu Director lo revise.
                                </p>
                                <c:if test="${not empty proy.enlace_documento_final}">
                                    <div class="p-3 bg-light rounded-3 mb-3 border d-flex flex-wrap justify-content-between align-items-center gap-2">
                                        <div>
                                            <div class="fw-bold text-success"><i class="bi bi-file-earmark-pdf-fill me-1"></i>Informe del Proyecto Cargado:</div>
                                            <small class="text-muted text-break"><c:out value="${proy.enlace_documento_final}" /></small>
                                        </div>
                                        <a href="<c:out value='${proy.enlace_documento_final}' />" target="_blank" class="btn btn-sm btn-success">
                                            <i class="bi bi-box-arrow-up-right me-1"></i> Abrir Informe
                                        </a>
                                    </div>
                                </c:if>
                                <c:if test="${!f4Completa or proy.estado == 'En desarrollo' or proy.estado == 'Aprobado' or (proy.estado == 'Devuelto con observaciones' and not empty proy.enlace_documento_final)}">
                                    <form action="${pageContext.request.contextPath}/estudiante/entrega_final_guardar.jsp" method="POST" class="row g-3 bg-light p-3 rounded-3 border">
                                        <input type="hidden" name="id_anteproyecto" value="${proy.id_anteproyecto}">
                                        <input type="hidden" name="estado_anterior" value="${proy.estado}">
                                        <div class="col-md-12">
                                            <label class="form-label fw-semibold small mb-1"><span class="text-danger">*</span> Enlace al PDF del Informe del Proyecto (Drive / Nube):</label>
                                            <input type="url" name="enlace_documento_final" class="form-control" required
                                                   value="<c:out value='${proy.enlace_documento_final}' />"
                                                   placeholder="https://drive.google.com/file/d/... (Link del Informe del Proyecto)"
                                                   oninput="validarUrlDocumento(this)">
                                        </div>
                                        <div class="col-md-12">
                                            <label class="form-label fw-semibold small mb-1"><span class="text-danger">*</span> Resumen del Informe y Conclusiones:</label>
                                            <textarea name="resumen_documento_final" class="form-control" rows="2" required
                                                      placeholder="Síntesis de resultados y conclusiones del informe..."><c:out value='${proy.resumen_documento_final}' /></textarea>
                                        </div>
                                        <div class="col-md-12 text-end">
                                            <button type="submit" class="btn btn-uts-primary fw-semibold">
                                                <i class="bi bi-send-check-fill me-1"></i> Subir y Enviar Informe al Director (Completar Fase 4)
                                            </button>
                                        </div>
                                    </form>
                                </c:if>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- =============================================================== -->
            <!-- FASE 5: DIRECTOR ENVÍA EL INFORME AL COMITÉ EVALUADOR           -->
            <!-- =============================================================== -->
            <div class="col-12">
                <div class="card card-uts shadow-sm border-start border-4 ${f5Completa ? 'border-start-success' : (f5Desbloqueada ? 'border-start-warning' : '')}" style="${!f5Desbloqueada ? 'opacity: 0.72;' : ''}">
                    <div class="card-header bg-white py-3 d-flex flex-wrap justify-content-between align-items-center gap-2">
                        <div class="d-flex align-items-center gap-2">
                            <span class="badge ${f5Completa ? 'bg-success' : (f5Desbloqueada ? 'bg-warning text-dark' : 'bg-secondary')} rounded-pill px-3 py-2">FASE 5</span>
                            <h5 class="mb-0 fw-bold text-dark">El Director Revisa el Informe y lo Envía al Comité Evaluador</h5>
                        </div>
                        <c:choose>
                            <c:when test="${f5Completa}">
                                <span class="badge bg-success-subtle text-success border border-success-subtle px-3 py-2">
                                    <i class="bi bi-check-circle-fill me-1"></i>Completada (Informe enviado al Comité Evaluador)
                                </span>
                            </c:when>
                            <c:when test="${f5Desbloqueada}">
                                <span class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle px-3 py-2">
                                    <i class="bi bi-hourglass-split me-1"></i>En Revisión del Informe por el Director
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-secondary-subtle text-secondary border px-3 py-2">
                                    <i class="bi bi-lock-fill me-1"></i>Bloqueada (Requiere Fase 4)
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="card-body p-4">
                        <c:choose>
                            <c:when test="${!f5Desbloqueada}">
                                <div class="text-muted small">
                                    <i class="bi bi-lock-fill me-1"></i> Esta fase se desbloquea cuando subas el Informe del Proyecto al Director en la <strong>Fase 4</strong>.
                                </div>
                            </c:when>
                            <c:otherwise>
                                <p class="text-secondary small mb-2">
                                    El Docente Director (<strong><c:out value="${proy.nom_dir} ${proy.ape_dir}" /></strong>) revisa el Informe del Proyecto, adjunta su aval y lo remite al Comité Evaluador.
                                </p>
                                <c:if test="${not empty proy.enlace_informe_director}">
                                    <a href="<c:out value='${proy.enlace_informe_director}' />" target="_blank" class="btn btn-sm btn-outline-primary">
                                        <i class="bi bi-file-earmark-check me-1"></i> Ver Aval de Informe del Director
                                    </a>
                                </c:if>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- =============================================================== -->
            <!-- FASE 6 (FASE FINAL): NOTA FINAL Y APROBACIÓN DEL PROYECTO       -->
            <!-- =============================================================== -->
            <div class="col-12">
                <div class="card card-uts shadow-sm border-start border-4 ${f6Completa ? 'border-start-success' : (f6Desbloqueada ? 'border-start-info' : '')}" style="${!f6Desbloqueada ? 'opacity: 0.72;' : ''}">
                    <div class="card-header bg-white py-3 d-flex flex-wrap justify-content-between align-items-center gap-2">
                        <div class="d-flex align-items-center gap-2">
                            <span class="badge ${f6Completa ? 'bg-success' : (f6Desbloqueada ? 'bg-info text-dark' : 'bg-secondary')} rounded-pill px-3 py-2">FASE 6 &bull; FINAL</span>
                            <h5 class="mb-0 fw-bold text-dark">Evaluación del Comité Evaluador, Nota Final y Aprobación del Proyecto</h5>
                        </div>
                        <c:choose>
                            <c:when test="${f6Completa}">
                                <span class="badge bg-success px-3 py-2 fs-6">
                                    <i class="bi bi-trophy-fill me-1"></i>¡PROYECTO APROBADO!
                                </span>
                            </c:when>
                            <c:when test="${f6Desbloqueada}">
                                <span class="badge bg-info-subtle text-info-emphasis border border-info-subtle px-3 py-2">
                                    <i class="bi bi-hourglass-split me-1"></i>En Evaluación Final por Comité Evaluador
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-secondary-subtle text-secondary border px-3 py-2">
                                    <i class="bi bi-lock-fill me-1"></i>Bloqueada (Requiere Fase 5)
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="card-body p-4">
                        <c:choose>
                            <c:when test="${!f6Desbloqueada}">
                                <div class="text-muted small">
                                    <i class="bi bi-lock-fill me-1"></i> La fase final se desbloquea cuando el Director envíe tu Informe del Proyecto al Comité Evaluador en la <strong>Fase 5</strong>.
                                </div>
                            </c:when>
                            <c:when test="${f6Completa}">
                                <div class="p-4 bg-success-subtle border border-success rounded-3">
                                    <div class="row align-items-center gy-3">
                                        <div class="col-md-8">
                                            <h4 class="fw-bold text-success mb-1">
                                                <i class="bi bi-patch-check-fill me-2"></i>¡Felicitaciones! Tu Proyecto de Grado ha sido APROBADO
                                            </h4>
                                            <p class="text-dark mb-2">
                                                El Comité Evaluador ha emitido la calificación final aprobatoria de tu Trabajo de Grado: <strong>"<c:out value="${proy.titulo}" />"</strong>.
                                            </p>
                                            <div class="d-flex flex-wrap gap-2 mt-2">
                                                <c:if test="${not empty proy.enlace_acta_final}">
                                                    <a href="<c:out value='${proy.enlace_acta_final}' />" target="_blank" class="btn btn-sm btn-success">
                                                        <i class="bi bi-file-earmark-medical-fill me-1"></i> Ver Acta / Documento de Aprobación Final
                                                    </a>
                                                </c:if>
                                                <a href="${pageContext.request.contextPath}/estudiante/informe_calificaciones.jsp" class="btn btn-sm btn-outline-success">
                                                    <i class="bi bi-award-fill me-1"></i> Ver Desglose Completo de Notas
                                                </a>
                                            </div>
                                        </div>
                                        <div class="col-md-4 text-md-end">
                                            <div class="p-3 bg-white rounded-3 shadow-sm border text-center">
                                                <div class="small text-secondary fw-bold text-uppercase">Nota Final Definitiva</div>
                                                <div class="display-5 fw-bold text-success my-1">
                                                    <fmt:formatNumber value="${not empty proy.nota_final_eva ? proy.nota_final_eva : proy.promedio_notas}" pattern="0.0" />
                                                    <span class="fs-5 text-muted">/ 5.0</span>
                                                </div>
                                                <span class="badge bg-success rounded-pill px-3">APROBADO</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="alert alert-info mb-0 d-flex align-items-center">
                                    <i class="bi bi-info-circle-fill fs-4 me-3"></i>
                                    <div>
                                        El Director ya remitió tu Informe del Proyecto al Comité Evaluador (<strong><c:out value="${proy.nom_eva} ${proy.ape_eva}" /></strong>). 
                                        Una vez el Evaluador asiente la calificación final, verás aquí tu <strong>Nota Final y la Aprobación del Proyecto</strong>.
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="/includes/footer.jspf" %>
