import json
import mysql.connector
from mysql.connector import Error

def load_config():
    with open('config.json', 'r') as file:
        config = json.load(file)
    return config

def connect_to_database(config):
    try:
        # 데이터베이스 없는 상태로 MySQL 서버에 연결
        connection = mysql.connector.connect(
            host=config['host'],
            port=config['port'],
            user=config['username'],
            password=config['password']
        )
        cursor = connection.cursor()

        # 데이터베이스 생성
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {config['database']}")
        print(f"Database '{config['database']}' created or already exists.")
        
        # 커넥션 및 커서 닫기
        cursor.close()
        connection.close()

        # 새로 생성된 데이터베이스에 연결
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
    
def close_connection(connection):
    if connection.is_connected():
        connection.close()
        print("MySQL connection closed")


if __name__ == "__main__":
    # 설정 불러오기
    config = load_config()
    # 데이터베이스 연결 (필요 시 자동 생성)
    connection = connect_to_database(config)
    close_connection(connection)