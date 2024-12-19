DB structure 그대로 사용하면 됨 - survey_structure.sql 파일

mysql command line client에서

    ->CREATE DATABASE survey_db;
  
    ->USE survey_db;

일반 터미널에서

    ->"C:\Program Files\MySQL\MySQL Server 9.1\bin\mysql" -u root -p survey_db < survey_structure.sql
![image](https://github.com/user-attachments/assets/ba3c84bb-4f0a-48a5-a629-b4799a1c82ff)



# Survey Application API Documentation

## Authentication

### Sign Up
- **Endpoint**: `POST /auth/signup`
- **Description**: 새로운 사용자 계정을 생성합니다.
- **Request Body**:
  ```json
  {
    "email": "string",
    "password": "string",
    "name": "string",
    "birthDate": "YYYY-MM-DD",
    "gender": "string",
    "location": "string",
    "occupation": "string"
  }
  ```
- **Response**: 
  - Success (201):
    ```json
    {
      "id": "number",
      "email": "string",
      "name": "string",
      "birth_date": "YYYY-MM-DD",
      "gender": "string",
      "location": "string",
      "occupation": "string",
      "created_at": "timestamp",
      "current_points": "number",
      "activities": {
        "participated_surveys": []
      }
    }
    ```
  - Error (400):
    ```json
    {
      "message": "모든 필드를 입력해주세요",
      "missingFields": ["field1", "field2"]
    }
    ```
    또는
    ```json
    {
      "message": "이미 존재하는 이메일입니다."
    }
    ```
  - Error (500):
    ```json
    {
      "message": "회원가입 처리 중 오류가 발생했습니다.",
      "error": "error message"
    }
    ```

### Login
- **Endpoint**: `POST /auth/login`
- **Description**: 사용자 로그인을 처리합니다.
- **Request Body**:
  ```json
  {
    "email": "string",
    "password": "string"
  }
  ```
- **Response**:
  - Success (200):
    ```json
    {
      "token": "string",
      "user": {
        "id": "number",
        "email": "string",
        "name": "string",
        "birth_date": "YYYY-MM-DD",
        "gender": "string",
        "location": "string",
        "occupation": "string",
        "created_at": "timestamp"
      }
    }
    ```
  - Error (401):
    ```json
    {
      "message": "이메일 또는 비밀번호가 일치하지 않습니다."
    }
    ```
  - Error (500):
    ```json
    {
      "message": "Login failed"
    }
    ```

## Surveys

### Get All Surveys
- **Endpoint**: `GET /surveys`
- **Description**: 모든 설문 목록을 조회합니다.
- **Response**:
  - Success (200):
    ```json
    [
      {
        "id": "number",
        "creator_id": "number",
        "creator_name": "string",
        "title": "string",
        "description": "string",
        "questions": "array",
        "reward_amount": "number",
        "target_responses": "number",
        "current_responses": "number",
        "response_count": "number",
        "created_at": "timestamp",
        "target_conditions": {
          "ageRanges": "array",
          "genders": "array",
          "locations": "array",
          "occupations": "array"
        }
      }
    ]
    ```
  - Error (500):
    ```json
    {
      "success": false,
      "message": "설문 목록을 불러오는데 실패했습니다."
    }
    ```

### Get Survey by ID
- **Endpoint**: `GET /survey/:id`
- **Description**: 특정 설문의 상세 정보를 조회합니다.
- **Response**:
  - Success (200):
    ```json
    {
      "id": "number",
      "creator_id": "number",
      "creator_name": "string",
      "title": "string",
      "description": "string",
      "questions": "array",
      "reward_amount": "number",
      "target_responses": "number",
      "current_responses": "number",
      "created_at": "timestamp",
      "target_conditions": {
        "ageRanges": "array",
        "genders": "array",
        "locations": "array",
        "occupations": "array"
      }
    }
    ```
  - Error (404):
    ```json
    {
      "success": false,
      "message": "설문을 찾을 수 없습니다."
    }
    ```
  - Error (500):
    ```json
    {
      "success": false,
      "message": "설문을 불러오는데 실패했습니다."
    }
    ```

### Create Survey
- **Endpoint**: `POST /surveys`
- **Request Body**:
  ```json
  {
    "creatorId": "number",
    "title": "string",
    "description": "string",
    "questions": "array",
    "rewardAmount": "number",
    "targetResponses": "number",
    "targetConditions": {
      "ageRanges": "array",
      "genders": "array",
      "locations": "array",
      "occupations": "array"
    }
  }
  ```
- **Response**:
  - Success (201):
    ```json
    {
      "success": true,
      "id": "number"
    }
    ```
  - Error (500):
    ```json
    {
      "success": false,
      "message": "Failed to create survey",
      "error": "error message"
    }
    ```

### Participate in Survey
- **Endpoint**: `POST /surveys/:surveyId/participate`
- **Request Body**:
  ```json
  {
    "userId": "number",
    "responses": {
      "questionId": ["answer1", "answer2"]
    }
  }
  ```
- **Response**:
  - Success (200):
    ```json
    {
      "success": true,
      "message": "설문 참여가 완료되었습니다.",
      "points": {
        "earned": "number"
      }
    }
    ```
  - Error (400):
    ```json
    {
      "success": false,
      "message": "이미 참여한 설문입니다."
    }
    ```
  - Error (500):
    ```json
    {
      "success": false,
      "message": "참여 처리 중 오류가 발생했습니다.",
      "error": "error message"
    }
    ```

### Get Survey Statistics
- **Endpoint**: `GET /survey/:id/stats`
- **Response**:
  - Success (200):
    ```json
    {
      "success": true,
      "surveyId": "number",
      "title": "string",
      "totalResponses": "number",
      "rewardAmount": "number",
      "summary": {
        "totalResponses": "number",
        "lastUpdated": "timestamp"
      },
      "questions": {
        "questionId": {
          "responses": {
            "answer1": "number",
            "answer2": "number"
          }
        }
      }
    }
    ```
  - Error (404):
    ```json
    {
      "success": false,
      "message": "설문을 찾을 수 없습니다."
    }
    ```
  - Error (500):
    ```json
    {
      "success": false,
      "message": "통계를 불러오는데 실패했습니다.",
      "error": "error message"
    }
    ```

## User

### Get User Surveys
- **Endpoint**: `GET /users/:userId/surveys`
- **Response**:
  - Success (200):
    ```json
    [
      {
        "id": "number",
        "title": "string",
        "description": "string",
        "created_at": "timestamp",
        "response_count": "number",
        "reward_amount": "number",
        "target_responses": "number",
        "current_responses": "number"
      }
    ]
    ```
  - Error (500):
    ```json
    {
      "success": false,
      "message": "설문 목록을 불러오는데 실패했습니다."
    }
    ```

### Get User Activities
- **Endpoint**: `GET /users/:userId/activities`
- **Response**:
  - Success (200):
    ```json
    {
      "participated_surveys": [
        {
          "survey_id": "number",
          "participated_at": "timestamp",
          "survey_title": "string",
          "response_data": "object"
        }
      ],
      "created_surveys": [
        {
          "survey_id": "number",
          "created_at": "timestamp",
          "title": "string"
        }
      ]
    }
    ```
  - Error (500):
    ```json
    {
      "success": false,
      "message": "활동 내역을 불러오는데 실패했습니다."
    }
    ```

## Points

### Get Point History
- **Endpoint**: `GET /users/:userId/points/history`
- **Response**:
  - Success (200):
    ```json
    [
      {
        "id": "number",
        "points": "number",
        "title": "string",
        "type": "string(earn|use)",
        "created_at": "timestamp"
      }
    ]
    ```
  - Error (500):
    ```json
    {
      "success": false,
      "message": "포인트 내역을 불러오는데 실패했습니다.",
      "error": "error message"
    }
    ```

### Get Current Points
- **Endpoint**: `GET /users/:userId/points/current`
- **Response**:
  - Success (200):
    ```json
    {
      "success": true,
      "currentPoints": "number"
    }
    ```
  - Error (404):
    ```json
    {
      "success": false,
      "message": "포인트 정보를 찾을 수 없습니다."
    }
    ```
  - Error (500):
    ```json
    {
      "success": false,
      "message": "현재 포인트를 불러오는데 실패했습니다.",
      "error": "error message"
    }
    ```

## Gifticons

### Get Gifticon List
- **Endpoint**: `GET /gifticons`
- **Response**:
  - Success (200):
    ```json
    [
      {
        "id": "number",
        "name": "string",
        "description": "string",
        "price": "number",
        "image_url": "string",
        "created_at": "timestamp"
      }
    ]
    ```
  - Error (500):
    ```json
    {
      "success": false,
      "message": "기프티콘 목록을 불러오는데 실패했습니다."
    }
    ```
