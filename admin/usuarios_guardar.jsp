<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="ADMIN" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<%-- Limpieza y captura de variables del formulario --%>
<c:set var="esEdicion" value="${param.es_edicion == '1'}" />
<c:set var="idUsuario" value="${param.id_usuario}" />
<c:set var="idRol" value="${fn:trim(param.id_rol)}" />
<c:set var="idPrograma" value="${empty param.id_programa ? null : fn:trim(param.id_programa)}" />
<c:set var="codigo" value="${fn:trim(param.codigo)}" />
<c:set var="documento" value="${fn:trim(param.documento)}" />
<c:set var="nombres" value="${fn:trim(param.nombres)}" />
<c:set var="apellidos" value="${fn:trim(param.apellidos)}" />
<c:set var="correo" value="${fn:trim(param.correo)}" />
<c:set var="telefono" value="${empty param.telefono ? null : fn:trim(param.telefono)}" />
<c:set var="semestre" value="${empty param.semestre ? null : fn:trim(param.semestre)}" />
<c:set var="activo" value="${param.activo == '1' ? 1 : 0}" />
<c:set var="clave" value="${fn:trim(param.clave)}" />

<%-- 1. Validación de campos obligatorios --%>
<c:if test="${empty idRol or empty codigo or empty documento or empty nombres or empty apellidos or empty correo or (!esEdicion and empty clave)}">
    <c:set var="mensaje_error" value="Todos los campos obligatorios (*) deben ser diligenciados." scope="session" />
    <c:redirect url="/admin/usuarios_formulario.jsp${esEdicion ? '?id='.concat(idUsuario) : ''}" />
</c:if>

<%-- 2. Verificación de duplicados (código, documento o correo) --%>
<c:set var="checkId" value="${esEdicion ? idUsuario : 0}" />
<sql:query var="qDuplicados" dataSource="${conn}">
    SELECT codigo, documento, correo FROM usuarios
    WHERE (codigo = ? OR documento = ? OR correo = ?)
      AND (? = 0 OR id_usuario != ?)
    LIMIT 1
    <sql:param value="${codigo}" />
    <sql:param value="${documento}" />
    <sql:param value="${correo}" />
    <sql:param value="${checkId}" />
    <sql:param value="${checkId}" />
</sql:query>

<c:if test="${qDuplicados.rowCount > 0}">
    <c:set var="mensaje_error" value="El código, documento o correo institucional ya pertenece a otro usuario registrado." scope="session" />
    <c:redirect url="/admin/usuarios_formulario.jsp${esEdicion ? '?id='.concat(idUsuario) : ''}" />
</c:if>

<%-- 3. Ejecución de INSERT o UPDATE --%>
<c:choose>
    <c:when test="${esEdicion}">
        <c:choose>
            <%-- Si se proporcionó una nueva clave, actualizarla con SHA-256 --%>
            <c:when test="${not empty clave}">
                <sql:update dataSource="${conn}">
                    UPDATE usuarios 
                    SET id_rol = ?, id_programa = ?, codigo = ?, documento = ?, 
                        nombres = ?, apellidos = ?, correo = ?, clave = SHA2(?, 256), 
                        telefono = ?, semestre = ?, activo = ?
                    WHERE id_usuario = ?
                    <sql:param value="${idRol}" />
                    <sql:param value="${idPrograma}" />
                    <sql:param value="${codigo}" />
                    <sql:param value="${documento}" />
                    <sql:param value="${nombres}" />
                    <sql:param value="${apellidos}" />
                    <sql:param value="${correo}" />
                    <sql:param value="${clave}" />
                    <sql:param value="${telefono}" />
                    <sql:param value="${semestre}" />
                    <sql:param value="${activo}" />
                    <sql:param value="${idUsuario}" />
                </sql:update>
            </c:when>
            <c:otherwise>
                <%-- Conservar la contraseña anterior --%>
                <sql:update dataSource="${conn}">
                    UPDATE usuarios 
                    SET id_rol = ?, id_programa = ?, codigo = ?, documento = ?, 
                        nombres = ?, apellidos = ?, correo = ?, 
                        telefono = ?, semestre = ?, activo = ?
                    WHERE id_usuario = ?
                    <sql:param value="${idRol}" />
                    <sql:param value="${idPrograma}" />
                    <sql:param value="${codigo}" />
                    <sql:param value="${documento}" />
                    <sql:param value="${nombres}" />
                    <sql:param value="${apellidos}" />
                    <sql:param value="${correo}" />
                    <sql:param value="${telefono}" />
                    <sql:param value="${semestre}" />
                    <sql:param value="${activo}" />
                    <sql:param value="${idUsuario}" />
                </sql:update>
            </c:otherwise>
        </c:choose>
        <c:set var="mensaje_exito" value="Usuario '${nombres} ${apellidos}' actualizado exitosamente." scope="session" />
    </c:when>

    <c:otherwise>
        <%-- Creación de nuevo usuario con contraseña encriptada SHA2(?, 256) --%>
        <sql:update dataSource="${conn}">
            INSERT INTO usuarios 
            (id_rol, id_programa, codigo, documento, nombres, apellidos, correo, clave, telefono, semestre, activo)
            VALUES (?, ?, ?, ?, ?, ?, ?, SHA2(?, 256), ?, ?, ?)
            <sql:param value="${idRol}" />
            <sql:param value="${idPrograma}" />
            <sql:param value="${codigo}" />
            <sql:param value="${documento}" />
            <sql:param value="${nombres}" />
            <sql:param value="${apellidos}" />
            <sql:param value="${correo}" />
            <sql:param value="${clave}" />
            <sql:param value="${telefono}" />
            <sql:param value="${semestre}" />
            <sql:param value="${activo}" />
        </sql:update>
        <c:set var="mensaje_exito" value="Nuevo usuario '${nombres} ${apellidos}' registrado con éxito." scope="session" />
    </c:otherwise>
</c:choose>

<c:redirect url="/admin/usuarios_listar.jsp" />
