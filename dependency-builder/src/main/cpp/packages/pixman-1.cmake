include_guard(GLOBAL)

if (NOT BUILD_SHARED_LIBS)
  # @TODO: upstream this
  # Pixman only builds shared libraries.
  # lrwxrwxrwx 1 vilius vilius   16 Jun 15 14:13 libpixman-1.so -> libpixman-1.so.0
  # lrwxrwxrwx 1 vilius vilius   21 Jun 15 14:13 libpixman-1.so.0 -> libpixman-1.so.0.38.4
  # -rwxr-xr-x 1 vilius vilius 6.7M Jun 15 14:13 libpixman-1.so.0.38.4

  # We want static library
  SET(PIXMAN_SHARED_ARGUMENT EXTRA_ARGUMENTS
    UPDATE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/packages/FixPixmanSource.sh
    ${CMAKE_CURRENT_BINARY_DIR}/pixman-1-prefix/src/pixman-1/
    LOG_UPDATE 1
  )
endif (NOT BUILD_SHARED_LIBS)

# Build errors for armeabi-v7a SIMD and Neon asm code.
if(ANDROID_ABI STREQUAL armeabi-v7a)
  SET(ARM32_CONFIG CONFIGURE_ARGUMENTS -Dneon=disabled -Darm-simd=disabled)
endif()

ExternalProjectMeson(pixman-1
  DEPENDS libpng glib-2.0
  URL https://cairographics.org/releases/pixman-0.38.4.tar.gz
  URL_HASH SHA256=da66d6fd6e40aee70f7bd02e4f8f76fc3f006ec879d346bae6a723025cfbdde7
  ${ARM32_CONFIG}
  ${PIXMAN_SHARED_ARGUMENT}
)
