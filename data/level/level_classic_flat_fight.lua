Name = "Snow Classic Flat Fight"
Author = "Skeet"
ServerLua = "data/lua/level_classic_fight_server.lua"
ReleaseLevel = 2

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
	{ Position = CVector(10, -25, 3.5), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_island", Shape="snow_island", Friction = 0 },
	{ Position = CVector(6, -14, 1.8), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_island2", Shape="snow_island2", Friction = 0 },
	{ Position = CVector(-3.8, -17, 2), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_island3", Shape="snow_island3", Friction = 0 },
	{ Position = CVector(-0.1, -15.3, 1), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_target_50_flat", Shape="snow_target_50_flat", Score = 50, Friction = 25, Accel = 0.0001 },
	{ Position = CVector(-0.1, -15.35, 2.55), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_target_100_flat", Shape="snow_target_100_flat", Score = 100, Friction = 10, Accel = 0.0001 },
	{ Position = CVector(-0.1, -15.33, 2.8), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_target_300_flat", Shape="snow_target_300_flat", Score = 300, Friction = 10, Accel = 0.0001 }
}

Particles =
{
}

ExternalCameras =
{
	{ Position = CVector(-0.156463, -15.406598, 2.840894), Rotation = CAngleAxis(-0.015813, 0.005262, -0.315709, 0.948710) },
}
