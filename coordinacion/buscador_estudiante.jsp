<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="COORDINACION" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="pageTitle" value="Búsqueda de Estudiante y Trazabilidad - UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<c:set var="criterio" value="${not empty param.codigo ? fn:trim(param.codigo) : fn:trim(param.criterio)}" />
<c:set var="criterioPattern" value="%${criterio}%" />

<%-- Búsqueda de Estudiante si hay criterio --%>
<c:if test="${not empty criterio}">
    <sql:query var="qEstudiante" dataSource="${conn}">
        SELECT u.id_usuario, u.codigo, u.documento, u.nombres, u.apellidos, u.correo, u.telefono, u.semestre,
               p.nombre_programa, p.nivel
        FROM usuarios u
        LEFT JOIN programas p ON u.id_programa = p.id_programa
        INNER JOIN roles r ON u.id_rol = r.id_rol AND r.nombre_rol = 'ESTUDIANTE'
        WHERE u.codigo = ? OR u.documento = ? OR u.nombres LIKE ? OR u.apellidos LIKE ?
        LIMIT 1
        <sql:param value="${criterio}" />
        <sql:param value="${criterio}" />
        <sql:param value="${criterioPattern}" />
        <sql:param value="${criterioPattern}" />
    </sql:query>

    <c:if test="${qEstudiante.rowCount > 0}">
        <c:set var="est" value="${qEstudiante.rows[0]}" />

        <%-- Buscar Anteproyecto del estudiante --%>
        <sql:query var="qProy" dataSource="${conn}">
            SELECT a.*, 
                   d.nombres AS nom_dir, d.apellidos AS ape_dir, d.correo AS correo_dir,
                   e.nombres AS nom_eva, e.apellidos AS ape_eva, e.correo AS correo_eva,
                   i.titulo AS titulo_idea
            FROM anteproyectos a
            LEFT JOIN usuarios d ON a.id_director = d.id_usuario
            LEFT JOIN usuarios e ON a.id_evaluador = e.id_usuario
            LEFT JOIN ideas i ON a.id_idea = i.id_idea
            WHERE a.id_estudiante = ?
            <sql:param value="${est.id_usuario}" />
        </sql:query>

        <c:if test="${qProy.rowCount > 0}">
            <c:set var="proy" value="${qProy.rows[0]}" />

            <%-- Historial cronológico de cambios de estado --%>
            <sql:query var="qHist" dataSource="${conn}">
                SELECT h.*, u.nombres AS nom_usr, u.apellidos AS ape_usr, r.nombre_rol
                FROM historial_estados h
                INNER JOIN usuarios u ON h.id_usuario = u.id_usuario
                INNER JOIN roles r ON u.id_rol = r.id_rol
                WHERE h.id_anteproyecto = ?
                ORDER BY h.fecha_cambio ASC
                <sql:param value="${proy.id_anteproyecto}" />
            </sql:query>

            <%-- Calificaciones registradas --%>
            <sql:query var="qCalif" dataSource="${conn}">
                SELECT c.*, u.nombres AS nom_doc, u.apellidos AS ape_doc, r.nombre_rol
                FROM calificaciones c
                INNER JOIN usuarios u ON c.id_docente = u.id_usuario
                INNER JOIN roles r ON u.id_rol = r.id_rol
                WHERE c.id_anteproyecto = ?
                ORDER BY c.fecha_calificacion ASC
                <sql:param value="${proy.id_anteproyecto}" />
            </sql:query>
        </c:if>
    </c:if>
</c:if>

