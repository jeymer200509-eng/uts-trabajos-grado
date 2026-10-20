<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="COORDINACION" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="accion" value="${param.accion}" />

<c:choose>
    <c:when test="${accion == 'eliminar'}">
        <c:set var="idFormato" value="${param.id}" />
        <c:if test="${not empty idFormato}">
            <sql:update dataSource="${conn}">
                DELETE FROM formatos WHERE id_formato = ?
                <sql:param value="${idFormato}" />
            </sql:update>
            <c:set var="mensaje_exito" value="Formato eliminado del repositorio." scope="session" />
        </c:if>
    </c:when>

    <c:when test="${accion == 'crear'}">
        <c:set var="codigo" value="${fn:trim(param.codigo)}" />
        <c:set var="version" value="${fn:trim(param.version)}" />
        <c:set var="nombre" value="${fn:trim(param.nombre)}" />
        <c:set var="categoria" value="${fn:trim(param.categoria)}" />
        <c:set var="enlace" value="${fn:trim(param.enlace_descarga)}" />
        <c:set var="desc" value="${fn:trim(param.descripcion)}" />

        <c:if test="${empty codigo or empty version or empty nombre or empty categoria or empty enlace}">
            <c:set var="mensaje_error" value="Todos los campos obligatorios del formato deben ser diligenciados." scope="session" />
        </c:if>

        <c:if test="${not empty codigo and not empty version and not empty nombre and not empty categoria and not empty enlace}">
            <sql:update dataSource="${conn}">
                INSERT INTO formatos (codigo, nombre, descripcion, version, enlace_descarga, categoria, fecha_publicacion)
                VALUES (?, ?, ?, ?, ?, ?, CURRENT_DATE)
                <sql:param value="${codigo}" />
                <sql:param value="${nombre}" />
                <sql:param value="${desc}" />
                <sql:param value="${version}" />
                <sql:param value="${enlace}" />
                <sql:param value="${categoria}" />
            </sql:update>
            <c:set var="mensaje_exito" value="Formato oficial '${nombre}' publicado con éxito." scope="session" />
        </c:if>
    </c:when>
</c:choose>

<c:redirect url="/coordinacion/formatos_gestionar.jsp" />
