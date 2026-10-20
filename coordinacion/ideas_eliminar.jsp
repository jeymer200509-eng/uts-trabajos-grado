<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>

<c:set var="rolRequerido" value="COORDINACION" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="idIdea" value="${param.id}" />

<c:choose>
    <c:when test="${empty idIdea}">
        <c:set var="mensaje_error" value="Identificador de idea no válido." scope="session" />
    </c:when>
    <c:otherwise>
        <%-- Verificar si la idea ya está vinculada a un anteproyecto --%>
        <sql:query var="chkVinculo" dataSource="${conn}">
            SELECT COUNT(*) AS cant FROM anteproyectos WHERE id_idea = ?
            <sql:param value="${idIdea}" />
        </sql:query>

        <c:choose>
            <c:when test="${chkVinculo.rows[0].cant > 0}">
                <c:set var="mensaje_error" value="No se puede eliminar la idea porque ya fue seleccionada por un estudiante de grado." scope="session" />
            </c:when>
            <c:otherwise>
                <sql:update dataSource="${conn}">
                    DELETE FROM ideas WHERE id_idea = ?
                    <sql:param value="${idIdea}" />
                </sql:update>
                <c:set var="mensaje_exito" value="La idea ha sido eliminada del catálogo institucional." scope="session" />
            </c:otherwise>
        </c:choose>
    </c:otherwise>
</c:choose>

<c:redirect url="/coordinacion/ideas_listar.jsp" />
