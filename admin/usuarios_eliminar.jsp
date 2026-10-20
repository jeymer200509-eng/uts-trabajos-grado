<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>

<c:set var="rolRequerido" value="ADMIN" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="idTarget" value="${param.id}" />

<c:choose>
    <c:when test="${empty idTarget}">
        <c:set var="mensaje_error" value="Identificador de usuario no proporcionado." scope="session" />
    </c:when>
    <c:when test="${idTarget == sessionScope.id_usuario}">
        <c:set var="mensaje_error" value="No puede desactivar o eliminar su propia cuenta de administrador en sesión." scope="session" />
    </c:when>
    <c:otherwise>
        <%-- Alternar estado activo/inactivo manteniendo integridad referencial --%>
        <sql:update dataSource="${conn}">
            UPDATE usuarios 
            SET activo = CASE WHEN activo = 1 THEN 0 ELSE 1 END 
            WHERE id_usuario = ?
            <sql:param value="${idTarget}" />
        </sql:update>
        <c:set var="mensaje_exito" value="El estado de acceso del usuario ha sido modificado exitosamente." scope="session" />
    </c:otherwise>
</c:choose>

<c:redirect url="/admin/usuarios_listar.jsp" />
