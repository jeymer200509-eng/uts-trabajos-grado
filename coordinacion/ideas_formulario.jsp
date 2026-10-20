<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="COORDINACION" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="esEdicion" value="${not empty param.id}" />

<c:if test="${esEdicion}">
    <sql:query var="qIdeaEdit" dataSource="${conn}">
        SELECT * FROM ideas WHERE id_idea = ?
        <sql:param value="${param.id}" />
    </sql:query>
    <c:if test="${qIdeaEdit.rowCount == 0}">
        <c:set var="mensaje_error" value="La idea solicitada no existe." scope="session" />
        <c:redirect url="/coordinacion/ideas_listar.jsp" />
    </c:if>
    <c:set var="idea" value="${qIdeaEdit.rows[0]}" />
</c:if>

<%-- Catálogo de Programas --%>
<sql:query var="qProgs" dataSource="${conn}">
    SELECT id_programa, nombre_programa, nivel FROM programas ORDER BY nombre_programa ASC
</sql:query>

<c:set var="pageTitle" value="${esEdicion ? 'Editar Idea' : 'Nueva Idea'} - Banco de Ideas UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<div class="container py-4">
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <div class="card card-uts shadow-sm">
                <div class="card-header ${esEdicion ? 'card-header-blue' : 'card-header-uts'} py-3 d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 fw-bold">
                        <i class="bi ${esEdicion ? 'bi-pencil-square' : 'bi-lightbulb-fill'} me-2"></i>
                        <c:out value="${esEdicion ? 'Modificar Idea de Proyecto' : 'Publicar Nueva Idea de Trabajo de Grado'}" />
                    </h5>
                    <a href="${pageContext.request.contextPath}/coordinacion/ideas_listar.jsp" class="btn btn-sm btn-light">
                        <i class="bi bi-arrow-left"></i> Volver al Banco
                    </a>
                </div>
                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/coordinacion/ideas_guardar.jsp" method="POST">
                        <input type="hidden" name="es_edicion" value="${esEdicion ? '1' : '0'}">
                        <c:if test="${esEdicion}">
                            <input type="hidden" name="id_idea" value="${idea.id_idea}">
                        </c:if>

                        <div class="row g-3 mb-3">
                            <div class="col-md-7">
                                <label for="id_programa" class="form-label fw-semibold">
                                    <span class="text-danger">*</span> Programa Académico:
                                </label>
                                <select class="form-select" id="id_programa" name="id_programa" required>
                                    <option value="">-- Seleccione Programa --</option>
                                    <c:forEach var="p" items="${qProgs.rows}">
                                        <option value="${p.id_programa}" ${(esEdicion and idea.id_programa == p.id_programa) ? 'selected' : ''}>
                                            <c:out value="${p.nombre_programa}" /> (<c:out value="${p.nivel}" />)
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="col-md-5">
                                <label for="estado" class="form-label fw-semibold">
                                    <span class="text-danger">*</span> Estado de la Idea:
                                </label>
                                <select class="form-select" id="estado" name="estado" required>
                                    <option value="Disponible" ${(not esEdicion or idea.estado == 'Disponible') ? 'selected' : ''}>Disponible</option>
                                    <option value="Asignada" ${(esEdicion and idea.estado == 'Asignada') ? 'selected' : ''}>Asignada</option>
                                </select>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label for="titulo" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Título de la Idea / Propuesta:
                            </label>
                            <input type="text" class="form-control form-control-lg" id="titulo" name="titulo" 
                                   value="<c:out value='${esEdicion ? idea.titulo : \"\"}' />" required placeholder="Título descriptivo de la propuesta de grado">
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-8">
                                <label for="linea_investigacion" class="form-label fw-semibold">
                                    <span class="text-danger">*</span> Línea de Investigación:
                                </label>
                                <input type="text" class="form-control" id="linea_investigacion" name="linea_investigacion" 
                                       value="<c:out value='${esEdicion ? idea.linea_investigacion : \"\"}' />" required 
                                       placeholder="ej. Inteligencia Artificial, Redes, Software">
                            </div>

                            <div class="col-md-4">
                                <label for="cupos" class="form-label fw-semibold">
                                    <span class="text-danger">*</span> Cupos de Estudiantes:
                                </label>
                                <input type="number" class="form-control" id="cupos" name="cupos" min="1" max="5" 
                                       value="<c:out value='${esEdicion ? idea.cupos : 1}' />" required>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label for="descripcion" class="form-label fw-semibold">
                                <span class="text-danger">*</span> Descripción Detallada / Alcance:
                            </label>
                            <textarea class="form-control" id="descripcion" name="descripcion" rows="5" required 
                                      placeholder="Describa el contexto, objetivos preliminares y tecnologías propuestas..."><c:out value='${esEdicion ? idea.descripcion : ""}' /></textarea>
                        </div>

                        <div class="d-flex justify-content-end gap-2 pt-3 border-top">
                            <a href="${pageContext.request.contextPath}/coordinacion/ideas_listar.jsp" class="btn btn-secondary">
                                Cancelar
                            </a>
                            <button type="submit" class="btn btn-uts-primary px-4 shadow-sm">
                                <i class="bi bi-save me-1"></i> <c:out value="${esEdicion ? 'Guardar Cambios' : 'Publicar Idea'}" />
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="/includes/footer.jspf" %>
