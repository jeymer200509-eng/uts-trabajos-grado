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
        <c:set var="idEvento" value="${param.id}" />
        <c:if test="${not empty idEvento}">
            <sql:update dataSource="${conn}">
                DELETE FROM calendario WHERE id_evento = ?
                <sql:param value="${idEvento}" />
            </sql:update>
            <c:set var="mensaje_exito" value="Evento eliminado del calendario académico." scope="session" />
        </c:if>
    </c:when>

    <c:when test="${accion == 'crear'}">
        <c:set var="titulo" value="${fn:trim(param.titulo)}" />
        <c:set var="desc" value="${fn:trim(param.descripcion)}" />
        <c:set var="etapa" value="${fn:trim(param.tipo_etapa)}" />
        <c:set var="fInicio" value="${fn:trim(param.fecha_inicio)}" />
        <c:set var="fFin" value="${fn:trim(param.fecha_fin)}" />
        <c:set var="estado" value="${fn:trim(param.estado)}" />

        <c:if test="${empty titulo or empty etapa or empty fInicio or empty fFin or empty estado}">
            <c:set var="mensaje_error" value="Todos los campos obligatorios del evento deben ser diligenciados." scope="session" />
        </c:if>

        <c:if test="${not empty titulo and not empty etapa and not empty fInicio and not empty fFin and not empty estado}">
            <sql:update dataSource="${conn}">
                INSERT INTO calendario (titulo, descripcion, tipo_etapa, fecha_inicio, fecha_fin, estado)
                VALUES (?, ?, ?, ?, ?, ?)
                <sql:param value="${titulo}" />
                <sql:param value="${desc}" />
                <sql:param value="${etapa}" />
                <sql:param value="${fInicio}" />
                <sql:param value="${fFin}" />
                <sql:param value="${estado}" />
            </sql:update>
            <c:set var="mensaje_exito" value="Nuevo evento de calendario registrado con éxito." scope="session" />
        </c:if>
    </c:when>
</c:choose>

<c:redirect url="/coordinacion/calendario_gestionar.jsp" />
