# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.22

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Playcations version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="playcations"

ENV S6_STAGE2_HOOK="/init-hook"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    jpeg-dev \
    libffi-dev \
    libxml2-dev \
    libxslt-dev \
    mariadb-dev \
    postgresql-dev \
    python3-dev \
    zlib-dev && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    jpeg \
    libffi \
    libpq \
    libxml2 \
    libxslt \
    mariadb-connector-c \
    python3 && \
  echo "**** install babybuddy ****" && \
  curl -o \
    /tmp/babybuddy.tar.gz -L \
    "https://github.com/playcations/babybuddy/archive/refs/heads/master.tar.gz" && \
  mkdir -p /app/www/public && \
  tar xf \
    /tmp/babybuddy.tar.gz -C \
    /app/www/public --strip-components=1 && \
  cd /app/www/public && \
  python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.22/ \
    -r requirements.txt && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.22/ \
    mysqlclient && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    $HOME/.cargo

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8000
VOLUME /config
