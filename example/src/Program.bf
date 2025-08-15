using System;
using RaylibBeef;
using NanoVG;
using NanoVG.GL;

namespace example;

class Program
{
	public static void Main(String[] args)
	{
		Raylib.InitWindow(1280, 720, "nanovg test");

		let vg = nvgCreateGL3(.ANTIALIAS | .STENCIL_STROKES);

		while (!Raylib.WindowShouldClose())
		{
			Raylib.BeginDrawing();
			Raylib.ClearBackground(Raylib.GRAY);

			NanoVG.nvgBeginFrame(vg, Raylib.GetScreenWidth(), Raylib.GetScreenHeight(), 1.0f);

			paint(vg);

			NanoVG.nvgEndFrame(vg);

			Raylib.EndDrawing();
		}

		nvgDeleteGL3(vg);
		Raylib.CloseWindow();
	}

	private static void paint(NVGcontext* vg)
	{
		/*
		NanoVG.nvgBeginPath(vg);
		NanoVG.nvgRoundedRect(vg, 16, 16, Raylib.GetMousePosition().x - 16, 99, 16);
		NanoVG.nvgFillColor(vg, NanoVG.nvgRGBA(0, 0, 0, 255));
		NanoVG.nvgFill(vg);
		*/

		NVGpaint shadowPaint;

		let x = 16;
		let y = 16;
		let w = 100;
		let h = 100;
		let cornerRadius = 8;

		nvgSave(vg);

			// Window
			nvgBeginPath(vg);
			nvgRoundedRect(vg, x, y, w, h, cornerRadius);
			nvgFillColor(vg, nvgRGBA(28,30,34,192));
		//	nvgFillColor(vg, nvgRGBA(0,0,0,128));
			nvgFill(vg);

		// Drop shadow
		shadowPaint = nvgBoxGradient(vg, x,y+2, w,h, cornerRadius*2, 10, nvgRGBA(0,0,0,128), nvgRGBA(0,0,0,0));
		nvgBeginPath(vg);
		nvgRect(vg, x-10,y-10, w+20,h+30);
		nvgRoundedRect(vg, x,y, w,h, cornerRadius);
		nvgPathWinding(vg, (int)NVGsolidity.HOLE);
		nvgFillPaint(vg, shadowPaint);
		nvgFill(vg);

		nvgRestore(vg);
	}
}