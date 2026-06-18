# 🚀 CI/CD Demo — Docker + GitHub Actions + 학교 서버

## 📁 프로젝트 구조

```
cicd-demo/
├── .github/
│   └── workflows/
│       └── cicd.yml        # GitHub Actions 파이프라인
├── src/
│   └── app.js              # Express 앱
├── Dockerfile              # 멀티스테이지 빌드
├── docker-compose.yml      # 서버 배포용
├── package.json
└── .gitignore
```

## ⚙️ GitHub Secrets 설정

GitHub 레포 → Settings → Secrets and variables → Actions 에서 등록:

| Secret 이름 | 설명 | 예시 |
|---|---|---|
| `DOCKERHUB_USERNAME` | Docker Hub 아이디 | `myusername` |
| `DOCKERHUB_TOKEN` | Docker Hub Access Token | `dckr_pat_xxx...` |
| `SERVER_HOST` | 학교 서버 IP 또는 도메인 | `203.xxx.xxx.xxx` |
| `SERVER_USER` | SSH 접속 유저명 | `ubuntu` |
| `SERVER_SSH_KEY` | SSH 개인키 (PEM 전체 내용) | `-----BEGIN...` |
| `SERVER_PORT` | SSH 포트 (기본 22) | `22` |

## 🔑 SSH 키 생성 방법

```bash
# 1. 키 생성 (로컬에서)
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github_actions

# 2. 공개키를 학교 서버에 등록
ssh-copy-id -i ~/.ssh/github_actions.pub user@학교서버IP

# 3. 개인키 내용을 복사해서 SERVER_SSH_KEY 에 붙여넣기
cat ~/.ssh/github_actions
```

## 🔄 CI/CD 파이프라인 흐름

```
git push main
    │
    ▼
[GitHub Actions]
    │
    ├─ JOB 1: Build
    │   ├─ Docker 이미지 빌드 (멀티스테이지)
    │   └─ Docker Hub에 Push (sha-xxxxx, latest 태그)
    │
    └─ JOB 2: Deploy (Build 성공 시)
        └─ SSH → 학교 서버
            ├─ docker pull latest
            ├─ docker compose up -d
            └─ 이전 이미지 정리
```

## 🖥️ 학교 서버 초기 세팅

```bash
# Docker 설치 (Ubuntu 기준)
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# 배포 디렉토리 + docker-compose.yml 준비
mkdir -p ~/cicd-demo
# docker-compose.yml을 서버에 복사하거나 직접 작성
```

## 🚀 로컬 실행

```bash
npm install
npm start
# http://localhost:3000
```

## 🐳 Docker로 로컬 실행

```bash
docker build -t cicd-demo .
docker run -p 3000:3000 cicd-demo
```

## 📡 API 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| GET | `/` | 앱 정보 |
| GET | `/health` | 헬스체크 |
| GET | `/api/items` | 샘플 데이터 |
