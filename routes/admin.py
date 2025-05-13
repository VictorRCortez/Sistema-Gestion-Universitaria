from flask import Blueprint, render_template, request, redirect, url_for, session
from database import execute_stored_procedure

# Crear un Blueprint para las rutas de administrador
admin_bp = Blueprint('admin', __name__)

# Rutas de administrador
@admin_bp.route('/dashboard')
def admin_dashboard():
    """Dashboard del administrador."""
    # Verificar si el usuario está loggeado y es admin
    if 'loggedin' in session and session['rol'] == 'admin':
        # Si el usuario es admin, mostrar el dashboard
        return render_template('admin/dashboard.html', nombre=session['nombre'], apellido=session['apellido'])
    return redirect(url_for('auth.login')) # Redirige al login si no está autorizado

@admin_bp.route('/users')
def admin_list_users():
    """Lista todos los usuarios."""
    if 'loggedin' in session and session['rol'] == 'admin':
        usuarios = execute_stored_procedure('ListarUsuarios')
        return render_template('admin/list_users.html', usuarios=usuarios)
    return redirect(url_for('auth.login'))

@admin_bp.route('/subjects')
def admin_list_subjects():
    """Lista todas las materias."""
    if 'loggedin' in session and session['rol'] == 'admin':
        materias = execute_stored_procedure('ListarMaterias')
        return render_template('admin/list_subjects.html', materias=materias)
    return redirect(url_for('auth.login'))

# Rutas para crear y editar materias
@admin_bp.route('/save_subject', defaults={'id': None}, methods=['GET', 'POST'])
@admin_bp.route('/save_subject/<int:id>', methods=['GET', 'POST'])
def admin_save_subject(id):
    """Permite al admin crear o actualizar una materia."""
    if 'loggedin' in session and session['rol'] == 'admin':
        materia = None # Variable para almacenar los datos de la materia si se está editando

        if request.method == 'POST':
            # Leer el ID del formulario (será None si es una nueva materia)
            subject_id = request.form.get('id')
            # Convertir a int si no es None y no está vacío
            subject_id = int(subject_id) if subject_id and subject_id.isdigit() else None

            codigo = request.form['codigo']
            nombre = request.form['nombre']
            creditos = int(request.form['creditos'])
            descripcion = request.form.get('descripcion')

            params = {
                'id': subject_id, # Usar el ID obtenido del formulario
                'codigo': codigo,
                'nombre': nombre,
                'creditos': creditos,
                'descripcion': descripcion if descripcion else None # Pasar None si está vacío
            }
            result = execute_stored_procedure('GuardarMateria', params)
            print(result) # Simple impresión en consola
            return redirect(url_for('admin.admin_list_subjects'))

        # Si es GET, mostrar formulario
        if id is not None:
             # --- NOTA IMPORTANTE ---
             # Para obtener los datos de la materia, se puede usar:
             # 1. Un SP en la DB para obtener una materia por ID.
             # 2. Llamar a ese SP aquí y pasar los datos a la plantilla.
             # Ejemplo conceptual (requiere SP 'ObtenerMateriaPorId'):
             # materia_data = execute_stored_procedure('ObtenerMateriaPorId', {'id': id})
             # if materia_data and materia_data[0]:
             #    materia = materia_data[0]
             print(f"Editando materia con ID: {id} (Los datos no se pre-llenan sin SP)")

        # Pasar el ID recibido de la URL a la plantilla, incluso si no se obtuvieron los datos completos
        return render_template('admin/save_subject.html', materia=materia, subject_id_from_url=id)
    return redirect(url_for('auth.login'))

# Rutas para crear y editar cursos
@admin_bp.route('/save_course', defaults={'id': None}, methods=['GET', 'POST'])
@admin_bp.route('/save_course/<int:id>', methods=['GET', 'POST'])
def admin_save_course(id):
    """Permite al admin crear o actualizar un curso."""
    if 'loggedin' in session and session['rol'] == 'admin':
        curso = None # Variable para almacenar los datos del curso si se está editando

        if request.method == 'POST':
            # Leer el ID del formulario
            course_id = request.form.get('id')
            course_id = int(course_id) if course_id and course_id.isdigit() else None


            materia_id = int(request.form['materia_id'])
            profesor_id = int(request.form['profesor_id'])
            periodo = request.form['periodo']
            cupo_maximo = int(request.form['cupo_maximo'])
            dias_clase = request.form['dias_clase']
            horario = request.form['horario']
            aula = request.form['aula']

            params = {
                'id': course_id, # Usar el ID del formulario
                'materia_id': materia_id,
                'profesor_id': profesor_id,
                'periodo': periodo,
                'cupo_maximo': cupo_maximo,
                'dias_clase': dias_clase,
                'horario': horario,
                'aula': aula
            }
            result = execute_stored_procedure('GuardarCurso', params)
            print(result) # Simple impresión en consola
            # Redirigir a la lista de cursos (necesitaríamos una ruta para eso)
            # Por ahora, redirigimos al dashboard del admin
            return redirect(url_for('admin.admin_dashboard')) # Redirige al dashboard del admin

        # Si es GET, mostrar formulario
        if id is not None:
             # --- NOTA IMPORTANTE ---
             # Para pre-llenar el formulario de edición, se puede usar:
             # 1. Un SP en la DB para obtener un curso por ID.
             # 2. Llamar a ese SP aquí y pasar los datos a la plantilla.
             # Ejemplo conceptual (requiere SP 'ObtenerCursoPorId'):
             # curso_data = execute_stored_procedure('ObtenerCursoPorId', {'id': id})
             # if curso_data and curso_data[0]:
             #    curso = curso_data[0]
             print(f"Editando curso con ID: {id} (Los datos no se pre-llenan sin SP)")


        # Necesitarías listar materias y profesores para los dropdowns
        materias = execute_stored_procedure('ListarMaterias')
        # Obtener solo usuarios con rol 'profesor' para el dropdown
        profesores_usuarios = execute_stored_procedure('ListarUsuarios', {'rol': 'profesor'})
        # Necesitamos el ID del profesor, no el ID del usuario
        profesores = []
        if profesores_usuarios:
             for user in profesores_usuarios:
                 # Esto es ineficiente, idealmente se haría con un JOIN en un SP
                 profesor_data = execute_stored_procedure('ObtenerPerfilProfesor', {'usuario_id': user['id']})
                 if profesor_data and profesor_data[0]:
                     profesores.append({'id': profesor_data[0]['profesor_id'], 'nombre_completo': f"{user['nombre']} {user['apellido']}"})

        return render_template('admin/save_course.html', materias=materias, profesores=profesores, curso=curso, course_id_from_url=id) # Pasar curso y id de url
    return redirect(url_for('auth.login'))

