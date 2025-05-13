USE universidad_gestion_db;
GO

-- =====================================================================================
-- 1. Listar todos los usuarios registrados
--    Muestra información básica de cada cuenta de usuario.
-- =====================================================================================
SELECT 
    id,
    nombre,
    apellido,
    email,
    contrasena,
    rol,
    activo,
    fecha_registro
FROM Usuario;
GO


-- =====================================================================================
-- 2. Listar estudiantes con su número de cursos inscritos y promedio de calificaciones
--    Muestra cada estudiante, su matrícula, carrera, y cuántos cursos tiene activos,
--    además de su promedio (NULL si no tiene calificaciones aún).
-- =====================================================================================
SELECT 
    e.id           AS estudiante_id,
    u.nombre + ' ' + u.apellido AS estudiante,
    e.num_matricula,
    e.carrera,
    COUNT(i.id)    AS cursos_inscritos,
    ROUND(AVG(i.calificacion), 2) AS promedio_calificacion
FROM Estudiante e
JOIN Usuario u     ON e.usuario_id = u.id
LEFT JOIN Inscripcion i 
     ON e.id = i.estudiante_id 
    AND i.estado = 'activa'
GROUP BY e.id, u.nombre, u.apellido, e.num_matricula, e.carrera;
GO


-- =====================================================================================
-- 3. Listar profesores con la cantidad de cursos que dictan
--    Muestra cada profesor, su número de empleado, departamento y cuántos cursos activos imparte.
-- =====================================================================================
SELECT 
    p.id           AS profesor_id,
    u.nombre + ' ' + u.apellido AS profesor,
    p.num_empleado,
    p.departamento,
    COUNT(c.id)    AS cursos_a_cargo
FROM Profesor p
JOIN Usuario u ON p.usuario_id = u.id
LEFT JOIN Curso c
     ON p.id = c.profesor_id 
    AND c.activo = 1
GROUP BY p.id, u.nombre, u.apellido, p.num_empleado, p.departamento;
GO


-- =====================================================================================
-- 4. Detalle de cursos: inscritos, cupo y profesor
--    Muestra cada curso, la materia, periodo, aula, cupo máximo y número de inscritos activos.
-- =====================================================================================
SELECT
    c.id           AS curso_id,
    m.codigo       AS codigo_materia,
    m.nombre       AS materia,
    c.periodo,
    c.aula,
    c.cupo_maximo,
    COUNT(i.id)    AS inscritos_activos,
    u.nombre + ' ' + u.apellido AS profesor
FROM Curso c
JOIN Materia m        ON c.materia_id = m.id
JOIN Profesor p       ON c.profesor_id = p.id
JOIN Usuario u        ON p.usuario_id = u.id
LEFT JOIN Inscripcion i 
     ON c.id = i.curso_id 
    AND i.estado = 'activa'
GROUP BY c.id, m.codigo, m.nombre, c.periodo, c.aula, c.cupo_maximo, u.nombre, u.apellido;
GO


-- =====================================================================================
-- 5. Detalle de inscripciones activas con calificaciones
--    Lista cada inscripción activa con datos de estudiante, curso y calificación (si existe).
-- =====================================================================================
SELECT
    i.id              AS inscripcion_id,
    u_e.nombre + ' ' + u_e.apellido AS estudiante,
    m.codigo          AS codigo_materia,
    m.nombre          AS materia,
    c.periodo,
    i.fecha_inscripcion,
    i.calificacion
FROM Inscripcion i
JOIN Estudiante e    ON i.estudiante_id = e.id
JOIN Usuario u_e     ON e.usuario_id = u_e.id
JOIN Curso c         ON i.curso_id = c.id
JOIN Materia m       ON c.materia_id = m.id
WHERE i.estado = 'activa'
ORDER BY u_e.apellido, u_e.nombre, m.codigo;
GO


-- =====================================================================================
-- 6. Ver materias disponibles
--    Muestra todas las materias registradas.
-- =====================================================================================
SELECT
    id,
    codigo,
    nombre,
    creditos,
    descripcion
FROM Materia
ORDER BY nombre;
GO


-- =====================================================================================
-- 7. Ver anuncios publicados
--    Muestra todos los anuncios con autor y fecha de publicación.
-- =====================================================================================
SELECT
    a.id           AS anuncio_id,
    a.titulo,
    a.contenido,
    a.fecha_publicacion,
    u.nombre + ' ' + u.apellido AS autor,
    u.rol         AS rol_autor
FROM Anuncio a
JOIN Usuario u ON a.usuario_id = u.id
ORDER BY a.fecha_publicacion DESC;
GO
