import os, time, string, random
import psycopg2
from psycopg2 import sql
from datetime import datetime

# Подключение к БД
conn = psycopg2.connect(
    dbname=os.getenv("POSTGRES_DB"),
    user=os.getenv("POSTGRES_USER"),
    password=os.getenv("POSTGRES_PASSWORD"),
    host="db"
)

# Генерирование данных
def generate_data():
    data = ''.join(random.choices(string.ascii_lowercase + string.digits, k=10))
    date = datetime.now()
    return (data, date)

# Вставка данных
def insert_data(conn, data):
    cur = conn.cursor()
    insert = sql.SQL("INSERT INTO test (data, date) VALUES (%s, %s)")
    cur.execute(insert, data)
    conn.commit()
    cur.close()

# Отчистка данных 
def clean_data(conn):
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM test")
    count = cur.fetchone()[0]
    if count >= 30:
        cur.execute("DELETE FROM test")

        # Если нужно отчистить таблицу и сбросить счётчик id
        # cur.execute("TRUNCATE TABLE test RESTART IDENTITY")

        conn.commit()
    cur.close()

while True:
    data = generate_data()
    insert_data(conn, data)
    clean_data(conn)
    print(f"Inserted data: {data}")
    time.sleep(10)