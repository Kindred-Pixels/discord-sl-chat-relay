# Chainguard's Node images are built on Wolfi and provide a minimal,
# non-root runtime image with a development variant for dependency builds.
FROM cgr.dev/chainguard/node:latest-dev@sha256:dcb7cf99cf3eaf95bad12812e4233a2b534e464a277611287c3392d2171d662c AS dependencies
WORKDIR /app
COPY package.json package-lock.json ./
# The lockfile contains a pinned GitHub dependency required by node-metaverse.
RUN npm ci --omit=dev --allow-git=all && npm cache clean --force

FROM cgr.dev/chainguard/node:latest@sha256:753a66014b1310b8f93c76d4cac41d039958b9a86dd44a245289d6cb85455582
WORKDIR /app
ENV NODE_ENV=production

COPY --from=dependencies /app/node_modules ./node_modules
COPY index.js package.json ./
# Supply /app/config.js at runtime; only the non-secret example is packaged.
COPY config.js.example ./config.js.example
COPY DscEvents ./DscEvents
COPY DscSlash ./DscSlash
COPY SLevents ./SLevents
COPY modules ./modules

# Chainguard's runtime image uses UID 65532 but has no symbolic "nonroot" entry.
USER 65532
CMD ["index.js"]
