<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="COORDINACION" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="idAnteproyecto" value="${param.id_anteproyecto}" />
<c:set var="decisionPago" value="${fn:trim(param.decision_pago)}" />
<c:set var="observacionPago" value="${fn:trim(param.observacion_pago)}" />

<c:if test="${empty idAnteproyecto or (decisionPago != 'Aprobado' and decisionPago != 'Rechazado')}">
    <c:set var="mensaje_error" value="Datos inválidos para procesar la validación del desprendible de pago." scope="session" />
    <c:redirect url="/coordinacion/pagos_listar.jsp" />
</c:if>

<sql:query var="qAnt" dataSource="${conn}">
    SELECT estado FROM anteproyectos WHERE id_anteproyecto = ?
    <sql:param value="${idAnteproyecto}" />
</sql:query>

<c:if test="${qAnt.rowCount == 0}">
    <c:set var="mensaje_error" value="El registro del estudiante no existe." scope="session" />
    <c:redirect url="/coordinacion/pagos_listar.jsp" />
</c:if>

<c:set var="estadoActual" value="${qAnt.rows[0].estado}" />

<%-- Actualizar estado del pago en anteproyectos --%>
<sql:update dataSource="${conn}">
    UPDATE anteproyectos 
    SET estado_pago = ?,
        observacion_pago = ?
    WHERE id_anteproyecto = ?
    <sql:param value="${decisionPago}" />
    <sql:param value="${observacionPago}" />
    <sql:param value="${idAnteproyecto}" />
</sql:update>

<%-- Registrar en historial de estados --%>
<c:set var="textoHistorial" value="${decisionPago == 'Aprobado' ? 'Fase 1 Aceptada: Coordinación aprobó el desprendible de pago y desbloqueó la Fase 2.' : 'Fase 1 Rechazada: Coordinación rechazó el desprendible de pago. Motivo: '.concat(observacionPago)}" />

<sql:update dataSource="${conn}">
    INSERT INTO historial_estados (id_anteproyecto, id_usuario, estado_anterior, estado_nuevo, observacion)
    VALUES (?, ?, ?, ?, ?)
    <sql:param value="${idAnteproyecto}" />
    <sql:param value="${sessionScope.id_usuario}" />
    <sql:param value="${estadoActual}" />
    <sql:param value="${estadoActual}" />
    <sql:param value="${textoHistorial}" />
</sql:update>

<c:choose>
    <c:when test="${decisionPago == 'Aprobado'}">
        <c:set var="mensaje_exito" value="¡Desprendible de pago ACEPTADO! Se ha desbloqueado la Fase 2 para que el estudiante envíe su propuesta al Director." scope="session" />
    </c:when>
    <c:otherwise>
        <c:set var="mensaje_exito" value="El desprendible de pago ha sido RECHAZADO y se notificó la observación al estudiante." scope="session" />
    </c:otherwise>
</c:choose>

<c:redirect url="/coordinacion/pagos_listar.jsp" />
