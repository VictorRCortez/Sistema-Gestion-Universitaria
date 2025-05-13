// Archivo JavaScript para funcionalidades básicas en el cliente

// Función utilizada en templates/admin/save_user.html
// Muestra u oculta campos específicos del formulario de usuario
// basado en el rol seleccionado.
function toggleRoleFields() {
    const rol = document.getElementById('rol').value;
    const estudianteFields = document.getElementById('estudiante_fields');
    const profesorFields = document.getElementById('profesor_fields');

    if (estudianteFields) {
        estudianteFields.style.display = (rol === 'estudiante') ? 'block' : 'none';
    }
    if (profesorFields) {
         profesorFields.style.display = (rol === 'profesor') ? 'block' : 'none';
    }
}

// --- Funcionalidad para Confirmaciones de Acciones ---

// Configura listeners para formularios que requieren confirmación antes de enviar.
// Busca formularios con la clase 'js-confirm-form'.
function setupConfirmationForms() {
    // Obtener todos los formularios con la clase 'js-confirm-form'
    const forms = document.querySelectorAll('.js-confirm-form');

    // Iterar sobre cada formulario encontrado
    forms.forEach(form => {
        // Añadir un listener para el evento 'submit' del formulario
        form.addEventListener('submit', function(event) {
            // Obtener el mensaje de confirmación del atributo data-confirm-message
            // Si el atributo no existe, usar un mensaje genérico
            const message = this.getAttribute('data-confirm-message') || '¿Estás seguro de realizar esta acción?';

            // Mostrar el cuadro de diálogo de confirmación
            const isConfirmed = confirm(message);

            // Si el usuario NO confirma, prevenir el envío del formulario
            if (!isConfirmed) {
                event.preventDefault();
            }
        });
    });
}

// Ejecutar la configuración de confirmaciones cuando el DOM esté completamente cargado.
// Esto asegura que los formularios existan en la página cuando intentamos añadir listeners.
document.addEventListener('DOMContentLoaded', function() {
    // Si estás en la página de guardar usuario, ejecutar la función de alternar campos
    // Esto es útil si se carga la página en modo edición y ya hay un rol seleccionado
    if (document.getElementById('rol')) {
        toggleRoleFields();
    }

    // Configurar los diálogos de confirmación para los formularios
    setupConfirmationForms();

    // acá se podría agregar cualquier otra funcionalidad que se puedan necesitar
});
