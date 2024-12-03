import json
import mysql.connector
from mysql.connector import Error
import os

# 기존 DB 연결 함수
def load_config():
    with open('config.json', 'r', encoding='utf-8') as file:
        config = json.load(file)
    return config

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

# 설문 데이터를 DB에 삽입하는 함수
def insert_survey_data(connection, survey_data):
    cursor = connection.cursor()
    
    # 1. 설문 정보 삽입
    survey_query = """
        INSERT INTO survey (survey_title, survey_description, total_questions, reward, target_number, winning_number, price)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """
    survey_values = (
        survey_data['surveyTitle'],
        survey_data['surveyDescription'],
        survey_data['totalQuestions'],
        survey_data['reward'],
        survey_data['Target_number'],
        survey_data['winning_number'],
        survey_data['price']
    )
    cursor.execute(survey_query, survey_values)
    survey_id = cursor.lastrowid  # 삽입된 survey의 ID를 얻기

    # 2. 질문들 삽입
    for question_data in survey_data['questions']:
        question_query = """
            INSERT INTO questions (survey_id, question, question_type)
            VALUES (%s, %s, %s)
        """
        question_values = (
            survey_id,
            question_data['question'],
            question_data['type']
        )
        cursor.execute(question_query, question_values)
        question_id = cursor.lastrowid  # 삽입된 question의 ID를 얻기

        # 3. 선택지들 삽입
        for option in question_data['options']:
            option_query = """
                INSERT INTO options (question_id, option_text)
                VALUES (%s, %s)
            """
            option_values = (question_id, option)
            cursor.execute(option_query, option_values)
    
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
    
    # 1.json부터 10.json까지 파일을 순차적으로 읽어들여 데이터 삽입
    for i in range(1, 11):  # 1부터 10까지
        file_path = f'data/{i}.json'
        
        # 파일이 존재하는지 확인
        if os.path.exists(file_path):
            with open(file_path, 'r', encoding='utf-8') as file:
                survey_data = json.load(file)
            
            # 데이터 삽입
            insert_survey_data(connection, survey_data)
            print(f"{file_path} 데이터 삽입이 완료되었습니다.")
        else:
            print(f"{file_path} 파일이 존재하지 않습니다.")
    
    connection.close()

if __name__ == "__main__":
    main()
