<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="COORDINACION" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Validación de Desprendibles de Pago - Coordinación UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<c:set var="filtroEstadoPago" value="${not empty param.estado_pago ? param.estado_pago : ''}" />

<%-- Consultar todos los registros con desprendible de pago cargado --%>
<sql:query var="qPagos" dataSource="${conn}">
    SELECT a.id_anteproyecto, a.titulo, a.estado, a.enlace_desprendible, 
           a.estado_pago, a.observacion_pago, a.fecha_actualizacion,
           u.id_usuario, u.codigo, u.documento, u.nombres, u.apellidos, u.correo, u.semestre,
           p.nombre_programa
    FROM anteproyectos a
    INNER JOIN usuarios u ON a.id_estudiante = u.id_usuario
    LEFT JOIN programas p ON u.id_programa = p.id_programa
    WHERE a.enlace_desprendible IS NOT NULL AND a.enlace_desprendible != ''
      AND (? = '' OR a.estado_pago = ?)
    ORDER BY CASE WHEN a.estado_pago = 'En revisión' THEN 0 WHEN a.estado_pago = 'Rechazado' THEN 1 ELSE 2 END, a.fecha_actualizacion DESC
    <sql:param value="${filtroEstadoPago}" />
    <sql:param value="${filtroEstadoPago}" />
</sql:query>

