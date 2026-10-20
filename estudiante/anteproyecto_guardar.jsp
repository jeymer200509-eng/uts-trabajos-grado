<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="ESTUDIANTE" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="idAnteproyecto" value="${param.id_anteproyecto}" />
<c:set var="estadoAnterior" value="${param.estado_anterior}" />
<c:set var="idDirector" value="${empty param.id_director ? null : fn:trim(param.id_director)}" />

<c:set var="titulo" value="${fn:trim(param.titulo)}" />
<c:set var="linea" value="${fn:trim(param.linea_investigacion)}" />
<c:set var="version" value="${fn:trim(param.version)}" />
<c:set var="problema" value="${fn:trim(param.planteamiento_problema)}" />
<c:set var="justificacion" value="${fn:trim(param.justificacion)}" />
<c:set var="objGeneral" value="${fn:trim(param.objetivo_general)}" />
<c:set var="objEspecificos" value="${fn:trim(param.objetivos_especificos)}" />
<c:set var="resumen" value="${fn:trim(param.resumen)}" />
<c:set var="enlace" value="${fn:trim(param.enlace_documento)}" />

<%-- Validar que haya completado Fase 1 (Desprendible de Pago) --%>
<sql:query var="qProyEst" dataSource="${conn}">
    SELECT id_anteproyecto, estado, enlace_desprendible, id_director FROM anteproyectos WHERE id_estudiante = ?
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<c:if test="${qProyEst.rowCount == 0 or empty qProyEst.rows[0].enlace_desprendible}">
    <c:set var="mensaje_error" value="Fase bloqueada: Primero debes subir el desprendible de pago (Fase 1)." scope="session" />
    <c:redirect url="/estudiante/index.jsp" />
</c:if>

<c:set var="idAnteproyecto" value="${qProyEst.rows[0].id_anteproyecto}" />
<c:set var="estadoAnterior" value="${qProyEst.rows[0].estado}" />
<c:if test="${empty idDirector and not empty qProyEst.rows[0].id_director}">
    <c:set var="idDirector" value="${qProyEst.rows[0].id_director}" />
</c:if>

<%-- Validaciones en Servidor con JSTL --%>
<c:if test="${empty titulo or empty linea or empty version or empty problema or empty objGeneral or empty objEspecificos or empty resumen or empty enlace or empty idDirector}">
    <c:set var="mensaje_error" value="Todos los campos obligatorios (*), incluyendo el Director y el enlace al documento de la propuesta, deben ser diligenciados." scope="session" />
    <c:redirect url="/estudiante/anteproyecto_formulario.jsp" />
</c:if>

<c:if test="${!fn:startsWith(enlace, 'http://') and !fn:startsWith(enlace, 'https://')}">
    <c:set var="mensaje_error" value="El enlace al documento de la propuesta debe ser una URL válida que inicie con http:// o https://" scope="session" />
    <c:redirect url="/estudiante/anteproyecto_formulario.jsp" />
</c:if>

<%-- Al enviar la propuesta al Director, pasa a 'En revisión por director' (desbloquea Fase 3) --%>
<c:set var="nuevoEstado" value="En revisión por director" />

<sql:update dataSource="${conn}">
    UPDATE anteproyectos 
    SET id_director = ?, titulo = ?, linea_investigacion = ?, planteamiento_problema = ?, justificacion = ?,
        objetivo_general = ?, objetivos_especificos = ?, resumen = ?, enlace_documento = ?, 
        version = ?, estado = ?
    WHERE id_anteproyecto = ? AND id_estudiante = ?
    <sql:param value="${idDirector}" />
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

<sql:update dataSource="${conn}">
    INSERT INTO historial_estados (id_anteproyecto, id_usuario, estado_anterior, estado_nuevo, observacion)
    VALUES (?, ?, ?, ?, 'Fase 2 completada: El estudiante envió la propuesta y su documento en nube al Director para revisión.')
    <sql:param value="${idAnteproyecto}" />
    <sql:param value="${sessionScope.id_usuario}" />
    <sql:param value="${estadoAnterior}" />
    <sql:param value="${nuevoEstado}" />
</sql:update>

<c:set var="mensaje_exito" value="¡Fase 2 completada! Tu propuesta ha sido enviada al Director. Se ha desbloqueado la Fase 3 (Revisión del Director y envío al Comité Evaluador)." scope="session" />
<c:redirect url="/estudiante/index.jsp" />
