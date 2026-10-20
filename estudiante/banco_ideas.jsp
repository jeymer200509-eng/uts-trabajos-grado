<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="ESTUDIANTE" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Banco de Ideas - Estudiante UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<%-- Verificar si el estudiante ya seleccionó una idea --%>
<sql:query var="qCheckEst" dataSource="${conn}">
    SELECT id_anteproyecto, id_idea, titulo, linea_investigacion, estado, enlace_desprendible, estado_pago, observacion_pago, enlace_documento
    FROM anteproyectos WHERE id_estudiante = ?
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>
<c:set var="tieneIdeaSeleccionada" value="${qCheckEst.rowCount > 0}" />
<c:if test="${tieneIdeaSeleccionada}">
    <c:set var="miProy" value="${qCheckEst.rows[0]}" />
</c:if>

<%-- Consultar ideas disponibles --%>
<sql:query var="qIdeasDisp" dataSource="${conn}">
    SELECT i.*, p.nombre_programa, p.nivel, u.nombres AS nom_coord, u.apellidos AS ape_coord
    FROM ideas i
    INNER JOIN programas p ON i.id_programa = p.id_programa
    INNER JOIN usuarios u ON i.id_coordinador = u.id_usuario
    WHERE i.estado = 'Disponible'
    ORDER BY i.fecha_publicacion DESC
</sql:query>

