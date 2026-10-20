<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="DIRECTOR" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="idAnteproyecto" value="${param.id_anteproyecto}" />
<c:set var="estadoActual" value="${param.estado_actual}" />
<c:set var="tieneEvaluador" value="${param.tiene_evaluador == '1'}" />
<c:set var="tipoEval" value="${fn:trim(param.tipo_evaluacion)}" />
<c:set var="nota" value="${fn:trim(param.nota)}" />
<c:set var="decision" value="${fn:trim(param.estado_decision)}" />
<c:set var="observaciones" value="${fn:trim(param.observaciones)}" />

<%-- Validaciones --%>
<c:if test="${empty idAnteproyecto or empty tipoEval or empty nota or empty decision or empty observaciones}">
    <c:set var="mensaje_error" value="Todos los campos del formulario de calificación son obligatorios." scope="session" />
    <c:redirect url="/director/proyecto_revisar.jsp?id=${idAnteproyecto}" />
</c:if>

<%-- 1. Insertar registro en tabla calificaciones --%>
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

<%-- 2. Calcular nuevo estado según decisión --%>
<c:choose>
    <c:when test="${tipoEval == 'Documento Final - Director'}">
        <c:choose>
            <c:when test="${decision == 'Aprobado'}">
                <c:set var="nuevoEstado" value="Sustentado" />
                <c:set var="obsHistorial" value="Director avala monografía final con nota ${nota}. Proyecto habilitado para sustentación oral." />
            </c:when>
            <c:otherwise>
                <c:set var="nuevoEstado" value="Devuelto con observaciones" />
                <c:set var="obsHistorial" value="Director devuelve documento final con observaciones (Nota: ${nota})." />
            </c:otherwise>
        </c:choose>
    </c:when>

    <c:otherwise>
        <c:choose>
            <c:when test="${decision == 'Aprobado'}">
                <c:choose>
                    <c:when test="${tieneEvaluador}">
                        <c:set var="nuevoEstado" value="En revisión por evaluador" />
                        <c:set var="obsHistorial" value="Director aprueba anteproyecto (Nota: ${nota}) y remite al evaluador asignado." />
                    </c:when>
                    <c:otherwise>
                        <c:set var="nuevoEstado" value="Aprobado por director" />
                        <c:set var="obsHistorial" value="Director aprueba anteproyecto (Nota: ${nota}). Pendiente asignación de evaluador por Coordinación." />
                    </c:otherwise>
                </c:choose>
            </c:when>
            <c:otherwise>
                <c:set var="nuevoEstado" value="Devuelto con observaciones" />
                <c:set var="obsHistorial" value="Director devuelve anteproyecto con observaciones técnicas para corrección (Nota: ${nota})." />
            </c:otherwise>
        </c:choose>
    </c:otherwise>
</c:choose>

<%-- 3. Actualizar estado del anteproyecto --%>
<sql:update dataSource="${conn}">
    UPDATE anteproyectos 
    SET estado = ? 
    WHERE id_anteproyecto = ? AND id_director = ?
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
    <sql:param value="${obsHistorial}" />
</sql:update>

<c:set var="mensaje_exito" value="Calificación registrada correctamente. El proyecto ha avanzado al estado '${nuevoEstado}'." scope="session" />
<c:redirect url="/director/proyectos_listar.jsp" />
