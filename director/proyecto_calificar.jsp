<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="DIRECTOR" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<c:set var="idAnteproyecto" value="${param.id_anteproyecto}" />
<c:set var="estadoActual" value="${param.estado_actual}" />
<c:set var="idEvaluador" value="${empty param.id_evaluador ? null : fn:trim(param.id_evaluador)}" />
<c:set var="enlaceDocDirector" value="${empty param.enlace_documento_director ? null : fn:trim(param.enlace_documento_director)}" />
<c:set var="tipoEval" value="${fn:trim(param.tipo_evaluacion)}" />
<c:set var="nota" value="${fn:trim(param.nota)}" />
<c:set var="decision" value="${fn:trim(param.estado_decision)}" />
<c:set var="observaciones" value="${fn:trim(param.observaciones)}" />

<%-- Validaciones --%>
<c:if test="${empty idAnteproyecto or empty tipoEval or empty nota or empty decision or empty observaciones}">
    <c:set var="mensaje_error" value="Todos los campos obligatorios del formulario de revisión deben ser diligenciados." scope="session" />
    <c:redirect url="/director/proyecto_revisar.jsp?id=${idAnteproyecto}" />
</c:if>

<%-- 1. Insertar registro en tabla calificaciones --%>
<sql:update dataSource="${conn}">
    INSERT INTO calificaciones (id_anteproyecto, id_docente, tipo_evaluacion, nota, observaciones, estado_decision)
    VALUES (?, ?, ?, ?, ?, ?)
    <sql:param value="${idAnteproyecto}" />
    <sql:param value="${sessionScope.id_usuario}" />
    <sql:param value="${tipoEval}" />
    <sql:param value="${nota}" />
    <sql:param value="${observaciones}" />
    <sql:param value="${decision}" />
</sql:update>

<%-- 2. Calcular nuevo estado según etapa (Fase 3 o Fase 5) y decisión --%>
<c:choose>
    <c:when test="${tipoEval == 'Documento Final - Director'}">
        <c:choose>
            <c:when test="${decision == 'Aprobado'}">
                <c:set var="nuevoEstado" value="En revisión por evaluador" />
                <c:set var="obsHistorial" value="Fase 5 completada: El Director revisó y aprobó el Informe del Proyecto (Nota: ${nota}) y lo envió al Comité Evaluador para la Fase Final." />
            </c:when>
            <c:otherwise>
                <c:set var="nuevoEstado" value="Devuelto con observaciones" />
                <c:set var="obsHistorial" value="Fase 5: El Director devolvió el Informe del Proyecto con observaciones al estudiante (Nota: ${nota})." />
            </c:otherwise>
        </c:choose>

        <sql:update dataSource="${conn}">
            UPDATE anteproyectos 
            SET estado = ?,
                id_evaluador = COALESCE(?, id_evaluador),
                enlace_informe_director = COALESCE(?, enlace_informe_director)
            WHERE id_anteproyecto = ? AND id_director = ?
            <sql:param value="${nuevoEstado}" />
            <sql:param value="${idEvaluador}" />
            <sql:param value="${enlaceDocDirector}" />
            <sql:param value="${idAnteproyecto}" />
            <sql:param value="${sessionScope.id_usuario}" />
        </sql:update>
    </c:when>

    <c:otherwise>
        <c:choose>
            <c:when test="${decision == 'Aprobado'}">
                <c:set var="nuevoEstado" value="${not empty idEvaluador ? 'En revisión por evaluador' : 'Aprobado por director'}" />
                <c:set var="obsHistorial" value="Fase 3: El Director revisó y aprobó la propuesta (Nota: ${nota}) y la envió al Comité Evaluador." />
            </c:when>
            <c:otherwise>
                <c:set var="nuevoEstado" value="Devuelto con observaciones" />
                <c:set var="obsHistorial" value="Fase 3: El Director devolvió la propuesta con observaciones al estudiante para corrección (Nota: ${nota})." />
            </c:otherwise>
        </c:choose>

        <sql:update dataSource="${conn}">
            UPDATE anteproyectos 
            SET estado = ?,
                id_evaluador = COALESCE(?, id_evaluador),
                enlace_aval_director = COALESCE(?, enlace_aval_director)
            WHERE id_anteproyecto = ? AND id_director = ?
            <sql:param value="${nuevoEstado}" />
            <sql:param value="${idEvaluador}" />
            <sql:param value="${enlaceDocDirector}" />
            <sql:param value="${idAnteproyecto}" />
            <sql:param value="${sessionScope.id_usuario}" />
        </sql:update>
    </c:otherwise>
</c:choose>

<%-- 3. Registrar en historial de estados --%>
<sql:update dataSource="${conn}">
    INSERT INTO historial_estados (id_anteproyecto, id_usuario, estado_anterior, estado_nuevo, observacion)
    VALUES (?, ?, ?, ?, ?)
    <sql:param value="${idAnteproyecto}" />
    <sql:param value="${sessionScope.id_usuario}" />
    <sql:param value="${estadoActual}" />
    <sql:param value="${nuevoEstado}" />
    <sql:param value="${obsHistorial}" />
</sql:update>

<c:set var="mensaje_exito" value="Revisión del Director registrada con éxito. El proyecto pasó a estado '${nuevoEstado}'." scope="session" />
<c:redirect url="/director/proyectos_listar.jsp" />
