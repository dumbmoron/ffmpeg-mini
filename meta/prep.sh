#!/bin/bash
set -ex
die() {
    echo "prep: $1" >&2
    exit 1
}

[ "x$FFMPEG_VERSION" = x ] && die "no ffmpeg version (FFMPEG_VERSION) is set"
[ "x$FFMPEG_SHA256" = x ] && die "no ffmpeg tarball checksum (FFMPEG_SHA256) is set"

if [ "x$FFMPEG_TAR_OUTDIR" = x ]; then
    [ "x$TMP_DIR" = x ] && die "tmpdir is not set"
    FFMPEG_TAR_OUTDIR="$TMP_DIR"
fi

if [ "x$SRCDIR" = x ]; then
    [ "x$TMP_DIR" = x ] && die "tmpdir is not set"
    SRCDIR="$TMP_DIR"
fi

FFMPEG_TAR_PATH="$FFMPEG_TAR_OUTDIR/ffmpeg.tar.xz"

curl "https://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.xz" \
     -o "$FFMPEG_TAR_PATH"

echo "$FFMPEG_SHA256 $FFMPEG_TAR_PATH" | sha256sum -c
mkdir -p "$SRCDIR/ffmpeg/"
tar xvf "$FFMPEG_TAR_PATH" -C "$SRCDIR/ffmpeg/" --strip-components=1