<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="COORDINACION" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Banco de Ideas - Coordinación UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<c:set var="filtroEstado" value="${not empty param.estado ? param.estado : ''}" />
<c:set var="filtroBuscar" value="${not empty param.buscar ? fn:trim(param.buscar) : ''}" />
<c:set var="buscarPattern" value="%${filtroBuscar}%" />

<%-- Consulta del Banco de Ideas con búsqueda y filtro --%>
<sql:query var="qIdeas" dataSource="${conn}">
    SELECT i.id_idea, i.titulo, i.descripcion, i.linea_investigacion, i.cupos, i.estado, i.fecha_publicacion,
           p.nombre_programa, p.nivel,
           u.nombres AS nom_coord, u.apellidos AS ape_coord
    FROM ideas i
    INNER JOIN programas p ON i.id_programa = p.id_programa
    INNER JOIN usuarios u ON i.id_coordinador = u.id_usuario
    WHERE (? = '' OR i.estado = ?)
      AND (? = '' OR i.titulo LIKE ? OR i.linea_investigacion LIKE ? OR p.nombre_programa LIKE ?)
    ORDER BY i.fecha_publicacion DESC
    <sql:param value="${filtroEstado}" />
    <sql:param value="${filtroEstado}" />
    <sql:param value="${filtroBuscar}" />
    <sql:param value="${buscarPattern}" />
    <sql:param value="${buscarPattern}" />
    <sql:param value="${buscarPattern}" />
</sql:query>

<div class="container-fluid px-lg-4 py-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <div>
            <h2 class="fw-bold mb-1 text-dark">
                <i class="bi bi-lightbulb-fill text-warning me-2"></i>Banco de Ideas Institucionales
            </h2>
            <p class="text-secondary mb-0">Gestión de líneas y temas de investigación ofertados a los estudiantes de grado.</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/coordinacion/ideas_formulario.jsp" class="btn btn-uts-primary shadow-sm">
                <i class="bi bi-plus-circle me-1"></i> Publicar Nueva Idea
            </a>
        </div>
    </div>

    <!-- Barra de Búsqueda y Filtros -->
    <div class="card card-uts shadow-sm mb-4">
        <div class="card-body p-3">
            <form action="${pageContext.request.contextPath}/coordinacion/ideas_listar.jsp" method="GET" class="row g-2 align-items-center">
                <div class="col-md-6">
                    <div class="input-group">
                        <span class="input-group-text bg-light text-secondary"><i class="bi bi-search"></i></span>
                        <input type="text" name="buscar" class="form-control" placeholder="Buscar por título, línea o programa..." 
                               value="<c:out value='${filtroBuscar}' />">
                    </div>
                </div>
                <div class="col-md-3">
                    <select name="estado" class="form-select">
                        <option value="">-- Todos los estados --</option>
                        <option value="Disponible" ${filtroEstado == 'Disponible' ? 'selected' : ''}>Disponible</option>
                        <option value="Asignada" ${filtroEstado == 'Asignada' ? 'selected' : ''}>Asignada</option>
                    </select>
                </div>
                <div class="col-md-3 d-flex gap-2">
                    <button type="submit" class="btn btn-uts-secondary flex-grow-1">
                        <i class="bi bi-filter"></i> Filtrar
                    </button>
                    <c:if test="${not empty filtroBuscar or not empty filtroEstado}">
                        <a href="${pageContext.request.contextPath}/coordinacion/ideas_listar.jsp" class="btn btn-outline-secondary">
                            <i class="bi bi-x-circle"></i>
                        </a>
                    </c:if>
                </div>
            </form>
        </div>
    </div>

    <!-- Lista de Ideas en Tarjetas -->
    <div class="row g-3">
        <c:choose>
            <c:when test="${qIdeas.rowCount > 0}">
                <c:forEach var="idea" items="${qIdeas.rows}">
                    <div class="col-lg-6">
                        <div class="card card-uts card-uts-hover h-100 shadow-sm border-start border-4 ${idea.estado == 'Disponible' ? 'border-start-success' : 'border-start-secondary'}">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-start mb-2 gap-2">
                                    <span class="badge bg-primary-subtle text-primary border border-primary-subtle">
                                        <i class="bi bi-mortarboard me-1"></i><c:out value="${idea.nombre_programa}" />
                                    </span>
                                    <span class="badge ${idea.estado == 'Disponible' ? 'bg-success' : 'bg-secondary'} rounded-pill">
                                        <c:out value="${idea.estado}" />
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
                                <div class="small text-muted">
                                    <i class="bi bi-people me-1"></i>Cupos: <strong><c:out value="${idea.cupos}" /></strong>
                                </div>
                                <div class="btn-group btn-group-sm">
                                    <a href="${pageContext.request.contextPath}/coordinacion/ideas_formulario.jsp?id=${idea.id_idea}" class="btn btn-outline-primary" title="Editar Idea">
                                        <i class="bi bi-pencil-square"></i> Editar
                                    </a>
                                    <a href="${pageContext.request.contextPath}/coordinacion/ideas_eliminar.jsp?id=${idea.id_idea}" 
                                       class="btn btn-outline-danger" 
                                       onclick="return confirmarAccion(event, '¿Está seguro de eliminar esta idea de anteproyecto?');"
                                       title="Eliminar Idea">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="col-12">
                    <div class="card card-uts shadow-sm py-5 text-center text-muted">
                        <i class="bi bi-lightbulb fs-1 d-block mb-3 text-secondary opacity-50"></i>
                        <h5>No se encontraron ideas registradas</h5>
                        <p class="text-muted small">Publique nuevas ideas para que los estudiantes de grado puedan postularse.</p>
                        <div>
                            <a href="${pageContext.request.contextPath}/coordinacion/ideas_formulario.jsp" class="btn btn-sm btn-uts-primary">
                                <i class="bi bi-plus-circle me-1"></i> Publicar Primera Idea
                            </a>
                        </div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<%@ include file="/includes/footer.jspf" %>
