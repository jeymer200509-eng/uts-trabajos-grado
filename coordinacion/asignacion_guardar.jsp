<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="COORDINACION" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="idAnteproyecto" value="${param.id_anteproyecto}" />
<c:set var="estadoActual" value="${param.estado_actual}" />
<c:set var="idDirector" value="${empty param.id_director ? null : fn:trim(param.id_director)}" />
<c:set var="idEvaluador" value="${empty param.id_evaluador ? null : fn:trim(param.id_evaluador)}" />
<c:set var="observacion" value="${empty param.observacion ? 'Asignación de director/evaluador realizada por Coordinación' : fn:trim(param.observacion)}" />

<c:if test="${empty idAnteproyecto}">
    <c:set var="mensaje_error" value="Anteproyecto no especificado." scope="session" />
    <c:redirect url="/coordinacion/asignacion_listar.jsp" />
</c:if>

<%-- Validar que el director no supere los 5 proyectos simultáneos --%>
<c:if test="${not empty idDirector}">
    <sql:query var="qCargaDir" dataSource="${conn}">
        SELECT COUNT(*) AS total FROM anteproyectos 
        WHERE id_director = ? 
          AND id_anteproyecto != ? 
          AND estado NOT IN ('Rechazado', 'Sustentado')
        <sql:param value="${idDirector}" />
        <sql:param value="${idAnteproyecto}" />
    </sql:query>
    <c:if test="${qCargaDir.rows[0].total >= 5}">
        <c:set var="mensaje_error" value="El docente director seleccionado ha alcanzado el límite institucional de 5 proyectos activos simultáneos." scope="session" />
        <c:redirect url="/coordinacion/asignacion_listar.jsp" />
    </c:if>
</c:if>

<%-- Determinar transición de estado --%>
<c:set var="nuevoEstado" value="${estadoActual}" />
<c:choose>
    <c:when test="${estadoActual == 'Anteproyecto radicado' and not empty idDirector}">
        <c:set var="nuevoEstado" value="En revisión por director" />
    </c:when>
    <c:when test="${estadoActual == 'Aprobado por director' and not empty idEvaluador}">
        <c:set var="nuevoEstado" value="En revisión por evaluador" />
    </c:when>
</c:choose>

<%-- Actualizar anteproyecto --%>
<sql:update dataSource="${conn}">
    UPDATE anteproyectos 
    SET id_director = ?, id_evaluador = ?, estado = ?
    WHERE id_anteproyecto = ?
    <sql:param value="${idDirector}" />
    <sql:param value="${idEvaluador}" />
    <sql:param value="${nuevoEstado}" />
    <sql:param value="${idAnteproyecto}" />
</sql:update>

<%-- Registrar en historial de estados --%>
<sql:update dataSource="${conn}">
    INSERT INTO historial_estados (id_anteproyecto, id_usuario, estado_anterior, estado_nuevo, observacion)
    VALUES (?, ?, ?, ?, ?)
    <sql:param value="${idAnteproyecto}" />
    <sql:param value="${sessionScope.id_usuario}" />
    <sql:param value="${estadoActual}" />
    <sql:param value="${nuevoEstado}" />
    <sql:param value="${observacion}" />
</sql:update>

<c:set var="mensaje_exito" value="Asignación de tutores y actualización de estado registradas con éxito." scope="session" />
<c:redirect url="/coordinacion/asignacion_listar.jsp" />
