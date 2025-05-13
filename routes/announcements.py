from flask import Blueprint, render_template, request, redirect, url_for, session
from database import execute_stored_procedure

# Crear un Blueprint para las rutas de anuncios
announcements_bp = Blueprint('announcements', __name__)

@announcements_bp.route('/announcements')
def list_announcements():
    """Lista los anuncios recientes."""
    # Esta ruta puede ser accesible para todos los roles loggeados
    if 'loggedin' in session:
        anuncios = execute_stored_procedure('ObtenerAnuncios')
        return render_template('announcements.html', anuncios=anuncios)
    return redirect(url_for('auth.login'))

@announcements_bp.route('/admin/create_announcement', methods=['GET', 'POST'])
def admin_create_announcement():
    """Permite al admin crear un nuevo anuncio."""
    if 'loggedin' in session and session['rol'] == 'admin':
        if request.method == 'POST':
            titulo = request.form['titulo']
            contenido = request.form['contenido']
            usuario_id = session['user_id'] # El admin actual es el autor

            result = execute_stored_procedure('CrearAnuncio', {'titulo': titulo, 'contenido': contenido, 'usuario_id': usuario_id})
            print(result) # Simple impresión en consola
            return redirect(url_for('announcements.list_announcements')) # Redirige a la lista de anuncios

        # Si es GET, muestra el formulario para crear anuncio
        return render_template('admin/create_announcement.html')
    return redirect(url_for('auth.login'))

# acá se puede añadir más rutas específicas de anuncios si son necesarias (ej. editar, eliminar)
