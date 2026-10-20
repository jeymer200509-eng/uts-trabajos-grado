<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ include file="/includes/conexion.jspf" %>

<%-- Obtener y limpiar parámetros --%>
<c:set var="usuarioInput" value="${fn:trim(param.usuario)}" />
<c:set var="claveInput" value="${param.clave}" />

<%-- Validar que no vengan vacíos --%>
<c:if test="${empty usuarioInput or empty claveInput}">
    <c:set var="mensaje_error" value="Por favor ingrese su usuario y contraseña." scope="session" />
    <c:redirect url="/login.jsp" />
</c:if>

<%-- Consulta parametrizada con SHA2(?, 256) --%>
<sql:query var="resLogin" dataSource="${conn}">
    SELECT u.id_usuario, u.id_rol, u.id_programa, u.codigo, u.documento, 
           u.nombres, u.apellidos, u.correo, u.activo, r.nombre_rol, p.nombre_programa
    FROM usuarios u
    INNER JOIN roles r ON u.id_rol = r.id_rol
    LEFT JOIN programas p ON u.id_programa = p.id_programa
    WHERE (u.correo = ? OR u.codigo = ?)
      AND u.clave = SHA2(?, 256)
    LIMIT 1
    <sql:param value="${usuarioInput}" />
    <sql:param value="${usuarioInput}" />
    <sql:param value="${claveInput}" />
</sql:query>

<c:choose>
    <c:when test="${resLogin.rowCount == 1}">
        <c:set var="userRow" value="${resLogin.rows[0]}" />
        
        <c:choose>
            <c:when test="${userRow.activo}">
                <%-- Registrar atributos en sessionScope --%>
                <c:set var="id_usuario" value="${userRow.id_usuario}" scope="session" />
                <c:set var="usuario" value="${userRow.correo}" scope="session" />
                <c:set var="codigo" value="${userRow.codigo}" scope="session" />
                <c:set var="documento" value="${userRow.documento}" scope="session" />
                <c:set var="nombres" value="${userRow.nombres}" scope="session" />
                <c:set var="apellidos" value="${userRow.apellidos}" scope="session" />
                <c:set var="nombre_completo" value="${userRow.nombres} ${userRow.apellidos}" scope="session" />
                <c:set var="rol" value="${userRow.nombre_rol}" scope="session" />
                <c:set var="id_rol" value="${userRow.id_rol}" scope="session" />
                <c:set var="id_programa" value="${userRow.id_programa}" scope="session" />
                <c:set var="nombre_programa" value="${userRow.nombre_programa}" scope="session" />
                
                <c:set var="mensaje_exito" value="¡Bienvenido(a) al Sistema de Trabajos de Grado, ${userRow.nombres}!" scope="session" />
                <c:redirect url="/index.jsp" />
            </c:when>
            <c:otherwise>
                <c:set var="mensaje_error" value="Su cuenta de usuario se encuentra inactiva. Comuníquese con la Coordinación de Grado." scope="session" />
                <c:redirect url="/login.jsp" />
            </c:otherwise>
        </c:choose>
    </c:when>
    <c:otherwise>
        <c:set var="mensaje_error" value="Credenciales inválidas. Verifique su correo/código y contraseña." scope="session" />
        <c:redirect url="/login.jsp" />
    </c:otherwise>
</c:choose>
