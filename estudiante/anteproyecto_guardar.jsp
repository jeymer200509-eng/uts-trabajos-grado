<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="ESTUDIANTE" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="esEdicion" value="${param.es_edicion == '1'}" />
<c:set var="idAnteproyecto" value="${param.id_anteproyecto}" />
<c:set var="estadoAnterior" value="${param.estado_anterior}" />

<c:set var="titulo" value="${fn:trim(param.titulo)}" />
<c:set var="linea" value="${fn:trim(param.linea_investigacion)}" />
<c:set var="version" value="${fn:trim(param.version)}" />
<c:set var="problema" value="${fn:trim(param.planteamiento_problema)}" />
<c:set var="justificacion" value="${fn:trim(param.justificacion)}" />
<c:set var="objGeneral" value="${fn:trim(param.objetivo_general)}" />
<c:set var="objEspecificos" value="${fn:trim(param.objetivos_especificos)}" />
<c:set var="resumen" value="${fn:trim(param.resumen)}" />
<c:set var="enlace" value="${fn:trim(param.enlace_documento)}" />

<%-- Validaciones en Servidor con JSTL --%>
<c:if test="${empty titulo or empty linea or empty version or empty problema or empty objGeneral or empty objEspecificos or empty resumen or empty enlace}">
    <c:set var="mensaje_error" value="Todos los campos obligatorios (*) deben ser diligenciados." scope="session" />
    <c:redirect url="/estudiante/anteproyecto_formulario.jsp" />
</c:if>

<c:if test="${!fn:startsWith(enlace, 'http://') and !fn:startsWith(enlace, 'https://')}">
    <c:set var="mensaje_error" value="El enlace al documento debe ser una URL válida que inicie con http:// o https://" scope="session" />
    <c:redirect url="/estudiante/anteproyecto_formulario.jsp" />
</c:if>

<c:choose>
    <c:when test="${esEdicion}">
        <%-- Determinar nuevo estado tras la edición --%>
        <c:set var="nuevoEstado" value="${estadoAnterior}" />
        <c:choose>
            <c:when test="${estadoAnterior == 'Idea seleccionada'}">
                <c:set var="nuevoEstado" value="Anteproyecto radicado" />
            </c:when>
            <c:when test="${estadoAnterior == 'Devuelto con observaciones'}">
                <c:set var="nuevoEstado" value="En revisión por director" />
            </c:when>
        </c:choose>

        <sql:update dataSource="${conn}">
            UPDATE anteproyectos 
            SET titulo = ?, linea_investigacion = ?, planteamiento_problema = ?, justificacion = ?,
                objetivo_general = ?, objetivos_especificos = ?, resumen = ?, enlace_documento = ?, 
                version = ?, estado = ?
            WHERE id_anteproyecto = ? AND id_estudiante = ?
            <sql:param value="${titulo}" />
            <sql:param value="${linea}" />
            <sql:param value="${problema}" />
            <sql:param value="${justificacion}" />
            <sql:param value="${objGeneral}" />
            <sql:param value="${objEspecificos}" />
            <sql:param value="${resumen}" />
            <sql:param value="${enlace}" />
            <sql:param value="${version}" />
            <sql:param value="${nuevoEstado}" />
            <sql:param value="${idAnteproyecto}" />
            <sql:param value="${sessionScope.id_usuario}" />
        </sql:update>

        <%-- Registrar en historial de estados si hubo transición --%>
        <c:if test="${nuevoEstado != estadoAnterior}">
            <sql:update dataSource="${conn}">
                INSERT INTO historial_estados (id_anteproyecto, id_usuario, estado_anterior, estado_nuevo, observacion)
                VALUES (?, ?, ?, ?, 'Actualización de propuesta y radicación de ajustes por estudiante')
                <sql:param value="${idAnteproyecto}" />
                <sql:param value="${sessionScope.id_usuario}" />
                <sql:param value="${estadoAnterior}" />
                <sql:param value="${nuevoEstado}" />
            </sql:update>
        </c:if>

        <c:set var="mensaje_exito" value="Propuesta de anteproyecto actualizada y radicada con éxito." scope="session" />
    </c:when>

    <c:otherwise>
        <%-- Verificar unicidad de proyecto por estudiante --%>
        <sql:query var="qCheckUnico" dataSource="${conn}">
            SELECT id_anteproyecto FROM anteproyectos WHERE id_estudiante = ?
            <sql:param value="${sessionScope.id_usuario}" />
        </sql:query>

        <c:if test="${qCheckUnico.rowCount > 0}">
            <c:set var="mensaje_error" value="Ya posee un proyecto activo en el sistema. No puede registrar más de uno a la vez." scope="session" />
            <c:redirect url="/estudiante/anteproyecto_ver.jsp" />
        </c:if>

        <sql:update dataSource="${conn}">
            INSERT INTO anteproyectos 
            (id_estudiante, titulo, linea_investigacion, planteamiento_problema, justificacion,
             objetivo_general, objetivos_especificos, resumen, enlace_documento, version, estado)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Anteproyecto radicado')
            <sql:param value="${sessionScope.id_usuario}" />
            <sql:param value="${titulo}" />
            <sql:param value="${linea}" />
            <sql:param value="${problema}" />
            <sql:param value="${justificacion}" />
            <sql:param value="${objGeneral}" />
            <sql:param value="${objEspecificos}" />
            <sql:param value="${resumen}" />
            <sql:param value="${enlace}" />
            <sql:param value="${version}" />
        </sql:update>

        <sql:query var="qNuevo" dataSource="${conn}">
            SELECT id_anteproyecto FROM anteproyectos WHERE id_estudiante = ?
            <sql:param value="${sessionScope.id_usuario}" />
        </sql:query>

        <sql:update dataSource="${conn}">
            INSERT INTO historial_estados (id_anteproyecto, id_usuario, estado_anterior, estado_nuevo, observacion)
            VALUES (?, ?, NULL, 'Anteproyecto radicado', 'Radicación formal libre de anteproyecto de grado')
            <sql:param value="${qNuevo.rows[0].id_anteproyecto}" />
            <sql:param value="${sessionScope.id_usuario}" />
        </sql:update>

        <c:set var="mensaje_exito" value="¡Tu anteproyecto ha sido radicado exitosamente! Coordinación procederá con la asignación tutorial." scope="session" />
    </c:otherwise>
</c:choose>

<c:redirect url="/estudiante/anteproyecto_ver.jsp" />
