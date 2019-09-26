#!/bin/bash
set -euo pipefail
POPPLER_SRC=$1
CMAKELISTS=${POPPLER_SRC}CMakeLists.txt
THIRDPARTY_PREFIX=$2

echo "Fixing $CMAKELISTS"

# Poppler source fixing is a two part job

echo "Fixing TIFF package include"
# A) As described in libtiff-4.cmake
# Manually link against libjpeg in all packages, that link against libtiff.
sed -i '/macro_optional_find_package(TIFF)/a if(TIFF_FOUND)\n  SET(TIFF_LIBRARIES "${TIFF_LIBRARIES};${CMAKE_INSTALL_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}jpeg${CMAKE_STATIC_LIBRARY_SUFFIX}")\nendif(TIFF_FOUND)' $CMAKELISTS
echo "grep -A 5 'macro_optional_find_package(TIFF)' $CMAKELISTS"
grep -A 5 'macro_optional_find_package(TIFF)' $CMAKELISTS

echo ""

echo "Fixing Cairo package include"
# B) Manually link against pixman-1.a (and whatever else it depends on) if Cairo is used
# Poppler did not check Cairo's dependencies

echo "Before paching:"
grep 'macro_optional_find_package(Cairo' $CMAKELISTS -A 3

PIXMAN_LIBS=
LIBPATH=`$THIRDPARTY_PREFIX/bin/pkg-config --libs-only-L pixman-1`
# Remove the -L from the beginning
LIBPATH=${LIBPATH#*-L}
LIBS=`$THIRDPARTY_PREFIX/bin/pkg-config --libs-only-l pixman-1`
for LIB in $LIBS; do
  # Remove the -l from the beginning
  LIB=${LIB#*-l}
  LIB_WITH_PATH=$LIBPATH/lib$LIB.a
  if [ -f $LIB_WITH_PATH ]; then
    PIXMAN_LIBS+=${LIB_WITH_PATH}\;
    #libm is in sysroot, not built here
  elif [ "$LIB" != "m" ]; then
    echo "Missing lib $LIB !"
    exit 1
  fi
done

# cut off the last \;
PIXMAN_LIBS=${PIXMAN_LIBS%\;*}

sed -i "/set(poppler_LIBS \${FREETYPE_LIBRARIES})/a if(CAIRO_FOUND)\n set(poppler_LIBS \${poppler_LIBS} $PIXMAN_LIBS)\n endif()" $CMAKELISTS

echo "After paching:"

grep 'macro_optional_find_package(Cairo' $CMAKELISTS -A 3

# https://gitlab.freedesktop.org/poppler/poppler/commit/842a75d8d6cc0105da6c0b5dbb0997b79ba63246
# Poppler-0.74.0 fixed HAVE_FSEEKO detection issue that happens prior to Android-24
# Patch that file until we upgrade to Poppler-0.74.0+
THIS_FILE=$(readlink -f "$0")
BASEDIR=$(dirname "$THIS_FILE")
patch $POPPLER_SRC/ConfigureChecks.cmake < ${BASEDIR}/poppler-android-23.patch