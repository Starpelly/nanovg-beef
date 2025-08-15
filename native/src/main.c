#ifndef NANO_BUILD_STATIC
#define GLAD_API_CALL_EXPORT
#endif
#include <glad.h>

#ifndef NANO_BUILD_STATIC
#define STB_IMAGE_IMPLEMENTATION
#endif
#include "stb_image.h"

#include "nanovg.h"
#define NANOVG_GL3_IMPLEMENTATION
#include "nanovg_gl.h"