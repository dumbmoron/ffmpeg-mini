FROM alpine:3.19 AS builder

RUN apk add --no-cache curl tar xz bash alpine-sdk \
                       nasm coreutils 

# compile-time header/development files
RUN apk add --no-cache dav1d-dev lame-dev opus-dev libvorbis-dev \
                       openssl-dev libvpx-dev

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
# runtime libraries
RUN apk add --no-cache libdav1d lame-dev libopusenc \
                       libvorbis openssl libvpx