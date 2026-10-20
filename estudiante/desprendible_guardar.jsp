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

<%-- Verificar si el estudiante ya tiene un registro en anteproyectos --%>
<sql:query var="qExistente" dataSource="${conn}">
    SELECT id_anteproyecto, estado FROM anteproyectos WHERE id_estudiante = ?
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<c:choose>
    <c:when test="${qExistente.rowCount > 0}">
        <c:set var="idProy" value="${qExistente.rows[0].id_anteproyecto}" />
        <sql:update dataSource="${conn}">
            UPDATE anteproyectos 
            SET enlace_desprendible = ?
            WHERE id_anteproyecto = ? AND id_estudiante = ?
            <sql:param value="${enlaceDesprendible}" />
            <sql:param value="${idProy}" />
            <sql:param value="${sessionScope.id_usuario}" />
        </sql:update>

        <sql:update dataSource="${conn}">
            INSERT INTO historial_estados (id_anteproyecto, id_usuario, estado_anterior, estado_nuevo, observacion)
            VALUES (?, ?, ?, ?, 'Fase 1: Actualización del enlace al desprendible de pago por el estudiante')
            <sql:param value="${idProy}" />
            <sql:param value="${sessionScope.id_usuario}" />
            <sql:param value="${qExistente.rows[0].estado}" />
            <sql:param value="${qExistente.rows[0].estado}" />
        </sql:update>
    </c:when>

    <c:otherwise>
        <%-- Crear registro inicial en Fase 1 con el desprendible de pago --%>
        <sql:update dataSource="${conn}">
            INSERT INTO anteproyectos 
            (id_estudiante, titulo, linea_investigacion, planteamiento_problema, justificacion,
             objetivo_general, objetivos_especificos, resumen, enlace_documento, version, estado, enlace_desprendible)
            VALUES (?, 'Propuesta pendiente por enviar al Director', 'Por definir', 'Pendiente de diligenciar en Fase 2', '',
                    'Pendiente de diligenciar en Fase 2', 'Pendiente de diligenciar en Fase 2',
                    'Desprendible de pago registrado en Fase 1. Habilitada Fase 2 para envío de propuesta al Director.',
                    'PENDIENTE', '1.0', 'Idea seleccionada', ?)
            <sql:param value="${sessionScope.id_usuario}" />
            <sql:param value="${enlaceDesprendible}" />
        </sql:update>

        <sql:query var="qNuevo" dataSource="${conn}">
            SELECT id_anteproyecto FROM anteproyectos WHERE id_estudiante = ?
            <sql:param value="${sessionScope.id_usuario}" />
        </sql:query>

        <sql:update dataSource="${conn}">
            INSERT INTO historial_estados (id_anteproyecto, id_usuario, estado_anterior, estado_nuevo, observacion)
            VALUES (?, ?, NULL, 'Idea seleccionada', 'Fase 1 completada: Desprendible de pago cargado. Se desbloquea el envío de propuesta al Director.')
            <sql:param value="${qNuevo.rows[0].id_anteproyecto}" />
            <sql:param value="${sessionScope.id_usuario}" />
        </sql:update>
    </c:otherwise>
</c:choose>

<c:set var="mensaje_exito" value="¡Fase 1 completada! Desprendible de pago registrado con éxito. Ahora se ha desbloqueado la Fase 2 para enviar tu propuesta al Director." scope="session" />
<c:redirect url="/estudiante/index.jsp" />