@admin_bp.route('/save_user', defaults={'id': None}, methods=['GET', 'POST'])
@admin_bp.route('/save_user/<int:id>', methods=['GET', 'POST'])
def admin_save_user(id):
    """Permite al admin crear o actualizar un usuario (incluyendo estudiante o profesor)."""
    if 'loggedin' in session and session['rol'] == 'admin':
        usuario = None # Variable para almacenar los datos del usuario si se está editando
        estudiante_data = None
        profesor_data = None

        if request.method == 'POST':
            # Leer el ID del formulario
            user_id = request.form.get('id')
            user_id = int(user_id) if user_id and user_id.isdigit() else None

            nombre = request.form['nombre']
            apellido = request.form['apellido']
            email = request.form['email']
            contrasena = request.form.get('contrasena') # Puede ser None si no se cambia
            rol = request.form['rol']

            # Campos específicos según el rol
            num_matricula = request.form.get('num_matricula')
            carrera = request.form.get('carrera')
            semestre = request.form.get('semestre')
            num_empleado = request.form.get('num_empleado')
            departamento = request.form.get('departamento')
            titulo = request.form.get('titulo')

            params = {
                'id': user_id, # Usar el ID del formulario
                'nombre': nombre,
                'apellido': apellido,
                'email': email,
                'contrasena': contrasena if contrasena else None, # Pasar None si está vacío
                'rol': rol,
                'num_matricula': num_matricula if num_matricula else None,
                'carrera': carrera if carrera else None,
                'semestre': int(semestre) if semestre and semestre.isdigit() else None,
                'num_empleado': num_empleado if num_empleado else None,
                'departamento': departamento if departamento else None,
                'titulo': titulo if titulo else None
            }
            result = execute_stored_procedure('GuardarUsuario', params)
            print(result) # Simple impresión en consola
            return redirect(url_for('admin.admin_list_users'))

        # Si es GET, mostrar formulario
        if id is not None:
             # --- NOTA IMPORTANTE ---
             # Para pre-llenar el formulario de edición, se puede usar:
             # 1. Un SP en la DB para obtener un usuario por ID.
             # 2. Llamar a ese SP aquí y pasar los datos a la plantilla.
             # Los SPs ObtenerPerfilEstudiante y ObtenerPerfilProfesor ya existen,
             # podrías usarlos si el rol es conocido, pero obtener el rol primero
             # requeriría otro SP o una consulta directa.
             # Ejemplo conceptual (requiere SP 'ObtenerUsuarioPorId'):
             # usuario_data = execute_stored_procedure('ObtenerUsuarioPorId', {'id': id})
             # if usuario_data and usuario_data[0]:
             #    usuario = usuario_data[0]
             #    if usuario['rol'] == 'estudiante':
             #        estudiante_data = execute_stored_procedure('ObtenerPerfilEstudiante', {'usuario_id': id})
             #    elif usuario['rol'] == 'profesor':
             #        profesor_data = execute_stored_procedure('ObtenerPerfilProfesor', {'usuario_id': id})
             print(f"Editando usuario con ID: {id} (Los datos no se pre-llenan sin SP)")


        return render_template('admin/save_user.html', usuario=usuario, estudiante=estudiante_data, profesor=profesor_data, user_id_from_url=id) # Pasar id de url


@admin_bp.route('/toggle_user_status/<int:user_id>/<int:status>', methods=['POST'])
def admin_toggle_user_status(user_id, status):
    """Permite al admin deshabilitar/habilitar un usuario."""
    if 'loggedin' in session and session['rol'] == 'admin':
        result = execute_stored_procedure('CambiarEstadoUsuario', {'usuario_id': user_id, 'activo': status})
        print(result) # Simple impresión en consola
        return redirect(url_for('admin.admin_list_users'))
    return redirect(url_for('auth.login'))

# aca se puede agregar mas rutas si es necesario del admin
