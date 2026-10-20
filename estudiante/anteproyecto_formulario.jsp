<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="ESTUDIANTE" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<%-- Consultar registro del estudiante --%>
<sql:query var="qProy" dataSource="${conn}">
    SELECT * FROM anteproyectos WHERE id_estudiante = ?
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<c:set var="existe" value="${qProy.rowCount > 0}" />

<%-- Regla Fase 1: Debe haber subido primero el desprendible de pago --%>
<c:if test="${!existe or empty qProy.rows[0].enlace_desprendible}">
    <c:set var="mensaje_error" value="Fase bloqueada: Primero debes subir el desprendible de pago (Fase 1) para habilitar el envío de la propuesta al Director." scope="session" />
    <c:redirect url="/estudiante/index.jsp" />
</c:if>

<c:set var="proy" value="${qProy.rows[0]}" />
<c:set var="esBorradorFase1" value="${proy.enlace_documento == 'PENDIENTE'}" />

<%-- Validar que esté en fase de envío o corrección de propuesta --%>
<c:if test="${proy.estado != 'Idea seleccionada' and proy.estado != 'Anteproyecto radicado' and !(proy.estado == 'Devuelto con observaciones' and empty proy.enlace_documento_final)}">
    <c:set var="mensaje_error" value="Tu propuesta se encuentra en estado '${proy.estado}' y no admite modificaciones en esta fase." scope="session" />
    <c:redirect url="/estudiante/index.jsp" />
</c:if>

<%-- Consultar Directores disponibles para enviar la propuesta --%>
<sql:query var="qDirectores" dataSource="${conn}">
    SELECT u.id_usuario, u.nombres, u.apellidos, u.correo,
           COUNT(a.id_anteproyecto) AS proyectos_activos
    FROM usuarios u
    INNER JOIN roles r ON u.id_rol = r.id_rol AND r.nombre_rol = 'DIRECTOR'
    LEFT JOIN anteproyectos a ON u.id_usuario = a.id_director 
         AND a.estado NOT IN ('Rechazado', 'Sustentado')
    WHERE u.activo = 1
    GROUP BY u.id_usuario, u.nombres, u.apellidos, u.correo
    ORDER BY u.nombres ASC
</sql:query>

