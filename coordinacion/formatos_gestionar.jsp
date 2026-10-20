<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="COORDINACION" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Gestión de Formatos de Grado - Coordinación UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<sql:query var="qFormatos" dataSource="${conn}">
    SELECT * FROM formatos ORDER BY codigo ASC
</sql:query>

<div class="container-fluid px-lg-4 py-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <div>
            <h2 class="fw-bold mb-1 text-dark">
                <i class="bi bi-file-earmark-arrow-down text-primary me-2"></i>Gestión de Formatos y Guías de Grado
            </h2>
            <p class="text-secondary mb-0">Publicación y administración de documentos institucionales F-DC y rúbricas de grado.</p>
        </div>
        <button type="button" class="btn btn-uts-primary shadow-sm" data-bs-toggle="modal" data-bs-target="#modalFormatoNuevo">
            <i class="bi bi-file-earmark-plus me-1"></i> Publicar Nuevo Formato
        </button>
    </div>

    <div class="card card-uts shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light text-secondary">
                        <tr>
                            <th>Código</th>
                            <th>Nombre del Formato Institucional</th>
                            <th>Categoría</th>
                            <th>Versión</th>
                            <th>Publicación</th>
                            <th class="text-end pe-3">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="f" items="${qFormatos.rows}">
                            <tr>
                                <td><span class="badge bg-dark-subtle text-dark border"><code><c:out value="${f.codigo}" /></code></span></td>
                                <td>
                                    <div class="fw-bold text-dark"><c:out value="${f.nombre}" /></div>
                                    <small class="text-muted"><c:out value="${f.descripcion}" /></small>
                                </td>
                                <td>
                                    <span class="badge bg-info-subtle text-info-emphasis border border-info-subtle">
                                        <c:out value="${f.categoria}" />
                                    </span>
                                </td>
                                <td>v<c:out value="${f.version}" /></td>
                                <td><fmt:formatDate value="${f.fecha_publicacion}" pattern="dd/MM/yyyy" /></td>
                                <td class="text-end pe-3">
                                    <a href="<c:out value='${f.enlace_descarga}' />" target="_blank" class="btn btn-sm btn-outline-success me-1" title="Ver enlace">
                                        <i class="bi bi-download"></i>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/coordinacion/formatos_guardar.jsp?accion=eliminar&id=${f.id_formato}" 
                                       class="btn btn-sm btn-outline-danger" 
                                       onclick="return confirmarAccion(event, '¿Desea retirar este formato institucional del repositorio?');">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Modal para Crear Formato -->
<div class="modal fade" id="modalFormatoNuevo" tabindex="-1" aria-labelledby="modalFormatoLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header card-header-uts text-white">
                <h6 class="modal-title fw-bold" id="modalFormatoLabel">
                    <i class="bi bi-file-earmark-plus me-2"></i>Publicar Formato Institucional
                </h6>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <form action="${pageContext.request.contextPath}/coordinacion/formatos_guardar.jsp" method="POST">
                <input type="hidden" name="accion" value="crear">
                <div class="modal-body">
                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <label class="form-label fw-semibold"><span class="text-danger">*</span> Código UTS:</label>
                            <input type="text" name="codigo" class="form-control" required placeholder="ej. F-DC-06">
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-semibold"><span class="text-danger">*</span> Versión:</label>
                            <input type="text" name="version" class="form-control" required value="1.0">
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold"><span class="text-danger">*</span> Nombre del Formato:</label>
                        <input type="text" name="nombre" class="form-control" required placeholder="Nombre oficial según SIG UTS">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold"><span class="text-danger">*</span> Categoría:</label>
                        <select name="categoria" class="form-select" required>
                            <option value="Anteproyecto">Anteproyecto</option>
                            <option value="Tutoría">Tutoría</option>
                            <option value="Evaluación">Evaluación</option>
                            <option value="Documento Final">Documento Final</option>
                            <option value="Sustentación">Sustentación</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold"><span class="text-danger">*</span> Enlace Oficial de Descarga (URL):</label>
                        <input type="url" name="enlace_descarga" class="form-control" required placeholder="https://drive.google.com/... o https://uts.edu.co/...">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Descripción / Alcance:</label>
                        <textarea name="descripcion" class="form-control" rows="2" placeholder="Orientaciones de diligenciamiento..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-sm btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-sm btn-uts-primary fw-semibold">Publicar Formato</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%@ include file="/includes/footer.jspf" %>
