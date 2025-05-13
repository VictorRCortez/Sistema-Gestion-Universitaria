from flask import Blueprint, render_template, request, redirect, url_for, session
from database import execute_stored_procedure

# Crear un Blueprint para las rutas de estudiante
student_bp = Blueprint('student', __name__)

@student_bp.route('/dashboard')
def student_dashboard():
    """Dashboard del estudiante."""
    # Verificar si el usuario está loggeado y es estudiante
    if 'loggedin' in session and session['rol'] == 'estudiante':
        # Obtener el ID del estudiante
        estudiante_data = execute_stored_procedure('ObtenerPerfilEstudiante', {'usuario_id': session['user_id']})
        estudiante_id = estudiante_data[0]['estudiante_id'] if estudiante_data and estudiante_data[0] else None

        cursos_inscritos = []
        if estudiante_id:
            # Obtener los cursos inscritos por el estudiante
            cursos_inscritos = execute_stored_procedure('ObtenerCursosEstudiante', {'estudiante_id': estudiante_id})

        return render_template('student/dashboard.html',
                               nombre=session['nombre'],
                               apellido=session['apellido'],
                               cursos=cursos_inscritos)
    return redirect(url_for('auth.login')) # Redirige al login si no está autorizado

@student_bp.route('/courses')
def student_list_courses():
    """Lista todos los cursos disponibles para inscripción."""
    if 'loggedin' in session and session['rol'] == 'estudiante':
        cursos_disponibles = execute_stored_procedure('ListarCursosDisponibles')
        return render_template('student/list_courses.html', cursos=cursos_disponibles)
    return redirect(url_for('auth.login'))

@student_bp.route('/enroll/<int:curso_id>', methods=['POST'])
def student_enroll_course(curso_id):
    """Permite a un estudiante inscribirse a un curso."""
    if 'loggedin' in session and session['rol'] == 'estudiante':
        estudiante_data = execute_stored_procedure('ObtenerPerfilEstudiante', {'usuario_id': session['user_id']})
        estudiante_id = estudiante_data[0]['estudiante_id'] if estudiante_data and estudiante_data[0] else None

        if estudiante_id:
            result = execute_stored_procedure('InscribirCurso', {'estudiante_id': estudiante_id, 'curso_id': curso_id})
            # Aquí podrías manejar el mensaje de resultado (éxito o error de cupo)
            print(result) # Simple impresión en consola
        return redirect(url_for('student.student_dashboard')) # Redirige al dashboard después de intentar inscribir
    return redirect(url_for('auth.login'))

@student_bp.route('/drop/<int:inscripcion_id>', methods=['POST'])
def student_drop_course(inscripcion_id):
    """Permite a un estudiante dar de baja un curso."""
    if 'loggedin' in session and session['rol'] == 'estudiante':
        result = execute_stored_procedure('DarBajaCurso', {'inscripcion_id': inscripcion_id})
        print(result) # Simple impresión en consola
        return redirect(url_for('student.student_dashboard')) # Redirige al dashboard después de intentar dar de baja
    return redirect(url_for('auth.login'))

# acá se puede añadir más rutas específicas de estudiante si son necesarias
