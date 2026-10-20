<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="EVALUADOR" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="idAnteproyecto" value="${param.id_anteproyecto}" />
<c:set var="estadoActual" value="${param.estado_actual}" />
<c:set var="tipoEval" value="${fn:trim(param.tipo_evaluacion)}" />
<c:set var="nota" value="${fn:trim(param.nota)}" />
<c:set var="decision" value="${fn:trim(param.estado_decision)}" />
<c:set var="observaciones" value="${fn:trim(param.observaciones)}" />

<c:if test="${empty idAnteproyecto or empty tipoEval or empty nota or empty decision or empty observaciones}">
    <c:set var="mensaje_error" value="Todos los campos del dictamen de evaluación son obligatorios." scope="session" />
    <c:redirect url="/evaluador/proyecto_revisar.jsp?id=${idAnteproyecto}" />
</c:if>

<%-- 1. Insertar calificación emitida por el evaluador --%>
<sql:update dataSource="${conn}">
    INSERT INTO calificaciones (id_anteproyecto, id_docente, tipo_evaluacion, nota, observaciones, estado_decision)
    VALUES (?, ?, ?, ?, ?, ?)
    <sql:param value="${idAnteproyecto}" />
    <sql:param value="${sessionScope.id_usuario}" />
    <sql:param value="${tipoEval}" />
    <sql:param value="${nota}" />
    <sql:param value="${observaciones}" />
    <sql:param value="${decision}" />
</sql:update>

<%-- 2. Determinar transición de estado --%>
<c:choose>
    <c:when test="${tipoEval == 'Documento Final - Evaluador'}">
        <c:choose>
            <c:when test="${decision == 'Aprobado'}">
                <c:set var="nuevoEstado" value="Sustentado" />
                <c:set var="obsHist" value="Evaluador aprueba documento final de monografía (Nota: ${nota}). Veredicto favorable para grado." />
            </c:when>
            <c:otherwise>
                <c:set var="nuevoEstado" value="Devuelto con observaciones" />
                <c:set var="obsHist" value="Evaluador devuelve documento final con correcciones requeridas (Nota: ${nota})." />
            </c:otherwise>
        </c:choose>
    </c:when>

    <c:otherwise>
        <c:choose>
            <c:when test="${decision == 'Aprobado'}">
                <c:set var="nuevoEstado" value="En desarrollo" />
                <c:set var="obsHist" value="Evaluador emite concepto APROBADO (Nota: ${nota}). Proyecto habilitado para fase de desarrollo." />
            </c:when>
            <c:otherwise>
                <c:set var="nuevoEstado" value="Rechazado" />
                <c:set var="obsHist" value="Evaluador emite concepto RECHAZADO (Nota: ${nota}). No cumple con los lineamientos del comité de grado." />
            </c:otherwise>
        </c:choose>
    </c:otherwise>
</c:choose>

<%-- 3. Actualizar anteproyecto --%>
<sql:update dataSource="${conn}">
    UPDATE anteproyectos 
    SET estado = ? 
    WHERE id_anteproyecto = ? AND id_evaluador = ?
    <sql:param value="${nuevoEstado}" />
    <sql:param value="${idAnteproyecto}" />
    <sql:param value="${sessionScope.id_usuario}" />
</sql:update>

<%-- 4. Registrar en historial de estados --%>
<sql:update dataSource="${conn}">
    INSERT INTO historial_estados (id_anteproyecto, id_usuario, estado_anterior, estado_nuevo, observacion)
    VALUES (?, ?, ?, ?, ?)
    <sql:param value="${idAnteproyecto}" />
    <sql:param value="${sessionScope.id_usuario}" />
    <sql:param value="${estadoActual}" />
    <sql:param value="${nuevoEstado}" />
    <sql:param value="${obsHist}" />
</sql:update>

<c:set var="mensaje_exito" value="Dictamen del evaluador asentado exitosamente con concepto: ${decision} (Nota: ${nota}). Nuevo estado: '${nuevoEstado}'." scope="session" />
<c:redirect url="/evaluador/proyectos_listar.jsp" />
