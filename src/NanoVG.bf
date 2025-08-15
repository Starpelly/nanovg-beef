using System;
using System.Interop;
namespace NanoVG;

public enum NVGcreateFlags : c_int
{
	// Flag indicating if geometry based anti-aliasing is used (may not be needed when using MSAA).
	ANTIALIAS 		= 1<<0,
	// Flag indicating if strokes should be drawn using stencil buffer. The rendering will be a little
	// slower, but path overlaps (i.e. self-intersecting or sharp turns) will be drawn just once.
	STENCIL_STROKES	= 1<<1,
	// Flag indicating that additional debug checks are done.
	DEBUG 			= 1<<2,
}

public enum NVGtexture : c_int
{
	TEXTURE_ALPHA = 0x01,
	TEXTURE_RGBA = 0x02,
}

public enum NVGwinding : c_int
{
	CCW = 1,			// Winding for solid shapes
	CW = 2,				// Winding for holes
}

public enum NVGsolidity : c_int
{
	SOLID = 1,			// CCW
	HOLE = 2,			// CW
}

public enum NVGlineCap : c_int
{
	BUTT,
	ROUND,
	SQUARE,
	BEVEL,
	MITER,
}

public enum NVGalign : c_int
{
	// Horizontal align
	ALIGN_LEFT 		= 1<<0,	// Default, align text horizontally to left.
	ALIGN_CENTER 	= 1<<1,	// Align text horizontally to center.
	ALIGN_RIGHT 	= 1<<2,	// Align text horizontally to right.
	// Vertical align
	ALIGN_TOP 		= 1<<3,	// Align text vertically to top.
	ALIGN_MIDDLE	= 1<<4,	// Align text vertically to middle.
	ALIGN_BOTTOM	= 1<<5,	// Align text vertically to bottom.
	ALIGN_BASELINE	= 1<<6, // Default, align text vertically to baseline.
}

public enum NVGblendFactor  : c_int
{
	ZERO = 1<<0,
	ONE = 1<<1,
	SRC_COLOR = 1<<2,
	ONE_MINUS_SRC_COLOR = 1<<3,
	DST_COLOR = 1<<4,
	ONE_MINUS_DST_COLOR = 1<<5,
	SRC_ALPHA = 1<<6,
	ONE_MINUS_SRC_ALPHA = 1<<7,
	DST_ALPHA = 1<<8,
	ONE_MINUS_DST_ALPHA = 1<<9,
	SRC_ALPHA_SATURATE = 1<<10,
}

public enum NVGcompositeOperation  : c_int
{
	SOURCE_OVER,
	SOURCE_IN,
	SOURCE_OUT,
	ATOP,
	DESTINATION_OVER,
	DESTINATION_IN,
	DESTINATION_OUT,
	DESTINATION_ATOP,
	LIGHTER,
	COPY,
	XOR,
}

public enum NVGimageFlags : c_int
{
    IMAGE_GENERATE_MIPMAPS	= 1<<0,     // Generate mipmaps during creation of the image.
	IMAGE_REPEATX			= 1<<1,		// Repeat image in X direction.
	IMAGE_REPEATY			= 1<<2,		// Repeat image in Y direction.
	IMAGE_FLIPY				= 1<<3,		// Flips (inverses) image in Y direction when rendered.
	IMAGE_PREMULTIPLIED		= 1<<4,		// Image data has premultiplied alpha.
	IMAGE_NEAREST			= 1<<5,		// Image interpolation is Nearest instead Linear
}

[CRepr]
public struct NVGcontext
{
}

[CRepr]
public struct NVGscissor
{
	public float[6] xform;
	public float[2] extent;
}

[CRepr]
public struct NVGvertex
{
	public float x;
	public float y;
	public float u;
	public float v;
}

[CRepr]
public struct NVGpath
{
	public int first;
	public int count;
	public uint8 closed;
	public int nbevel;
	public NVGvertex* fill;
	public int nfill;
	public NVGvertex* stroke;
	public int nstroke;
	public int winding;
	public int convex;
}

[CRepr]
public struct NVGcolor
{
	public float r;
	public float g;
	public float b;
	public float a;
}

[CRepr]
public struct NVGpaint
{
	public float[6] xform;
	public float[2] extent;
	public float radius;
	public float feather;
	public NVGcolor innerColor;
	public NVGcolor outerColor;
	public int image;
}

