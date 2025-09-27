FROM node:22-alpine AS builder

RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

COPY pnpm-lock.yaml ./
COPY package.json ./
COPY scripts/preinstall.ts scripts/preinstall.ts

RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm run build

FROM node:22-alpine AS prod

LABEL org.opencontainers.image.url="https://bettergov.ph"
LABEL org.opencontainers.image.source="https://github.com/bettergovph/healthcare-providers-api"
LABEL org.opencontainers.image.authors="volunteers@bettergov.ph,root@guerzon.net"

RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

COPY --from=builder /app/dist ./dist

EXPOSE 3000
CMD ["pnpm", "run", "start:prod"]