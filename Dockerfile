# ── Stage 1: Build ──────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# 의존성 파일 먼저 복사 (레이어 캐시 최적화)
COPY package*.json ./

# 의존성 설치 (빌드/배포에 필요한 전체 의존성 설치)
RUN npm ci

# 소스 코드 복사
COPY src/ ./src/

# (선택 사항) 만약 TS나 번들러를 쓰신다면 여기에 빌드 명령어를 넣으세요.
# RUN npm run build

# 프로덕션 의존성만 남기기 위해 불필요한 devDependencies 제거
RUN npm prune --production


# ── Stage 2: Production ──────────────────────────────────────
FROM node:20-alpine AS production

WORKDIR /app

# Alpine 내장 wget 대신 안전한 헬스체크를 위해 curl 설치
RUN apk add --no-cache curl

# builder 스테이지에서 결과물만 복사
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY package*.json ./

# Node 공식 이미지에 내장된 'node' 유저 사용 (보안 적용)
USER node

EXPOSE 3000

# curl을 사용한 안정적인 헬스체크
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["node", "src/app.js"]
