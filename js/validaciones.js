/**
 * validaciones.js
 * Funcionalidades cliente para validación y dinamismo de interfaz
 * Sistema de Trabajos de Grado - UTS
 */

// Confirmación genérica de eliminación o acción crítica
function confirmarAccion(event, mensaje) {
    if (!confirm(mensaje || '¿Está seguro de realizar esta acción? Esta operación no se puede deshacer.')) {
        event.preventDefault();
        return false;
    }
    return true;
}

// Filtro rápido para tablas HTML
function filtrarTabla(inputId, tablaId) {
    const input = document.getElementById(inputId);
    const tabla = document.getElementById(tablaId);
    if (!input || !tabla) return;
    
    const filtro = input.value.toLowerCase().trim();
    const filas = tabla.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
    
    for (let i = 0; i < filas.length; i++) {
        const textoFila = filas[i].textContent || filas[i].innerText;
        if (textoFila.toLowerCase().indexOf(filtro) > -1) {
            filas[i].style.display = '';
        } else {
            filas[i].style.display = 'none';
        }
    }
}

// Validación de rango de notas (0.0 a 5.0) en formularios de evaluación
function validarNotaInput(input) {
    const val = parseFloat(input.value);
    if (isNaN(val) || val < 0.0 || val > 5.0) {
        input.setCustomValidity('La calificación debe estar comprendida entre 0.0 y 5.0');
    } else {
        input.setCustomValidity('');
    }
}

// Validación de enlace a repositorio/documento (Drive, OneDrive, Dropbox, etc.)
function validarUrlDocumento(input) {
    const url = input.value.trim();
    if (url === '') return;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
        input.setCustomValidity('El enlace debe iniciar con http:// o https://');
    } else {
        input.setCustomValidity('');
    }
}

// Auto-cierre de alertas flash tras 6 segundos
document.addEventListener('DOMContentLoaded', function () {
    const alerts = document.querySelectorAll('.alert-dismissible');
    alerts.forEach(function (alert) {
        setTimeout(function () {
            const bsAlert = bootstrap.Alert.getOrCreateInstance(alert);
            if (bsAlert) {
                bsAlert.close();
            }
        }, 6000);
    });
});
