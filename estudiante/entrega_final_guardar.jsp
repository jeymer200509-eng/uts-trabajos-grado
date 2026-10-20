<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="ESTUDIANTE" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="idAnteproyecto" value="${param.id_anteproyecto}" />
<c:set var="estadoAnterior" value="${param.estado_anterior}" />
<c:set var="enlaceFinal" value="${fn:trim(param.enlace_documento_final)}" />
<c:set var="resumenFinal" value="${fn:trim(param.resumen_documento_final)}" />

<c:if test="${empty idAnteproyecto or empty enlaceFinal or empty resumenFinal}">
    <c:set var="mensaje_error" value="Todos los campos son obligatorios para radicar la entrega final." scope="session" />
    <c:redirect url="/estudiante/entrega_final.jsp" />
</c:if>

<c:if test="${!fn:startsWith(enlaceFinal, 'http://') and !fn:startsWith(enlaceFinal, 'https://')}">
    <c:set var="mensaje_error" value="El enlace al documento final debe ser una URL válida (http:// o https://)." scope="session" />
    <c:redirect url="/estudiante/entrega_final.jsp" />
</c:if>

<%-- Actualizar anteproyecto a estado 'Documento final entregado' --%>
<sql:update dataSource="${conn}">
    UPDATE anteproyectos 
    SET enlace_documento_final = ?, 
        resumen_documento_final = ?, 
        fecha_entrega_final = NOW(), 
        estado = 'Documento final entregado'
    WHERE id_anteproyecto = ? AND id_estudiante = ?
    <sql:param value="${enlaceFinal}" />
    <sql:param value="${resumenFinal}" />
    <sql:param value="${idAnteproyecto}" />
    <sql:param value="${sessionScope.id_usuario}" />
</sql:update>

<%-- Registrar en historial de estados --%>
<sql:update dataSource="${conn}">
    INSERT INTO historial_estados (id_anteproyecto, id_usuario, estado_anterior, estado_nuevo, observacion)
    VALUES (?, ?, ?, 'Documento final entregado', 'El estudiante ha radicado el enlace al documento final de grado y monografía')
    <sql:param value="${idAnteproyecto}" />
    <sql:param value="${sessionScope.id_usuario}" />
    <sql:param value="${estadoAnterior}" />
</sql:update>

<c:set var="mensaje_exito" value="¡Entrega final radicada exitosamente! Tus docentes tutores y jurados evaluadores revisarán el informe final." scope="session" />
<c:redirect url="/estudiante/anteproyecto_ver.jsp" />
