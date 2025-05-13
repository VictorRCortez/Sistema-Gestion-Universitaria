# Sistema de Gestión Universitaria

Este proyecto es una aplicación web desarrollada con **Flask** y **SQL Server**, diseñada para gestionar cursos, inscripciones, usuarios (estudiantes, profesores y administradores) y anuncios institucionales.

---

## Estructura del Proyecto

/gestión_universitaria/
│
├── pycache/ # Archivos compilados automáticamente
├── routes/ # Blueprints con rutas por rol
│ ├── auth.py # Login/Logout
│ ├── admin.py # Funciones para admin
│ ├── announcements.py # Gestión de anuncios
│ ├── student.py # Funciones del estudiante
│ ├── profesor.py # Funciones del profesor
│
├── scripts MSSQL/ # Scripts para base de datos
│ ├── universidad_gestion_db(creacion).sql
│ ├── universidad_gestion_db(consultas).sql
│
├── static/ # Recursos estáticos
│ ├── css/
│ │ └── style.css
│ ├── js/
│ └── script.js
│
├── templates/ # Plantillas HTML (Jinja2)
│ ├── admin/
│ ├── professor/
│ ├── students/
│
├── app.py # Punto de entrada de la aplicación
├── database.py # Conexión y ejecución de procedimientos almacenados

---

## Requisitos

- Python 3.10+
- SQL Server (Express o superior)
- [ODBC Driver 17 para SQL Server]

Instala dependencias:
pip install flask pyodbc
pip install -r requirements.txt

---

## Cómo Ejecutar la Aplicación

Base de Datos:

Ejecuta universidad_gestion_db(creacion).sql para crear toda la estructura de la base de datos.

Verifica el usuario prueba (o crea uno si es necesario con los permisos adecuados).

Configuración de conexión:

Edita database.py con tus credenciales de SQL Server si no usas localhost / prueba.

Ejecutar Flask:

python app.py

Accede desde tu navegador a: http://localhost:5000/login

👤 Usuarios Iniciales
Rol Email Contraseña
Admin admin@universidad.edu admin123
Estudiante juan@universidad.edu 123456
Profesor maria@universidad.edu 123456
