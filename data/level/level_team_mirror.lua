Name = "Snow team mirror"
Author = "Skeet"
ServerLua = "data/lua/level_team_server.lua"
ReleaseLevel = 2

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
	-- Swapped to match StartPoints: Red (even) at +Y looks toward -Y, Blue (odd) at -Y looks toward +Y
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
	-- Swapped: Red team (even indices) now spawns at +Y (near blue targets)
	-- Blue team (odd indices) now spawns at -Y (near red targets)
	CVector(-0.411029,16.558670,9.689780),
	CVector(-0.251090,-16.565340,9.689780),
	CVector(0.073347,16.569500,9.689780),
	CVector(-0.570633,-16.552031,9.689780),
	CVector(0.394393,16.556160,9.689780),
	CVector(0.225997,-16.562820,9.689780),
	CVector(-0.178982,16.380600,9.689780),
	CVector(0.554403,-16.549530,9.689780),
	CVector(-0.491146,16.375311,9.689780),
	CVector(-0.331207,-16.381969,9.689780),
	CVector(-0.006771,16.386141,9.689780),
	CVector(-0.650750,-16.368660,9.689780),
	CVector(0.314275,16.372801,9.689780),
	CVector(0.145880,-16.379459,9.689780),
	CVector(-0.098865,16.563971,9.689780),
	CVector(0.474286,-16.366159,9.689780),
}

Modules =
{
	-- Decorative islands
	{ Position = CVector(10.000000,-10.000000,3.500000), Scale = CVector(1.000000, 1.000000, 1.000000), Rotation = CAngleAxis(1.000000,0.000000,0.000000,0.000000), Color = CRGBA(255,255,255,255), Lua="snow_island", Shape="snow_island", Friction = 0 },
	{ Position = CVector(6.000000,1.000000,2.800000), Scale = CVector(1.000000, 1.000000, 1.000000), Rotation = CAngleAxis(1.000000,0.000000,0.000000,0.000000), Color = CRGBA(255,255,255,255), Lua="snow_island2", Shape="snow_island2", Friction = 0 },
	{ Position = CVector(-3.800000,-2.000000,2.000000), Scale = CVector(1.000000, 1.000000, 1.000000), Rotation = CAngleAxis(1.000000,0.000000,0.000000,0.000000), Color = CRGBA(255,255,255,255), Lua="snow_island3", Shape="snow_island3", Friction = 0 },
	-- Red team targets (negative Y side) - outermost to innermost
	{ Position = CVector(0,-0.40,3), Scale = CVector(16, 16, 1), Rotation = CAngleAxis(1,0,0,0), Color = CRGBA(255,128,128,255), Lua="team_target_50_red", Shape="box_sol", Score = 50, Friction = 25 },
	{ Position = CVector(0,-0.16,3), Scale = CVector(8, 8, 1), Rotation = CAngleAxis(1,0,0,0), Color = CRGBA(255,64,64,255), Lua="team_target_100_red", Shape="box_sol", Score = 100, Friction = 10 },
	{ Position = CVector(0,-0.04,3), Scale = CVector(4, 4, 1), Rotation = CAngleAxis(1,0,0,0), Color = CRGBA(255,0,0,255), Lua="team_target_300_red", Shape="box_sol", Score = 300, Friction = 10 },
	-- Blue team targets (positive Y side) - outermost to innermost
	{ Position = CVector(0,0.40,3), Scale = CVector(16, 16, 1), Rotation = CAngleAxis(1,0,0,0), Color = CRGBA(128,128,255,255), Lua="team_target_50_blue", Shape="box_sol", Score = 50, Friction = 25 },
	{ Position = CVector(0,0.16,3), Scale = CVector(8, 8, 1), Rotation = CAngleAxis(1,0,0,0), Color = CRGBA(64,64,255,255), Lua="team_target_100_blue", Shape="box_sol", Score = 100, Friction = 10 },
	{ Position = CVector(0,0.04,3), Scale = CVector(4, 4, 1), Rotation = CAngleAxis(1,0,0,0), Color = CRGBA(0,0,255,255), Lua="team_target_300_blue", Shape="box_sol", Score = 300, Friction = 10 },
	-- Ramps
	{ Position = CVector(0,15,5), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(1,0,0,0), Color = CRGBA(255,255,255,255), Lua="snow_ramp", Shape="snow_ramp", Friction = 0, Bounce = 0, Accel = 0.0001 },
	{ Position = CVector(0,-15,5), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(0,0,1,3.1415), Color = CRGBA(255,255,255,255), Lua="snow_ramp", Shape="snow_ramp", Friction = 0, Bounce = 0, Accel = 0.0001 },

}


Particles =
{
}

ExternalCameras =
{
	{ Position = CVector(-0.108815, -0.000864, 3.132983), Rotation = CAngleAxis(-0.310493, 0.317307, -0.640444, 0.626691) },
}
