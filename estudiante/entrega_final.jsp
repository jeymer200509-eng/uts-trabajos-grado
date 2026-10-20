<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="ESTUDIANTE" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<sql:query var="qProy" dataSource="${conn}">
    SELECT * FROM anteproyectos WHERE id_estudiante = ?
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<c:choose>
    <c:when test="${qProy.rowCount == 0}">
        <c:set var="mensaje_error" value="No tienes ningún proyecto registrado en el sistema." scope="session" />
        <c:redirect url="/estudiante/index.jsp" />
    </c:when>
    <c:otherwise>
        <c:set var="proy" value="${qProy.rows[0]}" />
        <%-- Validar que el proyecto esté al menos aprobado o en desarrollo o ya entregado --%>
        <c:if test="${proy.estado != 'Aprobado' and proy.estado != 'En desarrollo' and proy.estado != 'Documento final entregado'}">
            <c:set var="mensaje_error" value="Para realizar la entrega final, tu anteproyecto debe haber sido aprobado previamente (Estado actual: ${proy.estado})." scope="session" />
            <c:redirect url="/estudiante/anteproyecto_ver.jsp" />
        </c:if>
    </c:otherwise>
</c:choose>

<c:set var="pageTitle" value="Entrega Final de Trabajo de Grado - UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<div class="container py-4">
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <div class="card card-uts shadow-sm">
                <div class="card-header card-header-uts py-3 d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 fw-bold">
                        <i class="bi bi-file-earmark-check-fill me-2"></i>Radicación del Documento Final de Grado
                    </h5>
                    <a href="${pageContext.request.contextPath}/estudiante/anteproyecto_ver.jsp" class="btn btn-sm btn-light">
                        <i class="bi bi-arrow-left"></i> Volver
                    </a>
                </div>

                <div class="card-body p-4">
                    <div class="p-3 bg-light rounded-3 mb-4 border">
                        <div class="small text-muted">Proyecto de Grado:</div>
                        <h5 class="fw-bold text-dark mb-1"><c:out value="${proy.titulo}" /></h5>
                        <div class="small text-secondary">
                            Estado actual: <span class="badge badge-estado badge-estado-${fn:replace(fn:toLowerCase(proy.estado), ' ', '-')}"><c:out value="${proy.estado}" /></span>
                        </div>
                    </div>

                    <form action="${pageContext.request.contextPath}/estudiante/entrega_final_guardar.jsp" method="POST">
                        <input type="hidden" name="id_anteproyecto" value="${proy.id_anteproyecto}">
                        <input type="hidden" name="estado_anterior" value="${proy.estado}">

                        <div class="mb-4">
                            <label for="enlace_documento_final" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Enlace de la Monografía / Documento Final (Google Drive / OneDrive):
                            </label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-link-45deg fs-5 text-primary"></i></span>
                                <input type="url" class="form-control form-control-lg" id="enlace_documento_final" name="enlace_documento_final" 
                                       value="<c:out value='${proy.enlace_documento_final != null ? proy.enlace_documento_final : \"\"}' />" required 
                                       placeholder="https://drive.google.com/file/d/.../view" 
                                       oninput="validarUrlDocumento(this)">
                            </div>
                            <div class="form-text">
                                Debe contener la versión final del informe escrito (normas APA 7ma UTS), manuales y enlaces al repositorio de código fuente.
                            </div>
                        </div>

                        <div class="mb-4">
                            <label for="resumen_documento_final" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Resumen de Resultados y Conclusiones:
                            </label>
                            <textarea class="form-control" id="resumen_documento_final" name="resumen_documento_final" rows="5" required 
                                      placeholder="Sintetice los logros alcanzados, prototipo o software desarrollado, impacto y conclusiones principales..."><c:out value='${proy.resumen_documento_final != null ? proy.resumen_documento_final : ""}' /></textarea>
                        </div>

                        <div class="d-flex justify-content-end gap-2 pt-3 border-top">
                            <a href="${pageContext.request.contextPath}/estudiante/anteproyecto_ver.jsp" class="btn btn-secondary">
                                Cancelar
                            </a>
                            <button type="submit" class="btn btn-uts-primary px-4 shadow-sm" onclick="return confirmarAccion(event, '¿Confirma la radicación de la entrega final de su documento de grado?');">
                                <i class="bi bi-send-check-fill me-1"></i> Radicar Entrega Final
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="/includes/footer.jspf" %>
