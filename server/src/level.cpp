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

extern "C"
{
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
};

#include <nel/misc/file.h>
#include <nel/misc/path.h>
#include <nel/misc/sha1.h>

#include "level.h"
#include "module.h"
#include "entity_manager.h"
#include "net_callbacks.h"
#include "network.h"
#include "variables.h"
#include "lua_engine.h"
#include "../../common/lua_nel.h"
#include "../../common/lua_utility.h"


//
// Namespaces
//

using namespace std;
using namespace NLNET;
using namespace NLMISC;


//
// Types
//

//
// Declarations
//

//
// Variables
//

uint8 CLevel::NextStartingPoint = 0;


//
// Functions
//

CLevel::CLevel(const string &filename)
{
	nlinfo("Trying to load level '%s'", filename.c_str());

	Valid = false;
	
	FileName = filename;
	_luaInit();

}


void CLevel::_luaInit()
{
	CLuaEngine::getInstance().init(FileName);
	lua_State *_luaSession = CLuaEngine::getInstance().session();
	if(_luaSession)
		Valid = true;
	else
		return;
	
	// Check if LevelPlaylist is defined - if so, it overrides ReleaseLevel
	bool skipReleaseLevelCheck = false;
	try {
		CConfigFile::CVar &playlist = IService::getInstance()->ConfigFile.getVar("LevelPlaylist");
		if(playlist.size() > 0)
			skipReleaseLevelCheck = true;
	} catch(...) {
		// LevelPlaylist not defined
	}

	if(!skipReleaseLevelCheck)
	{
		float ReleaseLevel = 1;
		luaGetGlobalVariable(_luaSession, ReleaseLevel);

		CConfigFile::CVar &releaseLevel = IService::getInstance()->ConfigFile.getVar("ReleaseLevel");
		bool releaseLevelOk = false;
		for(uint i = 0; i < (uint)releaseLevel.size(); i ++)
		{
			int rl = releaseLevel.asInt(i);
			if(ReleaseLevel == rl)
			{
				releaseLevelOk = true;
				break;
			}
		}
		if(releaseLevel.size()==0)
			releaseLevelOk = true;

		if(!releaseLevelOk)
		{
			Valid = false;
			return;
		}
	}

	string ServerLua;
	luaGetGlobalVariable(_luaSession, ServerLua);

	// Only try to load ServerLua if it's defined and not empty
	if (!ServerLua.empty())
	{
		luaLoad(CLuaEngine::getInstance().session(),ServerLua);

		if(!CLuaEngine::getInstance().session())
			return;
	}

	// v1.5.19 compatibility: if the level defines CLevel:init(), call it.
	// This populates global tables (Modules, StartPoints, Cameras, etc.)
	// from the imperative API used by v1.5.19-style levels.
	lua_getglobal(_luaSession, "CLevel");
	if (!lua_isnil(_luaSession, -1))
	{
		lua_getfield(_luaSession, -1, "init");
		if (lua_isfunction(_luaSession, -1))
		{
			lua_pushvalue(_luaSession, -2); // push CLevel table as self
			int res = lua_pcall(_luaSession, 1, 0, 0);
			if (res != 0)
			{
				const char *msg = lua_tostring(_luaSession, -1);
				if (msg == NULL) msg = "(error with no message)";
				nlwarning("LUA: CLevel:init() failed: %s", msg);
				lua_pop(_luaSession, 1); // pop error message
			}
		}
		else
		{
			lua_pop(_luaSession, 1); // pop non-function
		}
	}
	lua_pop(_luaSession, 1); // pop CLevel or nil

	luaGetGlobalVariable(_luaSession, Name);
	//	nlinfo("level name '%s'", Name.c_str());
	

	uint32 CrashedClientCollide = 1;
	luaGetGlobalVariable(_luaSession, CrashedClientCollide);
	this->CrashedClientCollide = CrashedClientCollide!=0;
	uint32 ClientBounce = 1;
	luaGetGlobalVariable(_luaSession, ClientBounce);
	this->ClientBounce = ClientBounce!=0;
	//nlinfo("ClientBounce = %f",ClientBounce);
	ClientBounceCoef = BounceClient;
	luaGetGlobalVariable(_luaSession, ClientBounceCoef);
	//nlinfo("ClientBounceCoef = %f",ClientBounceCoef);
	ClientBounceVel = BounceVelClient;
	luaGetGlobalVariable(_luaSession, ClientBounceVel);
	//nlinfo("ClientBounceVel = %f",ClientBounceVel);
	

	luaGetGlobalVector(_luaSession, Cameras);

/*
	nlinfo("%d Camera", Cameras.size());
	for(uint i = 0; i < Cameras.size(); i++)
	{
		nlinfo("  > camera %f %f %f", Cameras[i].x, Cameras[i].y, Cameras[i].z);
	}
*/

	vector<CLuaVector> luaStartPoints;
	luaGetGlobalVectorWithName(_luaSession, luaStartPoints,"StartPoints");
	uint8 startPositionId = 0;
	for(uint i = 0; i < luaStartPoints.size(); i++)
	{
//		nlinfo("start point : %f %f %f", luaStartPoints[i].x, luaStartPoints[i].y, luaStartPoints[i].z);
		CAngleAxis Rotation(CVector(1,0,0),0);
		CStartPoint *startPosition = new CStartPoint();
		startPosition->init("start pos","box.shape",startPositionId,luaStartPoints[i],Rotation);
		StartPoints.push_back(startPosition);		
		startPositionId++;
	}

/*
	nlinfo("%d Starting points", StartPoints.size());
	for(uint i = 0; i < StartPoints.size(); i++)
	{
		nlinfo("  > starting point %d : %f %f %f", i, StartPoints[i].x, StartPoints[i].y, StartPoints[i].z);
	}
*/


	// Load modules
	lua_getglobal(_luaSession, "Modules");
	if (lua_isnil(_luaSession, -1))
	{
		nlwarning("Modules table not found in level '%s' - level may not have loaded correctly", FileName.c_str());
		lua_pop(_luaSession, 1);
		Valid = false;
		return;
	}
	lua_pushnil(_luaSession);
	uint8 moduleId = 0;
	while(lua_next(_luaSession, -2) != 0)
	{
		// `key' is at index -2 and `value' at index -1

		string Lua;
		lua_pushstring(_luaSession,"Lua");
		lua_gettable(_luaSession, -2);
		luaGetVariable(_luaSession, Lua);		
		nlinfo("lua %s", Lua.c_str());
		lua_pop(_luaSession, 1);  // removes `value'; keeps `key' for next iteration
		
		// Get module position
		CLuaVector Position;
		lua_pushstring(_luaSession,"Position");
		lua_gettable(_luaSession, -2);
		luaGetVariable(_luaSession, Position);		
		nlinfo("pos %f %f %f", Position.x, Position.y, Position.z);
		lua_pop(_luaSession, 1);  // removes `value'; keeps `key' for next iteration
		
		// Get module position
		CLuaVector Scale;
		lua_pushstring(_luaSession,"Scale");
		lua_gettable(_luaSession, -2);
		luaGetVariable(_luaSession, Scale);		
		nlinfo("scale %f %f %f", Scale.x, Scale.y, Scale.z);
		lua_pop(_luaSession, 1);  // removes `value'; keeps `key' for next iteration
		
		// Get module rotation
		CLuaAngleAxis Rotation;
		lua_pushstring(_luaSession,"Rotation");
		lua_gettable(_luaSession, -2);
		luaGetVariable(_luaSession, Rotation);		
		nlinfo("rot %f %f %f %f", Rotation.Axis.x , Rotation.Axis.y, Rotation.Axis.z, Rotation.Angle);
		lua_pop(_luaSession, 1);  // removes `value'; keeps `key' for next iteration
		
		// Get module color
		CLuaRGBA Color(255,255,255,255);
		lua_pushstring(_luaSession,"Color");
		lua_gettable(_luaSession, -2);
		if (!lua_isnil(_luaSession, -1))
			luaGetVariable(_luaSession, Color);		
		nlinfo("color = %d %d %d %d", Color.R, Color.G, Color.B, Color.A);
		lua_pop(_luaSession, 1);  // removes `value'; keeps `key' for next iteration
		
		// Get module name
		
		// Get module ShapeName
		string ShapeName;
		lua_pushstring(_luaSession,"Shape");
		lua_gettable(_luaSession, -2);
		luaGetVariable(_luaSession, ShapeName);
		nlinfo("ShapeName %s", ShapeName.c_str());
		lua_pop(_luaSession, 1);  // removes `value'; keeps `key' for next iteration

		// Get module Score
		sint32 ModuleScore = 0;
		lua_pushstring(_luaSession,"Score");
		lua_gettable(_luaSession, -2);
		if (!lua_isnil(_luaSession, -1))
		{
			ModuleScore = (sint32)lua_tonumber(_luaSession, -1);
			nlinfo("Score %d", ModuleScore);
		}
		lua_pop(_luaSession, 1);

		// Get module Friction
		float ModuleFriction = 0;
		lua_pushstring(_luaSession,"Friction");
		lua_gettable(_luaSession, -2);
		if (!lua_isnil(_luaSession, -1))
		{
			ModuleFriction = (float)lua_tonumber(_luaSession, -1);
			nlinfo("Friction %f", ModuleFriction);
		}
		lua_pop(_luaSession, 1);

		// Get module Accel
		float ModuleAccel = 0;
		lua_pushstring(_luaSession,"Accel");
		lua_gettable(_luaSession, -2);
		if (!lua_isnil(_luaSession, -1))
		{
			ModuleAccel = (float)lua_tonumber(_luaSession, -1);
			nlinfo("Accel %f", ModuleAccel);
		}
		lua_pop(_luaSession, 1);

		// Get module Bounce
		bool ModuleBounce = false;
		lua_pushstring(_luaSession,"Bounce");
		lua_gettable(_luaSession, -2);
		if (!lua_isnil(_luaSession, -1))
		{
			ModuleBounce = lua_tonumber(_luaSession, -1) != 0;
			nlinfo("Bounce %d", ModuleBounce ? 1 : 0);
		}
		lua_pop(_luaSession, 1);

		// Get module Collide (default: true)
		bool ModuleCollide = true;
		lua_pushstring(_luaSession,"Collide");
		lua_gettable(_luaSession, -2);
		if (!lua_isnil(_luaSession, -1))
		{
			ModuleCollide = lua_tonumber(_luaSession, -1) != 0;
			nlinfo("Collide %d", ModuleCollide ? 1 : 0);
		}
		lua_pop(_luaSession, 1);

		// Apply default friction to scoring modules that don't specify one.
		// The v1.5.19 server applied friction to scoring targets automatically;
		// without this, balls roll across targets without slowing down.
		if (ModuleScore > 0 && ModuleFriction == 0)
		{
			ModuleFriction = 10;
			nlinfo("Module %d: applying default friction %f (score=%d)", moduleId, ModuleFriction, ModuleScore);
		}

		CModule *mod = new CModule();
		mod->init(Lua,ShapeName, moduleId, Position, Scale, Rotation, Color);
		mod->score(ModuleScore);
		mod->friction(ModuleFriction);
		mod->accel(ModuleAccel);
		mod->bounce(ModuleBounce);
		mod->collide(ModuleCollide);
		// Load module Lua script AFTER C++ property overrides, so the
		// module script (e.g. module_paint_bloc.lua) gets the last word
		// on friction, accel, etc.
		mod->loadModuleLuaScript();
		Modules.push_back(mod);
		moduleId++;
		lua_pop(_luaSession, 1);
	}
	lua_pop(_luaSession, 1);  // removes `key'
	

}