<div class="container-fluid px-lg-4 py-4">
    <!-- Encabezado -->
    <div class="mb-4">
        <h2 class="fw-bold mb-1 text-dark">
            <i class="bi bi-search text-success me-2"></i>Buscador de Proyecto y Trazabilidad por Estudiante
        </h2>
        <p class="text-secondary mb-0">Consulte el expediente institucional completo de un estudiante con su historial de estados y calificaciones.</p>
    </div>

    <!-- Caja de Búsqueda -->
    <div class="card card-uts shadow-sm mb-4">
        <div class="card-body p-4">
            <form action="${pageContext.request.contextPath}/coordinacion/buscador_estudiante.jsp" method="GET" class="row g-2 align-items-center">
                <div class="col-md-9 col-lg-10">
                    <div class="input-group input-group-lg">
                        <span class="input-group-text bg-white text-success"><i class="bi bi-person-bounding-box"></i></span>
                        <input type="text" name="criterio" class="form-control" 
                               placeholder="Ingrese código estudiantil, número de documento o nombre del estudiante..." 
                               value="<c:out value='${criterio}' />" required autofocus>
                    </div>
                </div>
                <div class="col-md-3 col-lg-2">
                    <button type="submit" class="btn btn-uts-primary btn-lg w-100 shadow-sm">
                        <i class="bi bi-search me-1"></i> Buscar
                    </button>
                </div>
            </form>
            <div class="form-text mt-2">
                Ejemplos de prueba: <code>1098765432</code> (Andrés Torres), <code>1098765433</code> (Valentina Castro), <code>1098765435</code> (Daniela Ramírez).
            </div>
        </div>
    </div>

    <!-- Resultados -->
    <c:choose>
        <c:when test="${not empty criterio and qEstudiante.rowCount == 0}">
            <div class="alert alert-warning shadow-sm d-flex align-items-center">
                <i class="bi bi-exclamation-triangle-fill fs-3 me-3 text-warning"></i>
                <div>
                    <strong>Estudiante no encontrado</strong>
                    <div class="small">No se localizó ningún estudiante activo con el código o nombre "<c:out value='${criterio}' />". Verifique el valor ingresado.</div>
                </div>
            </div>
        </c:when>

        <c:when test="${not empty criterio and qEstudiante.rowCount > 0}">
            <!-- Ficha del Estudiante -->
            <div class="card card-uts shadow-sm mb-4 border-start border-4 border-start-success">
                <div class="card-body p-4">
                    <div class="row align-items-center gy-3">
                        <div class="col-md-2 text-center">
                            <div class="display-3 text-success">
                                <i class="bi bi-mortarboard"></i>
                            </div>
                            <span class="badge badge-rol badge-rol-ESTUDIANTE">Estudiante UTS</span>
                        </div>
                        <div class="col-md-6">
                            <h4 class="fw-bold mb-1 text-dark"><c:out value="${est.nombres} ${est.apellidos}" /></h4>
                            <div class="text-secondary small mb-2">
                                <span class="me-3"><strong>Código:</strong> <code><c:out value="${est.codigo}" /></code></span>
                                <span><strong>Documento:</strong> <c:out value="${est.documento}" /></span>
                            </div>
                            <div class="fw-semibold text-dark mb-1">
                                <i class="bi bi-book me-1 text-success"></i> <c:out value="${est.nombre_programa}" /> (<c:out value="${est.nivel}" />)
                            </div>
                            <small class="text-muted">Semestre Académico: <strong><c:out value="${est.semestre}" />°</strong></small>
                        </div>
                        <div class="col-md-4 border-start-md ps-md-4">
                            <div class="small text-muted mb-1"><i class="bi bi-envelope me-1"></i> <c:out value="${est.correo}" /></div>
                            <div class="small text-muted mb-2"><i class="bi bi-telephone me-1"></i> <c:out value="${empty est.telefono ? 'Sin teléfono registrado' : est.telefono}" /></div>
                            <div>
                                <span class="badge bg-success-subtle text-success border border-success-subtle">
                                    <i class="bi bi-check-circle-fill me-1"></i>Usuario Habilitado
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ficha del Proyecto o Alerta si no tiene -->
            <c:choose>
                <c:when test="${empty proy}">
                    <div class="alert alert-info shadow-sm">
                        <i class="bi bi-info-circle-fill me-2 fs-5"></i>
                        El estudiante <strong><c:out value="${est.nombres} ${est.apellidos}" /></strong> aún no tiene ningún anteproyecto radicado ni idea seleccionada.
                    </div>
                </c:when>

                <c:otherwise>
                    <!-- Detalle del Proyecto -->
                    <div class="row g-4 mb-4">
                        <div class="col-lg-8">
                            <div class="card card-uts shadow-sm h-100">
                                <div class="card-header card-header-uts py-3 d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0 fw-bold"><i class="bi bi-journal-text me-2"></i>Información del Trabajo de Grado</h5>
                                    <span class="badge bg-light text-dark fw-bold">v<c:out value="${proy.version}" /></span>
                                </div>
                                <div class="card-body p-4">
                                    <div class="d-flex justify-content-between align-items-center mb-3">
                                        <span class="badge bg-primary-subtle text-primary border border-primary-subtle py-2 px-3">
                                            <i class="bi bi-tag-fill me-1"></i> Línea: <c:out value="${proy.linea_investigacion}" />
                                        </span>
                                        <span class="badge badge-estado badge-estado-${fn:replace(fn:toLowerCase(proy.estado), ' ', '-')} py-2 px-3 fs-6">
                                            <c:out value="${proy.estado}" />
                                        </span>
                                    </div>

                                    <h4 class="fw-bold text-dark mb-3"><c:out value="${proy.titulo}" /></h4>

                                    <div class="mb-3">
                                        <h6 class="fw-bold text-secondary mb-1">Planteamiento del Problema:</h6>
                                        <p class="text-muted small"><c:out value="${proy.planteamiento_problema}" /></p>
                                    </div>

                                    <div class="mb-3">
                                        <h6 class="fw-bold text-secondary mb-1">Objetivo General:</h6>
                                        <p class="text-muted small"><c:out value="${proy.objetivo_general}" /></p>
                                    </div>

                                    <div class="mb-3">
                                        <h6 class="fw-bold text-secondary mb-1">Objetivos Específicos:</h6>
                                        <p class="text-muted small" style="white-space: pre-line;"><c:out value="${proy.objetivos_especificos}" /></p>
                                    </div>

                                    <div class="mb-3">
                                        <h6 class="fw-bold text-secondary mb-1">Resumen del Proyecto:</h6>
                                        <p class="text-muted small"><c:out value="${proy.resumen}" /></p>
                                    </div>

                                    <!-- Enlace al documento en nube -->
                                    <div class="p-3 bg-light rounded-3 d-flex flex-wrap justify-content-between align-items-center gap-2">
                                        <div>
                                            <div class="fw-bold text-dark"><i class="bi bi-cloud-arrow-down-fill text-primary me-2"></i>Documento del Anteproyecto:</div>
                                            <small class="text-muted text-break"><c:out value="${proy.enlace_documento}" /></small>
                                        </div>
                                        <a href="<c:out value='${proy.enlace_documento}' />" target="_blank" class="btn btn-sm btn-outline-primary">
                                            <i class="bi bi-box-arrow-up-right me-1"></i> Abrir Documento
                                        </a>
                                    </div>

                                    <c:if test="${not empty proy.enlace_documento_final}">
                                        <div class="p-3 bg-success-subtle border border-success-subtle rounded-3 d-flex flex-wrap justify-content-between align-items-center gap-2 mt-3">
                                            <div>
                                                <div class="fw-bold text-success"><i class="bi bi-file-earmark-check-fill me-2"></i>Documento Final de Grado Entregado:</div>
                                                <small class="text-muted text-break"><c:out value="${proy.enlace_documento_final}" /></small>
                                            </div>
                                            <a href="<c:out value='${proy.enlace_documento_final}' />" target="_blank" class="btn btn-sm btn-success">
                                                <i class="bi bi-box-arrow-up-right me-1"></i> Ver Monografía Final
                                            </a>
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </div>

                        <!-- Tutores Asignados y Calificaciones -->
                        <div class="col-lg-4">
                            <!-- Card Tutores -->
                            <div class="card card-uts shadow-sm mb-4">
                                <div class="card-header bg-white py-3">
                                    <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-people-fill text-primary me-2"></i>Equipo Evaluador y Tutoral</h6>
                                </div>
                                <div class="card-body p-3">
                                    <div class="mb-3 p-2 bg-light rounded">
                                        <div class="small text-secondary fw-semibold">DOCENTE DIRECTOR:</div>
                                        <c:choose>
                                            <c:when test="${not empty proy.nom_dir}">
                                                <div class="fw-bold text-dark"><c:out value="${proy.nom_dir} ${proy.ape_dir}" /></div>
                                                <small class="text-muted"><i class="bi bi-envelope"></i> <c:out value="${proy.correo_dir}" /></small>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-warning-subtle text-warning border border-warning-subtle mt-1">Sin Director Asignado</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <div class="p-2 bg-light rounded">
                                        <div class="small text-secondary fw-semibold">DOCENTE EVALUADOR:</div>
                                        <c:choose>
                                            <c:when test="${not empty proy.nom_eva}">
                                                <div class="fw-bold text-dark"><c:out value="${proy.nom_eva} ${proy.ape_eva}" /></div>
                                                <small class="text-muted"><i class="bi bi-envelope"></i> <c:out value="${proy.correo_eva}" /></small>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle mt-1">Sin Evaluador Asignado</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>

                            <!-- Card Calificaciones -->
                            <div class="card card-uts shadow-sm">
                                <div class="card-header bg-white py-3">
                                    <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-award-fill text-warning me-2"></i>Calificaciones Emitidas</h6>
                                </div>
                                <div class="card-body p-3">
                                    <c:choose>
                                        <c:when test="${qCalif.rowCount > 0}">
                                            <c:forEach var="c" items="${qCalif.rows}">
                                                <div class="border-bottom pb-2 mb-2">
                                                    <div class="d-flex justify-content-between align-items-center">
                                                        <span class="fw-bold text-dark small"><c:out value="${c.tipo_evaluacion}" /></span>
                                                        <span class="badge ${c.nota >= 3.0 ? 'bg-success' : 'bg-danger'} fs-6">
                                                            <fmt:formatNumber value="${c.nota}" pattern="0.0" />
                                                        </span>
                                                    </div>
                                                    <div class="small text-muted mt-1"><c:out value="${c.observaciones}" /></div>
                                                    <div class="text-end text-secondary" style="font-size: 0.75rem;">
                                                        Por: <c:out value="${c.nom_doc} ${c.ape_doc}" /> &bull; <fmt:formatDate value="${c.fecha_calificacion}" pattern="dd/MM/yyyy HH:mm" />
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="text-center py-3 text-muted small">
                                                Aún no se han asentado notas en el sistema para este proyecto.
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Línea de Tiempo de Estados (Historial) -->
                    <div class="card card-uts shadow-sm">
                        <div class="card-header card-header-blue py-3">
                            <h5 class="mb-0 fw-bold">
                                <i class="bi bi-diagram-3-fill me-2"></i>Línea de Tiempo y Trazabilidad Histórica de Estados
                            </h5>
                        </div>
                        <div class="card-body p-4">
                            <c:choose>
                                <c:when test="${qHist.rowCount > 0}">
                                    <ul class="timeline">
                                        <c:forEach var="h" items="${qHist.rows}">
                                            <li class="timeline-item">
                                                <div class="timeline-icon">
                                                    <i class="bi bi-check2"></i>
                                                </div>
                                                <div class="bg-light p-3 rounded-3 shadow-sm">
                                                    <div class="d-flex flex-wrap justify-content-between align-items-center mb-1">
                                                        <div class="fw-bold text-dark fs-6">
                                                            <c:if test="${not empty h.estado_anterior}">
                                                                <span class="text-muted"><c:out value="${h.estado_anterior}" /> &rarr;</span>
                                                            </c:if>
                                                            <span class="badge badge-estado badge-estado-${fn:replace(fn:toLowerCase(h.estado_nuevo), ' ', '-')}">
                                                                <c:out value="${h.estado_nuevo}" />
                                                            </span>
                                                        </div>
                                                        <small class="text-muted">
                                                            <i class="bi bi-calendar3 me-1"></i>
                                                            <fmt:formatDate value="${h.fecha_cambio}" pattern="dd/MM/yyyy HH:mm" />
                                                        </small>
                                                    </div>
                                                    <div class="text-secondary small mb-1">
                                                        <i class="bi bi-person-fill"></i> Registrado por: 
                                                        <strong><c:out value="${h.nom_usr} ${h.ape_usr}" /></strong> (<c:out value="${h.nombre_rol}" />)
                                                    </div>
                                                    <c:if test="${not empty h.observacion}">
                                                        <div class="p-2 bg-white rounded border small text-muted mt-2">
                                                            <strong>Observación:</strong> <c:out value="${h.observacion}" />
                                                        </div>
                                                    </c:if>
                                                </div>
                                            </li>
                                        </c:forEach>
                                    </ul>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-4 text-muted">
                                        Sin movimientos históricos registrados en el ciclo de vida.
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </c:when>
    </c:choose>
</div>

<%@ include file="/includes/footer.jspf" %>
