import os
from dotenv import load_dotenv
import mysql.connector

# .env 파일 로드
load_dotenv()

def connect_to_database():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASS"),
        database=os.getenv("DB_NAME")
    )