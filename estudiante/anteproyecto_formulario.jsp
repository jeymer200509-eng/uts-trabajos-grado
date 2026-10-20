<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="ESTUDIANTE" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<%-- Consultar si ya tiene anteproyecto --%>
<sql:query var="qProy" dataSource="${conn}">
    SELECT * FROM anteproyectos WHERE id_estudiante = ?
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<c:set var="existe" value="${qProy.rowCount > 0}" />
<c:if test="${existe}">
    <c:set var="proy" value="${qProy.rows[0]}" />
    <%-- Validar que esté en un estado editable --%>
    <c:if test="${proy.estado != 'Idea seleccionada' and proy.estado != 'Anteproyecto radicado' and proy.estado != 'Devuelto con observaciones'}">
        <c:set var="mensaje_error" value="Tu anteproyecto se encuentra en estado '${proy.estado}' y no admite modificaciones en esta fase." scope="session" />
        <c:redirect url="/estudiante/anteproyecto_ver.jsp" />
    </c:if>
</c:if>

<c:set var="pageTitle" value="${existe ? 'Editar Anteproyecto' : 'Radicar Anteproyecto'} - UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<div class="container py-4">
    <div class="row justify-content-center">
        <div class="col-lg-10">
            <div class="card card-uts shadow-sm">
                <div class="card-header card-header-uts py-3 d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 fw-bold">
                        <i class="bi bi-file-earmark-text-fill me-2"></i>
                        <c:out value="${existe ? 'Actualizar Propuesta de Anteproyecto de Grado' : 'Formulario de Radicación de Anteproyecto de Grado'}" />
                    </h5>
                    <a href="${pageContext.request.contextPath}/estudiante/anteproyecto_ver.jsp" class="btn btn-sm btn-light">
                        <i class="bi bi-arrow-left"></i> Volver a Mi Anteproyecto
                    </a>
                </div>

                <div class="card-body p-4">
                    <div class="alert alert-info py-2 small mb-4">
                        <i class="bi bi-info-circle-fill me-1"></i>
                        Recuerda que según la normativa UTS, debes registrar el enlace a tu documento almacenado en Google Drive o OneDrive con permisos de lectura.
                    </div>

                    <form action="${pageContext.request.contextPath}/estudiante/anteproyecto_guardar.jsp" method="POST">
                        <input type="hidden" name="es_edicion" value="${existe ? '1' : '0'}">
                        <c:if test="${existe}">
                            <input type="hidden" name="id_anteproyecto" value="${proy.id_anteproyecto}">
                            <input type="hidden" name="estado_anterior" value="${proy.estado}">
                        </c:if>

                        <!-- Título y Línea -->
                        <div class="mb-3">
                            <label for="titulo" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Título Completo del Trabajo de Grado:
                            </label>
                            <input type="text" class="form-control form-control-lg" id="titulo" name="titulo" 
                                   value="<c:out value='${existe ? proy.titulo : \"\"}' />" required 
                                   placeholder="Título formal del proyecto de grado">
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-8">
                                <label for="linea_investigacion" class="form-label fw-semibold">
                                    <span class="text-danger">*</span> Línea de Investigación Institucional:
                                </label>
                                <input type="text" class="form-control" id="linea_investigacion" name="linea_investigacion" 
                                       value="<c:out value='${existe ? proy.linea_investigacion : \"\"}' />" required 
                                       placeholder="ej. Ingeniería de Software, Inteligencia Artificial, Telecomunicaciones">
                            </div>
                            <div class="col-md-4">
                                <label for="version" class="form-label fw-semibold">
                                    <span class="text-danger">*</span> Versión del Documento:
                                </label>
                                <input type="text" class="form-control" id="version" name="version" 
                                       value="<c:out value='${existe ? (proy.estado == \"Devuelto con observaciones\" ? \"1.1\" : proy.version) : \"1.0\"}' />" required>
                            </div>
                        </div>

                        <!-- Planteamiento del Problema -->
                        <div class="mb-3">
                            <label for="planteamiento_problema" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Planteamiento del Problema:
                            </label>
                            <textarea class="form-control" id="planteamiento_problema" name="planteamiento_problema" rows="4" required 
                                      placeholder="Describa la necesidad, problemática o vacío identificado en el contexto..."><c:out value='${existe ? proy.planteamiento_problema : ""}' /></textarea>
                        </div>

                        <!-- Justificación -->
                        <div class="mb-3">
                            <label for="justificacion" class="form-label fw-semibold">
                                Justificación y Delimitación:
                            </label>
                            <textarea class="form-control" id="justificacion" name="justificacion" rows="3" 
                                      placeholder="Importancia del trabajo, impacto social, regional o tecnológico para Santander..."><c:out value='${existe ? proy.justificacion : ""}' /></textarea>
                        </div>

                        <!-- Objetivo General -->
                        <div class="mb-3">
                            <label for="objetivo_general" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Objetivo General:
                            </label>
                            <input type="text" class="form-control" id="objetivo_general" name="objetivo_general" 
                                   value="<c:out value='${existe ? proy.objetivo_general : \"\"}' />" required 
                                   placeholder="Inicie con un verbo en infinitivo (Diseñar, Desarrollar, Implementar...)">
                        </div>

                        <!-- Objetivos Específicos -->
                        <div class="mb-3">
                            <label for="objetivos_especificos" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Objetivos Específicos (uno por línea):
                            </label>
                            <textarea class="form-control" id="objetivos_especificos" name="objetivos_especificos" rows="4" required 
                                      placeholder="1. Caracterizar los requisitos...&#10;2. Construir la arquitectura...&#10;3. Validar con usuarios finales..."><c:out value='${existe ? proy.objetivos_especificos : ""}' /></textarea>
                        </div>

                        <!-- Resumen -->
                        <div class="mb-3">
                            <label for="resumen" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Resumen de la Propuesta:
                            </label>
                            <textarea class="form-control" id="resumen" name="resumen" rows="3" required 
                                      placeholder="Síntesis del trabajo en máximo 250 palabras..."><c:out value='${existe ? proy.resumen : ""}' /></textarea>
                        </div>

                        <!-- Enlace al Documento -->
                        <div class="mb-4">
                            <label for="enlace_documento" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Enlace al Documento Digital en Nube (Google Drive / OneDrive):
                            </label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-cloud-arrow-up-fill text-primary"></i></span>
                                <input type="url" class="form-control form-control-lg" id="enlace_documento" name="enlace_documento" 
                                       value="<c:out value='${existe ? proy.enlace_documento : \"\"}' />" required 
                                       placeholder="https://drive.google.com/file/d/... o https://uts-my.sharepoint.com/..." 
                                       oninput="validarUrlDocumento(this)">
                            </div>
                            <div class="form-text">Asegúrese de configurar el enlace como público o accesible para la comunidad UTS.</div>
                        </div>

                        <!-- Botones de Acción -->
                        <div class="d-flex justify-content-end gap-2 pt-3 border-top">
                            <a href="${pageContext.request.contextPath}/estudiante/anteproyecto_ver.jsp" class="btn btn-secondary">
                                Cancelar
                            </a>
                            <button type="submit" class="btn btn-uts-primary px-4 shadow-sm">
                                <i class="bi bi-send-check-fill me-1"></i> <c:out value="${existe ? 'Guardar y Radicar Ajustes' : 'Radicar Anteproyecto'}" />
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="/includes/footer.jspf" %>
