# Documentación del API REST - Sistema de Gestión Universitaria

Esta API proporciona acceso a las funcionalidades clave del sistema: autenticación, gestión de usuarios, cursos, inscripciones y anuncios. Las rutas están organizadas por roles usando Blueprints de Flask.

---

## Autenticación

### POST `/login`
Inicia sesión con email y contraseña.

**Parámetros (form-data):**
- `email`: correo electrónico del usuario.
- `contrasena`: contraseña.

**Respuesta:** redirección según el rol del usuario.

### GET `logout`
Cierra la sesión del usuario.

---

## Estudiante (`/student/...`)

### GET `/student/dashboard`
Muestra el panel principal del estudiante.

### GET `/student/courses`
Lista los cursos en los que el estudiante está inscrito.

### POST `/student/enroll`
Inscribe al estudiante en un curso.

### POST `/student/drop`
Permite al estudiante darse de baja de un curso.

**Parámetros (form-data):**
`curso_id`: ID del curso.

**Parámetros (form-data):**
 `inscripcion_id`: ID de la inscripción.

---

##  Profesor (`/professor/...`)

### GET `/professor/dashboard`
Panel principal del profesor con su información y cursos asignados.

### GET `/professor/course_students/<int:curso_id>`
Lista de estudiantes inscritos en un curso específico.

### POST `/professor/assign_grade/<int:inscripcion_id>`
Asigna una calificación a un estudiante.

**Parámetros (form-data):**
- `inscripcion_id`: ID de la inscripción.
- `calificacion`: Nota entre 0 y 10.

---

## Administrador (`/admin/...`)

### GET `/admin/dashboard`
Panel principal del administrador.

### GET `/admin/users`
Lista todos los usuarios registrados.

### GET `/admin/save_user`
Formulario para crear usuario.

### GET `/admin/save_user/<int:id>`
Formulario para editar usuario.

### GET `/admin/subjects`
Lista todas las materias.

### GET `/admin/save_subject`
Formulario para editar materia.

### GET `/admin/save_course`
Formulario para crear un curso.

### GET `/admin/save_course/<int:id>`
Formulario para editar un curso.

### GET `/admin/toggle_user_status/<int:user_id>/<int:status>`
Permite al administrador desahabilitar/habilitar usuario.

---

## Anuncios

### GET `/announcements`
Lista todos los anuncios institucionales públicos.

### GET `/admin/create_announcement`
Formulario para crear un nuevo anuncio.

**Parámetros (form-data):**
- `titulo`: título del anuncio.
- `contenido`: contenido del mensaje.

---

## Notas Técnicas

- La autenticación se gestiona mediante sesiones de Flask.
- Todas las interacciones con la base de datos se realizan usando procedimientos almacenados en SQL Server.
- Los formularios usan `POST` para escritura y `GET` para navegación o recuperación de vistas.

---

