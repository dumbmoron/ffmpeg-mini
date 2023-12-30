FROM alpine:3.19 AS builder

RUN apk add --no-cache curl tar xz bash alpine-sdk \
                       nasm coreutils 

# Uncomment this line and add your compile-time headers here (*-dev packages)
# RUN apk add --no-cache ...

COPY . /build
WORKDIR /build

ENV FFMPEG_VERSION=6.1
ENV FFMPEG_SHA256=488c76e57dd9b3bee901f71d5c95eaf1db4a5a31fe46a28654e837144207c270
ENV FFMPEG_TAR_OUTDIR=/tmp
ENV SRCDIR=/usr/src
RUN ./meta/prep.sh

ENV PREFIX=/tmp/ffmpeg
RUN ./build.sh

FROM alpine:3.19 AS final
COPY --from=builder /tmp/ffmpeg/ /usr
# Uncomment this line and add your runtime libraries here
# RUN apk add --no-cache ...
