/* Copyright, 2010 Tux Target
 * Copyright, 2003 Melting Pot
 *
 * This file is part of Tux Target.
 * Tux Target is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.

 * Tux Target is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with Tux Target; see the file COPYING. If not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
 * MA 02111-1307, USA.
 */


//
// Includes
//

#include "stdpch.h"

#include <nel/3d/u_scene.h>
#include <nel/3d/u_camera.h>
#include <nel/3d/u_driver.h>
#include <nel/3d/u_texture.h>
#include <nel/3d/u_instance.h>
#include <nel/3d/u_cloud_scape.h>
#include <nel/3d/u_text_context.h>

#include <nel/3d/scene.h>
#include <nel/3d/scene_user.h>
#include <nel/3d/water_model.h>
#include <nel/3d/water_shape.h>
#include <nel/3d/texture_file.h>
#include <nel/3d/transform_shape.h>
#include <nel/3d/transformable.h>

#include "3d_task.h"
#include "time_task.h"
#include "game_task.h"
#include "chat_task.h"
#include "water_task.h"
#include "score_task.h"
#include "network_task.h"
#include "font_manager.h"
#include "task_manager.h"
#include "entity_manager.h"
#include "background_task.h"
#include "resource_manager2.h"
#include "config_file_task.h"


//
// Namespaces
//

using namespace std;
using namespace NL3D;
using namespace NLMISC;


//
// Variables
//


//
// Functions
//


CWaterTask::CWaterTask():ITask()
{
	envMap0Name("");
	envMap1Name("");
	heightMap0Name("");
	heightMap1Name("");

	nelWaterScene   = 0;
	WaterShape    = 0;
	WaterModel    = 0;
	WaterMesh     = 0;
	WaterInstance = 0;
}

void cbVar (CConfigFile::CVar &var)
{
	if (CWaterTask::getInstance().WaterShape == 0)
	{
		nlwarning ("Can't set water parameter");
		return;
	}

	if (var.Name == "Map1Scale")
		CWaterTask::getInstance().WaterShape->setHeightMapScale(0, NLMISC::CVector2f(var.asFloat(0), var.asFloat(1)));
	else if (var.Name == "Map2Scale")
		CWaterTask::getInstance().WaterShape->setHeightMapScale(1, NLMISC::CVector2f(var.asFloat(0), var.asFloat(1)));
	else if (var.Name == "Map1Speed")
		CWaterTask::getInstance().WaterShape->setHeightMapSpeed(0, NLMISC::CVector2f(var.asFloat(0), var.asFloat(1)));
	else if (var.Name == "Map2Speed")
		CWaterTask::getInstance().WaterShape->setHeightMapSpeed(1, NLMISC::CVector2f(var.asFloat(0), var.asFloat(1)));
	else
		nlwarning("Unknown water parameter: %s", var.Name.c_str());
}


