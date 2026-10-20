<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>

<c:set var="rolRequerido" value="ESTUDIANTE" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="idAnteproyecto" value="${param.id}" />

<c:if test="${empty idAnteproyecto}">
    <c:set var="mensaje_error" value="Anteproyecto no especificado." scope="session" />
    <c:redirect url="/estudiante/anteproyecto_ver.jsp" />
</c:if>

<%-- Verificar que pertenezca al estudiante y esté en estado inicial --%>
<sql:query var="qCheck" dataSource="${conn}">
    SELECT id_anteproyecto, id_idea, estado FROM anteproyectos 
    WHERE id_anteproyecto = ? AND id_estudiante = ?
    <sql:param value="${idAnteproyecto}" />
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<c:choose>
    <c:when test="${qCheck.rowCount == 0}">
        <c:set var="mensaje_error" value="No se encontró el registro o no tiene permisos sobre este proyecto." scope="session" />
    </c:when>
    <c:otherwise>
        <c:set var="proy" value="${qCheck.rows[0]}" />
        <c:choose>
            <c:when test="${proy.estado != 'Idea seleccionada' and proy.estado != 'Anteproyecto radicado'}">
                <c:set var="mensaje_error" value="Solo es posible anular el anteproyecto mientras se encuentre en etapa inicial ('Idea seleccionada' o 'Anteproyecto radicado')." scope="session" />
            </c:when>
            <c:otherwise>
                <%-- Liberar la idea si provino del banco --%>
                <c:if test="${not empty proy.id_idea}">
                    <sql:update dataSource="${conn}">
                        UPDATE ideas SET estado = 'Disponible' WHERE id_idea = ?
                        <sql:param value="${proy.id_idea}" />
                    </sql:update>
                </c:if>

                <%-- Eliminar anteproyecto --%>
                <sql:update dataSource="${conn}">
                    DELETE FROM anteproyectos WHERE id_anteproyecto = ? AND id_estudiante = ?
                    <sql:param value="${idAnteproyecto}" />
                    <sql:param value="${sessionScope.id_usuario}" />
                </sql:update>

                <c:set var="mensaje_exito" value="Registro de anteproyecto anulado exitosamente." scope="session" />
            </c:otherwise>
        </c:choose>
    </c:otherwise>
</c:choose>

<c:redirect url="/estudiante/index.jsp" />
