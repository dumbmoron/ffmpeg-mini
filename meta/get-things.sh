#!/bin/bash
## Some parts of this script copied from the ffmpeg
## `configure` script and modified, licensed under LGPLv2.1
set -e

find_things_extern() {
    out=${4:-$1}
    sed -n "s/^[^#]*extern.*$2 *ff_\([^ ]*\)_$1;/\1_$out/p" "$3"
}

find_filters_extern() {
    sed -n 's/^extern const AVFilter ff_[avfsinkrc]\{2,5\}_\([[:alnum:]_]\{1,\}\);/\1_filter/p' $1
}

find_things() {
    DECODER_LIST=$(find_things_extern decoder FFCodec libavcodec/allcodecs.c)
    ENCODER_LIST=$(find_things_extern encoder FFCodec libavcodec/allcodecs.c)

    HWACCEL_LIST=$(find_things_extern hwaccel FFHWAccel libavcodec/hwaccels.h)

    MUXER_LIST=$(find_things_extern muxer FFOutputFormat libavformat/allformats.c)
    DEMUXER_LIST=$(find_things_extern demuxer AVInputFormat libavformat/allformats.c)

    PARSER_LIST=$(find_things_extern parser AVCodecParser libavcodec/parsers.c)
    PROTOCOL_LIST=$(find_things_extern protocol URLProtocol libavformat/protocols.c)
    BSF_LIST=$(find_things_extern bsf FFBitStreamFilter libavcodec/bitstream_filters.c)
    INDEV_LIST=$(find_things_extern demuxer AVInputFormat libavdevice/alldevices.c indev)
    OUTDEV_LIST=$(find_things_extern muxer FFOutputFormat libavdevice/alldevices.c outdev)

    FILTER_LIST=$(find_filters_extern libavfilter/allfilters.c)
}

cleanup() {
    if [ "x$TMP_DIR" != x ]; then
        rm -rf "$TMP_DIR"
        cd - >/dev/null
    fi
}

die() {
    echo "fail: $1" >&2
    cleanup
    exit 1
}

ROOTDIR=$(git rev-parse --show-toplevel)
TMP_DIR=$(mktemp -d)

"$(dirname "$0")/prep.sh"
cd "$TMP_DIR/ffmpeg" || die "could not enter tmpdir"

find_things

import() {
    mkdir -p "$ROOTDIR/config/"
    FILE_PATH="$ROOTDIR/config/${1}s.sh"
    if [ ! -f "$FILE_PATH" ]; then
        echo "WANT_${1^^}S=(" > "$FILE_PATH"
        echo ")" >> "$FILE_PATH"
    fi

    echo "$2" | $ROOTDIR/meta/update-config.py "$ROOTDIR/config" "$1"
}

import bsf      "$BSF_LIST"
import muxer    "$MUXER_LIST"
import indev    "$INDEV_LIST"
import outdev   "$OUTDEV_LIST"
import filter   "$FILTER_LIST"
import parser   "$PARSER_LIST"
import decoder  "$DECODER_LIST"
import encoder  "$ENCODER_LIST"
import hwaccel  "$ENCODER_LIST"
import demuxer  "$DEMUXER_LIST"
import protocol "$PROTOCOL_LIST"