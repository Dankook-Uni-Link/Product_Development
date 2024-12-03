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


def execute_sql_from_file(connection, file_path):
    try:
        # 파일을 읽기
        with open(file_path, 'r') as file:
            sql_script = file.read()

        # 커서 생성
        cursor = connection.cursor()

        # SQL 스크립트 실행
        for statement in sql_script.split(';'):
            statement = statement.strip()
            if statement:
                cursor.execute(statement)
        
        # 변경 사항 커밋
        connection.commit()
        print("SQL script executed successfully.")
    except Error as e:
        print(f"Error executing SQL script: {e}")
    finally:
        cursor.close()


if __name__ == "__main__":
    # config.json에서 설정 불러오기
    config = load_config()

    # MySQL 서버에 연결
    db_connection = connect_to_database(config)
    
    if db_connection:
        execute_sql_from_file(db_connection, 'sql/question.sql')
        
        # 연결 종료
        close_connection(db_connection)
