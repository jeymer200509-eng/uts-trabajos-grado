<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="ESTUDIANTE" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<sql:query var="qProy" dataSource="${conn}">
    SELECT a.*, d.nombres AS nom_dir, d.apellidos AS ape_dir
    FROM anteproyectos a
    LEFT JOIN usuarios d ON a.id_director = d.id_usuario
    WHERE a.id_estudiante = ?
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<c:choose>
    <c:when test="${qProy.rowCount == 0 or empty qProy.rows[0].enlace_desprendible}">
        <c:set var="mensaje_error" value="Fase bloqueada: Primero debes completar la Fase 1 (Desprendible de Pago) y las fases de propuesta." scope="session" />
        <c:redirect url="/estudiante/index.jsp" />
    </c:when>
    <c:otherwise>
        <c:set var="proy" value="${qProy.rows[0]}" />
        <%-- Validar que la propuesta haya sido aprobada (Fase 4 desbloqueada) --%>
        <c:if test="${proy.estado != 'Aprobado' and proy.estado != 'En desarrollo' and proy.estado != 'Documento final entregado' and !(proy.estado == 'Devuelto con observaciones' and not empty proy.enlace_documento_final)}">
            <c:set var="mensaje_error" value="Fase bloqueada: Para subir el Informe del Proyecto al Director (Fase 4), tu propuesta primero debe haber sido revisada y aprobada (Estado actual: ${proy.estado})." scope="session" />
            <c:redirect url="/estudiante/index.jsp" />
        </c:if>
    </c:otherwise>
</c:choose>

<c:set var="pageTitle" value="Fase 4: Subir Informe del Proyecto al Director - UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<div class="container py-4">
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <div class="card card-uts shadow-sm">
                <div class="card-header card-header-uts py-3 d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 fw-bold">
                        <i class="bi bi-file-earmark-check-fill me-2"></i>Fase 4: Subir Informe del Proyecto al Director
                    </h5>
                    <a href="${pageContext.request.contextPath}/estudiante/index.jsp" class="btn btn-sm btn-light">
                        <i class="bi bi-arrow-left"></i> Volver al Panel de Fases
                    </a>
                </div>

                <div class="card-body p-4">
                    <div class="p-3 bg-light rounded-3 mb-4 border">
                        <div class="small text-muted">Proyecto de Grado Aprobado:</div>
                        <h5 class="fw-bold text-dark mb-1"><c:out value="${proy.titulo}" /></h5>
                        <div class="small text-secondary d-flex flex-wrap gap-3 mt-1">
                            <span>Director: <strong>Prof. <c:out value="${proy.nom_dir} ${proy.ape_dir}" /></strong></span>
                            <span>Estado actual: <span class="badge badge-estado badge-estado-${fn:replace(fn:toLowerCase(proy.estado), ' ', '-')}"><c:out value="${proy.estado}" /></span></span>
                        </div>
                    </div>

                    <form action="${pageContext.request.contextPath}/estudiante/entrega_final_guardar.jsp" method="POST">
                        <input type="hidden" name="id_anteproyecto" value="${proy.id_anteproyecto}">
                        <input type="hidden" name="estado_anterior" value="${proy.estado}">

                        <div class="mb-4 p-3 bg-success-subtle border border-success-subtle rounded-3">
                            <label for="enlace_documento_final" class="form-label fw-bold text-dark">
                                <span class="text-danger">*</span> Enlace al PDF del Informe del Proyecto (Google Drive / Nube):
                            </label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-file-earmark-pdf-fill fs-5 text-danger"></i></span>
                                <input type="url" class="form-control form-control-lg" id="enlace_documento_final" name="enlace_documento_final" 
                                       value="<c:out value='${proy.enlace_documento_final != null ? proy.enlace_documento_final : \"\"}' />" required 
                                       placeholder="https://drive.google.com/file/d/.../view" 
                                       oninput="validarUrlDocumento(this)">
                            </div>
                            <div class="form-text text-dark">
                                Adjunte el enlace al informe final del proyecto en la nube. Al enviarlo, se desbloqueará la <strong>Fase 5</strong> para que el Director lo revise y lo envíe al Comité Evaluador.
                            </div>
                        </div>

                        <div class="mb-4">
                            <label for="resumen_documento_final" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Resumen del Informe del Proyecto y Conclusiones:
                            </label>
                            <textarea class="form-control" id="resumen_documento_final" name="resumen_documento_final" rows="5" required 
                                      placeholder="Sintetice los logros alcanzados, desarrollo del proyecto, resultados y conclusiones principales..."><c:out value='${proy.resumen_documento_final != null ? proy.resumen_documento_final : ""}' /></textarea>
                        </div>

                        <div class="d-flex justify-content-end gap-2 pt-3 border-top">
                            <a href="${pageContext.request.contextPath}/estudiante/index.jsp" class="btn btn-secondary">
                                Cancelar
                            </a>
                            <button type="submit" class="btn btn-uts-primary px-4 shadow-sm" onclick="return confirmarAccion(event, '¿Confirma el envío del Informe del Proyecto al Director para habilitar la Fase 5?');">
                                <i class="bi bi-send-check-fill me-1"></i> Enviar Informe al Director (Completar Fase 4)
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="/includes/footer.jspf" %>
