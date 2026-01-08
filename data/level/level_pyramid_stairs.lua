Name = "Pyramid Stairs"
Author = "Skeet"
ServerLua = "data/lua/level_stairs_server.lua"
ReleaseLevel = 5

skyShapeFileName = "sky.shape";
sunAmbientColor = CRGBA(82, 100, 133, 255);
sunDiffuseColor = CRGBA(255, 255, 255, 255);
sunSpecularColor = CRGBA(255, 255, 255, 255);
sunDirection = CVector(-1,0,-1);

clearColor = CRGBA(30, 45, 90, 0);

fogDistMin = 0;
fogDistMax = 150;
fogColor = clearColor;

Cameras =
{
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10)
}

StartPoints =
{
	CVector(-0.5, 1.6, 9.38),
	CVector(-0.45, 1.6, 9.38),
	CVector(-0.4, 1.6, 9.38),
	CVector(-0.35, 1.6, 9.38),
	CVector(-0.3, 1.6, 9.38),
	CVector(-0.25, 1.6, 9.38),
	CVector(-0.2, 1.6, 9.38),
	CVector(-0.15, 1.6, 9.38),
	CVector(-0.1, 1.6, 9.38),
	CVector(-0.05, 1.6, 9.38),
	CVector(0.0, 1.6, 9.38),
	CVector(0.05, 1.6, 9.38),
	CVector(0.1, 1.6, 9.38),
	CVector(0.15, 1.6, 9.38),
	CVector(0.2, 1.6, 9.38),
	CVector(0.25, 1.6, 9.38)
}

Modules =
{
	{ Position = CVector(0, 0, 5), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_ramp", Shape="snow_ramp", Friction = 0, Bounce = 0, Accel = 0.0001 },
	{ Position = CVector(0, -15, 3.00), Scale = CVector(3, 3, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_box", Shape="snow_box", Score = 50, Friction = 10, Color = CRGBA(250,255,250,255) },
	{ Position = CVector(0, -15, 2.98), Scale = CVector(9, 9, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_box", Shape="snow_box", Score = 50, Friction = 10, Color = CRGBA(225,255,225,255) },
	{ Position = CVector(0, -15, 2.96), Scale = CVector(15, 15, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_box", Shape="snow_box", Score = 50, Friction = 10, Color = CRGBA(200,255,200,255) },
	{ Position = CVector(0, -15, 2.94), Scale = CVector(21, 21, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_box", Shape="snow_box", Score = 50, Friction = 10, Color = CRGBA(175,255,175,255) },
	{ Position = CVector(0, -15, 2.92), Scale = CVector(27, 27, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_box", Shape="snow_box", Score = 50, Friction = 10, Color = CRGBA(150,255,150,255) },
	{ Position = CVector(0, -15, 2.90), Scale = CVector(33, 33, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_box", Shape="snow_box", Score = 50, Friction = 10, Color = CRGBA(125,255,125,255) },
	{ Position = CVector(0, -15, 2.88), Scale = CVector(39, 39, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_box", Shape="snow_box", Score = 50, Friction = 10, Color = CRGBA(100,255,100,255) },
	{ Position = CVector(0, -15, 2.86), Scale = CVector(45, 45, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_box", Shape="snow_box", Score = 50, Friction = 10, Color = CRGBA(75,255,75,255) },
	{ Position = CVector(0, -15, 2.84), Scale = CVector(51, 51, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_box", Shape="snow_box", Score = 50, Friction = 10, Color = CRGBA(50,255,50,255) },
	{ Position = CVector(0, -15, 2.82), Scale = CVector(57, 57, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_box", Shape="snow_box", Score = 50, Friction = 10, Color = CRGBA(25,255,25,255) },
	{ Position = CVector(0, -15, 2.80), Scale = CVector(63, 63, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_box", Shape="snow_box", Score = 50, Friction = 10, Color = CRGBA(0,255,0,255) }
}

Particles =
{
}

ExternalCameras =
{
	{ Position = CVector(-0.033472, -15.974096, 3.567634), Rotation = CAngleAxis(-0.281957, 0.000176, -0.000600, 0.959427) },
}
