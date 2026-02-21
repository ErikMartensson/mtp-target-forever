Name = "Snow team classic"
Author = "Skeet"
ServerLua = "data/lua/level_team_server.lua"
ReleaseLevel = 1

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
	CVector(0, -3, 10),
}

StartPoints =
{
	CVector(-0.098865, 16.56397, 9.68978),
	CVector(-0.25109, -16.56534, 9.68978),
	CVector(-0.411029, 16.55867, 9.68978),
	CVector(-0.570633, -16.55203, 9.68978),
	CVector(0.0733468, 16.5695, 9.68978),
	CVector(0.225997, -16.56282, 9.68978),
	CVector(0.394393, 16.55616, 9.68978),
	CVector(0.554403, -16.54953, 9.68978),
	CVector(-0.178982, 16.3806, 9.68978),
	CVector(-0.331207, -16.38197, 9.68978),
	CVector(-0.491146, 16.37531, 9.68978),
	CVector(-0.65075, -16.36866, 9.68978),
	CVector(-0.00677051, 16.38614, 9.68978),
	CVector(0.14588, -16.37946, 9.68978),
	CVector(0.314275, 16.3728, 9.68978),
	CVector(0.474286, -16.36616, 9.68978)
}

Modules =
{
	-- Decorative islands
	{ Position = CVector(10.000000,-10.000000,3.500000), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(1,0,0,0), Lua="snow_island", Shape="snow_island", Friction = 0 },
	{ Position = CVector(6.000000,1.000000,2.800000), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(1,0,0,0), Lua="snow_island2", Shape="snow_island2", Friction = 0 },
	{ Position = CVector(-3.800000,-2.000000,2.000000), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(1,0,0,0), Lua="snow_island3", Shape="snow_island3", Friction = 0 },
	-- Red team targets (positive Y side) - outermost to innermost
	{ Position = CVector(0,0.40,3), Scale = CVector(16, 16, 1), Rotation = CAngleAxis(1,0,0,0), Color = CRGBA(255,128,128,255), Lua="team_target_50_red", Shape="box_sol", Score = 50, Friction = 25 },
	{ Position = CVector(0,0.16,3), Scale = CVector(8, 8, 1), Rotation = CAngleAxis(1,0,0,0), Color = CRGBA(255,64,64,255), Lua="team_target_100_red", Shape="box_sol", Score = 100, Friction = 10 },
	{ Position = CVector(0,0.04,3), Scale = CVector(4, 4, 1), Rotation = CAngleAxis(1,0,0,0), Color = CRGBA(255,0,0,255), Lua="team_target_300_red", Shape="box_sol", Score = 300, Friction = 10 },
	-- Blue team targets (negative Y side) - outermost to innermost
	{ Position = CVector(0,-0.40,3), Scale = CVector(16, 16, 1), Rotation = CAngleAxis(1,0,0,0), Color = CRGBA(128,128,255,255), Lua="team_target_50_blue", Shape="box_sol", Score = 50, Friction = 25 },
	{ Position = CVector(0,-0.16,3), Scale = CVector(8, 8, 1), Rotation = CAngleAxis(1,0,0,0), Color = CRGBA(64,64,255,255), Lua="team_target_100_blue", Shape="box_sol", Score = 100, Friction = 10 },
	{ Position = CVector(0,-0.04,3), Scale = CVector(4, 4, 1), Rotation = CAngleAxis(1,0,0,0), Color = CRGBA(0,0,255,255), Lua="team_target_300_blue", Shape="box_sol", Score = 300, Friction = 10 },
	-- Ramps
	{ Position = CVector(0,15,5), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(1,0,0,0), Lua="snow_ramp", Shape="snow_ramp", Friction = 0, Bounce = 0, Accel = 0.0001 },
	{ Position = CVector(0,-15,5), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(0,0,1,3.1415), Lua="snow_ramp", Shape="snow_ramp", Friction = 0, Bounce = 0, Accel = 0.0001 },
}


Particles =
{
}

ExternalCameras =
{
	{ Position = CVector(-0.108815, -0.000864, 3.132983), Rotation = CAngleAxis(-0.310493, 0.317307, -0.640444, 0.626691) },
}
