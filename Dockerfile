FROM node:10 as builder

LABEL version="2.0.0"
LABEL description="Example Fastify (Node.js) webapp Docker Image"
LABEL maintainer="Sandro Martini <sandro.martini@gmail.com>"

# set a non privileged user to use when running this image
RUN groupadd -r nodejs && useradd -g nodejs -s /bin/bash -d /home/nodejs -m nodejs
USER nodejs
# set right (secure) folder permissions
RUN mkdir -p /home/nodejs/app/node_modules && chown -R nodejs:nodejs /home/nodejs/app

WORKDIR /home/nodejs/app

# set default node env
ARG NODE_ENV=development
# ARG NODE_ENV=production
# to be able to run tests (for example in CI), do not set production as environment
ENV NODE_ENV=${NODE_ENV}

ENV NPM_CONFIG_LOGLEVEL=warn

# copy project definition/dependencies files, for better reuse of layers
COPY package*.json ./

# install dependencies here, for better reuse of layers
RUN npm install

# copy all sources in the container (exclusions in .dockerignore file)
COPY --chown=nodejs:nodejs . .

# build/pack binaries from sources ...


# This results in a single layer image
# FROM scratch AS release
# COPY --from=builder /dist /dist

EXPOSE 8000

# add an healthcheck, useful
# healthcheck with curl, but not recommended
# HEALTHCHECK CMD curl --fail http://localhost:8000/health || exit 1
# healthcheck by calling the additional script exposed by the plugin
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s CMD npm run healthcheck-manual

# ENTRYPOINT [ "npm" ]
# CMD [ "npm", "start" ]
CMD [ "node", "./src/server" ]

# end.
