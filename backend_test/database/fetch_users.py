from connect_db import connect_to_database

def fetch_all_users():
    connection = connect_to_database()
    cursor = connection.cursor(dictionary=True)  # 데이터를 딕셔너리 형태로 반환

    # users 테이블 조회
    cursor.execute("SELECT * FROM users")
    users = cursor.fetchall()

    cursor.close()
    connection.close()
    return users

if __name__ == "__main__":
    users = fetch_all_users()
    for user in users:
        print(user)