<c:set var="pageTitle" value="Fase 2: Enviar Propuesta al Director - UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<div class="container py-4">
    <div class="row justify-content-center">
        <div class="col-lg-10">
            <div class="card card-uts shadow-sm">
                <div class="card-header card-header-uts py-3 d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 fw-bold">
                        <i class="bi bi-send-check-fill me-2"></i>
                        Fase 2: Enviar Propuesta de Grado al Director
                    </h5>
                    <a href="${pageContext.request.contextPath}/estudiante/index.jsp" class="btn btn-sm btn-light">
                        <i class="bi bi-arrow-left"></i> Volver a Mi Panel de Fases
                    </a>
                </div>

                <div class="card-body p-4">
                    <div class="alert alert-success py-2 small mb-4 d-flex justify-content-between align-items-center flex-wrap gap-2">
                        <div>
                            <i class="bi bi-check-circle-fill me-1"></i>
                            <strong>Fase 1 Completada:</strong> Desprendible de pago verificado. Ahora puedes diligenciar y enviar tu propuesta junto con el enlace del archivo PDF al Director.
                        </div>
                        <a href="<c:out value='${proy.enlace_desprendible}' />" target="_blank" class="btn btn-sm btn-outline-success">
                            <i class="bi bi-file-earmark-pdf me-1"></i> Ver Desprendible
                        </a>
                    </div>

                    <form action="${pageContext.request.contextPath}/estudiante/anteproyecto_guardar.jsp" method="POST">
                        <input type="hidden" name="es_edicion" value="1">
                        <input type="hidden" name="id_anteproyecto" value="${proy.id_anteproyecto}">
                        <input type="hidden" name="estado_anterior" value="${proy.estado}">

                        <!-- Selección de Director Tutor -->
                        <div class="mb-3 p-3 bg-light rounded-3 border">
                            <label for="id_director" class="form-label fw-bold text-dark">
                                <span class="text-danger">*</span> Seleccionar Docente Director (a quien se enviará la propuesta):
                            </label>
                            <select class="form-select form-select-lg" id="id_director" name="id_director" required>
                                <option value="">-- Seleccione Docente Director --</option>
                                <c:forEach var="dir" items="${qDirectores.rows}">
                                    <c:set var="esMismoDir" value="${proy.id_director == dir.id_usuario}" />
                                    <c:set var="cupoLleno" value="${dir.proyectos_activos >= 5 and !esMismoDir}" />
                                    <option value="${dir.id_usuario}" ${esMismoDir ? 'selected' : ''} ${cupoLleno ? 'disabled' : ''}>
                                        Prof. <c:out value="${dir.nombres} ${dir.apellidos}" /> (<c:out value="${dir.correo}" />) - [<c:out value="${dir.proyectos_activos}" />/5 proyectos activos]
                                    </option>
                                </c:forEach>
                            </select>
                            <div class="form-text">Al enviar este formulario, se desbloqueará la Fase 3 para que el Director seleccionado revise tu propuesta y la envíe al Comité Evaluador.</div>
                        </div>

                        <!-- Título y Línea -->
                        <div class="mb-3">
                            <label for="titulo" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Título Completo de la Propuesta de Grado:
                            </label>
                            <input type="text" class="form-control form-control-lg" id="titulo" name="titulo" 
                                   value="<c:out value='${(esBorradorFase1 and proy.titulo == \"Propuesta pendiente por enviar al Director\") ? \"\" : proy.titulo}' />" required 
                                   placeholder="Título formal del proyecto de grado">
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-8">
                                <label for="linea_investigacion" class="form-label fw-semibold">
                                    <span class="text-danger">*</span> Línea de Investigación Institucional:
                                </label>
                                <input type="text" class="form-control" id="linea_investigacion" name="linea_investigacion" 
                                       value="<c:out value='${(esBorradorFase1 and proy.linea_investigacion == \"Por definir\") ? \"\" : proy.linea_investigacion}' />" required 
                                       placeholder="ej. Ingeniería de Software, Inteligencia Artificial, Telecomunicaciones">
                            </div>
                            <div class="col-md-4">
                                <label for="version" class="form-label fw-semibold">
                                    <span class="text-danger">*</span> Versión del Documento:
                                </label>
                                <input type="text" class="form-control" id="version" name="version" 
                                       value="<c:out value='${proy.estado == \"Devuelto con observaciones\" ? \"1.1\" : proy.version}' />" required>
                            </div>
                        </div>

                        <!-- Planteamiento del Problema -->
                        <div class="mb-3">
                            <label for="planteamiento_problema" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Planteamiento del Problema:
                            </label>
                            <textarea class="form-control" id="planteamiento_problema" name="planteamiento_problema" rows="3" required 
                                      placeholder="Describa la necesidad, problemática o vacío identificado en el contexto..."><c:out value='${(esBorradorFase1 and proy.planteamiento_problema == "Pendiente de diligenciar en Fase 2") ? "" : proy.planteamiento_problema}' /></textarea>
                        </div>

                        <!-- Justificación -->
                        <div class="mb-3">
                            <label for="justificacion" class="form-label fw-semibold">
                                Justificación y Delimitación:
                            </label>
                            <textarea class="form-control" id="justificacion" name="justificacion" rows="2" 
                                      placeholder="Importancia del trabajo, impacto social, regional o tecnológico..."><c:out value='${proy.justificacion}' /></textarea>
                        </div>

                        <!-- Objetivo General -->
                        <div class="mb-3">
                            <label for="objetivo_general" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Objetivo General:
                            </label>
                            <input type="text" class="form-control" id="objetivo_general" name="objetivo_general" 
                                   value="<c:out value='${(esBorradorFase1 and proy.objetivo_general == \"Pendiente de diligenciar en Fase 2\") ? \"\" : proy.objetivo_general}' />" required 
                                   placeholder="Inicie con un verbo en infinitivo (Diseñar, Desarrollar, Implementar...)">
                        </div>

                        <!-- Objetivos Específicos -->
                        <div class="mb-3">
                            <label for="objetivos_especificos" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Objetivos Específicos (uno por línea):
                            </label>
                            <textarea class="form-control" id="objetivos_especificos" name="objetivos_especificos" rows="3" required 
                                      placeholder="1. Caracterizar los requisitos...&#10;2. Construir la arquitectura...&#10;3. Validar con usuarios finales..."><c:out value='${(esBorradorFase1 and proy.objetivos_especificos == "Pendiente de diligenciar en Fase 2") ? "" : proy.objetivos_especificos}' /></textarea>
                        </div>

                        <!-- Resumen -->
                        <div class="mb-3">
                            <label for="resumen" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Resumen de la Propuesta:
                            </label>
                            <textarea class="form-control" id="resumen" name="resumen" rows="3" required 
                                      placeholder="Síntesis del trabajo en máximo 250 palabras..."><c:out value='${esBorradorFase1 ? "" : proy.resumen}' /></textarea>
                        </div>

                        <!-- Enlace al Documento de la Propuesta -->
                        <div class="mb-4 p-3 bg-primary-subtle border border-primary-subtle rounded-3">
                            <label for="enlace_documento" class="form-label fw-bold text-dark">
                                <span class="text-danger">*</span> Subir Archivo de la Propuesta (Enlace PDF en Google Drive / Nube):
                            </label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-file-earmark-pdf-fill text-danger"></i></span>
                                <input type="url" class="form-control form-control-lg" id="enlace_documento" name="enlace_documento" 
                                       value="<c:out value='${(esBorradorFase1 or proy.enlace_documento == \"https://drive.google.com/\") ? \"\" : proy.enlace_documento}' />" required 
                                       placeholder="https://drive.google.com/file/d/.../view" 
                                       oninput="validarUrlDocumento(this)">
                            </div>
                            <div class="form-text text-dark">Adjunte el link del PDF de la propuesta en Drive o nube con permisos de lectura para el Director y Comité Evaluador.</div>
                        </div>

                        <!-- Botones de Acción -->
                        <div class="d-flex justify-content-end gap-2 pt-3 border-top">
                            <a href="${pageContext.request.contextPath}/estudiante/index.jsp" class="btn btn-secondary">
                                Cancelar
                            </a>
                            <button type="submit" class="btn btn-uts-primary px-4 shadow-sm">
                                <i class="bi bi-send-check-fill me-1"></i> Enviar Propuesta al Director (Completar Fase 2)
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="/includes/footer.jspf" %>
