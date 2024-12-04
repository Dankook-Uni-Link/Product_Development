import json
import mysql.connector
from mysql.connector import Error

# pip install mysql-connector-python
# python connect_db.py
# config.json 파일에서 데이터베이스 설정을 읽어오기

def load_config():
    with open('config.json', 'r') as file:
        config = json.load(file)
    return config

# MySQL 데이터베이스에 연결
def connect_to_database(config):
    try:
        connection = mysql.connector.connect(
            host=config['host'],
            port=config['port'],
            user=config['username'],
            password=config['password'],
            database=config['database']
        )
        
        if connection.is_connected():
            print("MySQL database connection successful")
            return connection
    except Error as e:
        print(f"Error: {e}")
        return None

# 데이터베이스 연결 종료
def close_connection(connection):
    if connection.is_connected():
        connection.close()
        print("MySQL connection closed")
