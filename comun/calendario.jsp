<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- Accesible por todos los usuarios autenticados --%>
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Calendario Académico de Grado - UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<sql:query var="qEventos" dataSource="${conn}">
    SELECT * FROM calendario ORDER BY fecha_inicio ASC
</sql:query>

<div class="container px-lg-4 py-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <div>
            <h2 class="fw-bold mb-1 text-dark">
                <i class="bi bi-calendar3 text-danger me-2"></i>Calendario Académico de Trabajos de Grado
            </h2>
            <p class="text-secondary mb-0">Cronograma oficial de fechas límite, periodos de revisión tutorial y jornadas de sustentación oral UTS.</p>
        </div>
        <c:if test="${sessionScope.rol == 'COORDINACION' or sessionScope.rol == 'ADMIN'}">
            <a href="${pageContext.request.contextPath}/coordinacion/calendario_gestionar.jsp" class="btn btn-uts-primary shadow-sm">
                <i class="bi bi-gear-fill me-1"></i> Gestionar Calendario
            </a>
        </c:if>
    </div>

    <!-- Filtro rápido en cliente -->
    <div class="card card-uts shadow-sm mb-4">
        <div class="card-body p-3">
            <div class="row align-items-center g-2">
                <div class="col-md-6">
                    <div class="input-group">
                        <span class="input-group-text bg-light text-secondary"><i class="bi bi-search"></i></span>
                        <input type="text" id="filtroCal" class="form-control" placeholder="Buscar hito o actividad por palabra clave..." onkeyup="filtrarTabla('filtroCal', 'tablaCalComun')">
                    </div>
                </div>
                <div class="col-md-6 text-md-end text-muted small">
                    <span class="badge bg-success-subtle text-success border border-success-subtle me-1"><i class="bi bi-circle-fill" style="font-size: 8px;"></i> Activo</span>
                    <span class="badge bg-warning-subtle text-warning border border-warning-subtle me-1"><i class="bi bi-circle-fill" style="font-size: 8px;"></i> Próximo</span>
                    <span class="badge bg-secondary-subtle text-secondary border me-1"><i class="bi bi-circle-fill" style="font-size: 8px;"></i> Finalizado</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Tabla del Calendario -->
    <div class="card card-uts shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0" id="tablaCalComun">
                    <thead class="table-light text-secondary">
                        <tr>
                            <th style="width: 15%;">Etapa</th>
                            <th style="width: 35%;">Hito Académico / Actividad</th>
                            <th style="width: 20%;">Periodo de Ejecución</th>
                            <th style="width: 15%;" class="text-center">Estado</th>
                            <th style="width: 15%;" class="text-end pe-3">Recordatorio</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="e" items="${qEventos.rows}">
                            <tr>
                                <td>
                                    <span class="badge bg-primary-subtle text-primary border border-primary-subtle">
                                        <c:out value="${e.tipo_etapa}" />
                                    </span>
                                </td>
                                <td>
                                    <div class="fw-bold text-dark"><c:out value="${e.titulo}" /></div>
                                    <c:if test="${not empty e.descripcion}">
                                        <small class="text-muted"><c:out value="${e.descripcion}" /></small>
                                    </c:if>
                                </td>
                                <td>
                                    <div><i class="bi bi-calendar-check text-success me-1"></i> <fmt:formatDate value="${e.fecha_inicio}" pattern="dd/MM/yyyy" /></div>
                                    <div><i class="bi bi-calendar-x text-danger me-1"></i> <fmt:formatDate value="${e.fecha_fin}" pattern="dd/MM/yyyy" /></div>
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${e.estado == 'Activo'}">
                                            <span class="badge bg-success px-3 py-2 rounded-pill">
                                                <i class="bi bi-clock-history me-1"></i>En Curso
                                            </span>
                                        </c:when>
                                        <c:when test="${e.estado == 'Finalizado'}">
                                            <span class="badge bg-secondary px-3 py-2 rounded-pill">
                                                Finalizado
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-warning text-dark px-3 py-2 rounded-pill">
                                                Próximo
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end pe-3">
                                    <c:choose>
                                        <c:when test="${e.estado == 'Activo'}">
                                            <span class="text-success small fw-semibold"><i class="bi bi-bell-fill me-1"></i>Vigente</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted small">-</span>
                                        </c:otherwise>
                                    </c:choose>
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
