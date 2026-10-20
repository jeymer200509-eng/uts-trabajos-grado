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
                    <div id="alertaValidacionCliente" class="alert alert-danger d-none align-items-center shadow-sm mb-4" role="alert">
                        <i class="bi bi-exclamation-triangle-fill fs-5 me-2"></i>
                        <div id="textoAlertaCliente"></div>
                    </div>

                    <form action="${pageContext.request.contextPath}/admin/usuarios_guardar.jsp" method="POST" id="formUsuario" onsubmit="return validarFormularioUsuario(event)">
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
                                    <span class="text-danger">*</span> Correo Institucional (@uts.edu.co):
                                </label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                                    <input type="email" class="form-control" id="correo" name="correo" 
                                           value="<c:out value='${esEdicion ? u.correo : \"\"}' />" required 
                                           placeholder="usuario@uts.edu.co" oninput="validarCorreoInstitucional()">
                                </div>
                                <div id="feedbackCorreo" class="form-text">
                                    Debe ser obligatoriamente correo institucional terminado en <strong>@uts.edu.co</strong>.
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

                        <!-- Campos condicionales de Estudiante: Semestre y % de Créditos -->
                        <div class="row g-3 mb-3" id="campoSemestre">
                            <div class="col-md-6">
                                <label for="semestre" class="form-label fw-semibold">
                                    <span class="text-danger">*</span> Semestre Académico (1 al 10):
                                </label>
                                <input type="number" class="form-control" id="semestre" name="semestre" min="1" max="10" 
                                       value="<c:out value='${esEdicion ? u.semestre : \"\"}' />" placeholder="ej. 6">
                            </div>
                            <div class="col-md-6">
                                <label for="porcentaje_creditos" class="form-label fw-semibold">
                                    <span class="text-danger">*</span> % de Créditos Completados:
                                </label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-mortarboard-fill"></i></span>
                                    <input type="number" class="form-control" id="porcentaje_creditos" name="porcentaje_creditos" 
                                           min="0" max="100" step="0.1"
                                           value="<c:out value='${esEdicion ? \"75\" : \"\"}' />" 
                                           placeholder="Ej. 75 (Mínimo 75%)" oninput="validarCreditosEstudiante()">
                                    <span class="input-group-text fw-bold">%</span>
                                </div>
                                <div id="feedbackCreditos" class="form-text">
                                    Requisito: mínimo <strong>75%</strong> de créditos completados para poder registrarse.
                                </div>
                            </div>
                        </div>

                        <!-- Clave y Estado Activo -->
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
                            <div class="col-md-6 d-flex align-items-center pt-md-4">
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" id="activo" name="activo" value="1" 
                                           ${(not esEdicion or u.activo) ? 'checked' : ''}>
                                    <label class="form-check-label fw-semibold" for="activo">Usuario Habilitado / Activo</label>
                                </div>
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
function obtenerRolSeleccionado() {
    const selRol = document.getElementById('id_rol');
    const selectedOption = selRol.options[selRol.selectedIndex];
    return selectedOption ? selectedOption.getAttribute('data-nombre') : '';
}

function adaptarFormularioPorRol() {
    const nombreRol = obtenerRolSeleccionado();
    const labelCodigo = document.getElementById('labelCodigo');
    const campoSemestre = document.getElementById('campoSemestre');
    const inputSemestre = document.getElementById('semestre');
    const inputCreditos = document.getElementById('porcentaje_creditos');

    if (nombreRol === 'ESTUDIANTE') {
        labelCodigo.innerHTML = '<span class="text-danger">*</span> Código Estudiantil:';
        campoSemestre.style.display = 'flex';
        inputSemestre.required = true;
        inputCreditos.required = true;
    } else if (nombreRol === 'DIRECTOR' || nombreRol === 'EVALUADOR') {
        labelCodigo.innerHTML = '<span class="text-danger">*</span> Código Docente:';
        campoSemestre.style.display = 'none';
        inputSemestre.required = false;
        inputSemestre.value = '';
        inputCreditos.required = false;
        inputCreditos.value = '';
        inputCreditos.classList.remove('is-invalid', 'is-valid');
    } else {
        labelCodigo.innerHTML = '<span class="text-danger">*</span> Código Funcionario:';
        campoSemestre.style.display = 'none';
        inputSemestre.required = false;
        inputSemestre.value = '';
        inputCreditos.required = false;
        inputCreditos.value = '';
        inputCreditos.classList.remove('is-invalid', 'is-valid');
    }
}

