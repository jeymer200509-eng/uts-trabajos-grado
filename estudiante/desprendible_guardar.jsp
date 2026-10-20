<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="ESTUDIANTE" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="enlaceDesprendible" value="${fn:trim(param.enlace_desprendible)}" />

<c:if test="${empty enlaceDesprendible}">
    <c:set var="mensaje_error" value="Debes ingresar el enlace al PDF del desprendible de pago en Drive o nube." scope="session" />
    <c:redirect url="/estudiante/index.jsp" />
</c:if>

<c:if test="${!fn:startsWith(enlaceDesprendible, 'http://') and !fn:startsWith(enlaceDesprendible, 'https://')}">
    <c:set var="mensaje_error" value="El enlace del desprendible de pago debe iniciar con http:// o https://." scope="session" />
    <c:redirect url="/estudiante/index.jsp" />
</c:if>

<%-- Verificar que el estudiante ya haya seleccionado una idea --%>
<sql:query var="qExistente" dataSource="${conn}">
    SELECT id_anteproyecto, estado FROM anteproyectos WHERE id_estudiante = ?
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<c:if test="${qExistente.rowCount == 0}">
    <c:set var="mensaje_error" value="Primero debes seleccionar una idea en el Banco de Ideas para habilitar la subida del desprendible de pago." scope="session" />
    <c:redirect url="/estudiante/banco_ideas.jsp" />
</c:if>

<c:set var="idProy" value="${qExistente.rows[0].id_anteproyecto}" />
<sql:update dataSource="${conn}">
    UPDATE anteproyectos 
    SET enlace_desprendible = ?,
        estado_pago = 'En revisión',
        observacion_pago = NULL
    WHERE id_anteproyecto = ? AND id_estudiante = ?
    <sql:param value="${enlaceDesprendible}" />
    <sql:param value="${idProy}" />
    <sql:param value="${sessionScope.id_usuario}" />
</sql:update>

<sql:update dataSource="${conn}">
    INSERT INTO historial_estados (id_anteproyecto, id_usuario, estado_anterior, estado_nuevo, observacion)
    VALUES (?, ?, ?, ?, 'Fase 1: El estudiante subió el desprendible de pago. En espera de revisión y aceptación por Coordinación.')
    <sql:param value="${idProy}" />
    <sql:param value="${sessionScope.id_usuario}" />
    <sql:param value="${qExistente.rows[0].estado}" />
    <sql:param value="${qExistente.rows[0].estado}" />
</sql:update>

<c:set var="mensaje_exito" value="¡Desprendible de pago subido con éxito! Ahora Coordinación revisará el PDF y, al aceptarlo, se desbloqueará la Fase 2 para enviar tu propuesta al Director." scope="session" />
<c:redirect url="/estudiante/index.jsp" />