[CRepr]
public struct NVGcompositeOperationState
{
	public int srcRGB;
	public int dstRGB;
	public int srcAlpha;
	public int dstAlpha;
}

[CRepr]
public struct NVGglyphPosition
{
	public char8* str;	// Position of the glyph in the input string.
	public float x;			// The x-coordinate of the logical glyph position.
	public float minx, maxx;	// The bounds of the glyph shape.
}

[CRepr]
public struct NVGtextRow
{
	public char8* start;	// Pointer to the input text where the row starts.
	public char8* end;		// Pointer to the input text where the row ends (one past the last character).
	public char8* next;		// Pointer to the beginning of the next row.
	public float width;		// Logical width of the row.
	public float minx, maxx;	// Actual bounds of the row. Logical with and bounds can differ because of kerning and some parts over extending.
}

static
{
	// Begin drawing a new frame
	// Calls to nanovg drawing API should be wrapped in nvgBeginFrame() & nvgEndFrame()
	// nvgBeginFrame() defines the size of the window to render to in relation currently
	// set viewport (i.e. glViewport on GL backends). Device pixel ration allows to
	// control the rendering on Hi-DPI devices.
	// For example, GLFW returns two dimension for an opened window: window size and
	// frame buffer size. In that case you would set windowWidth/Height to the window size
	// devicePixelRatio to: frameBufferWidth / windowWidth.
	[CLink]
	public static extern void nvgBeginFrame(NVGcontext* ctx, float windowWidth, float windowHeight, float devicePixelRatio);

	// Cancels drawing the current frame.
	[CLink]
	public static extern void nvgCancelFrame(NVGcontext* ctx);

	// Ends drawing flushing remaining render state.
	[CLink]
	public static extern void nvgEndFrame(NVGcontext* ctx);

	//
	// Composite operation
	//
	// The composite operations in NanoVG are modeled after HTML Canvas API, and
	// the blend func is based on OpenGL (see corresponding manuals for more info).
	// The colors in the blending state have premultiplied alpha.

	// Sets the composite operation. The op parameter should be one of NVGcompositeOperation.
	[CLink]
	public static extern void nvgGlobalCompositeOperation(NVGcontext* ctx, int op);

	// Sets the composite operation with custom pixel arithmetic. The parameters should be one of NVGblendFactor.
	[CLink]
	public static extern void nvgGlobalCompositeBlendFunc(NVGcontext* ctx, int sfactor, int dfactor);

	// Sets the composite operation with custom pixel arithmetic for RGB and alpha components separately. The parameters should be one of NVGblendFactor.
	[CLink]
	public static extern void nvgGlobalCompositeBlendFuncSeparate(NVGcontext* ctx, int srcRGB, int dstRGB, int srcAlpha, int dstAlpha);

	//
	// Color utils
	//
	// Colors in NanoVG are stored as unsigned ints in ABGR format.

	// Returns a color value from red, green, blue values. Alpha will be set to 255 (1.0f).
	[CLink]
	public static extern NVGcolor nvgRGB(uint8 r, uint8 g, uint8 b);

	// Returns a color value from red, green, blue values. Alpha will be set to 1.0f.
	[CLink]
	public static extern NVGcolor nvgRGBf(float r, float g, float b);


	// Returns a color value from red, green, blue and alpha values.
	[CLink]
	public static extern NVGcolor nvgRGBA(uint8 r, uint8 g, uint8 b, uint8 a);

	// Returns a color value from red, green, blue and alpha values.
	[CLink]
	public static extern NVGcolor nvgRGBAf(float r, float g, float b, float a);


	// Linearly interpolates from color c0 to c1, and returns resulting color value.
	[CLink]
	public static extern NVGcolor nvgLerpRGBA(NVGcolor c0, NVGcolor c1, float u);

	// Sets transparency of a color value.
	[CLink]
	public static extern NVGcolor nvgTransRGBA(NVGcolor c0, uint8 a);

	// Sets transparency of a color value.
	[CLink]
	public static extern NVGcolor nvgTransRGBAf(NVGcolor c0, float a);

	// Returns color value specified by hue, saturation and lightness.
	// HSL values are all in range [0..1], alpha will be set to 255.
	[CLink]
	public static extern NVGcolor nvgHSL(float h, float s, float l);

	// Returns color value specified by hue, saturation and lightness and alpha.
	// HSL values are all in range [0..1], alpha in range [0..255]
	[CLink]
	public static extern NVGcolor nvgHSLA(float h, float s, float l, uint8 a);

	//
	// State Handling
	//
	// NanoVG contains state which represents how paths will be rendered.
	// The state contains transform, fill and stroke styles, text and font styles,
	// and scissor clipping.

	// Pushes and saves the current render state into a state stack.
	// A matching nvgRestore() must be used to restore the state.
	[CLink]
	public static extern void nvgSave(NVGcontext* ctx);

	// Pops and restores current render state.
	[CLink]
	public static extern void nvgRestore(NVGcontext* ctx);

	// Resets current render state to default values. Does not affect the render state stack.
	[CLink]
	public static extern void nvgReset(NVGcontext* ctx);

	//
	// Render styles
	//
	// Fill and stroke render style can be either a solid color or a paint which is a gradient or a pattern.
	// Solid color is simply defined as a color value, different kinds of paints can be created
	// using nvgLinearGradient(), nvgBoxGradient(), nvgRadialGradient() and nvgImagePattern().
	//
	// Current render style can be saved and restored using nvgSave() and nvgRestore().

	// Sets whether to draw antialias for nvgStroke() and nvgFill(). It's enabled by default.
	[CLink]
	public static extern void nvgShapeAntiAlias(NVGcontext* ctx, int enabled);

	// Sets current stroke style to a solid color.
	[CLink]
	public static extern void nvgStrokeColor(NVGcontext* ctx, NVGcolor color);

	// Sets current stroke style to a paint, which can be a one of the gradients or a pattern.
	[CLink]
	public static extern void nvgStrokePaint(NVGcontext* ctx, NVGpaint paint);

	// Sets current fill style to a solid color.
	[CLink]
	public static extern void nvgFillColor(NVGcontext* ctx, NVGcolor color);

	// Sets current fill style to a paint, which can be a one of the gradients or a pattern.
	[CLink]
	public static extern void nvgFillPaint(NVGcontext* ctx, NVGpaint paint);

	// Sets the miter limit of the stroke style.
	// Miter limit controls when a sharp corner is beveled.
	[CLink]
	public static extern void nvgMiterLimit(NVGcontext* ctx, float limit);

	// Sets the stroke width of the stroke style.
	[CLink]
	public static extern void nvgStrokeWidth(NVGcontext* ctx, float size);

	// Sets how the end of the line (cap) is drawn,
	// Can be one of: BUTT (default), ROUND, SQUARE.
	[CLink]
	public static extern void nvgLineCap(NVGcontext* ctx, int cap);

	// Sets how sharp path corners are drawn.
	// Can be one of MITER (default), ROUND, BEVEL.
	[CLink]
	public static extern void nvgLineJoin(NVGcontext* ctx, int join);

	// Sets the transparency applied to all rendered shapes.
	// Already transparent paths will get proportionally more transparent as well.
	[CLink]
	public static extern void nvgGlobalAlpha(NVGcontext* ctx, float alpha);

	//
	// Transforms
	//
	// The paths, gradients, patterns and scissor region are transformed by an transformation
	// matrix at the time when they are passed to the API.
	// The current transformation matrix is a affine matrix:
	//   [sx kx tx]
	//   [ky sy ty]
	//   [ 0  0  1]
	// Where: sx,sy define scaling, kx,ky skewing, and tx,ty translation.
	// The last row is assumed to be 0,0,1 and is not stored.
	//
	// Apart from nvgResetTransform(), each transformation function first creates
	// specific transformation matrix and pre-multiplies the current transformation by it.
	//
	// Current coordinate system (transformation) can be saved and restored using nvgSave() and nvgRestore().

	// Resets current transform to a identity matrix.
	[CLink]
	public static extern void nvgResetTransform(NVGcontext* ctx);

	// Premultiplies current coordinate system by specified matrix.
	// The parameters are interpreted as matrix as follows:
	//   [a c e]
	//   [b d f]
	//   [0 0 1]
	[CLink]
	public static extern void nvgTransform(NVGcontext* ctx, float a, float b, float c, float d, float e, float f);

	// Translates current coordinate system.
	[CLink]
	public static extern void nvgTranslate(NVGcontext* ctx, float x, float y);

	// Rotates current coordinate system. Angle is specified in radians.
	[CLink]
	public static extern void nvgRotate(NVGcontext* ctx, float angle);

	// Skews the current coordinate system along X axis. Angle is specified in radians.
	[CLink]
	public static extern void nvgSkewX(NVGcontext* ctx, float angle);

	// Skews the current coordinate system along Y axis. Angle is specified in radians.
	[CLink]
	public static extern void nvgSkewY(NVGcontext* ctx, float angle);

	// Scales the current coordinate system.
	[CLink]
	public static extern void nvgScale(NVGcontext* ctx, float x, float y);

	// Stores the top part (a-f) of the current transformation matrix in to the specified buffer.
	//   [a c e]
	//   [b d f]
	//   [0 0 1]
	// There should be space for 6 floats in the return buffer for the values a-f.
	[CLink]
	public static extern void nvgCurrentTransform(NVGcontext* ctx, float* xform);


	// The following functions can be used to make calculations on 2x3 transformation matrices.
	// A 2x3 matrix is represented as float[6].

	// Sets the transform to identity matrix.
	[CLink]
	public static extern void nvgTransformIdentity(float* dst);

	// Sets the transform to translation matrix matrix.
	[CLink]
	public static extern void nvgTransformTranslate(float* dst, float tx, float ty);

	// Sets the transform to scale matrix.
	[CLink]
	public static extern void nvgTransformScale(float* dst, float sx, float sy);

	// Sets the transform to rotate matrix. Angle is specified in radians.
	[CLink]
	public static extern void nvgTransformRotate(float* dst, float a);

	// Sets the transform to skew-x matrix. Angle is specified in radians.
	[CLink]
	public static extern void nvgTransformSkewX(float* dst, float a);

	// Sets the transform to skew-y matrix. Angle is specified in radians.
	[CLink]
	public static extern void nvgTransformSkewY(float* dst, float a);

	// Sets the transform to the result of multiplication of two transforms, of A = A*B.
	[CLink]
	public static extern void nvgTransformMultiply(float* dst, float* src);

	// Sets the transform to the result of multiplication of two transforms, of A = B*A.
	[CLink]
	public static extern void nvgTransformPremultiply(float* dst, float* src);

	// Sets the destination to inverse of specified transform.
	// Returns 1 if the inverse could be calculated, else 0.
	[CLink]
	public static extern int nvgTransformInverse(float* dst, float* src);

	// Transform a point by given transform.
	[CLink]
	public static extern void nvgTransformPoint(float* dstx, float* dsty, float* xform, float srcx, float srcy);

	// Converts degrees to radians and vice versa.
	[CLink]
	public static extern float nvgDegToRad(float deg);
	[CLink]
	public static extern float nvgRadToDeg(float rad);

	//
	// Images
	//
	// NanoVG allows you to load jpg, png, psd, tga, pic and gif files to be used for rendering.
	// In addition you can upload your own image. The image loading is provided by stb_image.
	// The parameter imageFlags is combination of flags defined in NVGimageFlags.

	// Creates image by loading it from the disk from specified file name.
	// Returns handle to the image.
	[CLink]
	public static extern int nvgCreateImage(NVGcontext* ctx, char8* filename, int imageFlags);

	// Creates image by loading it from the specified chunk of memory.
	// Returns handle to the image.
	[CLink]
	public static extern int nvgCreateImageMem(NVGcontext* ctx, int imageFlags, uint8* data, int ndata);

	// Creates image from specified image data.
	// Returns handle to the image.
	[CLink]
	public static extern int nvgCreateImageRGBA(NVGcontext* ctx, int w, int h, int imageFlags, uint8* data);

	// Updates image data specified by image handle.
	[CLink]
	public static extern void nvgUpdateImage(NVGcontext* ctx, int image, uint8* data);

	// Returns the dimensions of a created image.
	[CLink]
	public static extern void nvgImageSize(NVGcontext* ctx, int image, int* w, int* h);

	// Deletes created image.
	[CLink]
	public static extern void nvgDeleteImage(NVGcontext* ctx, int image);

	//
	// Paints
	//
	// NanoVG supports four types of paints: linear gradient, box gradient, radial gradient and image pattern.
	// These can be used as paints for strokes and fills.

	// Creates and returns a linear gradient. Parameters (sx,sy)-(ex,ey) specify the start and end coordinates
	// of the linear gradient, icol specifies the start color and ocol the end color.
	// The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
	[CLink]
	public static extern NVGpaint nvgLinearGradient(NVGcontext* ctx, float sx, float sy, float ex, float ey,
							   NVGcolor icol, NVGcolor ocol);

	// Creates and returns a box gradient. Box gradient is a feathered rounded rectangle, it is useful for rendering
	// drop shadows or highlights for boxes. Parameters (x,y) define the top-left corner of the rectangle,
	// (w,h) define the size of the rectangle, r defines the corner radius, and f feather. Feather defines how blurry
	// the border of the rectangle is. Parameter icol specifies the inner color and ocol the outer color of the gradient.
	// The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
	[CLink]
	public static extern NVGpaint nvgBoxGradient(NVGcontext* ctx, float x, float y, float w, float h,
							float r, float f, NVGcolor icol, NVGcolor ocol);

	// Creates and returns a radial gradient. Parameters (cx,cy) specify the center, inr and outr specify
	// the inner and outer radius of the gradient, icol specifies the start color and ocol the end color.
	// The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
	[CLink]
	public static extern NVGpaint nvgRadialGradient(NVGcontext* ctx, float cx, float cy, float inr, float outr,
							   NVGcolor icol, NVGcolor ocol);

	// Creates and returns an image pattern. Parameters (ox,oy) specify the left-top location of the image pattern,
	// (ex,ey) the size of one image, angle rotation around the top-left corner, image is handle to the image to render.
	// The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
	[CLink]
	public static extern NVGpaint nvgImagePattern(NVGcontext* ctx, float ox, float oy, float ex, float ey,
							 float angle, int image, float alpha);

	//
	// Scissoring
	//
	// Scissoring allows you to clip the rendering into a rectangle. This is useful for various
	// user interface cases like rendering a text edit or a timeline.

	// Sets the current scissor rectangle.
	// The scissor rectangle is transformed by the current transform.
	[CLink]
	public static extern void nvgScissor(NVGcontext* ctx, float x, float y, float w, float h);

	// Intersects current scissor rectangle with the specified rectangle.
	// The scissor rectangle is transformed by the current transform.
	// Note: in case the rotation of previous scissor rect differs from
	// the current one, the intersection will be done between the specified
	// rectangle and the previous scissor rectangle transformed in the current
	// transform space. The resulting shape is always rectangle.
	[CLink]
	public static extern void nvgIntersectScissor(NVGcontext* ctx, float x, float y, float w, float h);

	// Reset and disables scissoring.
	[CLink]
	public static extern void nvgResetScissor(NVGcontext* ctx);

	//
	// Paths
	//
	// Drawing a new shape starts with nvgBeginPath(), it clears all the currently defined paths.
	// Then you define one or more paths and sub-paths which describe the shape. The are functions
	// to draw common shapes like rectangles and circles, and lower level step-by-step functions,
	// which allow to define a path curve by curve.
	//
	// NanoVG uses even-odd fill rule to draw the shapes. Solid shapes should have counter clockwise
	// winding and holes should have counter clockwise order. To specify winding of a path you can
	// call nvgPathWinding(). This is useful especially for the common shapes, which are drawn CCW.
	//
	// Finally you can fill the path using current fill style by calling nvgFill(), and stroke it
	// with current stroke style by calling nvgStroke().
	//
	// The curve segments and sub-paths are transformed by the current transform.

	// Clears the current path and sub-paths.
	[CLink]
	public static extern void nvgBeginPath(NVGcontext* ctx);

	// Starts new sub-path with specified point as first point.
	[CLink]
	public static extern void nvgMoveTo(NVGcontext* ctx, float x, float y);

	// Adds line segment from the last point in the path to the specified point.
	[CLink]
	public static extern void nvgLineTo(NVGcontext* ctx, float x, float y);

	// Adds cubic bezier segment from last point in the path via two control points to the specified point.
	[CLink]
	public static extern void nvgBezierTo(NVGcontext* ctx, float c1x, float c1y, float c2x, float c2y, float x, float y);

	// Adds quadratic bezier segment from last point in the path via a control point to the specified point.
	[CLink]
	public static extern void nvgQuadTo(NVGcontext* ctx, float cx, float cy, float x, float y);

	// Adds an arc segment at the corner defined by the last path point, and two specified points.
	[CLink]
	public static extern void nvgArcTo(NVGcontext* ctx, float x1, float y1, float x2, float y2, float radius);

	// Closes current sub-path with a line segment.
	[CLink]
	public static extern void nvgClosePath(NVGcontext* ctx);

	// Sets the current sub-path winding, see NVGwinding and NVGsolidity.
	[CLink]
	public static extern void nvgPathWinding(NVGcontext* ctx, int dir);

	// Creates new circle arc shaped sub-path. The arc center is at cx,cy, the arc radius is r,
	// and the arc is drawn from angle a0 to a1, and swept in direction dir (CCW, or CW).
	// Angles are specified in radians.
	[CLink]
	public static extern void nvgArc(NVGcontext* ctx, float cx, float cy, float r, float a0, float a1, int dir);

	// Creates new rectangle shaped sub-path.
	[CLink]
	public static extern void nvgRect(NVGcontext* ctx, float x, float y, float w, float h);

	// Creates new rounded rectangle shaped sub-path.
	[CLink]
	public static extern void nvgRoundedRect(NVGcontext* ctx, float x, float y, float w, float h, float r);

	// Creates new rounded rectangle shaped sub-path with varying radii for each corner.
	[CLink]
	public static extern void nvgRoundedRectVarying(NVGcontext* ctx, float x, float y, float w, float h, float radTopLeft, float radTopRight, float radBottomRight, float radBottomLeft);

	// Creates new ellipse shaped sub-path.
	[CLink]
	public static extern void nvgEllipse(NVGcontext* ctx, float cx, float cy, float rx, float ry);

	// Creates new circle shaped sub-path.
	[CLink]
	public static extern void nvgCircle(NVGcontext* ctx, float cx, float cy, float r);

	// Fills the current path with current fill style.
	[CLink]
	public static extern void nvgFill(NVGcontext* ctx);

	// Fills the current path with current stroke style.
	[CLink]
	public static extern void nvgStroke(NVGcontext* ctx);


	//
	// Text
	//
	// NanoVG allows you to load .ttf files and use the font to render text.
	//
	// The appearance of the text can be defined by setting the current text style
	// and by specifying the fill color. Common text and font settings such as
	// font size, letter spacing and text align are supported. Font blur allows you
	// to create simple text effects such as drop shadows.
	//
	// At render time the font face can be set based on the font handles or name.
	//
	// Font measure functions return values in local space, the calculations are
	// carried in the same resolution as the final rendering. This is done because
	// the text glyph positions are snapped to the nearest pixels sharp rendering.
	//
	// The local space means that values are not rotated or scale as per the current
	// transformation. For example if you set font size to 12, which would mean that
	// line height is 16, then regardless of the current scaling and rotation, the
	// returned line height is always 16. Some measures may vary because of the scaling
	// since aforementioned pixel snapping.
	//
	// While this may sound a little odd, the setup allows you to always render the
	// same way regardless of scaling. I.e. following works regardless of scaling:
	//
	//		char8* txt = "Text me up.";
	//		nvgTextBounds(vg, x,y, txt, NULL, bounds);
	//		nvgBeginPath(vg);
	//		nvgRect(vg, bounds[0],bounds[1], bounds[2]-bounds[0], bounds[3]-bounds[1]);
	//		nvgFill(vg);
	//
	// Note: currently only solid color fill is supported for text.

	// Creates font by loading it from the disk from specified file name.
	// Returns handle to the font.
	[CLink]
	public static extern int nvgCreateFont(NVGcontext* ctx, char8* name, char8* filename);

	// fontIndex specifies which font face to load from a .ttf/.ttc file.
	[CLink]
	public static extern int nvgCreateFontAtIndex(NVGcontext* ctx, char8* name, char8* filename, int fontIndex);

	// Creates font by loading it from the specified memory chunk.
	// Returns handle to the font.
	[CLink]
	public static extern int nvgCreateFontMem(NVGcontext* ctx, char8* name, uint8* data, int ndata, int freeData);

	// fontIndex specifies which font face to load from a .ttf/.ttc file.
	[CLink]
	public static extern int nvgCreateFontMemAtIndex(NVGcontext* ctx, char8* name, uint8* data, int ndata, int freeData, int fontIndex);

	// Finds a loaded font of specified name, and returns handle to it, or -1 if the font is not found.
	[CLink]
	public static extern int nvgFindFont(NVGcontext* ctx, char8* name);

	// Adds a fallback font by handle.
	[CLink]
	public static extern int nvgAddFallbackFontId(NVGcontext* ctx, int baseFont, int fallbackFont);

	// Adds a fallback font by name.
	[CLink]
	public static extern int nvgAddFallbackFont(NVGcontext* ctx, char8* baseFont, char8* fallbackFont);

	// Resets fallback fonts by handle.
	[CLink]
	public static extern void nvgResetFallbackFontsId(NVGcontext* ctx, int baseFont);

	// Resets fallback fonts by name.
	[CLink]
	public static extern void nvgResetFallbackFonts(NVGcontext* ctx, char8* baseFont);

	// Sets the font size of current text style.
	[CLink]
	public static extern void nvgFontSize(NVGcontext* ctx, float size);

	// Sets the blur of current text style.
	[CLink]
	public static extern void nvgFontBlur(NVGcontext* ctx, float blur);

	// Sets the letter spacing of current text style.
	[CLink]
	public static extern void nvgTextLetterSpacing(NVGcontext* ctx, float spacing);

	// Sets the proportional line height of current text style. The line height is specified as multiple of font size.
	[CLink]
	public static extern void nvgTextLineHeight(NVGcontext* ctx, float lineHeight);

	// Sets the text align of current text style, see NVGalign for options.
	[CLink]
	public static extern void nvgTextAlign(NVGcontext* ctx, int align);

	// Sets the font face based on specified id of current text style.
	[CLink]
	public static extern void nvgFontFaceId(NVGcontext* ctx, int font);

	// Sets the font face based on specified name of current text style.
	[CLink]
	public static extern void nvgFontFace(NVGcontext* ctx, char8* font);

	// Draws text string at specified location. If end is specified only the sub-string up to the end is drawn.
	[CLink]
	public static extern float nvgText(NVGcontext* ctx, float x, float y, char8* string, char8* end);

	// Draws multi-line text string at specified location wrapped at the specified width. If end is specified only the sub-string up to the end is drawn.
	// White space is stripped at the beginning of the rows, the text is split at word boundaries or when new-line characters are encountered.
	// Words longer than the max width are slit at nearest character (i.e. no hyphenation).
	[CLink]
	public static extern void nvgTextBox(NVGcontext* ctx, float x, float y, float breakRowWidth, char8* string, char8* end);

	// Measures the specified text string. Parameter bounds should be a pointer to float[4],
	// if the bounding box of the text should be returned. The bounds value are [xmin,ymin, xmax,ymax]
	// Returns the horizontal advance of the measured text (i.e. where the next character should drawn).
	// Measured values are returned in local coordinate space.
	[CLink]
	public static extern float nvgTextBounds(NVGcontext* ctx, float x, float y, char8* string, char8* end, float* bounds);

	// Measures the specified multi-text string. Parameter bounds should be a pointer to float[4],
	// if the bounding box of the text should be returned. The bounds value are [xmin,ymin, xmax,ymax]
	// Measured values are returned in local coordinate space.
	[CLink]
	public static extern void nvgTextBoxBounds(NVGcontext* ctx, float x, float y, float breakRowWidth, char8* string, char8* end, float* bounds);

	// Calculates the glyph x positions of the specified text. If end is specified only the sub-string will be used.
	// Measured values are returned in local coordinate space.
	[CLink]
	public static extern int nvgTextGlyphPositions(NVGcontext* ctx, float x, float y, char8* string, char8* end, NVGglyphPosition* positions, int maxPositions);

	// Returns the vertical metrics based on the current text style.
	// Measured values are returned in local coordinate space.
	[CLink]
	public static extern void nvgTextMetrics(NVGcontext* ctx, float* ascender, float* descender, float* lineh);

	// Breaks the specified text into lines. If end is specified only the sub-string will be used.
	// White space is stripped at the beginning of the rows, the text is split at word boundaries or when new-line characters are encountered.
	// Words longer than the max width are slit at nearest character (i.e. no hyphenation).
	[CLink]
	public static extern int nvgTextBreakLines(NVGcontext* ctx, char8* string, char8* end, float breakRowWidth, NVGtextRow* rows, int maxRows);
}