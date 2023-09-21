##########################
# Cache-preserving image #
##########################
FROM alpine:3.15 AS deps

RUN apk --no-cache add jq

# prevent cache invalidation from changes in fields other than dependencies
COPY package.json .
COPY package-lock.json .

# override the current package version (arbitrarily set to 1.0.0) so it doesn't invalidate the build cache later
RUN (jq '{ dependencies, devDependencies }') < package.json > deps.json
RUN (jq '.version = "1.0.0"' | jq '.packages."".version = "1.0.0"') < package-lock.json > deps-lock.json

#################
# Builder image #
#################
FROM node:20.6-bullseye-slim AS builder

ENV WORKING_DIR=/usr/src/app
WORKDIR ${WORKING_DIR}

COPY --from=deps deps.json ./package.json
COPY --from=deps deps-lock.json ./package-lock.json
RUN npm ci --omit=dev
COPY package.json .

####################
# Production image #
####################
FROM node:20.6-bullseye-slim AS executer

# Define ARGS, ENV and LABEL
ARG VCS_REF
ARG BUILD_DATE
ARG app_service_port1=3002
ARG app_service_port2=9229
ENV WORKING_DIR=/usr/src/app

LABEL maintainer="jmbg" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.docker.dockerfile="/Dockerfile"

# EXPOSE ports application
EXPOSE ${app_service_port1}
EXPOSE ${app_service_port2}

# Define Working_dir
WORKDIR ${WORKING_DIR}
COPY --from=builder --chown=node:node ${WORKING_DIR} ${WORKING_DIR}
COPY --chown=node:node app ./app

# RUN Application whith specific user
USER node

# RUN Application using dumb-init
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD sh -c 'if [ "$DEBUG_NODEJS" = true ]; then node --inspect app/server/server.js; else node app/server/server.js; fi'