void CLevel::initBeforeStartLevel()
{
	
	CEntityManager::getInstance().initBeforeStartLevel();

	for(uint i = 0; i < Modules.size(); i++)
		Modules[i]->initBeforeStartLevel();

	CLuaEngine::getInstance().levelInit();
	
}

CLevel::~CLevel()
{
	CLuaEngine::getInstance().release();
	
	for(uint i = 0; i < Modules.size(); i++)
		delete Modules[i];
	
	Modules.clear();
}

void CLevel::update()
{
	vector<CModule *>::iterator it;

	for(it=Modules.begin();it!=Modules.end();it++)
		(*it)->update();
}

void CLevel::nextStartingPoint(CVector &pos, uint8 &id)
{
	if(StartPoints.size()==0)
	{
		nlwarning("No starting points defined in level, using default position (0, 0, 1)");
		pos = CVector(0.0f, 0.0f, 1.0f);
		id = 0;
		return;
	}

	id = (NextStartingPoint++)%StartPoints.size();
	pos = StartPoints[id]->position();
}

void CLevel::display(CLog *log) const
{
	log->displayNL("LevelName = %s", name().c_str());

	log->displayNL("The level contains %d modules:", Modules.size());
	for(uint i = 0; i < Modules.size(); i++)
	{
		log->displayNL("Module %d", i);
		Modules[i]->display(log);
	}
}

