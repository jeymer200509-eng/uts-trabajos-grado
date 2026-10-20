<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="rolRequerido" value="ADMIN" />
<%@ include file="/includes/conexion.jspf" %>
<%@ include file="/includes/seguridad.jspf" %>

<%-- Determinar si es Edición o Creación --%>
<c:set var="esEdicion" value="${not empty param.id}" />

<c:if test="${esEdicion}">
    <sql:query var="qUsuario" dataSource="${conn}">
        SELECT * FROM usuarios WHERE id_usuario = ?
        <sql:param value="${param.id}" />
    </sql:query>
    <c:if test="${qUsuario.rowCount == 0}">
        <c:set var="mensaje_error" value="El usuario solicitado no existe." scope="session" />
        <c:redirect url="/admin/usuarios_listar.jsp" />
    </c:if>
    <c:set var="u" value="${qUsuario.rows[0]}" />
</c:if>

<%-- Cargar catálogo de roles y programas --%>
<sql:query var="rolesCat" dataSource="${conn}">
    SELECT id_rol, nombre_rol, descripcion FROM roles ORDER BY id_rol ASC
</sql:query>

<sql:query var="programasCat" dataSource="${conn}">
    SELECT id_programa, codigo_programa, nombre_programa, nivel FROM programas ORDER BY nombre_programa ASC
</sql:query>

