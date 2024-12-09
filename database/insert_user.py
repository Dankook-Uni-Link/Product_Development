import json
import mysql.connector
from mysql.connector import Error
from connect_db import load_config, connect_to_database, close_connection
import os

# 사용자 데이터를 DB에 삽입하는 함수
def insert_user_data(connection, user_data):
    cursor = connection.cursor()
    
    # 1. 사용자 정보 삽입
    user_query = """
        INSERT INTO users (username, password, email, gender, birthdate)
        VALUES (%s, %s, %s, %s, %s)
    """
    user_values = (
        user_data['username'],
        user_data['password'],
        user_data['email'],
        user_data['gender'],
        user_data['birthdate']
    )
    cursor.execute(user_query, user_values)
    
    # 커밋하여 데이터 반영
    connection.commit()

# main 함수
def main():
    # 설정 파일 로드
    config = load_config()
    
    # DB 연결
    connection = connect_to_database(config)
    if connection is None:
        return
    
    # 1.json 파일을 읽어서 사용자 데이터를 삽입
    file_path = 'data_user/1.json'
    
    # 파일이 존재하는지 확인
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as file:
            user_data_list = json.load(file)
        
            # 각 사용자 데이터를 삽입
            for user_data in user_data_list:
                insert_user_data(connection, user_data)
                print(f"{file_path}의 사용자 데이터 삽입이 완료되었습니다.")
    else:
        print(f"{file_path} 파일이 존재하지 않습니다.")
    
    close_connection(connection)

if __name__ == "__main__":
    main()
