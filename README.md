# ffmpeg-mini
a script (set of scripts)? for building a custom made ffmpeg alpine container of your dreams

## why?
the distribution package of `ffmpeg` is pretty bloated for my purposes, as it contains a lot more than i could ever possibly use at once (for understandable reasons like convenience -- i'm not saying it's wrong, it's just not needed in most containers). i made this so that you can hopefully significantly reduce the size of your container while keeping everything you need

## usage
- fork this repo so you can store your changes
- enable/disable things you need/don't need in the `config` folder
- try to build the dockerfile locally
    - if you enabled some things, it will most likely fail due to the fact that you'll need some libraries
    - figure out [what package](https://pkgs.alpinelinux.org/packages) you need to install and add it to your dockerfile. remember that you need to add development headers (package name usually ends in **-dev**) for the build step, and the regular library (doesn't end in -dev) for the actual final image.
    - you will also most likely need to enable these libraries in `./build.sh`, in the "EXTERNAL LIBRARIES" section (simply uncommenting their particular line, or commenting if it's toggled by `--disable` will do).
- repeat the above until you have a working build, at which point you can commit your changes to your fork and let github actions build and push your image

## standalone/development usage
- set the TMP_DIR variable which will be used for temporary files (e.g. via `export TMP_DIR=$(mktemp -d)`)
- set FFMPEG_VERSION and FFMPEG_SHA256 to whatever version you want to build, and a SHA256 hash of its .tar.xz tarball
- run ./meta/prep.sh
