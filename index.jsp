<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Redirección inteligente según estado de sesión y rol --%>
<c:choose>
    <c:when test="${empty sessionScope.usuario}">
        <c:redirect url="/login.jsp" />
    </c:when>
    <c:when test="${sessionScope.rol == 'ADMIN'}">
        <c:redirect url="/admin/index.jsp" />
    </c:when>
    <c:when test="${sessionScope.rol == 'COORDINACION'}">
        <c:redirect url="/coordinacion/index.jsp" />
    </c:when>
    <c:when test="${sessionScope.rol == 'ESTUDIANTE'}">
        <c:redirect url="/estudiante/index.jsp" />
    </c:when>
    <c:when test="${sessionScope.rol == 'DIRECTOR'}">
        <c:redirect url="/director/index.jsp" />
    </c:when>
    <c:when test="${sessionScope.rol == 'EVALUADOR'}">
        <c:redirect url="/evaluador/index.jsp" />
    </c:when>
    <c:otherwise>
        <c:redirect url="/login.jsp" />
    </c:otherwise>
</c:choose>
