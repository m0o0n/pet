FROM oven/bun:1.3.9-alpine AS builder

WORKDIR /app

# Copy workspace manifests first for better layer caching
COPY package.json bun.lock bunfig.toml ./
COPY apps/api/package.json ./apps/api/
COPY apps/web/package.json ./apps/web/

RUN bun install --frozen-lockfile

COPY apps/web ./apps/web

RUN cd apps/web && bun run build


FROM node:22-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

# standalone contains the minimal server + bundled dependencies
COPY --from=builder /app/apps/web/.next/standalone ./
# static assets are not included in standalone, must be copied separately
COPY --from=builder /app/apps/web/.next/static ./apps/web/.next/static
COPY --from=builder /app/apps/web/public ./apps/web/public

EXPOSE 3000

CMD ["node", "apps/web/server.js"]
