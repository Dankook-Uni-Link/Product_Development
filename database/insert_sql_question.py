import json
from connect_db import load_config, connect_to_database, close_connection
from mysql.connector import Error


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
