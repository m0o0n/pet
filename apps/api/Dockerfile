FROM oven/bun:1.3.9-alpine

WORKDIR /app

COPY package.json bun.lock bunfig.toml ./
COPY apps/api/package.json ./apps/api/
COPY apps/web/package.json ./apps/web/

RUN bun install --frozen-lockfile

COPY apps/api ./apps/api

RUN cd apps/api && bunx prisma generate --schema=prisma/schema/schema.prisma
RUN cd apps/api && bun run build

WORKDIR /app/apps/api

ENV NODE_ENV=production

EXPOSE 8080

CMD ["node", "dist/src/main.js"]
