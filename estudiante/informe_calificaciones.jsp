<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="ESTUDIANTE" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Informe de Calificaciones y Conceptos - UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<%-- Consultar proyecto del estudiante --%>
<sql:query var="qProy" dataSource="${conn}">
    SELECT a.*, 
           d.nombres AS nom_dir, d.apellidos AS ape_dir,
           e.nombres AS nom_eva, e.apellidos AS ape_eva
    FROM anteproyectos a
    LEFT JOIN usuarios d ON a.id_director = d.id_usuario
    LEFT JOIN usuarios e ON a.id_evaluador = e.id_usuario
    WHERE a.id_estudiante = ?
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<div class="container px-lg-4 py-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <div>
            <h2 class="fw-bold mb-1 text-dark">
                <i class="bi bi-award-fill text-warning me-2"></i>Informe de Calificaciones y Conceptos
            </h2>
            <p class="text-secondary mb-0">Consulte el dictamen evaluativo, rúbrica de notas y observaciones de sus tutores.</p>
        </div>
        <a href="${pageContext.request.contextPath}/estudiante/anteproyecto_ver.jsp" class="btn btn-outline-secondary">
            <i class="bi bi-arrow-left"></i> Volver a Mi Anteproyecto
        </a>
    </div>

    <c:choose>
        <c:when test="${qProy.rowCount == 0}">
            <div class="card card-uts shadow-sm py-5 text-center text-muted">
                <i class="bi bi-journal-x fs-1 d-block mb-3 opacity-50"></i>
                <h5>No tiene un anteproyecto radicado para consultar calificaciones.</h5>
            </div>
        </c:when>

        <c:otherwise>
            <c:set var="proy" value="${qProy.rows[0]}" />

            <%-- Consultar calificaciones --%>
            <sql:query var="qNotas" dataSource="${conn}">
                SELECT c.*, u.nombres AS nom_doc, u.apellidos AS ape_doc, r.nombre_rol
                FROM calificaciones c
                INNER JOIN usuarios u ON c.id_docente = u.id_usuario
                INNER JOIN roles r ON u.id_rol = r.id_rol
                WHERE c.id_anteproyecto = ?
                ORDER BY c.fecha_calificacion DESC
                <sql:param value="${proy.id_anteproyecto}" />
            </sql:query>

            <!-- Resumen del Proyecto -->
            <div class="card card-uts shadow-sm mb-4">
                <div class="card-body p-4">
                    <div class="row align-items-center gy-3">
                        <div class="col-md-8">
                            <span class="badge badge-estado badge-estado-${fn:replace(fn:toLowerCase(proy.estado), ' ', '-')} mb-2">
                                <c:out value="${proy.estado}" />
                            </span>
                            <h4 class="fw-bold text-dark mb-1"><c:out value="${proy.titulo}" /></h4>
                            <div class="small text-muted">
                                Director: <strong><c:out value="${empty proy.nom_dir ? 'Sin asignar' : proy.nom_dir.concat(' ').concat(proy.ape_dir)}" /></strong> &bull;
                                Evaluador: <strong><c:out value="${empty proy.nom_eva ? 'Sin asignar' : proy.nom_eva.concat(' ').concat(proy.ape_eva)}" /></strong>
                            </div>
                        </div>
                        <div class="col-md-4 text-md-end">
                            <div class="small text-muted mb-1">Escala de Calificación UTS</div>
                            <span class="badge bg-secondary-subtle text-secondary border px-3 py-2">
                                Mínimo Aprobatorio: <strong>3.0 / 5.0</strong>
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Listado de Evaluaciones / Conceptos -->
            <div class="card card-uts shadow-sm">
                <div class="card-header bg-white py-3">
                    <h5 class="mb-0 fw-bold text-dark"><i class="bi bi-card-checklist text-primary me-2"></i>Historial de Conceptos y Notas Registradas</h5>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${qNotas.rowCount > 0}">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="table-light text-secondary">
                                        <tr>
                                            <th>Etapa / Evaluación</th>
                                            <th>Docente Calificador</th>
                                            <th class="text-center">Calificación (0.0 - 5.0)</th>
                                            <th class="text-center">Decisión</th>
                                            <th>Observaciones y Recomendaciones</th>
                                            <th class="text-end pe-3">Fecha</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="n" items="${qNotas.rows}">
                                            <tr>
                                                <td class="fw-bold text-dark"><c:out value="${n.tipo_evaluacion}" /></td>
                                                <td>
                                                    <div class="fw-semibold"><c:out value="${n.nom_doc} ${n.ape_doc}" /></div>
                                                    <span class="badge badge-rol badge-rol-${n.nombre_rol}"><c:out value="${n.nombre_rol}" /></span>
                                                </td>
                                                <td class="text-center">
                                                    <span class="badge ${n.nota >= 3.0 ? 'bg-success' : 'bg-danger'} fs-5 px-3 py-2">
                                                        <fmt:formatNumber value="${n.nota}" pattern="0.0" />
                                                    </span>
                                                </td>
                                                <td class="text-center">
                                                    <c:choose>
                                                        <c:when test="${n.estado_decision == 'Aprobado'}">
                                                            <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1">
                                                                <i class="bi bi-check-circle-fill me-1"></i>Aprobado
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${n.estado_decision == 'Devuelto'}">
                                                            <span class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle px-2 py-1">
                                                                <i class="bi bi-arrow-return-left me-1"></i>Devuelto
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-2 py-1">
                                                                <i class="bi bi-x-circle-fill me-1"></i>Rechazado
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <div class="small text-muted p-2 bg-light rounded border">
                                                        <c:out value="${n.observaciones}" />
                                                    </div>
                                                </td>
                                                <td class="text-end pe-3 text-secondary small">
                                                    <fmt:formatDate value="${n.fecha_calificacion}" pattern="dd/MM/yyyy HH:mm" />
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="py-5 text-center text-muted">
                                <i class="bi bi-hourglass-split display-4 d-block mb-3 text-secondary opacity-50"></i>
                                <h5>No se han registrado evaluaciones todavía</h5>
                                <p class="small text-muted">Tus docentes tutores notificarán aquí las calificaciones una vez revisado el documento.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<%@ include file="/includes/footer.jspf" %>