<div class="container px-lg-4 py-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
        <div>
            <h2 class="fw-bold mb-1 text-dark">
                <i class="bi bi-lightbulb-fill text-warning me-2"></i>Banco de Ideas para Grado
            </h2>
            <p class="text-secondary mb-0">Paso 1: Selecciona una idea del banco institucional para habilitar la carga de tu desprendible de pago y continuar las fases de tu proyecto.</p>
        </div>
        <a href="${pageContext.request.contextPath}/estudiante/index.jsp" class="btn btn-outline-secondary">
            <i class="bi bi-diagram-3 me-1"></i> Ir a Mi Panel de Fases
        </a>
    </div>

    <%-- Si ya seleccionó una idea, mostrar tarjeta de su idea con la opción habilitada de subir el Desprendible de Pago --%>
    <c:if test="${tieneIdeaSeleccionada}">
        <div class="card card-uts shadow-sm mb-4 border-start border-4 border-start-success">
            <div class="card-header bg-white py-3 d-flex flex-wrap justify-content-between align-items-center gap-2">
                <div>
                    <span class="badge bg-success me-2"><i class="bi bi-check2-circle me-1"></i>Idea Seleccionada</span>
                    <strong class="text-dark"><c:out value="${miProy.titulo}" /></strong>
                </div>
                <span class="badge bg-light text-secondary border">Estado Proyecto: <c:out value="${miProy.estado}" /></span>
            </div>
            <div class="card-body p-4">
                <h6 class="fw-bold text-dark mb-2">
                    <i class="bi bi-receipt-cutoff text-primary me-1"></i>Fase 1 Habilitada: Subir Desprendible de Pago (Link PDF Drive / Nube)
                </h6>
                <p class="small text-secondary mb-3">
                    Ya tienes tu idea seleccionada. Sube aquí el enlace a tu desprendible de pago en PDF para que <strong>Coordinación</strong> lo revise y acepte, desbloqueando el envío de la propuesta al Director.
                </p>

                <c:if test="${not empty miProy.enlace_desprendible and miProy.estado_pago == 'En revisión'}">
                    <div class="alert alert-warning py-2 small mb-3">
                        <i class="bi bi-hourglass-split me-1"></i>
                        <strong>En revisión por Coordinación:</strong> Tu desprendible ya fue subido y está pendiente de aceptación por el Coordinador.
                    </div>
                </c:if>

                <c:if test="${not empty miProy.enlace_desprendible and miProy.estado_pago == 'Rechazado'}">
                    <div class="alert alert-danger py-2 small mb-3">
                        <i class="bi bi-x-circle-fill me-1"></i>
                        <strong>Rechazado por Coordinación:</strong> <c:out value="${miProy.observacion_pago}" />. Por favor sube un nuevo enlace válido.
                    </div>
                </c:if>

                <c:if test="${not empty miProy.enlace_desprendible and miProy.estado_pago == 'Aprobado'}">
                    <div class="alert alert-success py-2 small d-flex flex-wrap justify-content-between align-items-center mb-3 gap-2">
                        <div>
                            <i class="bi bi-check-circle-fill me-1"></i>
                            <strong>¡Desprendible Aceptado por Coordinación!</strong> Ya tienes desbloqueadas las siguientes fases en tu panel.
                        </div>
                        <a href="${pageContext.request.contextPath}/estudiante/index.jsp" class="btn btn-sm btn-success fw-semibold">
                            Continuar a Fase 2 (Enviar Propuesta al Director) &rarr;
                        </a>
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/estudiante/desprendible_guardar.jsp" method="POST" class="row g-2 align-items-center">
                    <div class="col-md-8">
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-file-earmark-pdf-fill text-danger"></i></span>
                            <input type="url" name="enlace_desprendible" class="form-control" required
                                   value="<c:out value='${miProy.enlace_desprendible}' />"
                                   placeholder="https://drive.google.com/file/d/... (Enlace al PDF del desprendible de pago)"
                                   oninput="validarUrlDocumento(this)">
                        </div>
                    </div>
                    <div class="col-md-4 d-flex gap-2">
                        <button type="submit" class="btn btn-uts-primary flex-grow-1 fw-semibold">
                            <i class="bi bi-cloud-arrow-up-fill me-1"></i> <c:out value="${not empty miProy.enlace_desprendible ? 'Actualizar Desprendible' : 'Subir Desprendible de Pago'}" />
                        </button>
                        <c:if test="${not empty miProy.enlace_desprendible}">
                            <a href="<c:out value='${miProy.enlace_desprendible}' />" target="_blank" class="btn btn-outline-primary" title="Ver PDF">
                                <i class="bi bi-box-arrow-up-right"></i>
                            </a>
                        </c:if>
                    </div>
                </form>
            </div>
        </div>
    </c:if>

    <div class="row g-4">
        <c:choose>
            <c:when test="${qIdeasDisp.rowCount > 0}">
                <c:forEach var="idea" items="${qIdeasDisp.rows}">
                    <div class="col-lg-6">
                        <div class="card card-uts card-uts-hover h-100 shadow-sm border-start border-4 border-start-success">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <span class="badge bg-primary-subtle text-primary border border-primary-subtle">
                                        <c:out value="${idea.nombre_programa}" />
                                    </span>
                                    <span class="badge bg-success rounded-pill">
                                        <i class="bi bi-check-circle me-1"></i>Disponible
                                    </span>
                                </div>
                                <h5 class="card-title fw-bold text-dark mt-2">
                                    <c:out value="${idea.titulo}" />
                                </h5>
                                <div class="text-secondary small mb-3">
                                    <i class="bi bi-diagram-3-fill text-success me-1"></i>
                                    <strong>Línea:</strong> <c:out value="${idea.linea_investigacion}" />
                                </div>
                                <p class="card-text text-muted small">
                                    <c:out value="${idea.descripcion}" />
                                </p>
                            </div>
                            <div class="card-footer bg-white border-top-0 d-flex justify-content-between align-items-center py-3">
                                <span class="small text-muted"><i class="bi bi-people me-1"></i>Cupos: <c:out value="${idea.cupos}" /></span>
                                <c:choose>
                                    <c:when test="${!tieneIdeaSeleccionada}">
                                        <form action="${pageContext.request.contextPath}/estudiante/idea_seleccionar.jsp" method="POST" onsubmit="return confirmarAccion(event, '¿Desea seleccionar esta idea para habilitar la subida de su desprendible de pago?');">
                                            <input type="hidden" name="id_idea" value="${idea.id_idea}">
                                            <button type="submit" class="btn btn-sm btn-uts-primary">
                                                <i class="bi bi-check2-circle me-1"></i> Seleccionar Esta Idea
                                            </button>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="btn btn-sm btn-outline-secondary" disabled>
                                            Ya seleccionaste una idea
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="col-12">
                    <div class="card card-uts shadow-sm py-5 text-center text-muted">
                        <i class="bi bi-lightbulb-off fs-1 d-block mb-3 text-secondary opacity-50"></i>
                        <h5>No hay más ideas disponibles en este momento</h5>
                        <p class="text-muted small">Consulta el estado de tu proyecto en tu Panel de Fases.</p>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<%@ include file="/includes/footer.jspf" %>
