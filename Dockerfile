FROM alpine:3.19 AS builder

RUN apk add --no-cache curl tar xz bash alpine-sdk \
                       nasm coreutils 

# Uncomment this line and add your compile-time headers here (*-dev packages)
# RUN apk add --no-cache ...

COPY . /build
WORKDIR /build

ENV FFMPEG_VERSION=8.0
ENV FFMPEG_SHA256=b2751fccb6cc4c77708113cd78b561059b6fa904b24162fa0be2d60273d27b8e
ENV FFMPEG_TAR_OUTDIR=/tmp
ENV SRCDIR=/usr/src
RUN ./meta/prep.sh

ENV PREFIX=/tmp/ffmpeg
RUN ./build.sh

FROM alpine:3.19 AS final
COPY --from=builder /tmp/ffmpeg/ /usr
# Uncomment this line and add your runtime libraries here
# RUN apk add --no-cache ...
