# ── Stage 1: Build ──────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# 캐시 최적화를 위해 의존성 파일만 먼저 복사
COPY package*.json ./

# npm ci 대신 안정적인 npm install 사용 (--legacy-peer-deps로 충돌 방지)
RUN npm install --legacy-peer-deps

# 소스 코드 복사
COPY src/ ./src/

# 프로덕션에 불필요한 개발용 패키지(devDependencies) 제거로 용량 최적화
RUN npm prune --production


# ── Stage 2: Production ──────────────────────────────────────
FROM node:20-alpine AS production

WORKDIR /app

# 안전한 헬스체크를 위해 curl 설치
RUN apk add --no-cache curl

# builder 스테이지에서 빌드된 결과물만 깔끔하게 복사
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY package*.json ./

# Node 공식 이미지에 내장된 안전한 일반 유저(node)로 실행
USER node

EXPOSE 3000

# curl 기반의 안정적인 헬스체크 구문
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["node", "src/app.js"]
