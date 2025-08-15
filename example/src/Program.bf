using System;
using RaylibBeef;

namespace example;

class Program
{
	public static void Main(String[] args)
	{
		Raylib.InitWindow(1280, 720, "nanovg test");

		let vg = NanoVG.nvgCreateGL3(.NVG_ANTIALIAS | .NVG_STENCIL_STROKES);

		while (!Raylib.WindowShouldClose())
		{
			Raylib.BeginDrawing();
			Raylib.ClearBackground(Raylib.GRAY);

			NanoVG.nvgBeginFrame(vg, Raylib.GetScreenWidth(), Raylib.GetScreenHeight(), 1.0f);

			NanoVG.nvgBeginPath(vg);
			NanoVG.nvgRoundedRect(vg, 16, 16, 200, 48, 16);
			NanoVG.nvgFillColor(vg, NanoVG.nvgRGBA(255, 0, 0, 255));
			NanoVG.nvgFill(vg);

			NanoVG.nvgEndFrame(vg);

			Raylib.EndDrawing();
		}

		NanoVG.nvgDeleteGL3(vg);
		Raylib.CloseWindow();
	}
}