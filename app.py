from flask import Flask, redirect, url_for, session

# Importar los Blueprints de las rutas
from routes.auth import auth_bp
from routes.student import student_bp
from routes.professor import professor_bp
from routes.admin import admin_bp
from routes.announcements import announcements_bp

app = Flask(__name__)
app.secret_key = 'unversity_secret_key' # Clave secreta para la sesión

# Registrar los Blueprints
app.register_blueprint(auth_bp)
app.register_blueprint(student_bp, url_prefix='/student') # Prefijo para rutas de estudiante
app.register_blueprint(professor_bp, url_prefix='/professor') # Prefijo para rutas de profesor
app.register_blueprint(admin_bp, url_prefix='/admin') # Prefijo para rutas de admin
app.register_blueprint(announcements_bp)

# Ruta raíz que redirige al login
@app.route('/')
def index():
    """Redirige a la página de login."""
    return redirect(url_for('auth.main')) # Redirige a la ruta 'login' dentro del blueprint 'auth'

# añadir más rutas si es necesario acá

if __name__ == '__main__':
    # Para ejecutar la aplicación: python app.py
    # Esto iniciará el servidor web de desarrollo de Flask
    app.run(debug=True) # debug=True recarga el servidor automáticamente con los cambios
