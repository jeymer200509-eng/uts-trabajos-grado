<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>

<c:set var="rolRequerido" value="ESTUDIANTE" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="idIdea" value="${param.id_idea}" />

<c:if test="${empty idIdea}">
    <c:set var="mensaje_error" value="Idea no especificada." scope="session" />
    <c:redirect url="/estudiante/banco_ideas.jsp" />
</c:if>

<%-- 1. Validar que el estudiante haya completado Fase 1 (Desprendible de pago aceptado por Coordinación) --%>
<sql:query var="qCheck" dataSource="${conn}">
    SELECT id_anteproyecto, estado, enlace_desprendible, estado_pago, enlace_documento FROM anteproyectos WHERE id_estudiante = ?
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<c:if test="${qCheck.rowCount == 0 or empty qCheck.rows[0].enlace_desprendible or qCheck.rows[0].estado_pago != 'Aprobado'}">
    <c:set var="mensaje_error" value="Fase bloqueada: Primero debes subir el desprendible de pago (Fase 1) y esperar a que Coordinación lo acepte." scope="session" />
    <c:redirect url="/estudiante/index.jsp" />
</c:if>

<c:if test="${qCheck.rows[0].estado != 'Idea seleccionada' and qCheck.rows[0].enlace_documento != 'PENDIENTE'}">
    <c:set var="mensaje_error" value="Ya posee una propuesta enviada en el sistema. No puede registrar más de una simultáneamente." scope="session" />
    <c:redirect url="/estudiante/anteproyecto_ver.jsp" />
</c:if>

<%-- 2. Consultar datos de la idea seleccionada --%>
<sql:query var="qIdea" dataSource="${conn}">
    SELECT * FROM ideas WHERE id_idea = ? AND estado = 'Disponible'
    <sql:param value="${idIdea}" />
</sql:query>

<c:if test="${qIdea.rowCount == 0}">
    <c:set var="mensaje_error" value="La idea seleccionada ya no se encuentra disponible." scope="session" />
    <c:redirect url="/estudiante/banco_ideas.jsp" />
</c:if>

<c:set var="idea" value="${qIdea.rows[0]}" />
<c:set var="idProyActual" value="${qCheck.rows[0].id_anteproyecto}" />

<%-- 3. Actualizar el registro con la idea seleccionada conservando el desprendible de pago --%>
<sql:update dataSource="${conn}">
    UPDATE anteproyectos 
    SET id_idea = ?, 
        titulo = ?, 
        linea_investigacion = ?, 
        planteamiento_problema = ?, 
        objetivo_general = ?, 
        objetivos_especificos = ?, 
        resumen = ?, 
        estado = 'Idea seleccionada'
    WHERE id_anteproyecto = ? AND id_estudiante = ?
    <sql:param value="${idIdea}" />
    <sql:param value="${idea.titulo}" />
    <sql:param value="${idea.linea_investigacion}" />
    <sql:param value="${idea.descripcion}" />
    <sql:param value="Desarrollar el proyecto propuesto: ${idea.titulo}" />
    <sql:param value="1. Levantar requerimientos y estado del arte.&#10;2. Implementar prototipo tecnológico.&#10;3. Realizar pruebas y validación." />
    <sql:param value="${idea.descripcion}" />
    <sql:param value="${idProyActual}" />
    <sql:param value="${sessionScope.id_usuario}" />
</sql:update>

<%-- 4. Registrar en historial de estados --%>
<sql:update dataSource="${conn}">
    INSERT INTO historial_estados (id_anteproyecto, id_usuario, estado_anterior, estado_nuevo, observacion)
    VALUES (?, ?, 'Idea seleccionada', 'Idea seleccionada', 'El estudiante seleccionó la idea del banco institucional para enviar su propuesta al Director')
    <sql:param value="${idProyActual}" />
    <sql:param value="${sessionScope.id_usuario}" />
</sql:update>

<%-- 5. Actualizar estado de la idea a 'Asignada' --%>
<sql:update dataSource="${conn}">
    UPDATE ideas SET estado = 'Asignada' WHERE id_idea = ?
    <sql:param value="${idIdea}" />
</sql:update>

<c:set var="mensaje_exito" value="¡Idea seleccionada! Ahora adjunta el enlace de tu documento de propuesta (PDF en Drive/Nube) y envíala al Director." scope="session" />
<c:redirect url="/estudiante/anteproyecto_formulario.jsp" />
