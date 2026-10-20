<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="COORDINACION" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Gestión del Calendario Académico - UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<sql:query var="qEventos" dataSource="${conn}">
    SELECT * FROM calendario ORDER BY fecha_inicio ASC
</sql:query>

<div class="container-fluid px-lg-4 py-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <div>
            <h2 class="fw-bold mb-1 text-dark">
                <i class="bi bi-calendar-event text-danger me-2"></i>Gestión de Calendario Académico
            </h2>
            <p class="text-secondary mb-0">Programación de fechas de radicación, revisiones tutoriales y jornadas de sustentación.</p>
        </div>
        <button type="button" class="btn btn-uts-primary shadow-sm" data-bs-toggle="modal" data-bs-target="#modalEventoNuevo">
            <i class="bi bi-calendar-plus me-1"></i> Agregar Evento / Hito
        </button>
    </div>

    <div class="card card-uts shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light text-secondary">
                        <tr>
                            <th>Etapa / Tipo</th>
                            <th>Hito Académico</th>
                            <th>Fecha Inicio</th>
                            <th>Fecha Límite</th>
                            <th class="text-center">Estado</th>
                            <th class="text-end pe-3">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="ev" items="${qEventos.rows}">
                            <tr>
                                <td>
                                    <span class="badge bg-secondary-subtle text-secondary border">
                                        <c:out value="${ev.tipo_etapa}" />
                                    </span>
                                </td>
                                <td>
                                    <div class="fw-bold text-dark"><c:out value="${ev.titulo}" /></div>
                                    <small class="text-muted"><c:out value="${ev.descripcion}" /></small>
                                </td>
                                <td>
                                    <i class="bi bi-calendar-check text-success me-1"></i>
                                    <fmt:formatDate value="${ev.fecha_inicio}" pattern="dd/MM/yyyy" />
                                </td>
                                <td>
                                    <i class="bi bi-calendar-x text-danger me-1"></i>
                                    <fmt:formatDate value="${ev.fecha_fin}" pattern="dd/MM/yyyy" />
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${ev.estado == 'Activo'}">
                                            <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1">En Curso</span>
                                        </c:when>
                                        <c:when test="${ev.estado == 'Finalizado'}">
                                            <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle px-2 py-1">Cerrado</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-warning-subtle text-warning border border-warning-subtle px-2 py-1">Próximo</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end pe-3">
                                    <a href="${pageContext.request.contextPath}/coordinacion/calendario_guardar.jsp?accion=eliminar&id=${ev.id_evento}" 
                                       class="btn btn-sm btn-outline-danger" 
                                       onclick="return confirmarAccion(event, '¿Desea eliminar este evento del calendario académico?');">
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

<!-- Modal para Crear Nuevo Evento -->
<div class="modal fade" id="modalEventoNuevo" tabindex="-1" aria-labelledby="modalEventoLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header card-header-uts text-white">
                <h6 class="modal-title fw-bold" id="modalEventoLabel">
                    <i class="bi bi-calendar-plus me-2"></i>Registrar Hito de Calendario
                </h6>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <form action="${pageContext.request.contextPath}/coordinacion/calendario_guardar.jsp" method="POST">
                <input type="hidden" name="accion" value="crear">
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-semibold"><span class="text-danger">*</span> Título del Evento:</label>
                        <input type="text" name="titulo" class="form-control" required placeholder="ej. Radicación de Anteproyectos 2026-II">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold"><span class="text-danger">*</span> Tipo de Etapa:</label>
                        <select name="tipo_etapa" class="form-select" required>
                            <option value="Radicacion">Radicación de Anteproyecto</option>
                            <option value="Revision_Director">Revisión por Director</option>
                            <option value="Revision_Evaluador">Revisión por Evaluador</option>
                            <option value="Sustentacion">Sustentación</option>
                            <option value="General" selected>General / Institucional</option>
                        </select>
                    </div>
                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <label class="form-label fw-semibold"><span class="text-danger">*</span> Fecha Inicio:</label>
                            <input type="date" name="fecha_inicio" class="form-control" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-semibold"><span class="text-danger">*</span> Fecha Límite:</label>
                            <input type="date" name="fecha_fin" class="form-control" required>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold"><span class="text-danger">*</span> Estado:</label>
                        <select name="estado" class="form-select" required>
                            <option value="Activo">Activo (En curso)</option>
                            <option value="Proximo">Próximo</option>
                            <option value="Finalizado">Finalizado</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Descripción o Instrucciones:</label>
                        <textarea name="descripcion" class="form-control" rows="2" placeholder="Indicaciones para estudiantes y docentes..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-sm btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-sm btn-uts-primary fw-semibold">Guardar Evento</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%@ include file="/includes/footer.jspf" %>
