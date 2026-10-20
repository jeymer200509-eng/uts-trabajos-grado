<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- Accesible por todos los usuarios autenticados --%>
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Formatos y Guías Institucionales - UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<sql:query var="qFormatos" dataSource="${conn}">
    SELECT * FROM formatos ORDER BY codigo ASC
</sql:query>

<div class="container px-lg-4 py-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <div>
            <h2 class="fw-bold mb-1 text-dark">
                <i class="bi bi-file-earmark-arrow-down-fill text-primary me-2"></i>Formatos y Guías Institucionales de Grado
            </h2>
            <p class="text-secondary mb-0">Descarga oficial de documentos del Sistema Integrado de Gestión (SIG UTS) para cada etapa del trabajo de grado.</p>
        </div>
        <c:if test="${sessionScope.rol == 'COORDINACION' or sessionScope.rol == 'ADMIN'}">
            <a href="${pageContext.request.contextPath}/coordinacion/formatos_gestionar.jsp" class="btn btn-uts-primary shadow-sm">
                <i class="bi bi-gear-fill me-1"></i> Administrar Formatos
            </a>
        </c:if>
    </div>

    <!-- Buscador rápido -->
    <div class="card card-uts shadow-sm mb-4">
        <div class="card-body p-3">
            <div class="input-group">
                <span class="input-group-text bg-light text-secondary"><i class="bi bi-search"></i></span>
                <input type="text" id="filtroFormatos" class="form-control" placeholder="Buscar formato por código o nombre..." onkeyup="filtrarTabla('filtroFormatos', 'tablaFormatosComun')">
            </div>
        </div>
    </div>

    <!-- Catálogo de Formatos -->
    <div class="card card-uts shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0" id="tablaFormatosComun">
                    <thead class="table-light text-secondary">
                        <tr>
                            <th style="width: 12%;">Código SIG</th>
                            <th style="width: 38%;">Nombre del Formato y Propósito</th>
                            <th style="width: 15%;">Categoría</th>
                            <th style="width: 10%;">Versión</th>
                            <th style="width: 12%;">Publicación</th>
                            <th style="width: 13%;" class="text-end pe-3">Acción</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="f" items="${qFormatos.rows}">
                            <tr>
                                <td>
                                    <span class="badge bg-secondary-subtle text-dark border">
                                        <code><c:out value="${f.codigo}" /></code>
                                    </span>
                                </td>
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
                                <td><small class="text-muted"><fmt:formatDate value="${f.fecha_publicacion}" pattern="dd/MM/yyyy" /></small></td>
                                <td class="text-end pe-3">
                                    <a href="<c:out value='${f.enlace_descarga}' />" target="_blank" class="btn btn-sm btn-uts-primary">
                                        <i class="bi bi-download me-1"></i> Descargar
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

<%@ include file="/includes/footer.jspf" %>
