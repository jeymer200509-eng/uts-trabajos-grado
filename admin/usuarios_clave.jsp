<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="ADMIN" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="idUsuario" value="${param.id_usuario}" />
<c:set var="nuevaClave" value="${fn:trim(param.nueva_clave)}" />

<c:choose>
    <c:when test="${empty idUsuario or empty nuevaClave}">
        <c:set var="mensaje_error" value="Debe proporcionar el identificador y la nueva contraseña." scope="session" />
    </c:when>
    <c:when test="${fn:length(nuevaClave) < 6}">
        <c:set var="mensaje_error" value="La contraseña debe contener al menos 6 caracteres." scope="session" />
    </c:when>
    <c:otherwise>
        <%-- Actualizar contraseña con hash SHA-256 parametrizado --%>
        <sql:update dataSource="${conn}">
            UPDATE usuarios 
            SET clave = SHA2(?, 256) 
            WHERE id_usuario = ?
            <sql:param value="${nuevaClave}" />
            <sql:param value="${idUsuario}" />
        </sql:update>
        <c:set var="mensaje_exito" value="Contraseña restablecida exitosamente con cifrado SHA-256." scope="session" />
    </c:otherwise>
</c:choose>

<c:redirect url="/admin/usuarios_listar.jsp" />
