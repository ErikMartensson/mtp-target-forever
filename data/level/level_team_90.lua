Name = "Team 90"
Author = "Skeet"
ServerLua = "data/lua/level_team_server.lua"
ReleaseLevel = 3

skyShapeFileName = "sky.shape"

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
	CVector(0, -3, 10),
	CVector(0, 3, 10),
	CVector(0, -3, 10),
	CVector(0, 3, 10),
	CVector(0, -3, 10),
	CVector(0, 3, 10),
	CVector(0, -3, 10),
	CVector(0, 3, 10),
	CVector(0, -3, 10),
	CVector(0, 3, 10),
	CVector(0, -3, 10),
	CVector(0, 3, 10),
	CVector(0, -3, 10),
	CVector(0, 3, 10),
	CVector(0, -3, 10)
}

StartPoints =
{
	CVector(-0.5, 16.6, 9.38),
	CVector(-0.45, -16.6, 9.38),
	CVector(-0.4, 16.6, 9.38),
	CVector(-0.35, -16.6, 9.38),
	CVector(-0.3, 16.6, 9.38),
	CVector(-0.25, -16.6, 9.38),
	CVector(-0.2, 16.6, 9.38),
	CVector(-0.15, -16.6, 9.38),
	CVector(-0.1, 16.6, 9.38),
	CVector(-0.05, -16.6, 9.38),
	CVector(0.0, 16.6, 9.38),
	CVector(0.05, -16.6, 9.38),
	CVector(0.1, 16.6, 9.38),
	CVector(0.15, -16.6, 9.38),
	CVector(0.2, 16.6, 9.38),
	CVector(0.25, -16.6, 9.38)
}

Modules =
{
	{ Position = CVector(0, 15, 5), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_ramp", Shape="snow_ramp", Friction = 0, Bounce = 0, Accel = 0.0001, Color = CRGBA(255,200,200,255) },
	{ Position = CVector(0, -15, 5), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(0,0,1,3.1415), Lua = "snow_ramp", Shape="snow_ramp", Friction = 0, Bounce = 0, Accel = 0.0001, Color = CRGBA(200,200,255,255) },
	{ Position = CVector(10, -10, 3.5), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_island", Shape="snow_island", Friction = 0 },
	{ Position = CVector(-10, 10, 3.5), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_island", Shape="snow_island", Friction = 0 },
	{ Position = CVector(6, 3, 1.8), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_island2", Shape="snow_island2", Friction = 0 },
	{ Position = CVector(-3.8, -3, 2), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_island3", Shape="snow_island3", Friction = 0 },
	-- Red team targets (positive X side) - same as level_team_classic but rotated 90 degrees (X and Y swapped)
	{ Position = CVector(0.40, 0, 3), Scale = CVector(16, 16, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "team_target_50_red", Shape="box_sol", Score = 50, Friction = 25, Color = CRGBA(255,128,128,255) },
	{ Position = CVector(0.16, 0, 3), Scale = CVector(8, 8, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "team_target_100_red", Shape="box_sol", Score = 100, Friction = 10, Color = CRGBA(255,64,64,255) },
	{ Position = CVector(0.04, 0, 3), Scale = CVector(4, 4, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "team_target_300_red", Shape="box_sol", Score = 300, Friction = 10, Color = CRGBA(255,0,0,255) },
	-- Blue team targets (negative X side) - same as level_team_classic but rotated 90 degrees (X and Y swapped)
	{ Position = CVector(-0.40, 0, 3), Scale = CVector(16, 16, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "team_target_50_blue", Shape="box_sol", Score = 50, Friction = 25, Color = CRGBA(128,128,255,255) },
	{ Position = CVector(-0.16, 0, 3), Scale = CVector(8, 8, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "team_target_100_blue", Shape="box_sol", Score = 100, Friction = 10, Color = CRGBA(64,64,255,255) },
	{ Position = CVector(-0.04, 0, 3), Scale = CVector(4, 4, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "team_target_300_blue", Shape="box_sol", Score = 300, Friction = 10, Color = CRGBA(0,0,255,255) }
}

Particles =
{
}

ExternalCameras =
{
	{ Position = CVector(-0.108815, -0.000864, 3.132983), Rotation = CAngleAxis(-0.310493, 0.317307, -0.640444, 0.626691) },
}
