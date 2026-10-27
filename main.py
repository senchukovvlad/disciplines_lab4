import os
from typing import List
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import psycopg2
from psycopg2.extras import RealDictCursor

app = FastAPI(title="Disciplines API")

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "disciplines_db")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASS = os.getenv("DB_PASS", "postgres")
DB_PORT = os.getenv("DB_PORT", "5432")


def get_db_connection():
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASS,
            port=DB_PORT,
            cursor_factory=RealDictCursor,
        )
        return conn
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection error: {e}")


class DisciplineSchema(BaseModel):
    name: str
    number_of_hours: int


@app.get("/")
def read_root():
    return {"message": "Disciplines API is running"}


@app.get("/disciplines", response_model=list[dict])
def get_disciplines():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id, name, number_of_hours FROM disciplines;")
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return rows


@app.post("/disciplines", status_code=201)
def create_discipline(discipline: DisciplineSchema):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO disciplines (name, number_of_hours) VALUES (%s, %s) RETURNING id;",
        (discipline.name, discipline.number_of_hours),
    )
    new_id = cursor.fetchone()["id"]
    conn.commit()
    cursor.close()
    conn.close()
    return {"id": new_id, "name": discipline.name, "number_of_hours": discipline.number_of_hours}