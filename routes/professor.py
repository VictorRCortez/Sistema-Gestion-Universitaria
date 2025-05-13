from flask import Blueprint, render_template, request, redirect, url_for, session
from database import execute_stored_procedure

# Crear un Blueprint para las rutas de profesor
professor_bp = Blueprint('professor', __name__)

@professor_bp.route('/dashboard')
def professor_dashboard():
    """Dashboard del profesor."""
    # Verificar si el usuario está loggeado y es profesor
    if 'loggedin' in session and session['rol'] == 'profesor':
        # Obtener el ID del profesor
        profesor_data = execute_stored_procedure('ObtenerPerfilProfesor', {'usuario_id': session['user_id']})
        profesor_id = profesor_data[0]['profesor_id'] if profesor_data and profesor_data[0] else None

        cursos_impartidos = []
        if profesor_id:
            # Obtener los cursos impartidos por el profesor
            cursos_impartidos = execute_stored_procedure('ObtenerCursosProfesor', {'profesor_id': profesor_id})

        return render_template('professor/dashboard.html',
                               nombre=session['nombre'],
                               apellido=session['apellido'],
                               cursos=cursos_impartidos)
    return redirect(url_for('auth.login')) # Redirige al login si no está autorizado

@professor_bp.route('/course_students/<int:curso_id>')
def professor_course_students(curso_id):
    """Lista los estudiantes inscritos en un curso específico."""
    if 'loggedin' in session and session['rol'] == 'profesor':
        estudiantes = execute_stored_procedure('ObtenerEstudiantesCurso', {'curso_id': curso_id})
        # Obtener información del curso (ineficiente, idealmente un SP para un solo curso)
        curso_info_list = execute_stored_procedure('ListarCursosDisponibles') # Obtiene todos los cursos
        curso_actual = next((item for item in curso_info_list if item['id'] == curso_id), None) # Busca el curso por ID

        return render_template('professor/course_students.html', estudiantes=estudiantes, curso=curso_actual)
    return redirect(url_for('auth.login'))

@professor_bp.route('/assign_grade/<int:inscripcion_id>', methods=['GET', 'POST'])
def professor_assign_grade(inscripcion_id):
    """Permite a un profesor asignar una calificación a una inscripción."""
    if 'loggedin' in session and session['rol'] == 'profesor':
        if request.method == 'POST':
            calificacion = request.form['calificacion']
            try:
                calificacion_decimal = float(calificacion)
                # Asegurarse de que la calificación esté en el rango 0-10
                if 0 <= calificacion_decimal <= 10:
                    result = execute_stored_procedure('AsignarCalificacion', {'inscripcion_id': inscripcion_id, 'calificacion': calificacion_decimal})
                    print(result) # Simple impresión en consola
                else:
                    print("Error: La calificación debe estar entre 0 y 10.")

                # Redirigir de vuelta a la lista de estudiantes del curso (necesitaríamos el curso_id)
                # Para simplicidad, redirigimos al dashboard del profesor
                return redirect(url_for('professor.professor_dashboard'))
            except ValueError:
                # Manejar error si la calificación no es un número válido
                error = "La calificación debe ser un número."
                print(error)
                # Para simplicidad, redirigimos al dashboard
                return redirect(url_for('professor.professor_dashboard'))

        # Si es GET, mostrar el formulario para asignar calificación
        # Idealmente, aquí se obtendría la información del estudiante y curso para mostrarla
        # Para simplicidad, solo mostramos un formulario básico
        return render_template('professor/assign_grade.html', inscripcion_id=inscripcion_id)
    return redirect(url_for('auth.login'))

# acá se puede añadir más rutas específicas de profesor si son necesarias
