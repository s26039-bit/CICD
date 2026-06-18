# ── Stage 1: Build ──────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# 의존성 먼저 복사 (레이어 캐시 최적화)
COPY package*.json ./
RUN npm ci --only=production

# 소스 복사
COPY src/ ./src/

# ── Stage 2: Production ──────────────────────────────────────
FROM node:20-alpine AS production

# 보안: root가 아닌 유저로 실행
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY package*.json ./

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "src/app.js"]
