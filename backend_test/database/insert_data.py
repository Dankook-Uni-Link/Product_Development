import os
from connect_db import connect_to_database

def execute_sql_file(filename):
    connection = connect_to_database()
    cursor = connection.cursor()

    sql_file_path = os.path.join("sql", filename)

    with open(sql_file_path, "r") as file:
        sql_commands = file.read().split(';')
        for command in sql_commands:
            if command.strip():
                cursor.execute(command)

    connection.commit()
    cursor.close()
    connection.close()
    print(f"Executed {filename} successfully.")

# 테스트 실행
if __name__ == "__main__":
    # 테이블 생성
    execute_sql_file("create_users_table.sql")
    # 유저 데이터 삽입
    execute_sql_file("insert_users.sql")

