FROM oven/bun:1.3.9-alpine AS builder

WORKDIR /app

COPY package.json bun.lock bunfig.toml ./
COPY apps/api/package.json ./apps/api/
COPY apps/web/package.json ./apps/web/

RUN bun install --frozen-lockfile

COPY apps/web ./apps/web

ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL

RUN cd apps/web && bun run build

FROM oven/bun:1.3.9-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

COPY package.json bun.lock bunfig.toml ./
COPY apps/api/package.json ./apps/api/
COPY apps/web/package.json ./apps/web/

RUN bun install --frozen-lockfile --production

COPY --from=builder /app/apps/web/.next ./apps/web/.next
COPY --from=builder /app/apps/web/public ./apps/web/public

WORKDIR /app/apps/web

EXPOSE 3000

CMD ["bun", "run", "start"]