uint8 CLevel::getModuleCount() 
{
	nlassert(Modules.size()<255);
	return Modules.size();
}

CModule *CLevel::getModule(uint32 id)
{
	nlassert(id<getModuleCount());
	return Modules[id];
}


void CLevel::updateModule(uint32 id,CVector pos,CVector rot)
{
	getModule(id)->update(pos,rot);
}


uint8 CLevel::getStartPointCount() 
{
	nlassert(StartPoints.size()<255);
	return StartPoints.size();
}


CStartPoint *CLevel::getStartPoint(uint32 id)
{
	if(id>=getStartPointCount())
	{
		//nlwarning("id>=getStartPointCount():%d>=%d",id,getStartPointCount());
		return StartPoints[0];
	}
	return StartPoints[id];
}


void CLevel::updateStartPoint(uint32 id,CVector pos,CVector rot)
{
	getStartPoint(id)->update(pos,rot);
}

  
bool isLuaSeparator(char c)
{
	return c==' ' || c=='\t' || c=='\n';
}

bool findLuaEndingBrace(string &luaStr,uint32 &pos)
{
	uint32 i = pos;
	sint32 braceStack = 0;
	for(;i<luaStr.size();i++)
	{
		if(luaStr[i]=='{')
			braceStack++;
		else if(luaStr[i]=='}')
			braceStack--;
		if(braceStack<0)
			break;
	}
	if(braceStack<0)
	{
		pos = i;
		return true;
	}
	return false;
}