function validarCorreoInstitucional() {
    const inputCorreo = document.getElementById('correo');
    const feedback = document.getElementById('feedbackCorreo');
    const valor = inputCorreo.value.trim().toLowerCase();

    if (valor === '') {
        inputCorreo.classList.remove('is-invalid', 'is-valid');
        feedback.className = 'form-text';
        feedback.innerHTML = 'Debe ser obligatoriamente correo institucional terminado en <strong>@uts.edu.co</strong>.';
        return false;
    }

    const regexUts = /^[a-z0-9._%+-]+@uts\.edu\.co$/;
    if (!regexUts.test(valor)) {
        inputCorreo.classList.add('is-invalid');
        inputCorreo.classList.remove('is-valid');
        feedback.className = 'form-text text-danger fw-semibold';
        feedback.innerHTML = '<i class="bi bi-x-circle-fill me-1"></i>Correo inválido: debe pertenecer al dominio institucional <strong>@uts.edu.co</strong>.';
        return false;
    } else {
        inputCorreo.classList.remove('is-invalid');
        inputCorreo.classList.add('is-valid');
        feedback.className = 'form-text text-success fw-semibold';
        feedback.innerHTML = '<i class="bi bi-check-circle-fill me-1"></i>Correo institucional @uts.edu.co válido.';
        return true;
    }
}

function validarCreditosEstudiante() {
    const inputCreditos = document.getElementById('porcentaje_creditos');
    const feedback = document.getElementById('feedbackCreditos');
    const valorStr = inputCreditos.value.trim();

    if (valorStr === '') {
        inputCreditos.classList.remove('is-invalid', 'is-valid');
        feedback.className = 'form-text';
        feedback.innerHTML = 'Requisito: mínimo <strong>75%</strong> de créditos completados para poder registrarse.';
        return false;
    }

    const porcentaje = parseFloat(valorStr);
    if (isNaN(porcentaje) || porcentaje < 0 || porcentaje > 100) {
        inputCreditos.classList.add('is-invalid');
        inputCreditos.classList.remove('is-valid');
        feedback.className = 'form-text text-danger fw-semibold';
        feedback.innerHTML = '<i class="bi bi-x-circle-fill me-1"></i>Ingrese un porcentaje válido entre 0% y 100%.';
        return false;
    } else if (porcentaje < 75) {
        inputCreditos.classList.add('is-invalid');
        inputCreditos.classList.remove('is-valid');
        feedback.className = 'form-text text-danger fw-semibold';
        feedback.innerHTML = '<i class="bi bi-x-circle-fill me-1"></i>No permitido: tiene menos del 75% de créditos completados (' + porcentaje + '%). No se puede crear el estudiante.';
        return false;
    } else {
        inputCreditos.classList.remove('is-invalid');
        inputCreditos.classList.add('is-valid');
        feedback.className = 'form-text text-success fw-semibold';
        feedback.innerHTML = '<i class="bi bi-check-circle-fill me-1"></i>Cumple con el requisito mínimo del 75% de créditos completados (' + porcentaje + '%).';
        return true;
    }
}

function mostrarAlertaCliente(mensaje) {
    const alerta = document.getElementById('alertaValidacionCliente');
    const texto = document.getElementById('textoAlertaCliente');
    texto.innerHTML = mensaje;
    alerta.classList.remove('d-none');
    alerta.classList.add('d-flex');
    alerta.scrollIntoView({ behavior: 'smooth', block: 'center' });
}

function validarFormularioUsuario(event) {
    const nombreRol = obtenerRolSeleccionado();
    const correoValido = validarCorreoInstitucional();

    if (!correoValido) {
        event.preventDefault();
        mostrarAlertaCliente('<strong>Error de validación:</strong> El correo debe ser institucional y terminar en <strong>@uts.edu.co</strong>.');
        document.getElementById('correo').focus();
        return false;
    }

    if (nombreRol === 'ESTUDIANTE') {
        const inputCreditos = document.getElementById('porcentaje_creditos');
        const porcentaje = parseFloat(inputCreditos.value);
        if (isNaN(porcentaje) || porcentaje < 75 || porcentaje > 100) {
            event.preventDefault();
            validarCreditosEstudiante();
            mostrarAlertaCliente('<strong>Registro no permitido:</strong> Para registrar un estudiante debe tener el <strong>75% o más</strong> de créditos completados.');
            inputCreditos.focus();
            return false;
        }
    }

    return true;
}

document.addEventListener('DOMContentLoaded', adaptarFormularioPorRol);
</script>

<%@ include file="/includes/footer.jspf" %>
