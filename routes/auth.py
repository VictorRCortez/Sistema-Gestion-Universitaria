from flask import Blueprint, render_template, request, redirect, url_for, session
from database import execute_stored_procedure

# Crear un Blueprint para las rutas de autenticación
auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/main')
def main():
    return render_template('main.html')

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    """Maneja el login de usuarios."""
    if request.method == 'POST':
        email = request.form['email']
        contrasena = request.form['contrasena']

        # Llama al procedimiento almacenado para verificar el login
        user_data = execute_stored_procedure('VerificarLogin', {'email': email, 'contrasena': contrasena})

        if user_data and user_data[0]: # Verifica si se obtuvieron datos de usuario
            user = user_data[0]
            session['loggedin'] = True
            session['user_id'] = user['id']
            session['rol'] = user['rol']
            session['nombre'] = user['nombre']
            session['apellido'] = user['apellido']

            # Redirige según el rol del usuario
            if session['rol'] == 'admin':
                return redirect(url_for('admin.admin_dashboard')) # Usar nombre del blueprint + nombre de la función
            elif session['rol'] == 'estudiante':
                return redirect(url_for('student.student_dashboard')) # Usar nombre del blueprint + nombre de la función
            elif session['rol'] == 'profesor':
                return redirect(url_for('professor.professor_dashboard')) # Usar nombre del blueprint + nombre de la función
        else:
            # Mensaje de error de login (simple)
            error = 'Usuario o contraseña incorrectos'
            return render_template('login.html', error=error)

    # Si es GET, muestra el formulario de login
    return render_template('login.html')

@auth_bp.route('/logout')
def logout():
    """Cierra la sesión del usuario."""
    session.pop('loggedin', None)
    session.pop('user_id', None)
    session.pop('rol', None)
    session.pop('nombre', None)
    session.pop('apellido', None)
    return redirect(url_for('auth.login')) # Redirige a la ruta 'login' dentro del blueprint 'auth'
