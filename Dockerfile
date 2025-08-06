FROM alpine:3.19 AS builder

RUN apk add --no-cache curl tar xz bash alpine-sdk \
                       nasm coreutils 

# Uncomment this line and add your compile-time headers here (*-dev packages)
# RUN apk add --no-cache ...

COPY . /build
WORKDIR /build

ENV FFMPEG_VERSION=7.1.1
ENV FFMPEG_SHA256=733984395e0dbbe5c046abda2dc49a5544e7e0e1e2366bba849222ae9e3a03b1
ENV FFMPEG_TAR_OUTDIR=/tmp
ENV SRCDIR=/usr/src
RUN ./meta/prep.sh

ENV PREFIX=/tmp/ffmpeg
RUN ./build.sh

FROM alpine:3.19 AS final
COPY --from=builder /tmp/ffmpeg/ /usr
# Uncomment this line and add your runtime libraries here
# RUN apk add --no-cache ...
