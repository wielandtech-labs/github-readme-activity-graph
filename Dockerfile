# Self-host image for github-readme-activity-graph (serves /graph on PORT).
# Built by .github/workflows/build-selfhost-image.yml and deployed by the
# wielandtech-labs/w_homelab repo next to github-readme-stats.
FROM node:22-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY tsconfig.json ./
COPY src ./src
RUN npx tsc -p tsconfig.json && test -f dist/main.js

FROM node:22-alpine
ENV NODE_ENV=production \
    PORT=5100
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --no-audit --no-fund && npm cache clean --force
COPY --from=build /app/dist ./dist
USER node
EXPOSE 5100
CMD ["node", "dist/main.js"]
