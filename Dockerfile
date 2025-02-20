# Build stage
FROM node:lts-alpine as build

RUN apk update; \
  apk add git;
WORKDIR /tmp
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Release stage
FROM node:lts-alpine as release
VOLUME /parse-server/cloud /parse-server/config

WORKDIR /parse-server

COPY package*.json ./
COPY postinstall.js ./

RUN npm ci --production

COPY bin bin
COPY public_html public_html
COPY views views
COPY --from=build /tmp/lib lib
RUN mkdir -p logs && chown -R node: logs

ENV PORT=1337
USER node
EXPOSE $PORT

ENTRYPOINT ["node", "./bin/parse-server"]
