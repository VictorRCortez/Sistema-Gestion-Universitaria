import pyodbc

# Configuración de la conexión a la base de datos
DB_CONFIG = {
    'driver': '{ODBC Driver 17 for SQL Server}',
    'server': 'localhost', # Tu nombre/dirección del servidor MSSQL
    'database': 'universidad_gestion_db', # Nombre de la base de datos
    'uid': 'prueba', # Nombre de usuario
    'pwd': 'prueba1234567P'  # Contraseña
}

# Función para obtener una conexión a la base de datos
def get_db_connection():
    try:
        conn = pyodbc.connect(
            f"DRIVER={DB_CONFIG['driver']};"
            f"SERVER={DB_CONFIG['server']};"
            f"DATABASE={DB_CONFIG['database']};"
            f"UID={DB_CONFIG['uid']};"
            f"PWD={DB_CONFIG['pwd']}"
        )
        return conn
    except Exception as e:
        print(f"Error al conectar a la base de datos: {e}")
        return None

# Función para ejecutar un procedimiento almacenado y obtener resultados
def execute_stored_procedure(procedure_name, params=None):
    conn = None
    cursor = None
    results = None
    try:
        conn = get_db_connection()
        if conn:
            cursor = conn.cursor()
            # Construir la llamada al procedimiento almacenado
            sql = f"EXEC {procedure_name}"
            if params:
                # Crear placeholders para los parámetros
                placeholders = ', '.join(['?'] * len(params))
                sql = f"EXEC {procedure_name} {placeholders}"
                cursor.execute(sql, tuple(params.values()))
            else:
                cursor.execute(sql)

            # Intentar obtener resultados si los hay
            try:
                results = cursor.fetchall()
                # Convertir resultados a lista de diccionarios para fácil manejo
                columns = [column[0] for column in cursor.description]
                results = [dict(zip(columns, row)) for row in results]
            except pyodbc.ProgrammingError:
                # No hay resultados (ej. UPDATE, INSERT sin SELECT)
                results = []
                conn.commit() # Confirmar cambios si no hay resultados

    except Exception as e:
        print(f"Error al ejecutar el procedimiento {procedure_name}: {e}")
        results = None # Indicar error

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()
    return results
