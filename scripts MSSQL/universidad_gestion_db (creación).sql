CREATE DATABASE universidad_gestion_db;
GO

USE universidad_gestion_db;
GO

-- #### LOGIN DE APLICACIÓN: desactivar expiración de contraseña ####
ALTER LOGIN [prueba]
    WITH CHECK_EXPIRATION = OFF;    -- desactiva la expiración de la contraseña
GO

-- #### TABLAS PRINCIPALES ####
CREATE TABLE Usuario (
    id INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    contrasena VARCHAR(100) NOT NULL,
    rol VARCHAR(20) NOT NULL CHECK (rol IN ('estudiante', 'profesor', 'admin')),
    activo BIT DEFAULT 1,
    fecha_registro DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Estudiante (
    id INT PRIMARY KEY IDENTITY(1,1),
    num_matricula VARCHAR(20) UNIQUE NOT NULL,
    carrera VARCHAR(100),
    semestre INT,
    usuario_id INT NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES Usuario(id)
);
GO

CREATE TABLE Profesor (
    id INT PRIMARY KEY IDENTITY(1,1),
    num_empleado VARCHAR(20) UNIQUE NOT NULL,
    departamento VARCHAR(100),
    titulo VARCHAR(50),
    usuario_id INT NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES Usuario(id)
);
GO

CREATE TABLE Materia (
    id INT PRIMARY KEY IDENTITY(1,1),
    codigo VARCHAR(10) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    creditos INT NOT NULL,
    descripcion VARCHAR(500)
);
GO

CREATE TABLE Curso (
    id INT PRIMARY KEY IDENTITY(1,1),
    materia_id INT NOT NULL,
    profesor_id INT NOT NULL,
    periodo VARCHAR(20) NOT NULL,
    cupo_maximo INT DEFAULT 30,
    dias_clase VARCHAR(50),
    horario VARCHAR(50),
    aula VARCHAR(20),
    activo BIT DEFAULT 1,
    FOREIGN KEY (materia_id) REFERENCES Materia(id),
    FOREIGN KEY (profesor_id) REFERENCES Profesor(id)
);
GO

CREATE TABLE Inscripcion (
    id INT PRIMARY KEY IDENTITY(1,1),
    estudiante_id INT NOT NULL,
    curso_id INT NOT NULL,
    fecha_inscripcion DATETIME DEFAULT GETDATE(),
    estado VARCHAR(20) DEFAULT 'activa',
    calificacion DECIMAL(4,2),
    FOREIGN KEY (estudiante_id) REFERENCES Estudiante(id),
    FOREIGN KEY (curso_id) REFERENCES Curso(id),
    CONSTRAINT UQ_Inscripcion UNIQUE (estudiante_id, curso_id)
);
GO

CREATE TABLE Anuncio (
    id INT PRIMARY KEY IDENTITY(1,1),
    titulo VARCHAR(100) NOT NULL,
    contenido VARCHAR(1000) NOT NULL,
    fecha_publicacion DATETIME DEFAULT GETDATE(),
    usuario_id INT NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES Usuario(id)
);
GO

-- #### INSERCIÓN DE DATOS INICIALES ####
-- Usuarios
INSERT INTO Usuario (nombre, apellido, email, contrasena, rol) VALUES
('Admin', 'Sistema', 'admin@universidad.edu', 'admin123', 'admin'),
('Juan', 'Pérez', 'juan@universidad.edu', '123456', 'estudiante'),
('María', 'Gómez', 'maria@universidad.edu', '123456', 'profesor'),
('Pedro', 'Rodríguez', 'pedro@universidad.edu', '123456', 'estudiante'),
('Ana', 'Martínez', 'ana@universidad.edu', '123456', 'profesor');
GO

-- Estudiantes
INSERT INTO Estudiante (num_matricula, carrera, semestre, usuario_id) VALUES
('E001', 'Ingeniería de Sistemas', 5, 2),
('E002', 'Administración de Empresas', 3, 4);
GO

-- Profesores
INSERT INTO Profesor (num_empleado, departamento, titulo, usuario_id) VALUES
('P001', 'Ciencias de la Computación', 'PhD', 3),
('P002', 'Administración', 'Maestría', 5);
GO

-- Materias
INSERT INTO Materia (codigo, nombre, creditos, descripcion) VALUES
('PROG101', 'Programación I', 4, 'Fundamentos de programación y algoritmos'),
('BD201', 'Bases de Datos', 3, 'Diseño y gestión de bases de datos relacionales'),
('EST301', 'Estructuras de Datos', 4, 'Algoritmos y estructuras de datos avanzados'),
('ADM101', 'Introducción a la Administración', 3, 'Conceptos básicos de administración de empresas'),
('MAT101', 'Matemáticas Básicas', 4, 'Álgebra y cálculo básico');
GO

-- Cursos
INSERT INTO Curso (materia_id, profesor_id, periodo, cupo_maximo, dias_clase, horario, aula) VALUES
(1, 1, '2025-1', 25, 'Lunes, Miércoles', '08:00-10:00', 'A101'),
(2, 1, '2025-1', 20, 'Martes, Jueves', '10:00-12:00', 'B202'),
(3, 1, '2025-2', 15, 'Viernes', '14:00-18:00', 'C303'),
(4, 2, '2025-1', 30, 'Lunes, Miércoles', '14:00-16:00', 'D404'),
(5, 2, '2025-1', 35, 'Martes, Jueves', '16:00-18:00', 'E505');
GO

-- Inscripciones
INSERT INTO Inscripcion (estudiante_id, curso_id) VALUES
(1, 1),
(1, 2),
(2, 4),
(2, 5);
GO

-- Anuncios
INSERT INTO Anuncio (titulo, contenido, usuario_id) VALUES
('Bienvenidos al Semestre 2025-1', 'Estimados estudiantes y profesores, les damos la bienvenida al nuevo semestre. Les deseamos éxitos en sus actividades académicas.', 1),
('Mantenimiento del Sistema', 'El sistema estará en mantenimiento el próximo domingo de 8:00 a 12:00. Disculpen las molestias.', 1);
GO

-- #### PROCEDIMIENTOS ALMACENADOS ####

-- Login
CREATE PROCEDURE VerificarLogin
    @email VARCHAR(100),
    @contrasena VARCHAR(100)
AS
BEGIN
    SELECT id, nombre, apellido, email, rol
    FROM Usuario
    WHERE email = @email AND contrasena = @contrasena AND activo = 1;
END;
GO

-- Obtener información básica del usuario
CREATE PROCEDURE ObtenerUsuario
    @id INT
AS
BEGIN
    SELECT id, nombre, apellido, email, rol
    FROM Usuario
    WHERE id = @id;
END;
GO

-- Obtener información de estudiante
CREATE PROCEDURE ObtenerPerfilEstudiante
    @usuario_id INT
AS
BEGIN
    SELECT u.id, u.nombre, u.apellido, u.email, e.num_matricula, e.carrera, e.semestre, e.id AS estudiante_id
    FROM Usuario u
    JOIN Estudiante e ON u.id = e.usuario_id
    WHERE u.id = @usuario_id;
END;
GO

-- Obtener información de profesor
CREATE PROCEDURE ObtenerPerfilProfesor
    @usuario_id INT
AS
BEGIN
    SELECT u.id, u.nombre, u.apellido, u.email, p.num_empleado, p.departamento, p.titulo, p.id AS profesor_id
    FROM Usuario u
    JOIN Profesor p ON u.id = p.usuario_id
    WHERE u.id = @usuario_id;
END;
GO

-- Obtener ID por rol (estudiante o profesor)
CREATE PROCEDURE ObtenerIdPorRol
    @usuario_id INT
AS
BEGIN
    DECLARE @rol VARCHAR(20);
    SELECT @rol = rol FROM Usuario WHERE id = @usuario_id;
    
    IF @rol = 'estudiante'
        SELECT id AS tipo_id FROM Estudiante WHERE usuario_id = @usuario_id;
    ELSE IF @rol = 'profesor'
        SELECT id AS tipo_id FROM Profesor WHERE usuario_id = @usuario_id;
    ELSE
        SELECT 0 AS tipo_id;
END;
GO

-- Listar todos los cursos disponibles
CREATE PROCEDURE ListarCursosDisponibles
AS
BEGIN
    SELECT c.id, m.codigo, m.nombre AS materia, m.creditos,
           u.nombre + ' ' + u.apellido AS profesor, 
           c.periodo, c.dias_clase, c.horario, c.aula,
           c.cupo_maximo,
           (SELECT COUNT(*) FROM Inscripcion i WHERE i.curso_id = c.id) AS inscritos
    FROM Curso c
    JOIN Materia m ON c.materia_id = m.id
    JOIN Profesor p ON c.profesor_id = p.id
    JOIN Usuario u ON p.usuario_id = u.id
    WHERE c.activo = 1;
END;
GO

-- Obtener cursos de un estudiante
CREATE PROCEDURE ObtenerCursosEstudiante
    @estudiante_id INT
AS
BEGIN
    SELECT c.id, m.codigo, m.nombre AS materia, m.creditos,
           u.nombre + ' ' + u.apellido AS profesor,
           c.periodo, c.dias_clase, c.horario, c.aula,
           i.fecha_inscripcion, i.calificacion, i.id AS inscripcion_id
    FROM Inscripcion i
    JOIN Curso c ON i.curso_id = c.id
    JOIN Materia m ON c.materia_id = m.id
    JOIN Profesor p ON c.profesor_id = p.id
    JOIN Usuario u ON p.usuario_id = u.id
    WHERE i.estudiante_id = @estudiante_id AND i.estado = 'activa';
END;
GO

-- Inscribirse a un curso
CREATE PROCEDURE InscribirCurso
    @estudiante_id INT,
    @curso_id INT
AS
BEGIN
    BEGIN TRY
        DECLARE @cupo_disponible BIT = 0;
        
        -- Verificar si hay cupo
        IF (SELECT cupo_maximo FROM Curso WHERE id = @curso_id) > 
           (SELECT COUNT(*) FROM Inscripcion WHERE curso_id = @curso_id AND estado = 'activa')
            SET @cupo_disponible = 1;
            
        IF @cupo_disponible = 1
        BEGIN
            INSERT INTO Inscripcion (estudiante_id, curso_id)
            VALUES (@estudiante_id, @curso_id);
            SELECT 1 AS resultado, 'Inscripción exitosa' AS mensaje;
        END
        ELSE
            SELECT 0 AS resultado, 'No hay cupo disponible' AS mensaje;
    END TRY
    BEGIN CATCH
        SELECT 0 AS resultado, ERROR_MESSAGE() AS mensaje;
    END CATCH
END;
GO

-- Dar de baja curso
CREATE PROCEDURE DarBajaCurso
    @inscripcion_id INT
AS
BEGIN
    BEGIN TRY
        UPDATE Inscripcion SET estado = 'baja' WHERE id = @inscripcion_id;
        SELECT 1 AS resultado, 'Baja procesada exitosamente' AS mensaje;
    END TRY
    BEGIN CATCH
        SELECT 0 AS resultado, ERROR_MESSAGE() AS mensaje;
    END CATCH
END;
GO

-- Obtener cursos de un profesor
CREATE PROCEDURE ObtenerCursosProfesor
    @profesor_id INT
AS
BEGIN
    SELECT c.id, m.codigo, m.nombre AS materia, m.creditos,
           c.periodo, c.dias_clase, c.horario, c.aula,
           c.cupo_maximo,
           (SELECT COUNT(*) FROM Inscripcion i WHERE i.curso_id = c.id AND i.estado = 'activa') AS estudiantes_inscritos
    FROM Curso c
    JOIN Materia m ON c.materia_id = m.id
    WHERE c.profesor_id = @profesor_id AND c.activo = 1;
END;
GO

-- Obtener estudiantes de un curso
CREATE PROCEDURE ObtenerEstudiantesCurso
    @curso_id INT
AS
BEGIN
    SELECT e.id AS estudiante_id, u.nombre, u.apellido, e.num_matricula, e.carrera,
           i.fecha_inscripcion, i.calificacion, i.id AS inscripcion_id
    FROM Inscripcion i
    JOIN Estudiante e ON i.estudiante_id = e.id
    JOIN Usuario u ON e.usuario_id = u.id
    WHERE i.curso_id = @curso_id AND i.estado = 'activa'
    ORDER BY u.apellido, u.nombre;
END;
GO

-- Asignar calificación
CREATE PROCEDURE AsignarCalificacion
    @inscripcion_id INT,
    @calificacion DECIMAL(4,2)
AS
BEGIN
    BEGIN TRY
        IF @calificacion >= 0 AND @calificacion <= 10
        BEGIN
            UPDATE Inscripcion SET calificacion = @calificacion WHERE id = @inscripcion_id;
            SELECT 1 AS resultado, 'Calificación asignada correctamente' AS mensaje;
        END
        ELSE
            SELECT 0 AS resultado, 'La calificación debe estar entre 0 y 10' AS mensaje;
    END TRY
    BEGIN CATCH
        SELECT 0 AS resultado, ERROR_MESSAGE() AS mensaje;
    END CATCH
END;
GO

-- Listar usuarios para admin
CREATE PROCEDURE ListarUsuarios
    @rol VARCHAR(20) = NULL
AS
BEGIN
    IF @rol IS NULL
        SELECT id, nombre, apellido, email, rol, activo, fecha_registro
        FROM Usuario
        ORDER BY rol, apellido, nombre;
    ELSE
        SELECT id, nombre, apellido, email, rol, activo, fecha_registro
        FROM Usuario
        WHERE rol = @rol
        ORDER BY apellido, nombre;
END;
GO

-- Listar materias para admin
CREATE PROCEDURE ListarMaterias
AS
BEGIN
    SELECT id, codigo, nombre, creditos, descripcion
    FROM Materia
    ORDER BY nombre;
END;
GO

-- Crear/actualizar materia
CREATE PROCEDURE GuardarMateria
    @id INT = NULL,
    @codigo VARCHAR(10),
    @nombre VARCHAR(100),
    @creditos INT,
    @descripcion VARCHAR(500) = NULL
AS
BEGIN
    BEGIN TRY
        IF @id IS NULL OR @id = 0
        BEGIN
            INSERT INTO Materia (codigo, nombre, creditos, descripcion)
            VALUES (@codigo, @nombre, @creditos, @descripcion);
            SELECT SCOPE_IDENTITY() AS id, 1 AS resultado, 'Materia creada correctamente' AS mensaje;
        END
        ELSE
        BEGIN
            UPDATE Materia
            SET codigo = @codigo,
                nombre = @nombre,
                creditos = @creditos,
                descripcion = @descripcion
            WHERE id = @id;
            SELECT @id AS id, 1 AS resultado, 'Materia actualizada correctamente' AS mensaje;
        END
    END TRY
    BEGIN CATCH
        SELECT 0 AS id, 0 AS resultado, ERROR_MESSAGE() AS mensaje;
    END CATCH
END;
GO

-- Crear/actualizar curso
CREATE PROCEDURE GuardarCurso
    @id INT = NULL,
    @materia_id INT,
    @profesor_id INT,
    @periodo VARCHAR(20),
    @cupo_maximo INT,
    @dias_clase VARCHAR(50),
    @horario VARCHAR(50),
    @aula VARCHAR(20)
AS
BEGIN
    BEGIN TRY
        IF @id IS NULL OR @id = 0
        BEGIN
            INSERT INTO Curso (materia_id, profesor_id, periodo, cupo_maximo, dias_clase, horario, aula)
            VALUES (@materia_id, @profesor_id, @periodo, @cupo_maximo, @dias_clase, @horario, @aula);
            SELECT SCOPE_IDENTITY() AS id, 1 AS resultado, 'Curso creado correctamente' AS mensaje;
        END
        ELSE
        BEGIN
            UPDATE Curso
            SET materia_id = @materia_id,
                profesor_id = @profesor_id,
                periodo = @periodo,
                cupo_maximo = @cupo_maximo,
                dias_clase = @dias_clase,
                horario = @horario,
                aula = @aula
            WHERE id = @id;
            SELECT @id AS id, 1 AS resultado, 'Curso actualizado correctamente' AS mensaje;
        END
    END TRY
    BEGIN CATCH
        SELECT 0 AS id, 0 AS resultado, ERROR_MESSAGE() AS mensaje;
    END CATCH
END;
GO

-- Crear/actualizar usuario (incluyendo estudiante o profesor)
CREATE PROCEDURE GuardarUsuario
    @id INT = NULL,
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @email VARCHAR(100),
    @contrasena VARCHAR(100) = NULL,
    @rol VARCHAR(20),
    @num_matricula VARCHAR(20) = NULL,
    @carrera VARCHAR(100) = NULL,
    @semestre INT = NULL,
    @num_empleado VARCHAR(20) = NULL,
    @departamento VARCHAR(100) = NULL,
    @titulo VARCHAR(50) = NULL
AS
BEGIN
    BEGIN TRY
        DECLARE @usuario_id INT;
        IF @id IS NULL OR @id = 0
        BEGIN
            INSERT INTO Usuario (nombre, apellido, email, contrasena, rol)
            VALUES (@nombre, @apellido, @email, @contrasena, @rol);
            SET @usuario_id = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            SET @usuario_id = @id;
            IF @contrasena IS NOT NULL AND @contrasena <> ''
                UPDATE Usuario SET nombre=@nombre, apellido=@apellido, email=@email, contrasena=@contrasena, rol=@rol WHERE id=@usuario_id;
            ELSE
                UPDATE Usuario SET nombre=@nombre, apellido=@apellido, email=@email, rol=@rol WHERE id=@usuario_id;
        END
        IF @rol='estudiante'
        BEGIN
            DECLARE @estudiante_id INT;
            SELECT @estudiante_id=id FROM Estudiante WHERE usuario_id=@usuario_id;
            IF @estudiante_id IS NULL
                INSERT INTO Estudiante(num_matricula,carrera,semestre,usuario_id) VALUES(@num_matricula,@carrera,@semestre,@usuario_id);
            ELSE
                UPDATE Estudiante SET num_matricula=@num_matricula,carrera=@carrera,semestre=@semestre WHERE usuario_id=@usuario_id;
        END
        IF @rol='profesor'
        BEGIN
            DECLARE @profesor_id INT;
            SELECT @profesor_id=id FROM Profesor WHERE usuario_id=@usuario_id;
            IF @profesor_id IS NULL
                INSERT INTO Profesor(num_empleado,departamento,titulo,usuario_id) VALUES(@num_empleado,@departamento,@titulo,@usuario_id);
            ELSE
                UPDATE Profesor SET num_empleado=@num_empleado,departamento=@departamento,titulo=@titulo WHERE usuario_id=@usuario_id;
        END
        SELECT @usuario_id AS id, 1 AS resultado, 'Usuario guardado correctamente' AS mensaje;
    END TRY
    BEGIN CATCH
        SELECT 0 AS id, 0 AS resultado, ERROR_MESSAGE() AS mensaje;
    END CATCH
END;
GO

-- Obtener anuncios recientes
CREATE PROCEDURE ObtenerAnuncios
AS
BEGIN
    SELECT a.id, a.titulo, a.contenido, a.fecha_publicacion,
           u.nombre+' '+u.apellido AS autor, u.rol
    FROM Anuncio a
    JOIN Usuario u ON a.usuario_id=u.id
    ORDER BY a.fecha_publicacion DESC;
END;
GO

-- Crear anuncio
CREATE PROCEDURE CrearAnuncio
    @titulo VARCHAR(100),
    @contenido VARCHAR(1000),
    @usuario_id INT
AS
BEGIN
    BEGIN TRY
        INSERT INTO Anuncio(titulo,contenido,usuario_id) VALUES(@titulo,@contenido,@usuario_id);
        SELECT SCOPE_IDENTITY() AS id,1 AS resultado,'Anuncio publicado correctamente' AS mensaje;
    END TRY
    BEGIN CATCH
        SELECT 0 AS id,0 AS resultado, ERROR_MESSAGE() AS mensaje;
    END CATCH
END;
GO

-- Deshabilitar/Habilitar Usuario
CREATE PROCEDURE CambiarEstadoUsuario
    @usuario_id INT,
    @activo BIT
AS
BEGIN
    BEGIN TRY
        UPDATE Usuario SET activo=@activo WHERE id=@usuario_id;
        IF @activo=1 SELECT 1 AS resultado,'Usuario habilitado correctamente' AS mensaje;
        ELSE SELECT 1 AS resultado,'Usuario deshabilitado correctamente' AS mensaje;
    END TRY
    BEGIN CATCH
        SELECT 0 AS resultado,ERROR_MESSAGE() AS mensaje;
    END CATCH
END;
GO

-- Deshabilitar/Habilitar Curso
CREATE PROCEDURE CambiarEstadoCurso
    @curso_id INT,
    @activo BIT
AS
BEGIN
    BEGIN TRY
        UPDATE Curso SET activo=@activo WHERE id=@curso_id;
        IF @activo=1 SELECT 1 AS resultado,'Curso habilitado correctamente' AS mensaje;
        ELSE SELECT 1 AS resultado,'Curso deshabilitado correctamente' AS mensaje;
    END TRY
    BEGIN CATCH
        SELECT 0 AS resultado,ERROR_MESSAGE() AS mensaje;
    END CATCH
END;
GO
