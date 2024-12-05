# flutter survey application

플러터 앱 개발 가이드라인입니다.

## 목차

- [디렉토리 설명](#디렉토리-설명)
- [설치 방법](#설치-방법)
- [실행 방법](#실행-방법)
- [디버깅](#디버깅)
- [라이센스](#라이센스)

## 디렉토리 설명

1. `frontend` - 앱 관련 코드
2. `backend` - 백엔드 서버 코드
3. `database` - 데이터베이스 관련 파일

자세한 설명은 `docs` 폴더를 참고해주세요.

## 설치 방법

깃 클론:
```bash
git clone https://<개인 키>@github.com/Dankook-Uni-Link/Product_Development.git
```

깃 풀로 변경사항 업데이트:
```bash
git pull origin master
```

사용자 설정:
```bash
git config --global user.email "???@gmail.com"
git config --global user.name "???"
```

브랜치 설정:
```bash
git branch -a
git branch -M ???
```


## 실행 방법

1. `flutter run` - 플러터 앱 실행 (localhost:???)
2. `node server.js` - 백엔드 서버 실행 (localhost:3000)
3. 로컬 DB 서버 실행 (localhost:3306)

## 디버깅

- **HTTP 요청 에러 - CORS 문제**:
  - CORS(Cross-Origin Resource Sharing) 문제는 주로 클라이언트와 서버 간 도메인이 다를 때 발생합니다.
  - 해결 방법:
    - 백엔드 서버에서 CORS 미들웨어를 추가하여 외부 요청을 허용합니다. (예: Express.js의 `cors` 패키지 사용)
    - 서버 코드에 `app.use(cors())`를 추가하여 모든 출처에서의 요청을 허용합니다.

## 라이센스

프로젝트 라이센스: MIT 라이센스
