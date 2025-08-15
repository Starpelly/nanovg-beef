using System;
using System.Interop;
namespace NanoVG.GL;

static
{
	[CLink]
	public static extern NVGcontext* nvgCreateGL3(NVGcreateFlags flags);
	[CLink]
	public static extern void nvgDeleteGL3(NVGcontext* ctx);
}