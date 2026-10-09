
from flask import Flask, render_template, request, redirect, url_for
import os
import psycopg2
from psycopg2.extras import RealDictCursor

app = Flask(__name__)


def get_db_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        database=os.getenv("DB_NAME", "devopsdb"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASSWORD", "postgres"),
        port=os.getenv("DB_PORT", "5432")
    )


@app.route("/")
def home():
    connection = get_db_connection()

    try:
        with connection.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute(
                "SELECT id, title, completed FROM tasks ORDER BY id"
            )
            tasks = cursor.fetchall()

        return render_template("index.html", tasks=tasks)
    finally:
        connection.close()


@app.route("/health")
def health():
    return {
        "status": "healthy",
        "application": "DevOps Dashboard"
    }


@app.route("/db-test")
def db_test():
    try:
        with get_db_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT version()")
                version = cursor.fetchone()[0]

        return {
            "status": "success",
            "database": "PostgreSQL",
            "version": version
        }
    except Exception:
        app.logger.exception("Database connection failed")
        return {"status": "failed", "error": "Database connection failed"}, 500


@app.route("/add-task", methods=["POST"])
def add_task():
    title = request.form.get("title", "").strip()

    if not title or len(title) > 200:
        return "Task title must contain 1–200 characters", 400

    with get_db_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                "INSERT INTO tasks (title) VALUES (%s)",
                (title,)
            )

    return redirect(url_for("home"))


@app.route("/complete-task/<int:task_id>", methods=["POST"])
def complete_task(task_id):
    with get_db_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                "UPDATE tasks SET completed = TRUE WHERE id = %s",
                (task_id,)
            )

    return redirect(url_for("home"))


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)