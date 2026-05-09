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

FROM node:22-alpine AS runner

WORKDIR /app/apps/web

ENV NODE_ENV=production

COPY --from=builder /app/node_modules /app/node_modules
COPY --from=builder /app/apps/web/.next ./.next
COPY --from=builder /app/apps/web/public ./public
COPY --from=builder /app/apps/web/next.config.ts ./next.config.ts
COPY --from=builder /app/apps/web/package.json ./package.json

EXPOSE 3000

CMD ["node", "/app/node_modules/.bin/next", "start"]
