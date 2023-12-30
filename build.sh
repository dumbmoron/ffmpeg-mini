#!/bin/bash
set -e

if [ "x$TMP_DIR" = x ]; then
    [ "x$PREFIX" = x ] && echo "need tmpdir or PREFIX" >&2 && exit 1
    [ "x$SRCDIR" = x ] && echo "need tmpdir or SRCDIR" >&2 && exit 1
fi

[ "x$PREFIX" = x ] && PREFIX="$TMP_DIR/build"
[ "x$SRCDIR" = x ] && SRCDIR="$TMP_DIR"

## For a more in-depth explanation of what these flags do,
## see the `configure` script within ffmpeg (run
## ./configure --help for help with options).
CONFIGURE_ARGS=(
    --prefix="$PREFIX"
## LICENSING OPTIONS
    --enable-gpl
    --enable-version3
    # --enable-nonfree

## CONFIGURATION OPTIONS
    --fatal-warnings
    --optflags="-O3"
    --disable-static
    --enable-shared
    # --enable-small
    # --disable-runtime-cpudetect
    # --enable-gray
    # --disable-swscale-alpha
    # --disable-all
    --disable-autodetect
    --disable-debug
    --enable-pic
    --enable-lto=auto
    --enable-postproc

## BINARY OPTIONS
    # --disable-programs
    # --disable-ffmpeg
    --disable-ffplay
    # --disable-ffprobe

## DOCUMENTATION OPTIONS
    --disable-doc

## FFMPEG COMPONENTS
    --disable-avdevice
    # --disable-avcodec
    # --disable-avformat
    # --disable-swresample
    --disable-swscale
    --disable-postproc
    # --disable-avfilter
    # --disable-network
    # --disable-dwt
    # --disable-error-resilience
    # --disable-lsp
    # --disable-faan
    # --disable-pixelutils

## INDIVIDUAL COMPONENT OPTIONS
    --disable-everything
## `enable`s are configured by ENABLE_COMPONENT_ARGS
## which is controlled by ./config/* files

## EXTERNAL LIBRARIES
## you will probably need to change the `apk` packages
## in the Dockerfile if you enable/disable anything here.
    --disable-alsa
    --disable-appkit
    --disable-avfoundation
    # --enable-avisynth
    --disable-bzlib
    --disable-coreimage
    # --enable-chromaprint
    # --enable-frei0r
    # --enable-gcrypt
    # --enable-gmp
    # --enable-gnutls
    --disable-iconv
    # --enable-jni
    # --enable-ladspa
    # --enable-lcms2
    # --enable-libaom
    # --enable-libaribb24
    # --enable-libaribcaption
    # --enable-libass
    # --enable-libbluray
    # --enable-libbs2b
    # --enable-libcaca
    # --enable-libcelt
    # --enable-libcdio
    # --enable-libcodec2
    # --enable-libdav1d
    # --enable-libdavs2
    # --enable-libdc1394
    # --enable-libfdk-aac
    # --enable-libflite
    # --enable-libfontconfig
    # --enable-libfreetype
    # --enable-libfribidi
    # --enable-libharfbuzz
    # --enable-libglslang
    # --enable-libgme
    # --enable-libgsm
    # --enable-libiec61883
    # --enable-libilbc
    # --enable-libjack
    # --enable-libjxl
    # --enable-libklvanc
    # --enable-libkvazaar
    # --enable-liblensfun
    # --enable-libmodplug
    # --enable-libmp3lame
    # --enable-libopencore-amrnb
    # --enable-libopencore-amrwb
    # --enable-libopencv
    # --enable-libopenh264
    # --enable-libopenjpeg
    # --enable-libopenmpt
    # --enable-libopenvino
    # --enable-libopus
    # --enable-libplacebo
    # --enable-libpulse
    # --enable-librabbitmq
    # --enable-librav1e
    # --enable-librist
    # --enable-librsvg
    # --enable-librubberband
    # --enable-librtmp
    # --enable-libshaderc
    # --enable-libshine
    # --enable-libsmbclient
    # --enable-libsnappy
    # --enable-libsoxr
    # --enable-libspeex
    # --enable-libsrt
    # --enable-libssh
    # --enable-libsvtav1
    # --enable-libtensorflow
    # --enable-libtesseract
    # --enable-libtheora
    # --enable-libtls
    # --enable-libtwolame
    # --enable-libuavs3d
    # --enable-libv4l2
    # --enable-libvidstab
    # --enable-libvmaf
    # --enable-libvo-amrwbenc
    # --enable-libvorbis
    # --enable-libvpx
    # --enable-libwebp
    # --enable-libx264
    # --enable-libx265
    # --enable-libxavs
    # --enable-libxavs2
    # --enable-libxcb
    # --enable-libxcb-shm
    # --enable-libxcb-xfixes
    # --enable-libxcb-shape
    # --enable-libxvid
    # --enable-libxml2
    # --enable-libzimg
    # --enable-libzmq
    # --enable-libzvbi
    # --enable-lv2
    # --disable-lzma
    # --enable-decklink
    # --enable-mbedtls
    # --enable-mediacodec
    # --enable-mediafoundation
    --disable-metal
    # --enable-libmysofa
    # --enable-openal
    # --enable-opencl
    # --enable-opengl
    # --enable-openssl
    # --enable-pocketsphinx
    --disable-sndio
    --disable-schannel
    --disable-sdl2
    --disable-securetransport
    # --enable-vapoursynth
    --disable-xlib
    --disable-zlib

## HARDWARE ACCELERATION
## enabling the vast majority of these will most likely
## be useless within a docker container
    --disable-amf
    --disable-audiotoolbox
    # --enable-cuda-nvcc
    --disable-cuda-llvm
    --disable-cuvid
    --disable-d3d11va
    --disable-dxva2
    --disable-ffnvcodec
    # --enable-libdrm
    # --enable-libmfx
    # --enable-libvpl
    # --enable-libnpp
    # --enable-mmal
    --disable-nvdec
    --disable-nvenc
    # --enable-omx
    # --enable-omx-rpi
    # --enable-rkmpp
    --disable-v4l2-m2m
    --disable-vaapi
    --disable-vdpau
    --disable-videotoolbox
    --disable-vulkan
)

# https://stackoverflow.com/a/53839647
join() {
  local IFS="$1"
  shift
  echo "$*"
}

ENABLE_COMPONENT_ARGS=()
for type in bsf decoder muxer demuxer encoder decoder \
            filter hwaccel indev outdev parser protocol; do
    . ./config/${type}s.sh
    WANT_VARNAME="WANT_${type^^}S"
    WANT_VALUES=$(eval 'join , "${'"$WANT_VARNAME"'[@]}"')

    if [ "x$WANT_VALUES" != x ]; then
        ENABLE_COMPONENT_ARGS+=("--enable-$type=$WANT_VALUES")
    fi
done

ROOTDIR=$(git rev-parse --show-toplevel)
mkdir -p "$SRCDIR/ffmpeg"  \
    && cd "$SRCDIR/ffmpeg" \
    && ./configure "${CONFIGURE_ARGS[@]}" "${ENABLE_COMPONENT_ARGS[@]}" \
    && make -j $(nproc) \
    && make install