bool findLuaNextWord(string &luaStr,string word,uint32 &pos)
{
	uint32 i = pos;
	while( i<luaStr.size() && isLuaSeparator(luaStr[i]) )
	{
		i++;
	}
	if(i>=luaStr.size()) return false;
	string next = luaStr.substr(i,word.size());
	if(next==word)
	{
		pos = i;
		return true;
	}
	return false;
}

bool findLuaWord(string &luaStr,string word,uint32 &pos)
{
	size_t res = luaStr.find(word,pos);
	if(res!=string::npos)
	{
		pos = res;
		return true;
	}
	return false;
}

bool findLuaArrayDeclaration(string &luaStr,string name,uint32 &start,uint32 &end)
{
	uint32 pos = 0;
	uint32 resStart;
	uint32 resEnd;
	bool nameFound = findLuaWord(luaStr,name,pos);
	pos += name.size();
	while(nameFound)
	{
		bool resEqual = findLuaNextWord(luaStr,"=",pos);
		pos++;
		if(resEqual)
		{
			bool resBrace = findLuaNextWord(luaStr,"{",pos);
			pos++;
			if(resBrace)
			{
				resStart = pos;
				bool resEndingBrace = findLuaEndingBrace(luaStr,pos);
				if(resEndingBrace)
				{
					resEnd = pos;
					break;
				}
			}
		}
		nameFound = findLuaWord(luaStr,name,pos);		
	}
	if(nameFound)
	{
		start = resStart;
		end = resEnd;
		return true;
	}
	return false;
}

void CLevel::save()
{
	if(!changed()) return;

	string fn = CPath::lookup(FileName, false);
	if(fn.empty())
	{
		nlwarning("Llevel::save(%s) file not found ", FileName.c_str());
		return;
	}
	
	/*
	CHashKey serverHashKey = getSHA1(fn);
	CNetMessage msgout(CNetMessage::RequestCRCKey);
	msgout.serial(FileName);
	msgout.serial(serverHashKey);
	CNetwork::getInstance().send(msgout);
	*/

	
	FILE *fp;
	fp = fopen(fn.c_str(),"rt");
	nlassert(fp!=0);
	string luaStr = "";
	char ch[256];
	while(!feof(fp))
	{
		uint32 res = fread(ch,1,255,fp);
		ch[res]='\0';
		luaStr += ch;
	}
	fclose(fp);

	bool found;

	uint32 moduleStartPos;
	uint32 moduleEndPos;
	found = findLuaArrayDeclaration(luaStr,"Modules",moduleStartPos,moduleEndPos);
	if(found)
	{
		string beforeModule = luaStr.substr(0,moduleStartPos);
		string moduleStr = luaStr.substr(moduleStartPos,moduleEndPos-moduleStartPos);
		string afterModule = luaStr.substr(moduleEndPos);
		
		luaStr = "";
		luaStr += beforeModule;
		luaStr += "\n";
		
		uint32 i;
		for(i=0;i<Modules.size();i++)
		{
			luaStr += "\t" + Modules[i]->toLuaString() + ",\n";
		}
		luaStr += "\n";
		luaStr += afterModule;
	}
	
	uint32 StartPointsStartPos;
	uint32 StartPointsEndPos;
	found = findLuaArrayDeclaration(luaStr,"StartPoints",StartPointsStartPos,StartPointsEndPos);
	if(found)
	{
		string beforeModule = luaStr.substr(0,StartPointsStartPos);
		string moduleStr = luaStr.substr(StartPointsStartPos,StartPointsEndPos-StartPointsStartPos);
		string afterModule = luaStr.substr(StartPointsEndPos);
		
		luaStr = "";
		luaStr += beforeModule;
		luaStr += "\n";
		
		uint32 i;
		for(i=0;i<StartPoints.size();i++)
		{
			luaStr += "\t" + StartPoints[i]->toLuaString() + ",\n";
		}
		luaStr += "\n";
		luaStr += afterModule;
	}
	
	
	fp = fopen(fn.c_str(),"wt");
	nlassert(fp!=0);
	fwrite(luaStr.c_str(),1,luaStr.size(),fp);
	fclose(fp);
	
}

bool CLevel::changed()
{
	for(uint32 i=0;i<Modules.size();i++)
	{
		if(Modules[i]->changed())
			return true;
	}
	for(uint32 i=0;i<StartPoints.size();i++)
	{
		if(StartPoints[i]->changed())
			return true;
	}
	return false;
}

bool CLevel::valid()
{ 
	return Valid && !CLuaEngine::getInstance().hasError(); 
}


