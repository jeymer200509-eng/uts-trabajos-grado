<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Si ya está autenticado, redirigir a index.jsp --%>
<c:if test="${not empty sessionScope.usuario}">
    <c:redirect url="/index.jsp" />
</c:if>

<c:set var="pageTitle" value="Iniciar Sesión - Trabajos de Grado UTS" />
<%@ include file="/includes/header.jspf" %>
<%@ include file="/includes/navbar.jspf" %>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-9 col-lg-7 col-xl-6" style="max-width: 620px;">
            <!-- ORYZO AI Dark Elevated Card (12px radius, no drop shadows) -->
            <div class="card card-uts text-center py-4 px-3 px-md-4" style="width: 100%;">
                <div class="card-body p-3 p-md-4">
                    <!-- Institutional Tag -->
                    <div class="mb-3">
                        <span class="badge rounded-pill px-3 py-1" style="background: rgba(0, 102, 51, 0.25); color: #86efac; border: 1px solid #165e34; font-size: 11px; letter-spacing: 0.06em;">
                            <i class="bi bi-mortarboard-fill me-1"></i> UNIDADES TECNOLÓGICAS DE SANTANDER
                        </span>
                    </div>

                    <!-- Editorial Headlines in Warm Cream -->
                    <h2 class="fw-bold mb-1" style="color: var(--color-warm-cream); letter-spacing: 0.05em; font-size: 1.85rem;">TRABAJOS DE GRADO</h2>
                    <p class="mb-4" style="color: var(--color-cream-muted); font-size: 0.92rem; font-weight: 400;">
                        Sistema institucional de gestión, seguimiento y sustentaciones.
                    </p>

                    <form action="${pageContext.request.contextPath}/login_procesar.jsp" method="POST" novalidate class="text-start">
                        <div class="mb-4">
                            <label for="usuario" class="form-label">
                                Correo institucional o código
                            </label>
                            <input type="text" class="form-control" id="usuario" name="usuario" 
                                   placeholder="estudiante1@uts.edu.co o 1098765432" required autofocus>
                        </div>

                        <div class="mb-4">
                            <label for="clave" class="form-label">
                                Contraseña
                            </label>
                            <input type="password" class="form-control" id="clave" name="clave" 
                                   placeholder="••••••••" required>
                        </div>

                        <!-- Primary CTA: UTS Green 36px Pill Button -->
                        <button type="submit" class="btn btn-uts-primary w-100 mb-3 shadow-none">
                            Iniciar Sesión
                        </button>
                    </form>

                    <div class="mt-2 mb-4">
                        <a href="mailto:coordinacion@uts.edu.co" class="small" style="color: var(--color-warm-cream); font-size: 0.82rem;">
                            ¿Problemas para acceder? Contactar Coordinación &rarr;
                        </a>
                    </div>

                    <!-- Acordeón con credenciales de prueba en estilo ORYZO AI -->
                    <div class="accordion mt-3 text-start" id="accordionCuentasPrueba">
                        <div class="accordion-item border-0" style="background: rgba(0, 0, 0, 0.25); border-radius: 12px; border: 1px dashed var(--color-border-cork) !important;">
                            <h2 class="accordion-header" id="headingCuentas">
                                <button class="accordion-button collapsed py-2 px-3 small border-0 text-uppercase shadow-none" type="button" data-bs-toggle="collapse" data-bs-target="#collapseCuentas" aria-expanded="false" aria-controls="collapseCuentas" style="background: transparent; color: var(--color-warm-cream); font-size: 11px; letter-spacing: 0.05em;">
                                    <i class="bi bi-key me-2 text-success"></i> Credenciales de prueba rápida (clic para autocompletar)
                                </button>
                            </h2>
                            <div id="collapseCuentas" class="accordion-collapse collapse" aria-labelledby="headingCuentas" data-bs-parent="#accordionCuentasPrueba">
                                <div class="accordion-body p-2 p-md-3">
                                    <div class="table-responsive">
                                        <table class="table table-sm table-borderless align-middle mb-0" style="min-width: 480px;">
                                            <thead>
                                                <tr style="border-bottom: 1px dashed var(--color-border-cork); font-size: 0.75rem;">
                                                    <th style="width: 25%;">Rol</th>
                                                    <th style="width: 50%;">Usuario</th>
                                                    <th style="width: 25%;" class="text-end pe-2">Clave</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <tr style="cursor: pointer; transition: background 0.15s ease;" onclick="llenarCredenciales('admin@uts.edu.co', 'admin123')" title="Clic para usar">
                                                    <td><span class="badge badge-rol badge-rol-ADMIN">Admin</span></td>
                                                    <td><code style="font-size: 0.82rem;">admin@uts.edu.co</code></td>
                                                    <td class="text-end pe-2"><code style="font-size: 0.84rem; color: #86efac; font-weight: 600;">admin123</code></td>
                                                </tr>
                                                <tr style="cursor: pointer; transition: background 0.15s ease;" onclick="llenarCredenciales('coordinacion@uts.edu.co', 'coord123')" title="Clic para usar">
                                                    <td><span class="badge badge-rol badge-rol-COORDINACION">Coord</span></td>
                                                    <td><code style="font-size: 0.82rem;">coordinacion@uts.edu.co</code></td>
                                                    <td class="text-end pe-2"><code style="font-size: 0.84rem; color: #86efac; font-weight: 600;">coord123</code></td>
                                                </tr>
                                                <tr style="cursor: pointer; transition: background 0.15s ease;" onclick="llenarCredenciales('director1@uts.edu.co', 'docente123')" title="Clic para usar">
                                                    <td><span class="badge badge-rol badge-rol-DIRECTOR">Director</span></td>
                                                    <td><code style="font-size: 0.82rem;">director1@uts.edu.co</code></td>
                                                    <td class="text-end pe-2"><code style="font-size: 0.84rem; color: #86efac; font-weight: 600;">docente123</code></td>
                                                </tr>
                                                <tr style="cursor: pointer; transition: background 0.15s ease;" onclick="llenarCredenciales('evaluador1@uts.edu.co', 'eval123')" title="Clic para usar">
                                                    <td><span class="badge badge-rol badge-rol-EVALUADOR">Evaluador</span></td>
                                                    <td><code style="font-size: 0.82rem;">evaluador1@uts.edu.co</code></td>
                                                    <td class="text-end pe-2"><code style="font-size: 0.84rem; color: #86efac; font-weight: 600;">eval123</code></td>
                                                </tr>
                                                <tr style="cursor: pointer; transition: background 0.15s ease;" onclick="llenarCredenciales('estudiante1@uts.edu.co', 'est123')" title="Clic para usar">
                                                    <td><span class="badge badge-rol badge-rol-ESTUDIANTE">Estudiante</span></td>
                                                    <td><code style="font-size: 0.82rem;">estudiante1@uts.edu.co</code></td>
                                                    <td class="text-end pe-2"><code style="font-size: 0.84rem; color: #86efac; font-weight: 600;">est123</code></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                    <div class="text-center mt-2">
                                        <small class="text-white-50" style="font-size: 0.72rem;">Tip: Haz clic sobre cualquier fila para rellenar usuario y contraseña.</small>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function llenarCredenciales(usr, pass) {
        var u = document.getElementById('usuario');
        var c = document.getElementById('clave');
        if (u) u.value = usr;
        if (c) c.value = pass;
    }
</script>

<%@ include file="/includes/footer.jspf" %>
