<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="COORDINACION" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="esEdicion" value="${param.es_edicion == '1'}" />
<c:set var="idIdea" value="${param.id_idea}" />
<c:set var="idPrograma" value="${fn:trim(param.id_programa)}" />
<c:set var="titulo" value="${fn:trim(param.titulo)}" />
<c:set var="descripcion" value="${fn:trim(param.descripcion)}" />
<c:set var="linea" value="${fn:trim(param.linea_investigacion)}" />
<c:set var="cupos" value="${fn:trim(param.cupos)}" />
<c:set var="estado" value="${fn:trim(param.estado)}" />

<%-- Validaciones obligatorias --%>
<c:if test="${empty idPrograma or empty titulo or empty descripcion or empty linea or empty cupos or empty estado}">
    <c:set var="mensaje_error" value="Todos los campos obligatorios deben ser diligenciados." scope="session" />
    <c:redirect url="/coordinacion/ideas_formulario.jsp${esEdicion ? '?id='.concat(idIdea) : ''}" />
</c:if>

<c:choose>
    <c:when test="${esEdicion}">
        <sql:update dataSource="${conn}">
            UPDATE ideas 
            SET id_programa = ?, titulo = ?, descripcion = ?, linea_investigacion = ?, cupos = ?, estado = ?
            WHERE id_idea = ?
            <sql:param value="${idPrograma}" />
            <sql:param value="${titulo}" />
            <sql:param value="${descripcion}" />
            <sql:param value="${linea}" />
            <sql:param value="${cupos}" />
            <sql:param value="${estado}" />
            <sql:param value="${idIdea}" />
        </sql:update>
        <c:set var="mensaje_exito" value="La idea '${titulo}' ha sido actualizada exitosamente." scope="session" />
    </c:when>
    <c:otherwise>
        <sql:update dataSource="${conn}">
            INSERT INTO ideas (id_programa, id_coordinador, titulo, descripcion, linea_investigacion, cupos, estado)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            <sql:param value="${idPrograma}" />
            <sql:param value="${sessionScope.id_usuario}" />
            <sql:param value="${titulo}" />
            <sql:param value="${descripcion}" />
            <sql:param value="${linea}" />
            <sql:param value="${cupos}" />
            <sql:param value="${estado}" />
        </sql:update>
        <c:set var="mensaje_exito" value="Nueva idea de grado '${titulo}' publicada exitosamente." scope="session" />
    </c:otherwise>
</c:choose>

<c:redirect url="/coordinacion/ideas_listar.jsp" />
