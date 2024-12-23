# Use the official Bun image
# see all versions at https://hub.docker.com/r/oven/bun/tags
FROM oven/bun:1.1.38-alpine AS base
WORKDIR /usr/src/app

# Install dependencies into temp directory
# This will cache them and speed up future builds
FROM base AS install
RUN mkdir -p /temp/dev
COPY package.json bun.lockb /temp/dev/
RUN cd /temp/dev && bun install --frozen-lockfile

# Install with --production (exclude devDependencies)
RUN mkdir -p /temp/prod
COPY package.json bun.lockb /temp/prod/
RUN cd /temp/prod && bun install --frozen-lockfile --production

# Copy node_modules from temp directory
# Then copy all (non-ignored) project files into the image
FROM base AS prerelease
COPY --from=install /temp/dev/node_modules node_modules
COPY ./src ./src
COPY ./package.json .
COPY ./tsconfig.json .
COPY ./conf/entrypoint.sh .

# Copy production dependencies and source code into final image
FROM base AS release
COPY --from=install /temp/prod/node_modules /node_modules
COPY --from=prerelease /usr/src/app/src ./src
COPY --from=prerelease /usr/src/app/package.json .
COPY --from=prerelease /usr/src/app/tsconfig.json .
COPY --from=prerelease /usr/src/app/entrypoint.sh .

# Ensure entrypoint.sh has execution permission
RUN chmod +x /usr/src/app/entrypoint.sh

# Run the app
USER bun
EXPOSE 3000
ENTRYPOINT [ "sh", "./entrypoint.sh" ]
