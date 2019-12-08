include_guard(GLOBAL)

IF (BUILD_3RDPARTY_BINARIES)
  SET(POPPLER_CONFIGURE_ARGUMENTS -DBUILD_CPP_TESTS=ON -DENABLE_UTILS=ON)
ELSE()
  SET(POPPLER_CONFIGURE_ARGUMENTS -DBUILD_CPP_TESTS=OFF -DENABLE_UTILS=OFF)
ENDIF ()

ExternalProjectCMake(poppler
  DEPENDS cairo fontconfig freetype glib-2.0 lcms2 libpng libjpeg libopenjp2 libtiff-4 poppler-data

  URL https://poppler.freedesktop.org/poppler-0.81.0.tar.xz
  URL_HASH SHA256=212d020b035b67b36c9666bd08ac778dff3222d85c01c338787d546f0f9bfe02

  CONFIGURE_ARGUMENTS -DENABLE_UNSTABLE_API_ABI_HEADERS=ON
    -DBUILD_GTK_TESTS=OFF -DBUILD_QT5_TESTS=OFF -DENABLE_QT5=OFF
    -DENABLE_LIBOPENJPEG=openjpeg2

    ${POPPLER_CONFIGURE_ARGUMENTS}
)