<c:set var="pageTitle" value="${esEdicion ? 'Editar Usuario' : 'Registrar Nuevo Usuario'} - Admin UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<div class="container py-4">
    <div class="row justify-content-center">
        <div class="col-lg-9 col-xl-8">
            <div class="card card-uts shadow-sm">
                <div class="card-header ${esEdicion ? 'card-header-blue' : 'card-header-uts'} py-3 d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 fw-bold">
                        <i class="bi ${esEdicion ? 'bi-pencil-square' : 'bi-person-plus-fill'} me-2"></i>
                        <c:out value="${esEdicion ? 'Modificar Usuario Institucional' : 'Registro de Nuevo Usuario'}" />
                    </h5>
                    <a href="${pageContext.request.contextPath}/admin/usuarios_listar.jsp" class="btn btn-sm btn-light">
                        <i class="bi bi-arrow-left"></i> Volver al Directorio
                    </a>
                </div>

                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/admin/usuarios_guardar.jsp" method="POST" id="formUsuario">
                        <input type="hidden" name="es_edicion" value="${esEdicion ? '1' : '0'}">
                        <c:if test="${esEdicion}">
                            <input type="hidden" name="id_usuario" value="${u.id_usuario}">
                        </c:if>

                        <!-- Selección de Rol -->
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label for="id_rol" class="form-label fw-semibold">
                                    <span class="text-danger">*</span> Tipo de Usuario (Rol):
                                </label>
                                <select class="form-select form-select-lg" id="id_rol" name="id_rol" required onchange="adaptarFormularioPorRol()">
                                    <option value="">-- Seleccione Rol --</option>
                                    <c:forEach var="r" items="${rolesCat.rows}">
                                        <option value="${r.id_rol}" data-nombre="${r.nombre_rol}" 
                                                ${(esEdicion and u.id_rol == r.id_rol) ? 'selected' : ''}>
                                            <c:out value="${r.nombre_rol}" /> - <c:out value="${r.descripcion}" />
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="col-md-6" id="contenedorPrograma">
                                <label for="id_programa" class="form-label fw-semibold">
                                    Programa Académico:
                                </label>
                                <select class="form-select form-select-lg" id="id_programa" name="id_programa">
                                    <option value="">-- Seleccione Programa (si aplica) --</option>
                                    <c:forEach var="p" items="${programasCat.rows}">
                                        <option value="${p.id_programa}" ${(esEdicion and u.id_programa == p.id_programa) ? 'selected' : ''}>
                                            <c:out value="${p.nombre_programa}" /> (<c:out value="${p.nivel}" />)
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>

                        <hr class="my-3 text-muted">

                        <!-- Datos de Identificación -->
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label for="codigo" class="form-label fw-semibold" id="labelCodigo">
                                    <span class="text-danger">*</span> Código:
                                </label>
                                <input type="text" class="form-control" id="codigo" name="codigo" 
                                       value="<c:out value='${esEdicion ? u.codigo : \"\"}' />" required placeholder="ej. 1098765432 o DIR001">
                            </div>

                            <div class="col-md-6">
                                <label for="documento" class="form-label fw-semibold">
                                    <span class="text-danger">*</span> Documento de Identidad (CC/TI):
                                </label>
                                <input type="text" class="form-control" id="documento" name="documento" 
                                       value="<c:out value='${esEdicion ? u.documento : \"\"}' />" required placeholder="Número de cédula">
                            </div>
                        </div>

                        <!-- Nombres y Apellidos -->
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label for="nombres" class="form-label fw-semibold">
                                    <span class="text-danger">*</span> Nombres:
                                </label>
                                <input type="text" class="form-control" id="nombres" name="nombres" 
                                       value="<c:out value='${esEdicion ? u.nombres : \"\"}' />" required placeholder="Nombres del usuario">
                            </div>

                            <div class="col-md-6">
                                <label for="apellidos" class="form-label fw-semibold">
                                    <span class="text-danger">*</span> Apellidos:
                                </label>
                                <input type="text" class="form-control" id="apellidos" name="apellidos" 
                                       value="<c:out value='${esEdicion ? u.apellidos : \"\"}' />" required placeholder="Apellidos completos">
                            </div>
                        </div>

                        <!-- Correo y Teléfono -->
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label for="correo" class="form-label fw-semibold">
                                    <span class="text-danger">*</span> Correo Institucional:
                                </label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                                    <input type="email" class="form-control" id="correo" name="correo" 
                                           value="<c:out value='${esEdicion ? u.correo : \"\"}' />" required placeholder="usuario@uts.edu.co">
                                </div>
                            </div>

                            <div class="col-md-6">
                                <label for="telefono" class="form-label fw-semibold">
                                    Teléfono / Celular de Contacto:
                                </label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-phone"></i></span>
                                    <input type="tel" class="form-control" id="telefono" name="telefono" 
                                           value="<c:out value='${esEdicion ? u.telefono : \"\"}' />" placeholder="ej. 3151234567">
                                </div>
                            </div>
                        </div>

                        <!-- Campos condicionales de Estudiante: Semestre -->
                        <div class="row g-3 mb-3" id="campoSemestre">
                            <div class="col-md-6">
                                <label for="semestre" class="form-label fw-semibold">
                                    Semestre Académico (1 al 10):
                                </label>
                                <input type="number" class="form-control" id="semestre" name="semestre" min="1" max="10" 
                                       value="<c:out value='${esEdicion ? u.semestre : \"\"}' />" placeholder="ej. 6">
                            </div>
                            <div class="col-md-6 d-flex align-items-center pt-md-4">
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" id="activo" name="activo" value="1" 
                                           ${(not esEdicion or u.activo) ? 'checked' : ''}>
                                    <label class="form-check-label fw-semibold" for="activo">Usuario Habilitado / Activo</label>
                                </div>
                            </div>
                        </div>

                        <!-- Clave -->
                        <div class="row g-3 mb-4">
                            <div class="col-md-6">
                                <label for="clave" class="form-label fw-semibold">
                                    <c:choose>
                                        <c:when test="${esEdicion}">
                                            Nueva Contraseña (dejar en blanco para no modificar):
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-danger">*</span> Contraseña de Acceso Inicial:
                                        </c:otherwise>
                                    </c:choose>
                                </label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-lock"></i></span>
                                    <input type="password" class="form-control" id="clave" name="clave" 
                                           ${esEdicion ? '' : 'required'} minlength="6" placeholder="Mínimo 6 caracteres">
                                </div>
                                <div class="form-text">Se encriptará con SHA-256 en la base de datos.</div>
                            </div>
                        </div>

                        <!-- Botones de Acción -->
                        <div class="d-flex justify-content-end gap-2 pt-3 border-top">
                            <a href="${pageContext.request.contextPath}/admin/usuarios_listar.jsp" class="btn btn-secondary">
                                Cancelar
                            </a>
                            <button type="submit" class="btn btn-uts-primary px-4 shadow-sm">
                                <i class="bi bi-save me-1"></i> <c:out value="${esEdicion ? 'Guardar Cambios' : 'Registrar Usuario'}" />
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function adaptarFormularioPorRol() {
    const selRol = document.getElementById('id_rol');
    const selectedOption = selRol.options[selRol.selectedIndex];
    const nombreRol = selectedOption ? selectedOption.getAttribute('data-nombre') : '';
    const labelCodigo = document.getElementById('labelCodigo');
    const campoSemestre = document.getElementById('campoSemestre');
    const inputSemestre = document.getElementById('semestre');

    if (nombreRol === 'ESTUDIANTE') {
        labelCodigo.innerHTML = '<span class="text-danger">*</span> Código Estudiantil:';
        campoSemestre.style.display = 'flex';
        inputSemestre.required = true;
    } else if (nombreRol === 'DIRECTOR' || nombreRol === 'EVALUADOR') {
        labelCodigo.innerHTML = '<span class="text-danger">*</span> Código Docente:';
        campoSemestre.style.display = 'none';
        inputSemestre.required = false;
        inputSemestre.value = '';
    } else {
        labelCodigo.innerHTML = '<span class="text-danger">*</span> Código Funcionario:';
        campoSemestre.style.display = 'none';
        inputSemestre.required = false;
        inputSemestre.value = '';
    }
}
document.addEventListener('DOMContentLoaded', adaptarFormularioPorRol);
</script>

<%@ include file="/includes/footer.jspf" %>
