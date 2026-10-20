<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Limpieza de atributos de sesión con c:remove según las buenas prácticas de JSTL --%>
<c:remove var="id_usuario" scope="session" />
<c:remove var="usuario" scope="session" />
<c:remove var="codigo" scope="session" />
<c:remove var="documento" scope="session" />
<c:remove var="nombres" scope="session" />
<c:remove var="apellidos" scope="session" />
<c:remove var="nombre_completo" scope="session" />
<c:remove var="rol" scope="session" />
<c:remove var="id_rol" scope="session" />
<c:remove var="id_programa" scope="session" />
<c:remove var="nombre_programa" scope="session" />

<c:set var="mensaje_info" value="Ha cerrado su sesión de manera segura. ¡Hasta pronto!" scope="session" />
<c:redirect url="/login.jsp" />
