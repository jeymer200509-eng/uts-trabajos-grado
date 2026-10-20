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

<%-- 1. Validar que el estudiante no tenga ya una idea o proyecto registrado --%>
<sql:query var="qCheck" dataSource="${conn}">
    SELECT id_anteproyecto FROM anteproyectos WHERE id_estudiante = ?
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>

<c:if test="${qCheck.rowCount > 0}">
    <c:set var="mensaje_error" value="Ya seleccionaste una idea previamente. Ahora sube tu desprendible de pago para continuar." scope="session" />
    <c:redirect url="/estudiante/banco_ideas.jsp" />
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

<%-- 3. Crear el registro con la idea seleccionada y habilitar la subida del desprendible de pago (Fase 1) --%>
<sql:update dataSource="${conn}">
    INSERT INTO anteproyectos 
    (id_estudiante, id_idea, titulo, linea_investigacion, planteamiento_problema, 
     objetivo_general, objetivos_especificos, resumen, enlace_documento, version, estado, estado_pago)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PENDIENTE', '1.0', 'Idea seleccionada', 'Pendiente')
    <sql:param value="${sessionScope.id_usuario}" />
    <sql:param value="${idIdea}" />
    <sql:param value="${idea.titulo}" />
    <sql:param value="${idea.linea_investigacion}" />
    <sql:param value="${idea.descripcion}" />
    <sql:param value="Desarrollar el proyecto propuesto: ${idea.titulo}" />
    <sql:param value="1. Levantar requerimientos y estado del arte.&#10;2. Implementar prototipo tecnológico.&#10;3. Realizar pruebas y validación." />
    <sql:param value="${idea.descripcion}" />
</sql:update>

<%-- Obtener el ID del anteproyecto creado --%>
<sql:query var="qNuevoProy" dataSource="${conn}">
    SELECT id_anteproyecto FROM anteproyectos WHERE id_estudiante = ?
    <sql:param value="${sessionScope.id_usuario}" />
</sql:query>
<c:set var="idNuevoProy" value="${qNuevoProy.rows[0].id_anteproyecto}" />

<%-- 4. Registrar en historial de estados --%>
<sql:update dataSource="${conn}">
    INSERT INTO historial_estados (id_anteproyecto, id_usuario, estado_anterior, estado_nuevo, observacion)
    VALUES (?, ?, NULL, 'Idea seleccionada', 'El estudiante seleccionó la idea del banco institucional. Se habilitó la Fase 1 para subir el desprendible de pago.')
    <sql:param value="${idNuevoProy}" />
    <sql:param value="${sessionScope.id_usuario}" />
</sql:update>

<%-- 5. Actualizar estado de la idea a 'Asignada' --%>
<sql:update dataSource="${conn}">
    UPDATE ideas SET estado = 'Asignada' WHERE id_idea = ?
    <sql:param value="${idIdea}" />
</sql:update>

<c:set var="mensaje_exito" value="¡Idea seleccionada con éxito! Se ha habilitado la opción para subir tu desprendible de pago (PDF en Drive/Nube)." scope="session" />
<c:redirect url="/estudiante/banco_ideas.jsp" />
