using System;
using System.Interop;
namespace NanoVG;

typealias NVGcontext = void;

enum NVGcreateFlags : c_int
{
	// Flag indicating if geometry based anti-aliasing is used (may not be needed when using MSAA).
	NVG_ANTIALIAS 		= 1<<0,
	// Flag indicating if strokes should be drawn using stencil buffer. The rendering will be a little
	// slower, but path overlaps (i.e. self-intersecting or sharp turns) will be drawn just once.
	NVG_STENCIL_STROKES	= 1<<1,
	// Flag indicating that additional debug checks are done.
	NVG_DEBUG 			= 1<<2,
}

[CRepr]
struct NVGColor
{
	public float r;
	public float g;
	public float b;
	public float a;
}

static
{
	[CLink]
	public static extern NVGcontext* nvgCreateGL3(NVGcreateFlags flags);

	[CLink]
	public static extern void nvgDeleteGL3(NVGcontext* ctx);

	[CLink]
	public static extern void nvgBeginFrame(void* ctx, float windowWidth, float windowHeight, float devicePixelRatio);

	[CLink]
	public static extern void nvgEndFrame(void* ctx);

	[CLink]
	public static extern void nvgBeginPath(void* ctx);

	[CLink]
	public static extern void nvgFill(void* ctx);

	[CLink]
	public static extern void nvgRoundedRect(void* ctx, float x, float y, float w, float h, float r);

	[CLink]
	public static extern void nvgFillColor(void* ctx, NVGColor color);

	[CLink]
	public static extern NVGColor nvgRGBA(uint8 r, uint8 g, uint8 b, uint8 a);
}