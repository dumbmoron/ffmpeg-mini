FROM alpine:3.19 AS builder

RUN apk add --no-cache curl tar xz bash alpine-sdk \
                       nasm coreutils 

# Uncomment this line and add your compile-time headers here (*-dev packages)
# RUN apk add --no-cache ...

COPY . /build
WORKDIR /build

ENV FFMPEG_VERSION=7.1
ENV FFMPEG_SHA256=40973d44970dbc83ef302b0609f2e74982be2d85916dd2ee7472d30678a7abe6
ENV FFMPEG_TAR_OUTDIR=/tmp
ENV SRCDIR=/usr/src
RUN ./meta/prep.sh

ENV PREFIX=/tmp/ffmpeg
RUN ./build.sh

FROM alpine:3.19 AS final
COPY --from=builder /tmp/ffmpeg/ /usr
# Uncomment this line and add your runtime libraries here
# RUN apk add --no-cache ...