void CWaterTask::init()
{
	int displayWater = CConfigFileTask::getInstance().configFile().getVar("DisplayWater").asInt();

	if(displayWater == 2)
	{
		// Advanced pixel shader water
		nlinfo("CWaterTask: Starting advanced water init (DisplayWater=2)");

		try
		{
			// Ensure 3D model classes are registered (including CWaterModel)
			nlinfo("CWaterTask: Calling CScene::registerBasics()...");
			CScene::registerBasics();

			string res;
			CSceneUser *su = dynamic_cast<CSceneUser *>(&C3DTask::getInstance().scene());
			if(!su)
			{
				nlwarning("CWaterTask: Failed to get CSceneUser, falling back to basic water");
				displayWater = 1;
				goto basic_water;
			}
			CScene &scene = su->getScene();
			nlinfo("CWaterTask: Got internal CScene at %p", &scene);

			// Load textures
			nlinfo("CWaterTask: Loading water textures...");
			res = CResourceManager::getInstance().get(envMap0Name());
			nlinfo("CWaterTask: envMap0 path: %s", res.c_str());
			ITexture *envMap1 = new CTextureFile(res);

			res = CResourceManager::getInstance().get(envMap1Name());
			nlinfo("CWaterTask: envMap1 path: %s", res.c_str());
			ITexture *envMap2 = new CTextureFile(res);

			res = CResourceManager::getInstance().get(heightMap0Name());
			nlinfo("CWaterTask: heightMap0 path: %s", res.c_str());
			ITexture *heightMap = new CTextureFile(res);

			res = CResourceManager::getInstance().get(heightMap1Name());
			nlinfo("CWaterTask: heightMap1 path: %s", res.c_str());
			ITexture *heightMap2 = new CTextureFile(res);

			// Create water shape
			nlinfo("CWaterTask: Creating CWaterShape...");
			WaterShape = new CWaterShape;

			// Create water polygon FIRST (required before other settings)
			nlinfo("CWaterTask: Creating water polygon...");
			const float wqSize = 10000.0f;
			CVector2f corners[] = {
				CVector2f(-wqSize, wqSize), CVector2f(wqSize, wqSize),
				CVector2f(wqSize, -wqSize), CVector2f(-wqSize, -wqSize)
			};
			CPolygon2D waterPoly;
			waterPoly.Vertices.resize(4);
			copy(corners, corners + 4, waterPoly.Vertices.begin());
			WaterShape->setShape(waterPoly);

			nlinfo("CWaterTask: Setting env maps...");
			WaterShape->setEnvMap(0, envMap1);
			WaterShape->setEnvMap(1, envMap2);

			nlinfo("CWaterTask: Setting height maps...");
			WaterShape->setHeightMap(0, heightMap);
			WaterShape->setHeightMap(1, heightMap2);

			nlinfo("CWaterTask: Setting water pool ID...");
			WaterShape->setWaterPoolID(0);

			// Setup config callbacks for wave parameters
			nlinfo("CWaterTask: Setting up wave parameters...");
			CConfigFileTask::getInstance().configFile().setCallback("Map1Scale", cbVar);
			cbVar(CConfigFileTask::getInstance().configFile().getVar("Map1Scale"));
			CConfigFileTask::getInstance().configFile().setCallback("Map2Scale", cbVar);
			cbVar(CConfigFileTask::getInstance().configFile().getVar("Map2Scale"));
			CConfigFileTask::getInstance().configFile().setCallback("Map1Speed", cbVar);
			cbVar(CConfigFileTask::getInstance().configFile().getVar("Map1Speed"));
			CConfigFileTask::getInstance().configFile().setCallback("Map2Speed", cbVar);
			cbVar(CConfigFileTask::getInstance().configFile().getVar("Map2Speed"));

			// Use shape bank approach like v1.5.19 code
			static string shapeName("water_quad_dynamic.shape");
			nlinfo("CWaterTask: Adding shape to bank as '%s'...", shapeName.c_str());
			scene.getShapeBank()->add(shapeName, WaterShape);

			nlinfo("CWaterTask: Creating instance from shape bank...");
			WaterInstance = scene.createInstance(shapeName);

			if(!WaterInstance)
			{
				nlwarning("CWaterTask: createInstance returned null!");
				WaterShape = 0; // Don't delete, shape bank owns it now
				goto basic_water;
			}
			nlinfo("CWaterTask: createInstance returned %p", WaterInstance);

			nlinfo("CWaterTask: Casting to CWaterModel...");
			WaterModel = NLMISC::safe_cast<CWaterModel *>(WaterInstance);
			if(!WaterModel)
			{
				nlwarning("CWaterTask: Failed to cast to CWaterModel!");
				scene.deleteInstance(WaterInstance);
				WaterInstance = 0;
				WaterShape = 0;
				goto basic_water;
			}

			nlinfo("CWaterTask: Setting position...");
			WaterModel->setPos(0.0f, 0.0f, 1.0f * GScale);

			nlinfo("CWaterTask: Advanced water init complete!");
			return;
		}
		catch(const std::exception &e)
		{
			nlwarning("CWaterTask: Advanced water init failed: %s", e.what());
			nlwarning("CWaterTask: Falling back to basic water");
			if(WaterShape) { delete WaterShape; WaterShape = 0; }
			WaterInstance = 0;
			WaterModel = 0;
			displayWater = 1;
		}
		catch(...)
		{
			nlwarning("CWaterTask: Advanced water init failed with unknown exception");
			nlwarning("CWaterTask: Falling back to basic water");
			if(WaterShape) { delete WaterShape; WaterShape = 0; }
			WaterInstance = 0;
			WaterModel = 0;
			displayWater = 1;
		}
	}

basic_water:
	if(displayWater == 1)
	{
		// Basic water using pre-made shape
		nlinfo("CWaterTask: Using basic water (DisplayWater=1)");
		string res;
		res = CResourceManager::getInstance().get("water_light.shape");
		if(!res.empty())
		{
			WaterMesh = C3DTask::getInstance().scene().createInstance(res);
			if(!WaterMesh.empty())
			{
				WaterMesh.setPos(0.0f, 0.0f, 1.0f * GScale);
				nlinfo("CWaterTask: Basic water init complete!");
			}
			else
			{
				nlwarning("CWaterTask: Failed to create water mesh instance");
			}
		}
		else
		{
			nlwarning("CWaterTask: Failed to get water_light.shape, water will be disabled");
		}
	}
}

void CWaterTask::update()
{
	// Water is rendered as part of the main scene, no separate update needed
}

void CWaterTask::render()
{
	// Water is rendered as part of the main scene, no separate render needed
}

void CWaterTask::release()
{
	CSceneUser *su = dynamic_cast<CSceneUser *>(&C3DTask::getInstance().scene());
	CScene &scene = su->getScene();

	if(!WaterMesh.empty())
	{
		C3DTask::getInstance().scene().deleteInstance(WaterMesh);
	}

	if(WaterInstance)
	{
		scene.deleteInstance(WaterInstance);
		WaterInstance = 0;
	}
}


void CWaterTask::envMap0Name(const std::string &envMapName)
{
	EnvMap0Name = "water_env.dds";
	if(envMapName.empty()) return;
	EnvMap0Name = envMapName;
}

void CWaterTask::envMap1Name(const std::string &envMapName)
{
	EnvMap1Name = "water_env.dds";
	if(envMapName.empty()) return;
	EnvMap1Name = envMapName;
}

void CWaterTask::heightMap0Name(const std::string &heightMap)
{
	HeightMap0Name = "water_disp.dds";
	if(heightMap.empty()) return;
	HeightMap0Name = heightMap;
}

void CWaterTask::heightMap1Name(const std::string &heightMap)
{
	HeightMap1Name = "water_disp2.dds";
	if(heightMap.empty()) return;
	HeightMap1Name = heightMap;
}



string CWaterTask::envMap0Name()
{
	return EnvMap0Name;
}

string CWaterTask::envMap1Name()
{
	return EnvMap1Name;
}

string CWaterTask::heightMap0Name()
{
	return HeightMap0Name;
}

string CWaterTask::heightMap1Name()
{
	return HeightMap1Name;
}

