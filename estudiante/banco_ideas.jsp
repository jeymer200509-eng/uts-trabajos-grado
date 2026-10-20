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

<%-- Verificar estado del proyecto y si ya subió el desprendible de pago (Fase 1) --%>
<sql:query var="qCheckEst" dataSource="${conn}">
    SELECT id_anteproyecto, titulo, estado, enlace_desprendible, enlace_documento FROM anteproyectos WHERE id_estudiante = ?
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>
<c:set var="tieneRegistro" value="${qCheckEst.rowCount > 0}" />
<c:set var="fase1Completa" value="${tieneRegistro and not empty qCheckEst.rows[0].enlace_desprendible}" />
<c:set var="yaEnvioPropuesta" value="${tieneRegistro and qCheckEst.rows[0].estado != 'Idea seleccionada' and qCheckEst.rows[0].enlace_documento != 'PENDIENTE'}" />

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
    <div class="mb-4">
        <h2 class="fw-bold mb-1 text-dark">
            <i class="bi bi-lightbulb-fill text-warning me-2"></i>Banco de Ideas para Grado
        </h2>
        <p class="text-secondary mb-0">Explore las propuestas y líneas de investigación publicadas por los comités y grupos de investigación de las UTS.</p>
    </div>

    <c:if test="${!fase1Completa}">
        <div class="alert alert-danger shadow-sm d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
            <div class="d-flex align-items-center">
                <i class="bi bi-lock-fill fs-3 me-3 text-danger"></i>
                <div>
                    <strong>Fase Bloqueada (Falta Desprendible de Pago):</strong> Para seleccionar una idea y enviar la propuesta al Director, primero debes subir el enlace de tu <strong>Desprendible de Pago (Fase 1)</strong>.
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/estudiante/index.jsp" class="btn btn-danger btn-sm fw-semibold">
                <i class="bi bi-upload me-1"></i> Ir a Fase 1 (Subir Desprendible)
            </a>
        </div>
    </c:if>

    <c:if test="${yaEnvioPropuesta}">
        <div class="alert alert-warning shadow-sm d-flex align-items-center mb-4">
            <i class="bi bi-exclamation-triangle-fill fs-3 me-3 text-warning"></i>
            <div>
                <strong>Aviso de Restricción UTS:</strong> Ya tienes una propuesta de grado enviada en el sistema: 
                "<strong><c:out value="${qCheckEst.rows[0].titulo}" /></strong>" (Estado: <c:out value="${qCheckEst.rows[0].estado}" />).
                <div class="small">La normativa institucional solo permite tener un proyecto activo simultáneamente.</div>
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
                                    <c:when test="${!fase1Completa}">
                                        <button class="btn btn-sm btn-outline-danger" disabled>
                                            <i class="bi bi-lock-fill me-1"></i> Suba Desprendible (Fase 1)
                                        </button>
                                    </c:when>
                                    <c:when test="${!yaEnvioPropuesta}">
                                        <form action="${pageContext.request.contextPath}/estudiante/idea_seleccionar.jsp" method="POST" onsubmit="return confirmarAccion(event, '¿Desea postularse y seleccionar esta idea para enviarla al Director?');">
                                            <input type="hidden" name="id_idea" value="${idea.id_idea}">
                                            <button type="submit" class="btn btn-sm btn-uts-primary">
                                                <i class="bi bi-check2-circle me-1"></i> Seleccionar Esta Idea
                                            </button>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="btn btn-sm btn-outline-secondary" disabled>
                                            Ya tienes proyecto activo
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
                        <h5>No hay ideas disponibles en este momento</h5>
                        <p class="text-muted small">Puedes radicar una propuesta libre de anteproyecto o esperar una nueva convocatoria de la Coordinación.</p>
                        <c:if test="${!yaTieneProyecto}">
                            <div>
                                <a href="${pageContext.request.contextPath}/estudiante/anteproyecto_formulario.jsp" class="btn btn-uts-primary">
                                    <i class="bi bi-pencil-square me-1"></i> Radicar Propuesta Libre
                                </a>
                            </div>
                        </c:if>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<%@ include file="/includes/footer.jspf" %>