<div class="container-fluid px-lg-4 py-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <div>
            <h2 class="fw-bold mb-1 text-dark">
                <i class="bi bi-receipt-cutoff text-success me-2"></i>Validación de Desprendibles de Pago (Fase 1)
            </h2>
            <p class="text-secondary mb-0">Revise el PDF del comprobante de pago subido por cada estudiante y acéptelo para desbloquear la Fase 2 o rechácelo con observaciones.</p>
        </div>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/coordinacion/pagos_listar.jsp" class="btn btn-sm ${empty filtroEstadoPago ? 'btn-uts-primary' : 'btn-outline-secondary'}">Todos</a>
            <a href="${pageContext.request.contextPath}/coordinacion/pagos_listar.jsp?estado_pago=En revisión" class="btn btn-sm ${filtroEstadoPago == 'En revisión' ? 'btn-warning fw-bold' : 'btn-outline-warning'}">En Revisión</a>
            <a href="${pageContext.request.contextPath}/coordinacion/pagos_listar.jsp?estado_pago=Aprobado" class="btn btn-sm ${filtroEstadoPago == 'Aprobado' ? 'btn-success' : 'btn-outline-success'}">Aceptados</a>
            <a href="${pageContext.request.contextPath}/coordinacion/pagos_listar.jsp?estado_pago=Rechazado" class="btn btn-sm ${filtroEstadoPago == 'Rechazado' ? 'btn-danger' : 'btn-outline-danger'}">Rechazados</a>
        </div>
    </div>

    <div class="card card-uts shadow-sm">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
            <span class="fw-bold text-dark">
                Comprobantes de Pago Recibidos: <span class="badge bg-secondary rounded-pill"><c:out value="${qPagos.rowCount}" /></span>
            </span>
            <div class="w-25">
                <input type="text" id="filtroTablaPagos" class="form-control form-control-sm" placeholder="Buscar estudiante o código..." onkeyup="filtrarTabla('filtroTablaPagos', 'tablaPagosCoord')">
            </div>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0" id="tablaPagosCoord">
                    <thead class="table-light text-secondary">
                        <tr>
                            <th>Estudiante</th>
                            <th>Programa / Semestre</th>
                            <th>Comprobante PDF (Drive/Nube)</th>
                            <th class="text-center">Estado del Pago</th>
                            <th>Observación</th>
                            <th class="text-end pe-3">Decisión de Coordinación</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${qPagos.rowCount > 0}">
                                <c:forEach var="item" items="${qPagos.rows}">
                                    <tr>
                                        <td>
                                            <div class="fw-bold text-dark"><c:out value="${item.nombres} ${item.apellidos}" /></div>
                                            <small class="text-muted d-block">Cód: <code><c:out value="${item.codigo}" /></code> &bull; CC: <c:out value="${item.documento}" /></small>
                                            <small class="text-secondary"><i class="bi bi-envelope"></i> <c:out value="${item.correo}" /></small>
                                        </td>
                                        <td>
                                            <div class="small fw-semibold text-dark"><c:out value="${item.nombre_programa}" /></div>
                                            <small class="text-muted">Semestre: <c:out value="${item.semestre}" />°</small>
                                        </td>
                                        <td>
                                            <a href="<c:out value='${item.enlace_desprendible}' />" target="_blank" class="btn btn-sm btn-outline-danger fw-semibold">
                                                <i class="bi bi-file-earmark-pdf-fill me-1"></i> Revisar PDF del Desprendible
                                            </a>
                                            <div class="small text-muted text-truncate mt-1" style="max-width: 240px;">
                                                <c:out value="${item.enlace_desprendible}" />
                                            </div>
                                        </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${item.estado_pago == 'Aprobado'}">
                                                    <span class="badge bg-success-subtle text-success border border-success-subtle px-3 py-2">
                                                        <i class="bi bi-check-circle-fill me-1"></i>Aceptado
                                                    </span>
                                                </c:when>
                                                <c:when test="${item.estado_pago == 'Rechazado'}">
                                                    <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-3 py-2">
                                                        <i class="bi bi-x-circle-fill me-1"></i>Rechazado
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle px-3 py-2">
                                                        <i class="bi bi-hourglass-split me-1"></i>En Revisión
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <small class="text-muted">
                                                <c:out value="${not empty item.observacion_pago ? item.observacion_pago : 'Sin observaciones'}" />
                                            </small>
                                        </td>
                                        <td class="text-end pe-3">
                                            <div class="d-flex justify-content-end gap-1">
                                                <form action="${pageContext.request.contextPath}/coordinacion/pagos_guardar.jsp" method="POST" class="d-inline">
                                                    <input type="hidden" name="id_anteproyecto" value="${item.id_anteproyecto}">
                                                    <input type="hidden" name="decision_pago" value="Aprobado">
                                                    <input type="hidden" name="observacion_pago" value="Desprendible de pago verificado y aceptado por Coordinación.">
                                                    <button type="submit" class="btn btn-sm btn-success" title="Aceptar desprendible y desbloquear Fase 2"
                                                            onclick="return confirmarAccion(event, '¿Confirma ACEPTAR el desprendible de pago de este estudiante? Esto desbloqueará su Fase 2.');">
                                                        <i class="bi bi-check-lg me-1"></i> Aceptar
                                                    </button>
                                                </form>

                                                <button type="button" class="btn btn-sm btn-danger" data-bs-toggle="modal" data-bs-target="#modalRechazarPago${item.id_anteproyecto}" title="Rechazar desprendible con motivo">
                                                    <i class="bi bi-x-lg me-1"></i> Rechazar
                                                </button>
                                            </div>

                                            <!-- Modal para Rechazar o Evaluar con Observación -->
                                            <div class="modal fade" id="modalRechazarPago${item.id_anteproyecto}" tabindex="-1" aria-hidden="true">
                                                <div class="modal-dialog modal-dialog-centered text-start">
                                                    <div class="modal-content">
                                                        <div class="modal-header bg-danger text-white">
                                                            <h6 class="modal-title fw-bold">
                                                                <i class="bi bi-x-octagon-fill me-2"></i>Rechazar Desprendible de Pago
                                                            </h6>
                                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                                                        </div>
                                                        <form action="${pageContext.request.contextPath}/coordinacion/pagos_guardar.jsp" method="POST">
                                                            <div class="modal-body">
                                                                <input type="hidden" name="id_anteproyecto" value="${item.id_anteproyecto}">
                                                                <input type="hidden" name="decision_pago" value="Rechazado">
                                                                <p class="small text-muted mb-2">
                                                                    Estudiante: <strong><c:out value="${item.nombres} ${item.apellidos}" /></strong> (<code><c:out value="${item.codigo}" /></code>)
                                                                </p>
                                                                <div class="mb-3">
                                                                    <label class="form-label fw-semibold">Motivo del rechazo / Observación para el estudiante:</label>
                                                                    <textarea name="observacion_pago" class="form-control" rows="3" required placeholder="Ej. El enlace en Drive no tiene permisos de lectura o el recibo no corresponde al periodo actual..."></textarea>
                                                                </div>
                                                            </div>
                                                            <div class="modal-footer">
                                                                <button type="button" class="btn btn-sm btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                                                <button type="submit" class="btn btn-sm btn-danger fw-semibold">Confirmar Rechazo</button>
                                                            </div>
                                                        </form>
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <i class="bi bi-receipt fs-1 d-block mb-2 text-secondary opacity-50"></i>
                                        No hay desprendibles de pago registrados con el filtro seleccionado.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<%@ include file="/includes/footer.jspf" %>
