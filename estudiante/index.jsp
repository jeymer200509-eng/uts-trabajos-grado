<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="ESTUDIANTE" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Portal del Estudiante - Trabajos de Grado UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<%-- Consultar anteproyecto del estudiante logueado --%>
<sql:query var="qMiProyecto" dataSource="${conn}">
    SELECT a.*, 
           d.nombres AS nom_dir, d.apellidos AS ape_dir, d.correo AS correo_dir,
           e.nombres AS nom_eva, e.apellidos AS ape_eva, e.correo AS correo_eva,
           (SELECT COUNT(*) FROM calificaciones c WHERE c.id_anteproyecto = a.id_anteproyecto) AS total_calificaciones
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
                <div class="col-md-4 text-md-end">
                    <c:choose>
                        <c:when test="${!tieneProyecto}">
                            <a href="${pageContext.request.contextPath}/estudiante/banco_ideas.jsp" class="btn btn-uts-primary shadow-sm">
                                <i class="bi bi-lightbulb-fill me-1"></i> Explorar Banco de Ideas
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/estudiante/anteproyecto_ver.jsp" class="btn btn-uts-primary shadow-sm">
                                <i class="bi bi-journal-check me-1"></i> Ver Mi Anteproyecto
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <!-- Banner de Notificación Visual de Aprobación por Evaluador -->
    <c:if test="${tieneProyecto and (proy.estado == 'Aprobado' or proy.estado == 'En desarrollo')}">
        <div class="alert alert-success shadow-sm d-flex align-items-center p-3 mb-4 rounded-3" role="alert">
            <i class="bi bi-patch-check-fill fs-2 me-3 text-success"></i>
            <div>
                <h5 class="alert-heading fw-bold mb-1">¡Felicitaciones! Tu propuesta de grado ha sido APROBADA</h5>
                <p class="mb-0 small">El docente evaluador ha otorgado concepto favorable. Tu proyecto se encuentra oficialmente en fase de desarrollo.</p>
            </div>
        </div>
    </c:if>

    <!-- Estado del Proyecto o Alerta de Inicio -->
    <c:choose>
        <c:when test="${tieneProyecto}">
            <!-- Tarjeta de Estado del Proyecto -->
            <div class="row g-4 mb-4">
                <div class="col-lg-8">
                    <div class="card card-uts shadow-sm h-100">
                        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                            <h5 class="mb-0 fw-bold text-dark">
                                <i class="bi bi-journal-bookmark-fill text-success me-2"></i>Mi Trabajo de Grado Radicado
                            </h5>
                            <span class="badge badge-estado badge-estado-${fn:replace(fn:toLowerCase(proy.estado), ' ', '-')} fs-6">
                                <c:out value="${proy.estado}" />
                            </span>
                        </div>
                        <div class="card-body p-4">
                            <h4 class="fw-bold text-dark mb-2"><c:out value="${proy.titulo}" /></h4>
                            <p class="text-secondary small mb-3">
                                <i class="bi bi-diagram-3-fill text-success me-1"></i>
                                Línea de Investigación: <strong><c:out value="${proy.linea_investigacion}" /></strong> &bull; Versión: v<c:out value="${proy.version}" />
                            </p>
                            
                            <div class="mb-3">
                                <h6 class="fw-semibold text-secondary mb-1">Resumen Ejecutivo:</h6>
                                <p class="text-muted small"><c:out value="${proy.resumen}" /></p>
                            </div>

                            <div class="p-3 bg-light rounded-3 d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
                                <div>
                                    <div class="small fw-bold text-dark"><i class="bi bi-link-45deg"></i> Documento en Drive/OneDrive:</div>
                                    <small class="text-muted text-break"><c:out value="${proy.enlace_documento}" /></small>
                                </div>
                                <a href="<c:out value='${proy.enlace_documento}' />" target="_blank" class="btn btn-sm btn-outline-primary">
                                    <i class="bi bi-box-arrow-up-right me-1"></i> Abrir Enlace
                                </a>
                            </div>

                            <!-- Estado y Orientación de Próximos Pasos -->
                            <div class="alert alert-light border p-3 mb-0">
                                <div class="fw-bold text-dark mb-1"><i class="bi bi-info-circle text-primary me-1"></i> Siguiente Paso en el Proceso:</div>
                                <div class="small text-secondary">
                                    <c:choose>
                                        <c:when test="${proy.estado == 'Idea seleccionada'}">
                                            Debes radicar la propuesta formal de tu anteproyecto con el enlace a tu documento escrito en Google Drive.
                                        </c:when>
                                        <c:when test="${proy.estado == 'Anteproyecto radicado'}">
                                            Tu propuesta está radicada y a la espera de que Coordinación asigne a tu docente Director tutor.
                                        </c:when>
                                        <c:when test="${proy.estado == 'En revisión por director'}">
                                            Tu docente Director está revisando el documento para emitir calificación y observaciones.
                                        </c:when>
                                        <c:when test="${proy.estado == 'Devuelto con observaciones'}">
                                            <span class="text-danger fw-bold">El Director devolvió tu anteproyecto con observaciones.</span> Revisa la retroalimentación, actualiza tu enlace y vuelve a radicar.
                                        </c:when>
                                        <c:when test="${proy.estado == 'Aprobado por director'}">
                                            El Director aprobó la propuesta. Coordinación o el sistema la derivó al jurado Evaluador.
                                        </c:when>
                                        <c:when test="${proy.estado == 'En revisión por evaluador'}">
                                            El jurado evaluador asignado se encuentra dictaminando tu anteproyecto.
                                        </c:when>
                                        <c:when test="${proy.estado == 'En desarrollo' or proy.estado == 'Aprobado'}">
                                            Tu anteproyecto está formalmente avalado. Puedes avanzar en el desarrollo y registrar tu entrega final cuando esté lista.
                                        </c:when>
                                        <c:when test="${proy.estado == 'Documento final entregado'}">
                                            Has entregado tu documento final de grado. Tu director y evaluador calificarán tu monografía previo a la sustentación.
                                        </c:when>
                                        <c:when test="${proy.estado == 'Sustentado'}">
                                            ¡Proceso de trabajo de grado completado con éxito!
                                        </c:when>
                                        <c:otherwise>
                                            Consulta periódicamente el estado con tu director y coordinación.
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                        <div class="card-footer bg-white border-top-0 d-flex justify-content-between py-3">
                            <c:if test="${proy.estado == 'Idea seleccionada' or proy.estado == 'Anteproyecto radicado' or proy.estado == 'Devuelto con observaciones'}">
                                <a href="${pageContext.request.contextPath}/estudiante/anteproyecto_formulario.jsp" class="btn btn-sm btn-outline-primary">
                                    <i class="bi bi-pencil-square me-1"></i> Modificar Anteproyecto
                                </a>
                            </c:if>
                            <c:if test="${proy.estado == 'En desarrollo' or proy.estado == 'Aprobado'}">
                                <a href="${pageContext.request.contextPath}/estudiante/entrega_final.jsp" class="btn btn-sm btn-success">
                                    <i class="bi bi-file-earmark-arrow-up me-1"></i> Radicar Documento Final
                                </a>
                            </c:if>
                            <a href="${pageContext.request.contextPath}/estudiante/informe_calificaciones.jsp" class="btn btn-sm btn-outline-secondary">
                                <i class="bi bi-award-fill me-1"></i> Ver Calificaciones (<c:out value="${proy.total_calificaciones}" />)
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Tarjeta de Tutores Asignados -->
                <div class="col-lg-4">
                    <div class="card card-uts shadow-sm mb-4">
                        <div class="card-header bg-white py-3">
                            <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-people-fill text-success me-2"></i>Mis Tutores Asignados</h6>
                        </div>
                        <div class="card-body p-3">
                            <div class="p-3 bg-light rounded-3 mb-3 border">
                                <div class="small text-secondary fw-semibold">DOCENTE DIRECTOR (TUTOR):</div>
                                <c:choose>
                                    <c:when test="${not empty proy.nom_dir}">
                                        <div class="fw-bold text-dark fs-6 mt-1"><c:out value="${proy.nom_dir} ${proy.ape_dir}" /></div>
                                        <div class="small text-muted"><i class="bi bi-envelope"></i> <c:out value="${proy.correo_dir}" /></div>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-warning-subtle text-warning border border-warning-subtle mt-1">Pendiente de asignación</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="p-3 bg-light rounded-3 border">
                                <div class="small text-secondary fw-semibold">DOCENTE EVALUADOR (JURADO):</div>
                                <c:choose>
                                    <c:when test="${not empty proy.nom_eva}">
                                        <div class="fw-bold text-dark fs-6 mt-1"><c:out value="${proy.nom_eva} ${proy.ape_eva}" /></div>
                                        <div class="small text-muted"><i class="bi bi-envelope"></i> <c:out value="${proy.correo_eva}" /></div>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle mt-1">Pendiente de asignación</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <!-- Enlaces rápidos de consulta -->
                    <div class="card card-uts shadow-sm">
                        <div class="card-header bg-white py-3">
                            <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-bookmark-star-fill text-warning me-2"></i>Recursos Útiles</h6>
                        </div>
                        <div class="list-group list-group-flush">
                            <a href="${pageContext.request.contextPath}/comun/calendario.jsp" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center py-2">
                                <span><i class="bi bi-calendar3 text-danger me-2"></i>Calendario Académico</span>
                                <i class="bi bi-chevron-right text-muted"></i>
                            </a>
                            <a href="${pageContext.request.contextPath}/comun/formatos.jsp" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center py-2">
                                <span><i class="bi bi-file-earmark-arrow-down text-primary me-2"></i>Formatos Oficiales F-DC</span>
                                <i class="bi bi-chevron-right text-muted"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </c:when>

        <c:otherwise>
            <!-- Caso cuando aún no tiene anteproyecto radicado -->
            <div class="card card-uts shadow-sm py-5 text-center">
                <div class="card-body">
                    <div class="display-3 text-success mb-3">
                        <i class="bi bi-journal-plus"></i>
                    </div>
                    <h4 class="fw-bold text-dark">Aún no has registrado tu Trabajo de Grado</h4>
                    <p class="text-secondary col-md-8 mx-auto mb-4">
                        Para iniciar tu proceso de titulación en las UTS, puedes postularte a una idea del Banco de Proyectos Institucionales o radicar tu propia propuesta de anteproyecto.
                    </p>
                    <div class="d-flex justify-content-center gap-3">
                        <a href="${pageContext.request.contextPath}/estudiante/banco_ideas.jsp" class="btn btn-uts-primary btn-lg shadow-sm">
                            <i class="bi bi-lightbulb-fill me-1"></i> Seleccionar Idea de Grado
                        </a>
                        <a href="${pageContext.request.contextPath}/estudiante/anteproyecto_formulario.jsp" class="btn btn-outline-secondary btn-lg shadow-sm">
                            <i class="bi bi-file-earmark-plus me-1"></i> Radicar Propuesta Libre
                        </a>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<%@ include file="/includes/footer.jspf" %>
